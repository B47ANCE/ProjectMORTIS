"""Offline host runner; dependency integrations use explicitly selected source."""
from pathlib import Path
import argparse
import json
import os
import sys
sys.dont_write_bytecode = True
from lupa.lua51 import LuaRuntime
from check_versions import ROOT, SOURCE, check

ARGUMENTS = {
    'anatomy_attachments': 'API/AnatomyAttachments', 'anatomy_capabilities': 'API/AnatomyCapabilities',
    'anatomy_consequence_providers': 'Runtime/AnatomyConsequenceRuntime', 'collision_untyped': 'Runtime/CollisionRuntime',
    'crowd_flow': 'Runtime/CrowdFlowRuntime', 'detached_parts': 'API/DetachedParts', 'developer_reports': 'Runtime/DeveloperReports',
    'locomotion_overrides': 'Runtime/LocomotionOverrides', 'pile_model': 'Runtime/PileModel',
    'pile_observations': 'Runtime/PileObservationRuntime', 'pile_support_profiles': 'API/PileSupportProfiles',
    'pile_traversal_links': 'Runtime/PileTraversalLinks', 'script_item_collections': 'Runtime/Adapters/ScriptItemAdapter',
    'state_request_stand': 'Runtime/Adapters/StateAdapter', 'system_settings': 'Runtime/SystemSettings',
    'trauma_transition_events': 'Runtime/TraumaRuntime', 'trip_adapter': 'Runtime/Adapters/TripAdapter',
}
DEPENDENCY = 'B47ANCEDKnowledgeAndWisdom'
INTEGRATIONS = {'test_research_archive', 'test_history_dependency'}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--knowledge-and-wisdom', type=Path, help='B47ANCEDKnowledgeAndWisdom repository root')
    parser.add_argument('--unit-only', action='store_true')
    parser.add_argument('--test', help='Run only a named test stem')
    args = parser.parse_args()
    os.chdir(ROOT)
    failures = 0 if check() else 1
    lua_root = SOURCE / 'media/lua'
    search = ';'.join((lua_root / side).as_posix() + '/?.lua' for side in ('shared','client','server')) + ';'
    dependency_root = (args.knowledge_and_wisdom.resolve() / 'src' / DEPENDENCY / '42') if args.knowledge_and_wisdom else None
    dependency_shared = dependency_root / 'media/lua/shared' if dependency_root else None
    dependency_ready = dependency_shared and all((dependency_shared / DEPENDENCY / file).is_file()
                                                 for file in ('API.lua', 'HistoryRecords.lua'))
    if dependency_shared:
        search += dependency_shared.as_posix() + '/?.lua;'
    lua = LuaRuntime(unpack_returned_tuples=True)
    compile_lua = lua.eval('function(s,n) local f,e=loadstring(s,n); return f~=nil,e end')
    count = 0
    for path in sorted(lua_root.rglob('*.lua')):
        ok, error = compile_lua(path.read_text(encoding='utf-8-sig'), '@' + path.relative_to(ROOT).as_posix())
        count += 1
        if not ok:
            failures += 1
            print('FAIL syntax: ' + str(error))
    print('Syntax files: ' + str(count))
    records = []
    paths = sorted((ROOT / 'tests').glob('test_*.lua'))
    if args.test:
        paths = [p for p in paths if p.stem == args.test]
        if not paths:
            parser.error('No matching test')
    for path in paths:
        if path.stem in INTEGRATIONS and args.unit_only:
            records.append({'test': path.name, 'status':'NOT TESTED', 'reason':'--unit-only excludes '+DEPENDENCY+' integration'})
            continue
        if path.stem in INTEGRATIONS and not dependency_ready:
            failures += 1
            records.append({'test':path.name,'status':'BLOCKED','reason':'Select the declared '+DEPENDENCY+' source/API with --knowledge-and-wisdom <repository-root>'})
            continue
        if path.stem == 'test_no_project_remnants':
            from lupa.lua54 import LuaRuntime as Factory
        else:
            Factory = LuaRuntime
        runtime = Factory(unpack_returned_tuples=True)
        runtime.globals().search = search
        runtime.execute('package.path=search..package.path')
        runtime.globals().print = lambda *values: None
        target = ARGUMENTS.get(path.stem.removeprefix('test_'))
        runtime.globals().arg = runtime.table_from({1:(lua_root / ('shared/Mortis/' + target + '.lua')).as_posix()} if target else {})
        try:
            runtime.execute(path.read_text(encoding='utf-8-sig'), name='@' + path.name)
            records.append({'test': path.name, 'status':'PASS', 'runtime':runtime.eval('_VERSION')})
        except Exception as error:
            failures += 1
            records.append({'test':path.name, 'status':'FAIL', 'error':str(error)})
    report = {'version':(ROOT/'VERSION').read_text().strip(), 'environment':'Offline Lupa, NOT PZ runtime',
              'syntax_files':count, 'tests':records, 'G7':'BLOCKED / NOT TESTED', 'G8':'BLOCKED'}
    (ROOT / 'validation-results.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    for row in records:
        print(row['status'] + ': ' + row['test'] + (' - ' + row.get('error',row.get('reason','')) if 'error' in row or 'reason' in row else ''))
    return 1 if failures else 0

if __name__ == '__main__':
    sys.exit(main())
