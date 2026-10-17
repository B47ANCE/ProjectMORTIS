"""Disposable exact-input checks, independent of live dependency checkouts."""
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
from check_dependency_input import verify


class DependencyInput(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'src').mkdir()
        (self.root / 'src/API.lua').write_bytes(b'return {}\n')
        self.manifest = self.root / 'evidence.json'
        self.files = {'src/API.lua': hashlib.sha256(b'return {}\n').hexdigest()}
        self.write()

    def write(self):
        rows = ''.join(name+'\0'+sha+'\n' for name, sha in sorted(self.files.items()))
        self.data = {'manifest_version': 1, 'files': self.files, 'source_roots': ['src'],
                     'inventory_sha256': hashlib.sha256(rows.encode()).hexdigest()}
        self.manifest.write_text(json.dumps(self.data), encoding='utf-8')

    def test_exact_and_changed_line_endings(self):
        self.assertEqual(verify(self.root, self.manifest), 1)
        (self.root / 'src/API.lua').write_bytes(b'return {}\r\n')
        with self.assertRaisesRegex(ValueError, 'input mismatch'):
            verify(self.root, self.manifest)

    def test_extra_and_missing_source(self):
        extra = self.root / 'src/Unexpected.lua'; extra.write_text('return true')
        with self.assertRaisesRegex(ValueError, 'inventory differs'):
            verify(self.root, self.manifest)
        extra.unlink(); (self.root / 'src/API.lua').unlink()
        with self.assertRaisesRegex(ValueError, 'input mismatch'):
            verify(self.root, self.manifest)

    def test_unsafe_paths(self):
        for name in ('../outside', '/absolute', 'C:/absolute', 'src\\API.lua', 'src/./API.lua'):
            self.files = {name: 'a'*64}; self.write()
            with self.assertRaisesRegex(ValueError, 'unsafe dependency path'):
                verify(self.root, self.manifest)

    def test_future_and_corrupt_manifest(self):
        for version in (2, True, 1.0, '1'):
            self.data['manifest_version'] = version
            self.manifest.write_text(json.dumps(self.data))
            with self.assertRaisesRegex(ValueError, 'unsupported'):
                verify(self.root, self.manifest)
        self.write(); self.data['inventory_sha256'] = '0'*64
        self.manifest.write_text(json.dumps(self.data))
        with self.assertRaisesRegex(ValueError, 'checksum mismatch'):
            verify(self.root, self.manifest)
        self.manifest.write_text('{"manifest_version":1,"manifest_version":2}')
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            verify(self.root, self.manifest)
        self.manifest.write_text('[]')
        with self.assertRaisesRegex(ValueError, 'invalid dependency manifest'):
            verify(self.root, self.manifest)


if __name__ == '__main__':
    unittest.main()
