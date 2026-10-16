"""Development-only checker integration tests; all mutations use temp fixtures."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / 'scripts/check_versions.py'


class VersionChecks(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.write('VERSION', '0.1.0-dev.1\n')
        self.write('README.md', 'Project Version: 0.1.0-dev.1\n')
        self.write('CHANGELOG.md', '## [0.1.0-dev.1]\n\nFixture initialization.\n')
        inventory = json.loads((ROOT / 'version-inventory.json').read_text())
        inventory['mirrors'] = [inventory['mirrors'][0]]
        self.write('version-inventory.json', json.dumps(inventory))

    def write(self, name, value):
        (self.root / name).write_text(value, encoding='utf-8')

    def check(self, expected, *args):
        result = subprocess.run(
            [sys.executable, str(CHECKER), '--root', str(self.root), '--json', *args],
            capture_output=True, text=True)
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return json.loads(result.stdout)

    def test_matching(self):
        self.assertFalse(self.check(0)['errors'])

    def test_missing_canonical(self):
        (self.root / 'VERSION').unlink()
        self.check(1)

    def test_missing_mirror(self):
        (self.root / 'README.md').unlink()
        self.check(1)

    def test_malformed_values(self):
        for value in ['v0.1.0', '01.1.0', '0.1.0-dev.01', '0.1', '0.1.0\nextra']:
            with self.subTest(value=value):
                self.write('VERSION', value)
                self.check(1)

    def test_malformed_mirror(self):
        self.write('README.md', 'Project Version: nonsense\n')
        self.check(1)

    def test_inconsistent(self):
        self.write('README.md', 'Project Version: 0.1.0-dev.2\n')
        self.check(1)

    def test_duplicate_selector(self):
        self.write('README.md', 'Project Version: 0.1.0-dev.1\n' * 2)
        self.check(1)

    def test_release_requires_artifact(self):
        self.check(1, '--release')

    def test_preserved_research_and_historical_documents(self):
        baseline = json.loads((ROOT / 'scripts/versioning-preservation-baseline.json').read_text())
        if not (ROOT / 'research').exists():
            print('NOTE: local research evidence absent; only tracked historical documents checked.')
        for name, expected in baseline.items():
            if name.startswith('research/') and not (ROOT / 'research').exists():
                continue  # Local proprietary evidence is deliberately excluded from GitHub.
            with self.subTest(path=name):
                self.assertEqual(hashlib.sha256((ROOT / name).read_bytes()).hexdigest(), expected)


if __name__ == '__main__':
    unittest.main()
