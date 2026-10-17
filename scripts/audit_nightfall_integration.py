"""Pinned first-party host audit; models native methods, never opens the game."""
import sys
sys.dont_write_bytecode = True
import argparse
import json
from pathlib import Path
import re
from check_dependency_input import verify

ROOT = Path(__file__).resolve().parents[1]


def audit(nightfall, knowledge):
    nightfall = Path(nightfall); knowledge = Path(knowledge)
    verify(ROOT, ROOT/'docs/evidence/mortis-runtime-input.json')
    verify(nightfall, ROOT/'docs/evidence/nightfall-6988b57-git-bytes.json')
    verify(knowledge, ROOT/'docs/evidence/knowledge-dependency-6ba66c0-git-bytes.json')
    from lupa.lua51 import LuaRuntime
    lua = LuaRuntime(unpack_returned_tuples=True)
    roots = [ROOT/'src/ProjectMORTIS/42/media/lua/shared',
             knowledge/'src/B47ANCEDKnowledgeAndWisdom/42/media/lua/shared',
             nightfall/'src/ProjectNightfall/42/media/lua/shared']
    lua.globals().package.path = ';'.join(p.as_posix()+'/?.lua' for p in roots)
    lua.execute('print=function()end;package.cpath="";package.loadlib=nil;io=nil;os={clock=function()return 0 end}')
    source = (roots[2]/'ProjectNightfall/PN_ZombieUV.lua').read_text(encoding='utf-8-sig')
    # Execute only these identified original branches in a controlled host scope.
    # This is explicitly fragment evidence, not execution of the whole UV module.
    for name, pattern in (
        ('_auditDisableBody', r'if Config.EnableFerals==false then\s*(MortisIntegration.clear\(z\).*?)\n        end'),
        ('_auditSlowBody', r'if s.uvSlowed then\s*(MortisIntegration.setUVSlowed\(z,false\).*?)\n    end'),
    ):
        match = re.search(pattern, source, re.S)
        if not match:
            raise ValueError('Selected consumer branch changed; review required')
        lua.globals()[name] = match.group(1)
    observed = dict(lua.execute((ROOT/'experiments/nightfall/integration_probe.lua').read_text()).items())
    findings = []
    def finding(condition, identifier, priority, title):
        if condition:
            findings.append({'id':identifier,'priority':priority,'title':title,'status':'OPEN'})
    finding(observed['phase_after_failed_clear']=='NORMAL' and observed['type_after_failed_clear'] is not None,
            'NF-M01','P1','Disabling ferals commits NORMAL despite refused canonical clear')
    finding(observed['busy_release'] is False and observed['busy_journal_retained'] and not observed['slow_flag_after_failed_release'],
            'NF-M02','P1','Hibernation drops UV-slow bookkeeping after refused release')
    finding(observed['failed_assignment'] is False and observed.get('type_after_failed_assignment')==observed['requested_type'],
            'NF-M03','P1','Failed initial nutrition assignment retains new identity when compensation clear refuses')
    finding(observed['diagnostic_admitted'] and not observed['dependency_mp_permitted'],
            'NF-M04','P2','API-presence diagnostics omit the guarded MP capability limitation')
    return {'environment':'Offline Lua 5.1; real first-party modules and identified source fragments; native methods modeled',
            'nightfall_commit':'6988b57b81ff0dbb859857eb79aace81c2e65c8f',
            'knowledge_commit':'6ba66c0d8f246d438f2e2f3c974fee9f77fdb426',
            'mortis_version':(ROOT/'VERSION').read_text().strip(),
            'findings':findings,'observed':observed,'native_tests':'HUMAN / NOT TESTED','G7':'BLOCKED / NOT TESTED','G8':'BLOCKED'}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--nightfall', required=True, type=Path)
    parser.add_argument('--knowledge-and-wisdom', required=True, type=Path)
    args = parser.parse_args()
    try:
        report = audit(args.nightfall,args.knowledge_and_wisdom)
        print(json.dumps(report,indent=2))
        sys.exit(1 if report['findings'] else 0)
    except Exception as error:
        print(json.dumps({'status':'ERROR','reason':type(error).__name__,'detail':'Pinned audit input unavailable; no native test performed.'}))
        sys.exit(2)
