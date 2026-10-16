"""Check declared current mirrors; never rewrite historical evidence."""
from pathlib import Path
import hashlib
import re
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'src/ProjectMORTIS/42'
MIRRORS = {
    'src/ProjectMORTIS/info.txt': r'(?m)^Version: ([^\r\n]+)',
    'src/ProjectMORTIS/42/mod.info': r'(?m)^modversion=([^\r\n]+)',
    'src/ProjectMORTIS/42/media/lua/shared/Mortis/init.lua': r'Mortis.VERSION = "([^"]+)"',
    'README.md': r'- Version: `([^`]+)`',
    'docs/MASTER_ROADMAP.md': r'Canonical version: ([^;]+);',
    'TESTER_HANDOFF.md': r'^# Project M\.O\.R\.T\.I\.S\. (\S+) playtester handoff',
    'CHANGELOG.md': r'(?m)^## (\S+) ',
    'workshop.txt': r'\[b\]Mod Version:\[/b\] (\S+)',
    'WORKSHOP_DESCRIPTION.txt': r'\[b\]Mod Version:\[/b\] (\S+)',
    'docs/STEAM_WORKSHOP_DESCRIPTION.txt': r'\[b\]Mod Version:\[/b\] (\S+)',
    'WORKSHOP_CHANGE_NOTE.txt': r'\[b\]Version ([^\[]+)\[/b\]',
}

def check(release=False):
    version = (ROOT / 'VERSION').read_text().strip()
    errors = []
    if not re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-[0-9A-Za-z.-]+)?', version):
        errors.append('Invalid canonical SemVer')
    for path, pattern in MIRRORS.items():
        match = re.search(pattern, (ROOT / path).read_text(encoding='utf-8-sig'))
        if not match or match.group(1).strip() != version:
            errors.append(path + ': missing or inconsistent current version')
    if release:
        if '-' in version:
            errors.append('Stable release rejects prerelease versions')
        path = ROOT / ('dist/ProjectMORTIS-' + version + '-workshop-ready.zip')
        if not path.exists():
            errors.append('Current-version package absent')
        else:
            with zipfile.ZipFile(path) as archive:
                names = archive.namelist()
                if len(names) != len(set(n.lower() for n in names)) or any(n.startswith('/') or '\\' in n or ':' in n or '..' in n.split('/') for n in names):
                    errors.append('Unsafe/duplicate/case-colliding package members')
                if archive.testzip():
                    errors.append('Package CRC failure')
                for file in SOURCE.rglob('*'):
                    if file.is_file():
                        member = 'Contents/mods/ProjectMORTIS/42/' + file.relative_to(SOURCE).as_posix()
                        if member not in names or hashlib.sha256(archive.read(member)).digest() != hashlib.sha256(file.read_bytes()).digest():
                            errors.append('Package differs: ' + member)
    for error in errors:
        print('FAIL: ' + error)
    print(('FAIL' if errors else 'PASS') + ': canonical version ' + version + '; ' + str(len(MIRRORS)) + ' current mirrors; historical artifacts excluded')
    return not errors

if __name__ == '__main__':
    sys.exit(0 if check('--release' in sys.argv) else 1)
