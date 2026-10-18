"""Read selected installed Lua/class metadata; never load or execute engine code.

Print portable fingerprints, observed method descriptors and evidence ranges.
No copied source, decompilation, runtime claim or native adapter is produced.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import zipfile

LUA = {
    'media/lua/shared/Foraging/forageSystem.lua': [[1944, 1951]],
    'media/lua/client/Foraging/ISZoneDisplay.lua': [[273, 285], [310, 321], [713, 723]],
    'media/lua/server/Foraging/forageServer.lua': [[1, 3], [26, 49]],
    'media/lua/shared/TimedActions/ISGrabCorpseAction.lua': [[80, 91]],
}
CLASSES = {
    'zombie/GameTime.class': {'isEndlessDay', 'isEndlessNight', 'getTimeOfDay'},
    'zombie/iso/weather/ClimateManager.class': {'getSeason', 'getDayLightStrength'},
    'zombie/erosion/season/ErosionSeason.class': {'getDawn', 'getDusk', 'setDay'},
    'zombie/characters/IsoZombie.class': {'getOnlineID', 'setOnlineID', 'getPersistentOutfitID', 'getModData', 'save', 'load'},
    'zombie/characters/IsoGameCharacter.class': {'getPersistentOutfitID', 'setPersistentOutfitID', 'getModData', 'save', 'load'},
    'zombie/iso/IsoObject.class': {'getModData', 'transmitModData', 'save', 'load'},
    'zombie/iso/objects/IsoDeadBody.class': {'reanimate', 'getModData', 'getPersistentOutfitID', 'save', 'load'},
    'zombie/world/moddata/ModData.class': {'getOrCreate', 'transmit', 'request', 'save', 'get', 'add'},
}


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def metadata(raw):
    """Minimal class-file member metadata parser; no bytecode execution."""
    if len(raw) > 10000000 or raw[:4] != b'\xca\xfe\xba\xbe':
        raise ValueError('invalid/oversized class')
    offset = 8
    def number(size):
        nonlocal offset
        end = offset + size
        if end > len(raw): raise ValueError('truncated class')
        value = int.from_bytes(raw[offset:end], 'big'); offset = end
        return value
    count = number(2); pool = [None]*count; i = 1
    while i < count:
        tag = number(1)
        if tag == 1:
            length = number(2); end = offset + length
            if end > len(raw): raise ValueError('truncated constant')
            pool[i] = raw[offset:end].decode('utf-8', errors='replace'); offset = end
        elif tag in (3, 4): number(4)
        elif tag in (5, 6): number(8); i += 1
        elif tag in (7, 8, 16, 19, 20): number(2)
        elif tag in (9, 10, 11, 12, 17, 18): number(4)
        elif tag == 15: number(3)
        else: raise ValueError('unsupported constant tag')
        i += 1
    number(2); number(2); number(2)
    for _ in range(number(2)): number(2)
    def members():
        nonlocal offset
        result = []
        for _ in range(number(2)):
            flags = number(2); name = pool[number(2)]; descriptor = pool[number(2)]
            result.append({'name': name, 'descriptor': descriptor, 'public': bool(flags & 1), 'static': bool(flags & 8)})
            for _ in range(number(2)):
                number(2); length = number(4); offset += length
                if offset > len(raw): raise ValueError('truncated attributes')
        return result
    fields = members(); methods = members()
    return fields, methods


def inspect(game, steam_manifest):
    game = Path(game)
    steam = Path(steam_manifest).read_text(encoding='utf-8')
    if not re.search(r'"appid"\s+"108600"', steam): raise ValueError('wrong app manifest')
    build = re.search(r'"buildid"\s+"(\d+)"', steam)
    if not build: raise ValueError('missing build')
    jar = game/'projectzomboid.jar'
    hasher = hashlib.sha256()
    with jar.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''): hasher.update(block)
    result = {'scope': 'READ-ONLY source/member metadata, NOT PZ runtime; no Lua binding/durability guarantee',
              'steam_build': build.group(1), 'executed_game_version': 'UNKNOWN / NOT TESTED',
              'packaged_jar_sha256': hasher.hexdigest(), 'lua': {}, 'classes': {}}
    for name, ranges in LUA.items():
        raw = (game/name).read_bytes()
        if len(raw) > 10000000: raise ValueError('oversized Lua')
        lines = raw.decode('utf-8-sig').splitlines()
        if any(end > len(lines) for _, end in ranges): raise ValueError('missing range')
        result['lua'][name] = {'sha256': sha(raw), 'lines': ranges}
    with zipfile.ZipFile(jar) as archive:
        for name, selected in CLASSES.items():
            info = archive.getinfo(name)
            if info.file_size > 10000000: raise ValueError('oversized member')
            raw = archive.read(info); fields, methods = metadata(raw)
            loose = game/name
            loose_hash = sha(loose.read_bytes()) if loose.is_file() else None
            result['classes'][name] = {'packaged_sha256': sha(raw), 'loose_sha256': loose_hash,
                'selected_declared_methods': [m for m in methods if m['name'] in selected],
                'identity_field_metadata': [f for f in fields if any(k in f['name'].lower() for k in ('onlineid', 'persistentoutfit'))],
                'absent_selected_declarations': sorted(selected - {m['name'] for m in methods}),
                'limits': 'Absence here does not rule out inheritance; member presence is not Lua invocation, life uniqueness, persistence or atomicity proof.'}
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--game-root', type=Path, required=True)
    parser.add_argument('--steam-manifest', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(inspect(args.game_root, args.steam_manifest), indent=2))
