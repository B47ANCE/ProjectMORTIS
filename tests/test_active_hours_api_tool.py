"""Class metadata bounds on synthetic bytes; no engine is loaded."""
from pathlib import Path
import struct
import sys
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'scripts'))
from audit_active_hours_api import metadata


class Metadata(unittest.TestCase):
    def fixture(self):
        u2 = lambda n: struct.pack('>H', n)
        pool = b'\x01'+u2(7)+b'getDawn'+b'\x01'+u2(3)+b'()F'
        header = b'\xca\xfe\xba\xbe'+u2(0)+u2(61)+u2(3)+pool
        # access/this/super/interfaces/fields, one public instance method, no attributes
        return header + u2(1)+u2(0)+u2(0)+u2(0)+u2(0)+u2(1)+u2(1)+u2(1)+u2(2)+u2(0)

    def test_selected_descriptor_is_metadata_only(self):
        fields, methods = metadata(self.fixture())
        self.assertEqual(fields, [])
        self.assertEqual(methods, [{'name': 'getDawn', 'descriptor': '()F', 'public': True, 'static': False}])

    def test_truncation_and_bad_magic_refuse(self):
        raw = self.fixture()
        for count in (0, 5, 9, len(raw)-1):
            with self.assertRaises(ValueError): metadata(raw[:count])
        with self.assertRaises(ValueError): metadata(b'not an engine class')

    def test_unknown_constant_tag_refuses(self):
        raw = bytearray(self.fixture()); raw[10] = 255
        with self.assertRaises(ValueError): metadata(raw)


if __name__ == '__main__':
    unittest.main()
