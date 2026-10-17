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
    'docs/AUTHORITY_REPLICATION.md': r'Current development iteration: ([^.]+\.[^.]+\.[^ ]+)\.',
    'docs/VALIDATION.md': r'Current development version: (\S+)\n',
    'workshop.txt': r'\[b\]Mod Version:\[/b\] (\S+)',
    'WORKSHOP_DESCRIPTION.txt': r'\[b\]Mod Version:\[/b\] (\S+)',
    'docs/STEAM_WORKSHOP_DESCRIPTION.txt': r'\[b\]Mod Version:\[/b\] (\S+)',
    'WORKSHOP_CHANGE_NOTE.txt': r'\[b\]Version ([^\[]+)\[/b\]',
    'docs/MOD_OVERVIEW.json': r'"version": "([^"]+)"',
    'docs/evidence/mortis-runtime-input.json': r'"version": "([^"]+)"',
}

def check(release=False):
    version = (ROOT / 'VERSION').read_text().strip()
    errors = []
    if not re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-[0-9A-Za-z.-]+)?', version):
        errors.append('Invalid canonical SemVer')
    for path, pattern in MIRRORS.items():
        matches = re.findall(pattern, (ROOT / path).read_text(encoding='utf-8-sig'))
        # Runtime VERSION may be assigned more than once: a later stale value
        # must not escape validation because the first declaration matched.
        # Changelogs and release notes deliberately retain older entries.
        if path != 'src/ProjectMORTIS/42/media/lua/shared/Mortis/init.lua':
            matches = matches[:1]
        if not matches or any(value.strip() != version for value in matches):
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
                expected={'Contents/mods/ProjectMORTIS/42/'+f.relative_to(SOURCE).as_posix(): f for f in SOURCE.rglob('*') if f.is_file()}
                expected.update({'Contents/mods/ProjectMORTIS/info.txt': SOURCE.parent/'info.txt',
                                 'Contents/mods/ProjectMORTIS/thumbnail.png': SOURCE.parent/'thumbnail.png',
                                 'preview.png': ROOT/'preview.png', 'workshop.txt': ROOT/'workshop.txt'})
                if set(names)!=set(expected):
                    errors.append('Unexpected/missing package members')
                for member,file in expected.items():
                    if member in names and hashlib.sha256(archive.read(member)).digest()!=hashlib.sha256(file.read_bytes()).digest():
                        errors.append('Package authoring/source mismatch: '+member)
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
