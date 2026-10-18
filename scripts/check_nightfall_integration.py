"""Run three pinned Nightfall regressions against selected real MORTIS/Knowledge."""
import sys
sys.dont_write_bytecode = True
import argparse
import json
from pathlib import Path
from check_dependency_input import verify
from check_nightfall_input import inspect, EVIDENCE

ROOT = Path(__file__).resolve().parents[1]
CASES = ('test_mortis_recovery.lua','test_mortis_lifecycle_recovery.lua','test_dependency_diagnostics.lua')


def check(mortis, knowledge, nightfall, mortis_evidence, nightfall_evidence=EVIDENCE):
    mortis, knowledge, nightfall = map(Path, (mortis, knowledge, nightfall))
    verify(mortis, mortis_evidence)
    manifest = json.loads(Path(mortis_evidence).read_text(encoding='utf-8'))
    if manifest.get('dependency_mod_id') != 'ProjectMORTIS' or manifest.get('source_roots') != ['src/ProjectMORTIS/42'] or manifest.get('version') != (mortis/'VERSION').read_text().strip():
        raise ValueError('wrong MORTIS input')
    verify(knowledge, ROOT/'docs/evidence/knowledge-dependency-6ba66c0-git-bytes.json')
    inputs = inspect(mortis, nightfall, nightfall_evidence)
    pinned = json.loads(Path(nightfall_evidence).read_text(encoding='utf-8'))['files']
    if any('tests/'+name not in pinned for name in CASES):
        raise ValueError('regression input not pinned')
    from lupa.lua51 import LuaRuntime
    roots = [mortis/'src/ProjectMORTIS/42/media/lua/shared',
             knowledge/'src/B47ANCEDKnowledgeAndWisdom/42/media/lua/shared',
             nightfall/'src/ProjectNightfall/42/media/lua/shared']
    search = ';'.join(root.as_posix()+'/?.lua' for root in roots)
    records = []
    for name in CASES:
        lua = LuaRuntime(unpack_returned_tuples=True)
        lua.globals().package.path = search
        lua.execute('package.cpath="";package.loadlib=nil;os={clock=function()return 0 end};io=nil;print=function()end;isClient=function()return false end;isServer=function()return false end')
        # Native file I/O is replaced by a read-only string fixture for the one
        # identified production file the pinned lifecycle-fragment test reads.
        relative = 'src/ProjectNightfall/42/media/lua/shared/ProjectNightfall/PN_ZombieUV.lua'
        lua.globals()._sourcePath = relative
        lua.globals()._sourceText = (nightfall/relative).read_text(encoding='utf-8-sig')
        diagnostic = roots[2]/'ProjectNightfall/PN_DependencyDiagnostics.lua'
        lua.globals()._diagnosticPath = diagnostic.as_posix()
        lua.globals()._diagnosticText = diagnostic.read_text(encoding='utf-8-sig')
        lua.globals().arg = lua.table_from({1:diagnostic.as_posix()})
        lua.execute('''io={open=function(path,mode)
            assert(path==_sourcePath and mode=="r","unreviewed file access")
            return {read=function(_,format)assert(format=="*a");return _sourceText end,close=function()end}
        end};dofile=function(path)
            assert(path==_diagnosticPath,"unreviewed dofile")
            return assert(loadstring(_diagnosticText,"@PN_DependencyDiagnostics.lua"))()
        end''')
        try:
            lua.execute((nightfall/'tests'/name).read_text(encoding='utf-8-sig'), name='@'+name)
            records.append({'test':name,'status':'PASS'})
        except Exception as error:
            records.append({'test':name,'status':'FAIL','error_type':type(error).__name__})
    return {'status':'PASS' if all(r['status']=='PASS' for r in records) else 'FAIL',
            'mortis_version':(mortis/'VERSION').read_text().strip(),
            'mortis_input':{'commit':manifest.get('git_commit'),'inventory_sha256':manifest['inventory_sha256']},
            'nightfall_input':inputs,'knowledge_commit':'6ba66c0d8f246d438f2e2f3c974fee9f77fdb426',
            'tests':records,'scope':'Offline Lua 5.1; real modules, modeled native boundaries and identified production fragments; no whole UV bootstrap',
            'native_tests':'HUMAN / NOT TESTED','G7':'BLOCKED / NOT TESTED','G8':'BLOCKED'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mortis', type=Path, default=ROOT)
    parser.add_argument('--mortis-evidence', type=Path, default=ROOT/'docs/evidence/mortis-runtime-input.json')
    parser.add_argument('--knowledge-and-wisdom', type=Path, required=True)
    parser.add_argument('--nightfall', type=Path, required=True)
    parser.add_argument('--nightfall-evidence', type=Path, default=EVIDENCE,
                        help='Explicit reviewed bytes; old CRLF fixtures remain historical')
    args = parser.parse_args()
    try:
        result = check(args.mortis,args.knowledge_and_wisdom,args.nightfall,args.mortis_evidence,args.nightfall_evidence)
        print(json.dumps(result,indent=2));sys.exit(0 if result['status']=='PASS' else 1)
    except Exception as error:
        print(json.dumps({'status':'ERROR','error_type':type(error).__name__,'detail':'Pinned input/probe unavailable; no native test performed.'}));sys.exit(2)
