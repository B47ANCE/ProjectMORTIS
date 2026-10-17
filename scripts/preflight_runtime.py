"""Read-only local input preflight. Never launches PZ, fetches Git or writes files."""
import sys
sys.dont_write_bytecode = True
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import zipfile
from check_dependency_input import verify, _unique
from check_overview import check as check_overview, linked, safe
from check_nightfall_input import inspect as inspect_nightfall, EVIDENCE as NIGHTFALL_EVIDENCE

ROOT = Path(__file__).resolve().parents[1]


def read_json(path):
    if linked(path) or path.stat().st_size > 2000000:
        raise ValueError('unsafe-json')
    data = json.loads(path.read_text(encoding='utf-8-sig'), object_pairs_hook=_unique)
    if not isinstance(data, dict):
        raise ValueError('invalid-json-object')
    return data


def sha(path, limit=512000000):
    if linked(path) or not path.is_file() or path.stat().st_size > limit:
        raise ValueError('unsafe-input')
    before = path.stat(); digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            digest.update(block)
    after = path.stat()
    if (before.st_size, before.st_mtime_ns) != (after.st_size, after.st_mtime_ns):
        raise ValueError('concurrent-input-change')
    return digest.hexdigest()


def preflight(mortis, knowledge, mortis_evidence, dependency_evidence, game=None,
              engine_evidence=None, steam_manifest=None, environment=None,
              nightfall=None, nightfall_evidence=None):
    rows = []
    versions = {}
    def record(name, status, detail):
        rows.append({'check':name, 'status':status, 'detail':detail})
    for name, root, evidence, mod_id in (
        ('mortis', Path(mortis), Path(mortis_evidence), 'ProjectMORTIS'),
        ('knowledge', Path(knowledge), Path(dependency_evidence), 'B47ANCEDKnowledgeAndWisdom'),
    ):
        try:
            manifest = read_json(evidence)
            version_file = safe(root, 'VERSION')
            if version_file.stat().st_size>256 or manifest.get('source_roots') != ['src/'+mod_id+'/42'] or 'VERSION' not in manifest.get('files', {}):
                raise ValueError('incomplete runtime scope')
            version = version_file.read_text(encoding='utf-8-sig').strip()
            if not re.fullmatch(r'\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?', version):
                raise ValueError('invalid-version')
            if manifest.get('version') != version or manifest.get('dependency_mod_id') != mod_id:
                raise ValueError('wrong-manifest-identity')
            count = verify(root, evidence)
            versions[name] = version
            record(name+'_input', 'PASS', {'files':count,'version':version,'inventory_sha256':manifest['inventory_sha256']})
            if name == 'knowledge':
                # This is a reviewed input contract, not code inference or an API call.
                record('knowledge_mp_contract', 'BLOCKED' if manifest.get('multiplayer_status') else 'UNKNOWN',
                       'Selected input has an unresolved MP implementation contract; no bypass or downgrade.')
        except (OSError, ValueError, TypeError, KeyError, RecursionError):
            record(name+'_input', 'ERROR', 'Selected input/manifest is missing, malformed or does not match; no file contents or local paths are printed.')
    if nightfall is None:
        if nightfall_evidence is not None:
            record('nightfall_input', 'ERROR', 'Nightfall evidence requires an explicit Nightfall source selection.')
        else:
            record('nightfall_input', 'NOT SELECTED', 'Optional consumer excluded; no Nightfall acceptance implied.')
    else:
        try:
            if 'mortis' not in versions or 'knowledge' not in versions:
                raise ValueError('dependency input unavailable')
            consumer = inspect_nightfall(mortis, nightfall, nightfall_evidence or NIGHTFALL_EVIDENCE)
            versions['nightfall'] = consumer['version']
            record('nightfall_input', 'PASS', consumer)
            record('nightfall_remaining_dependencies', 'NOT CHECKED',
                   {'mod_ids':['B47ANCEDSPXTRM','B47ANCEDPower','B47ANCEDHealthCare'],
                    'scope':'Loader requirements reviewed; these other installations and native startup were not inspected.'})
        except (OSError, ValueError, TypeError, KeyError, RecursionError):
            record('nightfall_input', 'ERROR', 'Selected Nightfall input/manifest or reviewed dependency contract differs; no private paths or source contents printed.')
    try:
        check_overview(mortis)
        record('overview', 'PASS', 'Reviewed descriptor matches this checkout layout, version and source; source review only.')
    except (OSError, ValueError, TypeError, RecursionError):
        record('overview', 'ERROR', 'Descriptor/evidence is missing or stale for this checkout layout.')
    env = os.environ if environment is None else environment
    injected = [name for name in ('JAVA_TOOL_OPTIONS','JDK_JAVA_OPTIONS','_JAVA_OPTIONS','CLASSPATH') if env.get(name)]
    record('java_environment', 'BLOCKED' if injected else 'PASS', {'nonempty_variable_names':injected})
    if game is None:
        record('engine_inputs', 'UNKNOWN', 'No game directory selected; native baseline was not inspected.')
    else:
        try:
            game = Path(game)
            baseline = read_json(Path(engine_evidence))
            config = read_json(safe(game, 'ProjectZomboid64.json'))
            if not isinstance(config, dict) or not isinstance(config.get('classpath'), list) or not config['classpath']:
                raise ValueError('invalid-launcher')
            args = []
            def collect(node, depth=0):
                if depth > 8:
                    raise ValueError('launcher-depth-budget')
                if isinstance(node, dict):
                    for key, value in node.items():
                        if key == 'vmArgs':
                            if not isinstance(value, list) or any(not isinstance(v,str) for v in value):
                                raise ValueError('invalid-vmargs')
                            args.extend(value)
                        elif isinstance(value, dict):
                            collect(value,depth+1)
            collect(config)
            if any(not isinstance(v,str) for v in config['classpath']):
                raise ValueError('invalid-classpath')
            agent = any(v.lower().startswith(('-javaagent:','-agentpath:','-agentlib:','-xbootclasspath')) for v in args)
            extra = any(v.replace('\\','/').lower() not in ('.','projectzomboid.jar') for v in config['classpath'])
            record('launcher', 'BLOCKED' if agent or extra else 'PASS',
                   {'custom_agent_or_boot_override':agent,'unreviewed_classpath':extra})
            jar = safe(game, 'projectzomboid.jar')
            digest = sha(jar)
            record('packaged_engine', 'PASS' if digest == baseline.get('packaged_jar_sha256') else 'BLOCKED',
                   {'sha256':digest,'meaning':'Compared to selected source-review baseline; not Steam integrity proof.'})
            selected = baseline.get('selected_classes')
            if not isinstance(selected, dict) or not 1 <= len(selected) <= 64:
                raise ValueError('invalid-class-inventory')
            changed = 0
            with zipfile.ZipFile(jar) as package:
                members = package.infolist()
                if len(members) > 50000 or len({m.filename for m in members}) != len(members):
                    raise ValueError('engine-entry-budget')
                for name, expected in selected.items():
                    target = safe(game, name)
                    entry = package.getinfo(name)
                    if entry.file_size > 2000000:
                        raise ValueError('oversized-engine-class')
                    packed = hashlib.sha256(package.read(entry)).hexdigest()
                    if packed != expected.get('packaged_sha256'):
                        changed += 1
                    if target.exists() and sha(target, 2000000) != packed:
                        changed += 1
            record('selected_engine_classes', 'BLOCKED' if changed else 'PASS',
                   {'mismatches':changed,'scope':'Selected packaged/loose classes only; no execution or whole-install certification.'})
            if steam_manifest is None:
                record('steam_build', 'UNKNOWN', 'No explicit Steam manifest selected.')
            else:
                path = Path(steam_manifest)
                if linked(path) or path.stat().st_size > 200000:
                    raise ValueError('unsafe-steam-manifest')
                text = path.read_text(encoding='utf-8-sig')
                app = re.findall(r'"appid"\s+"(\d+)"',text)
                builds = re.findall(r'"buildid"\s+"(\d+)"',text)
                if app != ['108600'] or len(builds) != 1:
                    raise ValueError('ambiguous-steam-manifest')
                record('steam_build', 'PASS' if builds[0] == baseline.get('steam_build') else 'BLOCKED', {'build':builds[0]})
        except (OSError, ValueError, TypeError, KeyError, AttributeError, RecursionError, zipfile.BadZipFile):
            record('engine_inputs', 'ERROR', 'Missing/malformed/unreviewed engine input; no launcher arguments, file contents or private paths are printed.')
    state = 'ERROR' if any(r['status']=='ERROR' for r in rows) else (
        'BLOCKED' if any(r['status'] in ('BLOCKED','UNKNOWN') for r in rows) else 'INPUT_CHECKS_PASS')
    return {'schema':1,'environment':'Read-only local/offline preflight; no PZ runtime',
            'status':state,'versions':versions,'checks':rows,
            'remote_freshness':'NOT CHECKED; no Git/network operations',
            'native_tests':'HUMAN / NOT TESTED','G7':'BLOCKED / NOT TESTED','G8':'BLOCKED'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--knowledge-and-wisdom', required=True, type=Path)
    parser.add_argument('--dependency-evidence', type=Path, default=ROOT/'docs/evidence/knowledge-dependency-6ba66c0-git-bytes.json')
    parser.add_argument('--mortis-evidence', type=Path, default=ROOT/'docs/evidence/mortis-runtime-input.json')
    parser.add_argument('--game-root', type=Path)
    parser.add_argument('--steam-manifest', type=Path)
    parser.add_argument('--engine-evidence', type=Path, default=ROOT/'docs/evidence/native-test-preflight-25485521.json')
    parser.add_argument('--nightfall', type=Path, help='Optional exact Nightfall source; never executes Lua')
    parser.add_argument('--nightfall-evidence', type=Path, help='Explicit reviewed Nightfall input manifest')
    args = parser.parse_args()
    if args.nightfall_evidence and not args.nightfall:
        parser.error('--nightfall-evidence requires --nightfall')
    report = preflight(ROOT,args.knowledge_and_wisdom,args.mortis_evidence,args.dependency_evidence,
                       args.game_root,args.engine_evidence,args.steam_manifest,
                       nightfall=args.nightfall,nightfall_evidence=args.nightfall_evidence)
    print(json.dumps(report,indent=2))
    return {'ERROR':1,'BLOCKED':2,'INPUT_CHECKS_PASS':0}[report['status']]


if __name__ == '__main__':
    sys.exit(main())
