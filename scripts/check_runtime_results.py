"""Validate human result records offline; never grant runtime acceptance or gates."""
import argparse
import json
from pathlib import Path
import re
import sys
from check_dependency_input import _unique

ROOT = Path(__file__).resolve().parents[1]
CASES = {
    'creator': ('CU-01', 'CU-02', 'CU-03', 'CU-04', 'CU-05', 'CU-06'),
    'dependency': ('KW-01', 'KW-02', 'KW-03', 'KW-04', 'KW-05'),
    'mortis': ('MO-01', 'MO-02', 'MO-03', 'MO-04'),
    'locomotion': ('LO-01', 'LO-02', 'LO-03', 'LO-04', 'LO-BUSY', 'LO-PROFILE',
                   'LO-FAILURE', 'LO-STREAM', 'LO-RESTART'),
    'nightfall': ('NF-M01', 'NF-M02', 'NF-M03', 'NF-M04'),
}
STATUSES = {'PASS', 'FAIL', 'PARTIAL', 'BLOCKED', 'NOT TESTED'}


def exact(value, keys):
    if not isinstance(value, dict) or set(value) != set(keys.split()):
        raise ValueError('missing or unknown fields')


def text(value):
    if not isinstance(value, str) or not value.strip() or len(value) > 8192 or any(ord(c) < 32 and c not in '\n\t' for c in value):
        raise ValueError('missing or invalid text')


def digest(value, size):
    if not isinstance(value, str) or not re.fullmatch('[0-9a-f]{'+str(size)+'}', value):
        raise ValueError('invalid commit/hash')


def read(path):
    path = Path(path)
    if path.is_symlink() or getattr(path, 'is_junction', lambda: False)() or path.stat().st_size > 1048576:
        raise ValueError('unsafe/oversized result file')
    raw = path.read_bytes()
    if len(raw) > 1048576:
        raise ValueError('oversized result file')
    return json.loads(raw.decode('utf-8-sig'), object_pairs_hook=_unique,
                      parse_constant=lambda _: (_ for _ in ()).throw(ValueError('nonfinite JSON')))


def check(data, suite, mortis_commit, root=ROOT):
    """The caller selects the reviewed MORTIS commit; never trust record identity."""
    if suite not in CASES:
        raise ValueError('unknown suite')
    digest(mortis_commit, 40)
    exact(data, 'schema suite inputs environment cases')
    if type(data['schema']) is not int or data['schema'] != 1 or data['suite'] != suite:
        raise ValueError('wrong result schema/suite')
    names = ['mortis', 'knowledge'] + (['nightfall'] if suite == 'nightfall' else [])
    if not isinstance(data['inputs'], dict) or set(data['inputs']) != set(names):
        raise ValueError('wrong input set')
    manifests = {'mortis': 'mortis-runtime-input.json',
                 'knowledge': 'knowledge-dependency-6ba66c0-git-bytes.json',
                 'nightfall': 'nightfall-5690021-git-bytes.json'}
    for name in names:
        record = data['inputs'][name]
        exact(record, 'version commit inventory_sha256')
        manifest = read(Path(root)/'docs/evidence'/manifests[name])
        expected_commit = mortis_commit if name == 'mortis' else manifest['git_commit']
        if record != {'version': manifest['version'], 'commit': expected_commit,
                      'inventory_sha256': manifest['inventory_sha256']}:
            raise ValueError('input differs from selected candidate')
    env = data['environment']
    exact(env, 'steam_build client_version server_version clean_baseline mod_ids')
    for key in ('steam_build', 'client_version', 'server_version'):
        text(env[key])
    if type(env['clean_baseline']) is not bool:
        raise ValueError('clean baseline must be declared')
    expected_mods = {'ProjectMORTIS', 'B47ANCEDKnowledgeAndWisdom'}
    if suite == 'dependency':
        expected_mods = {'B47ANCEDKnowledgeAndWisdom'}
    if suite == 'nightfall':
        # Nightfall needs its family dependencies: explicitly record those too.
        expected_mods.update(read(Path(root)/'docs/evidence'/manifests['nightfall'])['integration_contract']['required_mod_ids'])
        expected_mods.add('ProjectNightfall')
    mods = env['mod_ids']
    if not isinstance(mods, list) or not 1 <= len(mods) <= 32 or any(not isinstance(m, str) or not re.fullmatch('[A-Za-z0-9_.-]{1,128}', m) for m in mods) or len(set(mods)) != len(mods):
        raise ValueError('invalid mod list')
    if (suite == 'nightfall' and not expected_mods.issubset(mods)) or (suite != 'nightfall' and set(mods) != expected_mods):
        raise ValueError('wrong suite mod list')
    cases = data['cases']
    if not isinstance(cases, list) or len(cases) > len(CASES[suite]):
        raise ValueError('invalid case list')
    seen = set()
    for row in cases:
        exact(row, 'id status roles settings fixture steps expected observed reason evidence affected_knowledge_mp_api')
        if not isinstance(row['id'], str) or row['id'] not in CASES[suite] or row['id'] in seen:
            raise ValueError('unknown/duplicate case')
        seen.add(row['id'])
        if not isinstance(row['status'], str) or row['status'] not in STATUSES:
            raise ValueError('invalid status')
        for key in ('settings', 'fixture', 'steps', 'expected', 'observed', 'reason'):
            text(row[key])
        if type(row['affected_knowledge_mp_api']) is not bool:
            raise ValueError('declare affected dependency MP API use')
        roles = row['roles']
        if not isinstance(roles, list) or not roles or any(r not in ('local-client', 'sp-authority', 'server', 'client-1', 'client-2') for r in roles) or len(set(roles)) != len(roles):
            raise ValueError('invalid roles')
        evidence = row['evidence']
        if not isinstance(evidence, list) or len(evidence) > 32:
            raise ValueError('invalid evidence list')
        for item in evidence:
            exact(item, 'reference sha256')
            if not isinstance(item['reference'], str) or not re.fullmatch('[A-Za-z0-9][A-Za-z0-9_.-]{0,127}', item['reference']):
                raise ValueError('use portable redacted evidence labels')
            digest(item['sha256'], 64)
        observed = row['status'] in {'PASS', 'FAIL', 'PARTIAL'}
        if observed:
            if not env['clean_baseline'] or env['steam_build'] in {'UNKNOWN', 'NOT TESTED'} or not env['steam_build'].isdigit() or env['client_version'] in {'UNKNOWN', 'NOT TESTED'} or not evidence:
                raise ValueError('observed case lacks baseline/build/evidence')
            if suite == 'locomotion' and (set(roles) != {'server', 'client-1', 'client-2'} or env['server_version'] in {'UNKNOWN', 'N/A', 'NOT TESTED'}):
                raise ValueError('dedicated case lacks server/two-client evidence')
            if row['status'] == 'PASS' and row['affected_knowledge_mp_api']:
                raise ValueError('selected Knowledge MP implementation is blocked')
            if suite == 'creator' and roles != ['local-client']:
                raise ValueError('creator suite is local presentation/storage')
            if suite in {'dependency', 'mortis'} and roles != ['sp-authority']:
                raise ValueError('baseline suite requires SP authority')
            if suite == 'nightfall' and set(roles) not in ({'sp-authority'}, {'server', 'client-1', 'client-2'}):
                raise ValueError('consumer suite needs explicit SP or dedicated roles')
            if 'server' in roles and env['server_version'] in {'UNKNOWN', 'N/A', 'NOT TESTED'}:
                raise ValueError('server role lacks executed server build')
    missing = sorted(set(CASES[suite]) - seen)
    return {'status': 'INCOMPLETE' if missing else 'VALID', 'missing_cases': missing,
            'reported_pass': sum(r['status'] == 'PASS' for r in cases),
            'review': 'HUMAN REVIEW REQUIRED; structure and declarations only, evidence content not authenticated',
            'G7': 'BLOCKED / NOT TESTED', 'G8': 'BLOCKED'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('result', type=Path)
    parser.add_argument('--suite', choices=CASES, required=True)
    parser.add_argument('--mortis-commit', required=True, help='Exact reviewed candidate SHA, selected independently of the result')
    args = parser.parse_args()
    try:
        result = check(read(args.result), args.suite, args.mortis_commit)
        print(json.dumps(result, indent=2))
        return 0 if result['status'] == 'VALID' else 1
    except (ValueError, OSError, TypeError, KeyError, RecursionError):
        # Never echo submitted text, paths, logs or player identifiers.
        print(json.dumps({'status': 'INVALID', 'detail': 'Result does not satisfy the selected schema/input contract; inspect privately.', 'G7': 'BLOCKED / NOT TESTED', 'G8': 'BLOCKED'}))
        return 2


if __name__ == '__main__':
    sys.exit(main())
