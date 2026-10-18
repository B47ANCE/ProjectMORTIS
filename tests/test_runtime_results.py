"""Synthetic human declarations only; these tests collect no native evidence."""
import copy
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'scripts'))
from check_runtime_results import CASES, check, read


def fixture(suite='creator', status='NOT TESTED'):
    inputs = {}
    for name, filename in [('mortis', 'mortis-runtime-input.json'),
                            ('knowledge', 'knowledge-dependency-6ba66c0-git-bytes.json')] + (
                            [('nightfall', 'nightfall-5690021-git-lf.json')] if suite == 'nightfall' else []):
        manifest = read(ROOT/'docs/evidence'/filename)
        inputs[name] = {'version': manifest['version'], 'commit': 'a'*40 if name == 'mortis' else manifest['git_commit'],
                        'inventory_sha256': manifest['inventory_sha256']}
    roles = ['server', 'client-1', 'client-2'] if suite == 'locomotion' else ['local-client']
    if suite in {'dependency', 'mortis', 'nightfall'}:
        roles = ['sp-authority']
    mods = ['ProjectMORTIS', 'B47ANCEDKnowledgeAndWisdom']
    if suite == 'dependency':
        mods = ['B47ANCEDKnowledgeAndWisdom']
    if suite == 'nightfall':
        mods = ['ProjectNightfall'] + read(ROOT/'docs/evidence/nightfall-5690021-git-lf.json')['integration_contract']['required_mod_ids']
    return {'schema': 1, 'suite': suite, 'inputs': inputs,
            'environment': {'steam_build': '12345', 'client_version': 'synthetic', 'server_version': 'synthetic',
                            'clean_baseline': status in {'PASS', 'FAIL', 'PARTIAL'}, 'mod_ids': mods},
            'cases': [{'id': case, 'status': status, 'roles': roles.copy(), 'settings': 'synthetic settings',
                       'fixture': 'synthetic disposable fixture', 'steps': 'synthetic steps',
                       'expected': 'synthetic expectation', 'observed': 'synthetic result',
                       'reason': 'synthetic declaration; never runtime proof',
                       'affected_knowledge_mp_api': False,
                       'evidence': [{'reference': 'synthetic-only', 'sha256': 'b'*64}] if status in {'PASS', 'FAIL', 'PARTIAL'} else []}
                      for case in CASES[suite]]}


class RuntimeResults(unittest.TestCase):
    def test_all_suites_and_reported_pass_never_grant_gates(self):
        for suite in CASES:
            for status in ('NOT TESTED', 'BLOCKED', 'PASS', 'FAIL', 'PARTIAL'):
                result = check(fixture(suite, status), suite, 'a'*40)
                self.assertEqual(result['status'], 'VALID')
                self.assertEqual(result['G7'], 'BLOCKED / NOT TESTED')
                self.assertEqual(result['G8'], 'BLOCKED')
                self.assertIn('HUMAN REVIEW REQUIRED', result['review'])

    def test_missing_duplicate_unknown_and_future(self):
        data = fixture(); data['cases'].pop()
        self.assertEqual(check(data, 'creator', 'a'*40)['missing_cases'], ['CU-06'])
        for mutate in (lambda d: d['cases'].__setitem__(1, copy.deepcopy(d['cases'][0])),
                       lambda d: d['cases'][0].update(id='UNKNOWN'),
                       lambda d: d.update(schema=2), lambda d: d.update(schema=True),
                       lambda d: d.update(extra='forbidden'), lambda d: d.update(suite='mortis')):
            data = fixture(); mutate(data)
            with self.assertRaises(ValueError): check(data, 'creator', 'a'*40)

    def test_wrong_commit_version_and_inventory(self):
        for name in ('mortis', 'knowledge'):
            for key in ('version', 'commit', 'inventory_sha256'):
                data = fixture(); data['inputs'][name][key] = 'wrong'
                with self.assertRaises(ValueError): check(data, 'creator', 'a'*40)
        with self.assertRaises(ValueError): check(fixture(), 'creator', 'c'*40)

    def test_claim_without_evidence_baseline_or_roles(self):
        for mutate in (lambda d: d['cases'][0].update(evidence=[]),
                       lambda d: d['environment'].update(clean_baseline=False),
                       lambda d: d['environment'].update(steam_build='UNKNOWN'),
                       lambda d: d['cases'][0].update(roles=['server'])):
            data = fixture(status='PASS'); mutate(data)
            with self.assertRaises(ValueError): check(data, 'creator', 'a'*40)
        data = fixture('locomotion', 'PASS'); data['cases'][0]['roles'].pop()
        with self.assertRaises(ValueError): check(data, 'locomotion', 'a'*40)
        data = fixture('locomotion', 'PASS'); data['cases'][0]['affected_knowledge_mp_api'] = True
        with self.assertRaises(ValueError): check(data, 'locomotion', 'a'*40)

    def test_mod_lists_and_local_evidence_references(self):
        data = fixture(); data['environment']['mod_ids'].append('ProjectNightfall')
        with self.assertRaises(ValueError): check(data, 'creator', 'a'*40)
        data = fixture('nightfall'); data['environment']['mod_ids'].remove('B47ANCEDSPXTRM')
        with self.assertRaises(ValueError): check(data, 'nightfall', 'a'*40)
        for ref in ('../console.txt', 'https://example.invalid/private', 'C:\\private.txt'):
            data = fixture(status='PASS'); data['cases'][0]['evidence'][0]['reference'] = ref
            with self.assertRaises(ValueError): check(data, 'creator', 'a'*40)

    def test_parser_and_cli_redaction(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder)/'results.json'
            for raw in ('{"schema":1,"schema":2}', '{"number":NaN}', 'x'*1048577):
                path.write_text(raw)
                with self.assertRaises(ValueError): read(path)
            data = fixture(); data['cases'][0]['status'] = 'PRIVATE-SENTINEL'
            path.write_text(json.dumps(data))
            result = subprocess.run([sys.executable, '-B', str(ROOT/'scripts/check_runtime_results.py'),
                                     str(path), '--suite', 'creator', '--mortis-commit', 'a'*40],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 2)
            self.assertNotIn('PRIVATE-SENTINEL', result.stdout + result.stderr)
            data = fixture(); data['cases'].pop(); path.write_text(json.dumps(data))
            result = subprocess.run([sys.executable, '-B', str(ROOT/'scripts/check_runtime_results.py'),
                                     str(path), '--suite', 'creator', '--mortis-commit', 'a'*40],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 1)


if __name__ == '__main__':
    unittest.main()
