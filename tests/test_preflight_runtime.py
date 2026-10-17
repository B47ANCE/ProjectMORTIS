"""Disposable files only: prove refusal, redaction and read-only inspection."""
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
import zipfile

sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'scripts'))
from preflight_runtime import preflight
from check_overview import check, source_digest


class Preflight(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory(); self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        self.mortis = self.root/'mortis'; self.knowledge = self.root/'knowledge'; self.game = self.root/'game'
        self.game.mkdir()
        self.me = self.prepare(self.mortis,'ProjectMORTIS','0.26.0-dev.4')
        self.ke = self.prepare(self.knowledge,'B47ANCEDKnowledgeAndWisdom','0.16.0')
        self.descriptor = {'schema':1,'id':'mortis','name':'MORTIS','version':'0.26.0-dev.4',
                           'reviewed':True,'source_digest':source_digest(self.mortis),
                           'features':[{'status':'Source','text':'Test fixture only'}],'evidence':['README.md']}
        self.write_overview()
        self.config = {'classpath':['.','projectzomboid.jar'],'vmArgs':['-Xmx1g']}
        self.write_config()
        self.class_name = 'zombie/Test.class'; self.class_bytes = b'not executed: synthetic class fixture'
        with zipfile.ZipFile(self.game/'projectzomboid.jar','w') as archive:
            archive.writestr(self.class_name,self.class_bytes)
        self.baseline = self.root/'engine.json'
        self.baseline.write_text(json.dumps({'steam_build':'123',
            'packaged_jar_sha256':hashlib.sha256((self.game/'projectzomboid.jar').read_bytes()).hexdigest(),
            'selected_classes':{self.class_name:{'packaged_sha256':hashlib.sha256(self.class_bytes).hexdigest()}}}))
        self.steam = self.root/'appmanifest_108600.acf'
        self.steam.write_text('"appid" "108600"\n"buildid" "123"')

    def prepare(self,root,mod_id,version):
        source = root/f'src/{mod_id}/42'; source.mkdir(parents=True)
        (root/'docs').mkdir(); (root/'VERSION').write_text(version+'\n'); (root/'README.md').write_text('fixture')
        (source/'mod.info').write_text(f'id={mod_id}\nmodversion={version}\n')
        files={p.relative_to(root).as_posix():hashlib.sha256(p.read_bytes()).hexdigest()
               for p in [root/'VERSION',source/'mod.info']}
        rows=''.join(n+'\0'+h+'\n' for n,h in sorted(files.items()))
        manifest={'manifest_version':1,'dependency_mod_id':mod_id,'version':version,
                  'files':files,'source_roots':[f'src/{mod_id}/42'],
                  'inventory_sha256':hashlib.sha256(rows.encode()).hexdigest(),
                  'multiplayer_status':'BLOCKED reviewed fixture contract'}
        path=root/'docs/input.json';path.write_text(json.dumps(manifest));return path

    def write_overview(self):
        (self.mortis/'docs/MOD_OVERVIEW.json').write_text(json.dumps(self.descriptor))

    def write_config(self):
        (self.game/'ProjectZomboid64.json').write_text(json.dumps(self.config))

    def run_preflight(self,game=True,environment=None):
        return preflight(self.mortis,self.knowledge,self.me,self.ke,
                         self.game if game else None,self.baseline,self.steam,
                         {} if environment is None else environment)

    @staticmethod
    def rows(report): return {r['check']:r for r in report['checks']}

    def test_clean_selected_inputs_are_not_native_pass(self):
        rows=self.rows(self.run_preflight())
        for name in ('mortis_input','knowledge_input','overview','launcher','packaged_engine','selected_engine_classes','steam_build'):
            self.assertEqual(rows[name]['status'],'PASS',name)
        self.assertEqual(rows['knowledge_mp_contract']['status'],'BLOCKED')
        self.assertEqual(self.run_preflight()['native_tests'],'HUMAN / NOT TESTED')

    def test_no_game_is_unknown_and_never_launched_or_written(self):
        def snapshot():return {p.relative_to(self.root).as_posix():p.read_bytes() for p in self.root.rglob('*') if p.is_file()}
        before=snapshot()
        with patch('subprocess.Popen',side_effect=AssertionError('process launch forbidden')):
            report=self.run_preflight(game=False)
        self.assertEqual(self.rows(report)['engine_inputs']['status'],'UNKNOWN')
        self.assertEqual(before,snapshot())
        self.assertEqual(report['remote_freshness'],'NOT CHECKED; no Git/network operations')

    def test_source_mismatch_and_missing_manifest_fail(self):
        (self.knowledge/'src/B47ANCEDKnowledgeAndWisdom/42/mod.info').write_text('changed')
        self.assertEqual(self.rows(self.run_preflight())['knowledge_input']['status'],'ERROR')
        self.me.unlink()
        self.assertEqual(self.run_preflight()['status'],'ERROR')

    def test_agent_classpath_and_environment_are_redacted(self):
        secret='PRIVATE_CANARY_DO_NOT_PRINT'
        self.config['windows']={'10':{'vmArgs':['-javaagent:'+secret]}}
        self.config['classpath'].append(secret);self.write_config()
        report=self.run_preflight(environment={'JAVA_TOOL_OPTIONS':secret})
        self.assertEqual(self.rows(report)['launcher']['status'],'BLOCKED')
        self.assertEqual(self.rows(report)['java_environment']['status'],'BLOCKED')
        self.assertNotIn(secret,json.dumps(report));self.assertNotIn(str(self.root),json.dumps(report))

    def test_loose_class_and_build_mismatch_block(self):
        loose=self.game/self.class_name;loose.parent.mkdir();loose.write_bytes(b'different')
        self.steam.write_text('"appid" "108600"\n"buildid" "124"')
        report=self.run_preflight()
        self.assertEqual(self.rows(report)['selected_engine_classes']['status'],'BLOCKED')
        self.assertEqual(self.rows(report)['steam_build']['status'],'BLOCKED')

    def test_malformed_engine_inputs_and_traversal_refuse(self):
        (self.game/'ProjectZomboid64.json').write_text('[]')
        self.assertEqual(self.rows(self.run_preflight())['engine_inputs']['status'],'ERROR')
        self.write_config()
        baseline=json.loads(self.baseline.read_text());baseline['selected_classes']={'../escape.class':{}}
        self.baseline.write_text(json.dumps(baseline))
        self.assertEqual(self.rows(self.run_preflight())['engine_inputs']['status'],'ERROR')

    def test_overview_staleness_and_unsafe_evidence(self):
        self.assertEqual(check(self.mortis)['id'],'mortis')
        (self.mortis/'README.md').write_text('changed reviewed source context')
        self.assertEqual(self.rows(self.run_preflight())['overview']['status'],'ERROR')
        self.descriptor['source_digest']=source_digest(self.mortis);self.descriptor['evidence']=['../private']
        self.write_overview()
        with self.assertRaisesRegex(ValueError,'unsafe'):
            check(self.mortis)

    def test_successful_full_inspection_preserves_all_bytes(self):
        before={p.relative_to(self.root).as_posix():hashlib.sha256(p.read_bytes()).hexdigest()
                for p in self.root.rglob('*') if p.is_file()}
        with patch('subprocess.Popen',side_effect=AssertionError('process launch forbidden')):
            self.run_preflight()
        after={p.relative_to(self.root).as_posix():hashlib.sha256(p.read_bytes()).hexdigest()
               for p in self.root.rglob('*') if p.is_file()}
        self.assertEqual(before,after)


if __name__=='__main__': unittest.main()
