"""Verify explicitly selected offline dependency bytes; never modify input."""
import hashlib
import json
from pathlib import Path, PurePosixPath
import re


def _unique(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('duplicate manifest key')
        result[key] = value
    return result


def verify(root, manifest):
    root = Path(root).resolve()
    data = json.loads(Path(manifest).read_text(encoding='utf-8'), object_pairs_hook=_unique)
    if not isinstance(data, dict):
        raise ValueError('invalid dependency manifest')
    if type(data.get('manifest_version')) is not int or data['manifest_version'] != 1:
        raise ValueError('unsupported dependency manifest version')
    files, scopes = data.get('files'), data.get('source_roots')
    if not isinstance(files, dict) or not files or not isinstance(scopes, list) or not scopes:
        raise ValueError('missing dependency file inventory/scopes')

    def safe(name):
        if not isinstance(name, str) or not name or any(c in name for c in ('\\', ':', '\0')):
            raise ValueError('unsafe dependency path')
        path = PurePosixPath(name)
        if path.is_absolute() or any(part in ('', '.', '..') for part in name.split('/')):
            raise ValueError('unsafe dependency path')
        target = root.joinpath(*path.parts).resolve()
        if not target.is_relative_to(root):
            raise ValueError('dependency path escapes selected root')
        return target

    rows = []
    for name, expected in sorted(files.items()):
        if not isinstance(expected, str) or not re.fullmatch('[0-9a-f]{64}', expected):
            raise ValueError('invalid dependency SHA-256')
        target = safe(name)
        if not target.is_file() or hashlib.sha256(target.read_bytes()).hexdigest() != expected:
            raise ValueError('dependency input mismatch: ' + name)
        rows.append(name + '\0' + expected + '\n')
    for scope in scopes:
        target = safe(scope)
        if not target.is_dir():
            raise ValueError('dependency source scope missing')
        actual = set()
        for file in target.rglob('*'):
            # Validate the resolved destination as well as inventory membership.
            if file.is_symlink():
                raise ValueError('dependency source symlink is not an exact snapshot')
            if file.is_file():
                actual.add(file.relative_to(root).as_posix())
        expected = {name for name in files if name.startswith(scope + '/')}
        if actual != expected:
            raise ValueError('dependency source inventory differs: ' + scope)
    digest = hashlib.sha256(''.join(rows).encode('utf-8')).hexdigest()
    if digest != data.get('inventory_sha256'):
        raise ValueError('dependency inventory checksum mismatch')
    return len(files)
