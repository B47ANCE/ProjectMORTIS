"""Bounded staged/tracked-file credential and local-artifact check; prints paths only."""
from pathlib import Path
import re
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
paths = subprocess.check_output(['git','ls-files','-z'],cwd=root).decode().split('\0')
errors = []
for name in filter(None,paths):
    if name.startswith(('.agents/', '.codex/', 'Contents/', 'dist/', 'docs/audits/')) or name.lower().endswith(('.zip','.log','.jar','.class','.pyc')):
        errors.append(name + ': forbidden local/generated file')
    data = subprocess.check_output(['git','show',':' + name],cwd=root) if '--staged' in sys.argv else (root/name).read_bytes()
    patterns = [rb'-----BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY-----',rb'\bgh[pousr]_[A-Za-z0-9]{30,}',rb'\bgithub_pat_[A-Za-z0-9_]{40,}',rb'\bAKIA[0-9A-Z]{16}\b']
    if any(re.search(p,data) for p in patterns):
        errors.append(name + ': suspected credential pattern')
for error in errors:
    print('FAIL: ' + error)
print(('FAIL' if errors else 'PASS') + ': bounded public-file scan; manual staged review also required')
sys.exit(1 if errors else 0)
