"""Read-only pinned Nightfall source contracts; no Lua/native execution."""
import json
from pathlib import Path
import re
from check_dependency_input import verify, _unique
from check_overview import safe, linked

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT/'docs/evidence/nightfall-5690021-git-lf.json'


def text(root, name):
    path = safe(root, name)
    if path.stat().st_size > 2000000:
        raise ValueError('oversized source contract')
    return path.read_text(encoding='utf-8-sig')


def single(source, pattern):
    values = re.findall(pattern, source, re.M)
    if len(values) != 1:
        raise ValueError('ambiguous source contract')
    return values[0]


def inspect(mortis, nightfall, evidence=EVIDENCE):
    mortis, nightfall, evidence = Path(mortis), Path(nightfall), Path(evidence)
    if linked(evidence) or evidence.stat().st_size > 2000000:
        raise ValueError('unsafe Nightfall manifest')
    manifest = json.loads(evidence.read_text(encoding='utf-8'), object_pairs_hook=_unique)
    if not isinstance(manifest, dict) or manifest.get('dependency_mod_id') != 'ProjectNightfall':
        raise ValueError('wrong Nightfall manifest identity')
    if manifest.get('source_roots') != ['src/ProjectNightfall/42']:
        raise ValueError('incomplete Nightfall runtime scope')
    if not isinstance(manifest.get('version'), str) or len(manifest['version'])>128 or not re.fullmatch(r'\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?',manifest['version']):
        raise ValueError('invalid Nightfall version')
    if not isinstance(manifest.get('git_commit'), str) or not re.fullmatch('[0-9a-f]{40}',manifest['git_commit']):
        raise ValueError('invalid Nightfall commit')
    if 'VERSION' not in manifest.get('files', {}) or text(nightfall, 'VERSION').strip() != manifest.get('version'):
        raise ValueError('Nightfall version differs')
    count = verify(nightfall, evidence)
    metadata = dict(line.split('=', 1) for line in text(nightfall, 'src/ProjectNightfall/42/mod.info').splitlines() if '=' in line)
    contract = manifest.get('integration_contract')
    if not isinstance(contract, dict) or contract.get('mortis_api_minimum') != '1.6.0' or type(contract.get('food_transaction_version')) is not int or contract.get('food_transaction_version') != 1 or type(contract.get('recovery_record_version')) is not int or contract.get('recovery_record_version') != 1:
        raise ValueError('unreviewed Nightfall integration contract')
    required = contract.get('required_mod_ids')
    expected = ['B47ANCEDSPXTRM','ProjectMORTIS','B47ANCEDPower','B47ANCEDHealthCare','B47ANCEDKnowledgeAndWisdom']
    if required != expected or metadata.get('require', '').split(',') != expected or metadata.get('id') != 'ProjectNightfall' or metadata.get('modversion') != manifest['version']:
        raise ValueError('Nightfall loader contract differs')
    shared = 'src/ProjectMORTIS/42/media/lua/shared/Mortis/'
    api = single(text(mortis, shared+'API/Compatibility.lua'), r'^Compatibility\.VERSION = "(\d+\.\d+\.\d+)"$')
    if not (tuple(map(int, api.split('.'))) >= (1,6,0) and tuple(map(int, api.split('.'))) < (2,0,0)):
        raise ValueError('MORTIS API outside reviewed range')
    transaction = single(text(mortis, shared+'API/FoodSources.lua'), r'TRANSACTION_VERSION = (\d+)')
    if transaction != '1':
        raise ValueError('MORTIS food transaction differs')
    # These are reviewed source markers, never interpreted as native capability proof.
    integration = text(nightfall, 'src/ProjectNightfall/42/media/lua/shared/ProjectNightfall/PN_MortisIntegration.lua')
    diagnostics = text(nightfall, 'src/ProjectNightfall/42/media/lua/shared/ProjectNightfall/PN_DependencyDiagnostics.lua')
    for marker in ('function Integration.recoverAssignment(', 'ProjectNightfallAssignmentRecovery', 'overrides.releaseCeiling', 'data[RECOVERY_KEY]=pending'):
        if marker not in integration:
            raise ValueError('reviewed recovery surface missing')
    if 'MULTIPLAYER_STORAGE_UNAVAILABLE' not in diagnostics or 'minimum="1.6.0"' not in diagnostics:
        raise ValueError('reviewed readiness diagnostics missing')
    return {'version':manifest['version'],'commit':manifest.get('git_commit'),'files':count,
            'inventory_sha256':manifest['inventory_sha256'],'mortis_api':api,
            'food_transaction_version':1,'recovery_record_version':1,
            'scope':'Exact input and reviewed source contracts only; other family mods and native execution NOT VERIFIED'}
