"""Read-only reviewed-descriptor check, matching the installed overview digest."""
import hashlib
import json
import os
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
from check_dependency_input import _unique

ROOT = Path(__file__).resolve().parents[1]
STATUSES = {'Source','Foundation','Planned','Blocked','Separate branch','Historical','UNKNOWN'}


def linked(path):
    return path.is_symlink() or getattr(path, 'is_junction', lambda: False)()


def safe(root, relative):
    if not isinstance(relative, str) or not relative or '\\' in relative or ':' in relative:
        raise ValueError('unsafe overview path')
    parts = relative.split('/')
    if any(p in ('', '.', '..') for p in parts):
        raise ValueError('unsafe overview path')
    path = Path(root)
    for part in parts:
        path = path / part
        if linked(path):
            raise ValueError('linked overview input')
    if not path.resolve().is_relative_to(Path(root).resolve()):
        raise ValueError('overview path escapes root')
    return path


def source_digest(root):
    root = Path(root).resolve()
    files = set()
    for name in ('src', 'Contents/mods', 'README.md', 'VERSION'):
        base = safe(root, name)
        if base.is_file():
            files.add(base)
        elif base.is_dir():
            for parent, dirs, names in os.walk(base, followlinks=False):
                dirs[:] = sorted(d for d in dirs if not d.startswith('.') and not linked(Path(parent)/d))
                for name in names:
                    path = Path(parent)/name
                    if not linked(path):
                        files.add(path)
                    if len(files) > 20000:
                        raise ValueError('overview source budget exceeded')
    digest = hashlib.sha256()
    for path in sorted(files, key=lambda p: p.as_posix()):
        if path.suffix.lower() not in {'.lua','.txt','.json','.md','.info',''}:
            continue
        before = path.stat()
        if before.st_size > 10000000:
            raise ValueError('oversized overview source')
        raw = path.read_bytes(); after = path.stat()
        if (before.st_size, before.st_mtime_ns) != (after.st_size, after.st_mtime_ns):
            raise ValueError('concurrent source change')
        digest.update(path.relative_to(root).as_posix().encode()); digest.update(b'\0')
        digest.update(hashlib.sha256(raw).digest())
    return digest.hexdigest()


def check(root):
    root = Path(root)
    path = safe(root, 'docs/MOD_OVERVIEW.json')
    if path.stat().st_size > 2000000:
        raise ValueError('oversized overview descriptor')
    data = json.loads(path.read_text(encoding='utf-8-sig'), object_pairs_hook=_unique)
    if not isinstance(data, dict) or type(data.get('schema')) is not int or data['schema'] != 1 or data.get('id') != 'mortis':
        raise ValueError('invalid MORTIS descriptor')
    if data.get('version') != safe(root, 'VERSION').read_text().strip() or data.get('reviewed') is not True:
        raise ValueError('overview version/review differs')
    if not re.fullmatch('[0-9a-f]{64}', str(data.get('source_digest', ''))) or data['source_digest'] != source_digest(root):
        raise ValueError('overview source digest differs')
    features = data.get('features')
    if not isinstance(features, list) or not 1 <= len(features) <= 200:
        raise ValueError('missing overview features')
    for feature in features:
        if not isinstance(feature, dict) or feature.get('status') not in STATUSES or not isinstance(feature.get('text'), str) or not feature['text'].strip():
            raise ValueError('invalid overview feature')
    evidence = data.get('evidence')
    if not isinstance(evidence, list) or not evidence:
        raise ValueError('missing overview evidence')
    for name in evidence:
        if not safe(root, name).is_file():
            raise ValueError('missing overview evidence file')
    return data


if __name__ == '__main__':
    try:
        print('PASS: reviewed overview ' + check(ROOT)['version'] + '; source only, native NOT TESTED')
    except (ValueError, OSError, TypeError) as error:
        print('FAIL: ' + str(error)); sys.exit(1)
