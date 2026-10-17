"""Verify explicitly selected offline dependency bytes; never modify input."""
import hashlib
import json
import os
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
    manifest = Path(manifest)
    if manifest.is_symlink() or manifest.stat().st_size > 2000000:
        raise ValueError('unsafe dependency manifest')
    data = json.loads(manifest.read_text(encoding='utf-8'), object_pairs_hook=_unique)
    if not isinstance(data, dict):
        raise ValueError('invalid dependency manifest')
    if type(data.get('manifest_version')) is not int or data['manifest_version'] != 1:
        raise ValueError('unsupported dependency manifest version')
    files, scopes = data.get('files'), data.get('source_roots')
    if not isinstance(files, dict) or not 1 <= len(files) <= 20000 or not isinstance(scopes, list) or not 1 <= len(scopes) <= 128:
        raise ValueError('missing dependency file inventory/scopes')

    def safe(name):
        if not isinstance(name, str) or not name or any(c in name for c in ('\\', ':', '\0')):
            raise ValueError('unsafe dependency path')
        path = PurePosixPath(name)
        if path.is_absolute() or any(part in ('', '.', '..') for part in name.split('/')):
            raise ValueError('unsafe dependency path')
        target = root
        for part in path.parts:
            target = target/part
            if target.is_symlink() or getattr(target, 'is_junction', lambda: False)():
                raise ValueError('linked dependency input')
        target = target.resolve()
        if not target.is_relative_to(root):
            raise ValueError('dependency path escapes selected root')
        return target

    rows = []
    for name, expected in sorted(files.items()):
        if not isinstance(expected, str) or not re.fullmatch('[0-9a-f]{64}', expected):
            raise ValueError('invalid dependency SHA-256')
        target = safe(name)
        if not target.is_file():
            raise ValueError('dependency input mismatch: ' + name)
        if target.stat().st_size > 10000000:
            raise ValueError('oversized dependency input: ' + name)
        before = target.stat(); digest_file = hashlib.sha256(); size = 0
        with target.open('rb') as stream:
            for block in iter(lambda: stream.read(1048576), b''):
                size += len(block)
                if size > 10000000:
                    raise ValueError('dependency input budget exceeded')
                digest_file.update(block)
        after = target.stat()
        if (before.st_size, before.st_mtime_ns) != (after.st_size, after.st_mtime_ns):
            raise ValueError('concurrent dependency input change')
        if digest_file.hexdigest() != expected:
            raise ValueError('dependency input mismatch: ' + name)
        rows.append(name + '\0' + expected + '\n')
    for scope in scopes:
        target = safe(scope)
        if not target.is_dir():
            raise ValueError('dependency source scope missing')
        actual = set()
        for parent, dirs, names in os.walk(target, followlinks=False):
            for name in dirs+names:
                file = Path(parent)/name
                if file.is_symlink() or getattr(file, 'is_junction', lambda: False)():
                    raise ValueError('dependency source link is not an exact snapshot')
                if file.is_file():
                    actual.add(file.relative_to(root).as_posix())
                    if len(actual) > 20000:
                        raise ValueError('dependency inventory budget exceeded')
        expected = {name for name in files if name.startswith(scope + '/')}
        if actual != expected:
            raise ValueError('dependency source inventory differs: ' + scope)
    digest = hashlib.sha256(''.join(rows).encode('utf-8')).hexdigest()
    if digest != data.get('inventory_sha256'):
        raise ValueError('dependency inventory checksum mismatch')
    return len(files)
