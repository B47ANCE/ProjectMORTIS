"""Check catalog integrity and complete English sandbox fallback, not fluency."""
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'src/ProjectMORTIS/42'

def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('duplicate translation key: ' + key)
        result[key] = value
    return result

def check():
    catalogs = {}
    errors = []
    for path in sorted((SOURCE / 'media/lua/shared/Translate').glob('*/*.json')):
        try:
            data = json.loads(path.read_text(encoding='utf-8-sig'), object_pairs_hook=unique_object)
            if not isinstance(data, dict) or any(not isinstance(v, str) or not v.strip() for v in data.values()):
                raise ValueError('catalog values must be nonempty strings')
            catalogs[(path.parent.name, path.name)] = data
        except (ValueError, OSError) as error:
            errors.append(str(path.relative_to(ROOT)) + ': ' + str(error))
    sandbox = (SOURCE / 'media/sandbox-options.txt').read_text(encoding='utf-8-sig')
    names = re.findall(r'\btranslation\s*=\s*(\w+)\s*,', sandbox)
    pages = set(re.findall(r'\bpage\s*=\s*(\w+)\s*,', sandbox))
    english = catalogs.get(('EN', 'Sandbox.json'), {})
    required = {'Sandbox_' + page for page in pages}
    for name in names:
        required.update(('Sandbox_' + name, 'Sandbox_' + name + '_tooltip'))
    for key in sorted(required - english.keys()):
        errors.append('English sandbox fallback missing: ' + key)
    for error in errors:
        print('FAIL: ' + error)
    print(('FAIL' if errors else 'PASS') + ': ' + str(len(catalogs)) + ' JSON catalogs; English names/tooltips for '
          + str(len(names)) + ' options; non-English fluency and native fallback NOT TESTED')
    return not errors

if __name__ == '__main__':
    sys.exit(0 if check() else 1)
