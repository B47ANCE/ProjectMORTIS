"""Portable offline boundary tests; framework/native behavior is mocked, never PZ proof."""
from pathlib import Path
import os
import unittest
import hashlib
import json
import contextlib
import importlib.util
import io
import tempfile
if os.environ.get('B47_PROOF_LUA') == '54':
    from lupa.lua54 import LuaRuntime
else:
    from lupa.lua51 import LuaRuntime

def plain(value):
    return {k: plain(v) for k, v in value.items()} if hasattr(value, 'items') else value

ROOT = Path(__file__).resolve().parents[1]
LUA = ROOT / 'src/ProjectMORTIS/42/media/lua'
MOCK = (ROOT / 'tests/fixtures/active_hours_native_mock.lua').read_text(encoding='utf-8')
FRAMEWORK = r'''
frameworkCalls={}
Mortis={Authority={canWriteCanonicalState=function() return mode=='S' and not denyAuthority end}}
Mortis.negotiateAPI=function(request)
 return not incompatible and request.minimum=='1.5.0' and request.maximumExclusive=='2.0.0'
end
Mortis.LocomotionOverrides={}
function Mortis.LocomotionOverrides.acquire(z,owner,definition)
 if frameworkError then error('mock framework error') end
 if rejectFramework then return false,'mock refusal' end
 if not z.baseline then z.baseline={walk=z.walk,category=z.category} end
 frameworkCalls[#frameworkCalls+1]={kind='acquire',owner=owner,tier=definition.tier}
 local walks={shambler='slow1',fastShambler='1',sprinter='sprint1'}
 local categories={shambler=3,fastShambler=2,sprinter=1}
 z:setWalkType(walks[definition.tier]);z.category=categories[definition.tier];z.scalar=0.75
 return true
end
function Mortis.LocomotionOverrides.release(z,owner)
 if frameworkError then error('mock framework error') end
 frameworkCalls[#frameworkCalls+1]={kind='release',owner=owner}
 z:setWalkType(z.baseline.walk);z.category=z.baseline.category
 return true
end
'''

# Reuse the production native-state classifier rather than copying its busy
# tokens into a permissive framework mock. Native getters remain host mocks.
def load_state_adapter(lua):
    lua.execute('''
        stateModules={['Mortis/API/Capabilities']={has=function() return true end},
                      ['Mortis/Core/ActionDiagnostics']={}}
        function require(name) return stateModules[name] end
    ''')
    for name in ('Runtime/Adapters/GameAdapter', 'Runtime/Adapters/StateAdapter'):
        module = lua.execute((LUA/'shared/Mortis'/(name+'.lua')).read_text(encoding='utf-8'))
        lua.globals().stateModules['Mortis/'+name] = module
    if lua.globals().Mortis is not None:
        lua.globals().Mortis.State = lua.globals().stateModules['Mortis/Runtime/Adapters/StateAdapter']
    lua.execute('function require(_) end')


class Peers:
    def __init__(self, prelude='', start=True):
        self.queue = []
        self.peers = {}
        for side in ('S', 'A', 'B'):
            lua = LuaRuntime(unpack_returned_tuples=True)
            lua.globals().mode = side
            lua.execute(MOCK)
            lua.execute(FRAMEWORK)
            load_state_adapter(lua)
            lua.globals().Mortis.VERSION = (ROOT / 'VERSION').read_text().strip()
            lua.execute(prelude)
            lua.globals().sendServerCommand = self.from_server
            lua.globals().sendClientCommand = self.from_client
            lua.execute((LUA / 'shared/Mortis/Diagnostics/ActiveHoursShared.lua').read_text())
            leaf = 'server/Mortis/Diagnostics/ActiveHoursServer.lua' if side == 'S' else 'client/Mortis/Diagnostics/ActiveHoursClient.lua'
            lua.execute((LUA / leaf).read_text())
            if start:
                lua.globals().mortisActiveHoursTestStart(True)
            self.peers[side] = lua

    def from_server(self, module, cmd, args):
        for side in ('A', 'B'):
            self.queue.append((side, module, cmd, plain(args), None))

    def from_client(self, player, module, cmd, args):
        self.queue.append(('S', module, cmd, plain(args), player['name']))

    def flush(self):
        for _ in range(30):
            if not self.queue:
                return
            side, module, cmd, args, sender = self.queue.pop(0)
            lua = self.peers[side]
            payload = lua.table_from(args) if args else None
            if side == 'S':
                lua.globals().emit('OnClientCommand', module, cmd, lua.globals().players[sender], payload)
            else:
                lua.globals().emit('OnServerCommand', module, cmd, payload)
        raise AssertionError('unbounded command cycle')

    def update(self, count=1):
        for _ in range(count):
            for lua in self.peers.values():
                lua.globals().emit('OnZombieUpdate', lua.globals().Z)

    def request(self, cmd, value=None, side='A'):
        self.peers[side].globals().MortisActiveHoursTest.request(cmd, value)
        self.flush()

    def select(self):
        self.request('Select', 7)
        self.update()


class MortisProofTests(unittest.TestCase):
    def setUp(self):
        self.n = Peers()
        self.n.select()

    def server(self):
        return self.n.peers['S'].globals().MortisActiveHoursTest.Server

    def test_loading_is_inert_until_explicit_start(self):
        n = Peers(start=False)
        for lua in n.peers.values():
            for name in ('OnTick', 'OnZombieUpdate', 'OnClientCommand', 'OnServerCommand', 'OnKeyPressed'):
                self.assertEqual(len(lua.globals().Events[name].handlers), 0)
            self.assertEqual(lua.globals().Z.writes, 0)
            self.assertFalse(lua.globals().mortisActiveHoursTestStart(False)[0])
            self.assertIsNone(lua.globals().MortisActiveHoursTest.Server)
            self.assertIsNone(lua.globals().MortisActiveHoursTest.Client)

    def test_legacy_diagnostics_block_start(self):
        for name in ('B47AHProof', 'B47AHMortisProof'):
            n = Peers(name + '={}', start=False)
            for lua in n.peers.values():
                self.assertFalse(lua.globals().mortisActiveHoursTestStart(True)[0])
                self.assertEqual(len(lua.globals().Events.OnZombieUpdate.handlers), 0)

    def test_legacy_diagnostic_loaded_later_stops_mutations(self):
        self.n.peers['S'].execute('B47AHMortisProof={}')
        self.n.request('Set', 'sprinter')
        self.assertTrue(self.server().invalid)
        self.assertEqual(self.n.peers['S'].globals().Z.writes, 0)

    def test_old_command_namespace_is_ignored(self):
        lua = self.n.peers['S']
        lua.globals().emit('OnClientCommand', 'B47AHMortisProof', 'Set', lua.globals().players.A,
                           lua.table_from({'tier':'sprinter'}))
        self.assertEqual(self.server().counts.requests, 0)
        self.assertEqual(lua.globals().Z.writes, 0)

    def test_runtime_version_comes_from_core(self):
        for lua in self.n.peers.values():
            self.assertEqual(lua.globals().MortisActiveHoursTest.Version, (ROOT/'VERSION').read_text().strip())

    def test_snapshot_matches_pinned_import_hashes(self):
        manifest = json.loads((ROOT/'docs/ACTIVE_HOURS_IMPORT.json').read_text())
        expected = set()
        for entry in manifest['files']:
            path = ROOT / entry['snapshot']
            expected.add(path.resolve())
            self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(), entry['sha256'], entry['source'])
        actual = {p.resolve() for p in (ROOT/manifest['snapshot_root']).rglob('*')
                  if p.is_file() and '__pycache__' not in p.parts}
        self.assertEqual(actual, expected)

    def test_checker_rejects_later_stale_runtime_version(self):
        spec = importlib.util.spec_from_file_location('version_fixture', ROOT/'scripts/check_versions.py')
        checker = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(checker)
        runtime = 'src/ProjectMORTIS/42/media/lua/shared/Mortis/init.lua'
        with tempfile.TemporaryDirectory() as directory:
            checker.ROOT = Path(directory)
            checker.MIRRORS = {runtime: checker.MIRRORS[runtime], 'CHANGELOG.md': checker.MIRRORS['CHANGELOG.md']}
            (checker.ROOT/'VERSION').write_text('1.2.3-dev.1\n')
            (checker.ROOT/'CHANGELOG.md').write_text('## 1.2.3-dev.1 current\n\n## 1.2.2 historical\n')
            path = checker.ROOT/runtime
            path.parent.mkdir(parents=True)
            with contextlib.redirect_stdout(io.StringIO()):
                path.write_text('Mortis.VERSION = "1.2.3-dev.1"\n')
                self.assertTrue(checker.check())
                path.write_text('Mortis.VERSION = "1.2.3-dev.1"\nMortis.VERSION = "0.23.2"\n')
                self.assertFalse(checker.check())

    def test_real_owner_stack_composes_and_releases_only_this_owner(self):
        # Real MORTIS stack/adapter/authority, with native methods and capability
        # export mocked. This is source integration, not native replication.
        lua = self.n.peers['S']
        lua.execute('''
            function Z:doSprinter() self:setWalkType('sprint1');self.category=1;self.scalar=.75 end
            function Z:doFastShambler() self:setWalkType('1');self.category=2;self.scalar=.75 end
            function Z:doShambler() self:setWalkType('slow1');self.category=3;self.scalar=.75 end
            loadedModules={['Mortis/API/Capabilities']={has=function() return true end}}
            function require(name) return loadedModules[name] end
        ''')
        for name in ('Runtime/Authority', 'Runtime/Adapters/GameAdapter',
                     'Runtime/Adapters/LocomotionAdapter', 'Runtime/LocomotionOverrides'):
            module = lua.execute((LUA/'shared/Mortis'/ (name+'.lua')).read_text())
            lua.globals().loadedModules['Mortis/'+name] = module
        lua.globals().Mortis.LocomotionOverrides = lua.globals().loadedModules['Mortis/Runtime/LocomotionOverrides']
        self.n.request('Set', 'fastShambler')
        lua.execute('assert(Mortis.LocomotionOverrides.acquire(Z,"other-consumer",{tier="sprinter",priority=40}))')
        self.n.request('Release')
        self.assertEqual(lua.globals().Z.category, 1)
        self.n.update(120)
        self.assertEqual(self.server().counts.nativeMismatch, 0,
                         'release must stop comparing an owner it no longer controls')
        self.assertIsNone(self.server().expectedCategory)
        lua.execute('assert(Mortis.LocomotionOverrides.release(Z,"other-consumer"))')
        self.assertEqual(lua.globals().Z.category, 3)
        self.assertEqual(lua.globals().Z.scalar, .75)  # Deliberately not full restoration.

    def test_three_tiers_use_server_api_only(self):
        for tier, category in [('fastShambler', 2), ('sprinter', 1), ('shambler', 3)]:
            self.n.request('Set', tier)
            self.assertEqual(self.n.peers['S'].globals().Z.category, category)
        self.assertEqual(len(self.n.peers['S'].globals().frameworkCalls), 3)
        for side in ('A', 'B'):
            self.assertEqual(self.n.peers[side].globals().Z.writes, 0)
            self.assertEqual(len(self.n.peers[side].globals().frameworkCalls), 0)

    def test_release_does_not_claim_scalar_restoration(self):
        self.n.request('Set', 'sprinter')
        self.n.request('Release')
        self.assertEqual(self.n.peers['S'].globals().Z.category, 3)
        self.assertEqual(self.n.peers['S'].globals().Z.scalar, .75)
        self.assertEqual(self.server().results[2].result, 'RELEASE_ACCEPTED')
        self.assertIn('not-full-restoration', self.server().results[2].reason)

    def test_nonadmin_and_other_admin_rejected(self):
        self.n.request('Set', 'sprinter', 'B')
        self.n.peers['S'].execute('function players.B:getAccessLevel() return "admin" end')
        self.n.request('Set', 'sprinter', 'B')
        self.assertEqual(self.server().counts.apiAccepted, 0)

    def test_duplicate_intent_has_no_second_call(self):
        self.n.peers['A'].globals().MortisActiveHoursTest.request('Set', 'sprinter')
        duplicate = self.n.queue[0]
        self.n.flush()
        self.n.queue.append(duplicate)
        self.n.flush()
        self.assertEqual(len(self.n.peers['S'].globals().frameworkCalls), 1)

    def test_stale_session_and_bad_tier_rejected(self):
        self.n.peers['A'].globals().MortisActiveHoursTest.Client.session = 'stale'
        self.n.request('Set', 'sprinter')
        self.assertEqual(self.server().counts.apiAccepted, 0)
        self.n.peers['A'].globals().MortisActiveHoursTest.Client.session = self.server().session
        self.n.request('Set', 'invalid')
        self.assertEqual(self.server().counts.apiAccepted, 0)

    def test_missing_api_fails_closed(self):
        n = Peers('Mortis=nil')
        self.assertIsNone(n.peers['S'].globals().MortisActiveHoursTest.Server)
        self.assertEqual(n.peers['S'].globals().Z.writes, 0)

    def test_incompatible_api_fails_closed(self):
        n = Peers('incompatible=true')
        server = n.peers['S']
        self.assertIsNone(server.globals().MortisActiveHoursTest.Server)
        self.assertEqual(len(server.globals().Events.OnClientCommand.handlers), 0)
        self.assertEqual(server.globals().Z.writes, 0)

    def test_real_api_negotiation_requires_native_state_surface(self):
        for missing in (None, 'isBusy', 'getNativeStateKey'):
            with self.subTest(missing=missing):
                n = Peers(start=False);lua = n.peers['S']
                lua.globals().actualCompatibility = lua.execute(
                    (LUA/'shared/Mortis/API/Compatibility.lua').read_text(encoding='utf-8'))
                lua.execute('function Mortis.negotiateAPI(request) return actualCompatibility.negotiate(Mortis,request) end')
                if missing:
                    lua.globals().Mortis.State[missing] = None
                result = lua.globals().mortisActiveHoursTestStart(True)
                accepted = result[0] if isinstance(result, tuple) else result
                self.assertEqual(accepted, missing is None)
                self.assertEqual(len(lua.globals().Events.OnClientCommand.handlers), 0 if missing else 1)

    def test_authority_denial_stops_following_writes(self):
        self.n.peers['S'].globals().denyAuthority = True
        self.n.request('Set', 'sprinter')
        self.n.peers['S'].globals().denyAuthority = False
        self.n.request('Set', 'fastShambler')
        self.assertTrue(self.server().invalid)
        self.assertEqual(self.n.peers['S'].globals().Z.writes, 0)

    def test_native_owner_transfer_never_dispatches_client_apply(self):
        self.n.peers['S'].globals().Z.owner = 'B'
        self.n.update()
        self.n.request('Set', 'sprinter')
        self.assertEqual(self.n.peers['S'].globals().Z.category, 1)
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)
        self.assertEqual(self.n.peers['B'].globals().Z.writes, 0)

    def test_observer_ignores_legacy_apply(self):
        lua = self.n.peers['B']
        lua.globals().emit('OnServerCommand', 'MortisActiveHoursTest', 'Apply', lua.table_from({'tier': 'sprinter'}))
        self.assertEqual(lua.globals().Z.writes, 0)

    def test_exception_freezes_without_retry(self):
        self.n.peers['S'].globals().frameworkError = True
        self.n.request('Set', 'sprinter')
        self.assertTrue(self.server().invalid)
        self.n.request('Set', 'sprinter')
        self.assertEqual(self.server().counts.errors, 1)

    def test_gap_replacement_and_both_guard(self):
        self.n.peers['S'].globals().SandboxVars.ZombieLore.ActiveOnly = 2
        self.n.request('Set', 'sprinter')
        self.assertEqual(self.server().counts.apiAccepted, 0)
        self.n.peers['S'].execute('Z=newZombie()')
        self.n.update()
        self.assertTrue(self.server().invalid)

    def test_native_overwrite_is_observed_never_repaired(self):
        self.n.request('Set', 'sprinter')
        z = self.n.peers['S'].globals().Z
        writes = z.writes
        z.category = 3
        self.n.update(120)
        self.assertEqual(z.writes, writes)
        self.assertGreater(self.server().counts.nativeMismatch, 0)

    def test_release_keeps_observations_without_claiming_a_baseline(self):
        self.n.request('Set', 'sprinter')
        self.n.request('Release')
        self.n.peers['S'].globals().Z.category = 2
        self.n.update(120)
        self.assertEqual(self.server().counts.nativeMismatch, 0)
        self.assertIsNone(self.server().expectedCategory)
        self.assertEqual(self.server().samples[len(self.server().samples)].category, 2)

    def test_busy_or_unavailable_native_state_rejects_both_mutations(self):
        cases = (
            'Z.gettingUp=true', 'Z.onFloor=true',
            'Z.nativeState="ZombieGetUpState"', 'Z.nativeState="ZombieAttackState"',
            'Z.nativeState="ZombieClimbOverFenceState"', 'Z.nativeState="ZombieFallDownState"',
            'Z.isOnFloor=nil', 'Z.isGettingUp=nil', 'Z.getCurrentState=nil',
            'function Z:getCurrentState() error("unavailable") end',
            'function Z:getCurrentState() return nil end',
            'function Z:getCurrentState() return "" end',
            'function Z:isOnFloor() return nil end',
            'function Z:isGettingUp() return nil end',
            'function Z:isOnFloor() error("unavailable") end',
            'function Mortis.State.isBusy() error("unavailable") end',
        )
        for change in cases:
            with self.subTest(change=change):
                n = Peers();n.select();lua = n.peers['S']
                n.request('Set', 'fastShambler')
                before = len(lua.globals().frameworkCalls)
                lua.execute(change)
                n.request('Set', 'sprinter');n.request('Release')
                self.assertEqual(len(lua.globals().frameworkCalls), before)
                self.assertTrue(lua.globals().MortisActiveHoursTest.Server.active)

    def test_busy_rejection_can_be_retried_by_a_new_standing_intent(self):
        lua = self.n.peers['S']
        lua.globals().Z.gettingUp = True
        self.n.peers['A'].globals().MortisActiveHoursTest.request('Set', 'sprinter')
        rejected = self.n.queue[0]
        self.n.flush()
        self.assertEqual(len(lua.globals().frameworkCalls), 0)
        self.assertFalse(bool(self.server().invalid))
        lua.globals().Z.gettingUp = False
        self.n.queue.append(rejected);self.n.flush()
        self.assertEqual(len(lua.globals().frameworkCalls), 0, 'busy requests must not replay after recovery')
        self.n.request('Set', 'sprinter');self.n.request('Release')
        self.assertEqual(len(lua.globals().frameworkCalls), 2)

    def test_bounded_rings_and_duplicate_registration(self):
        self.n.update(1200)
        for _ in range(30):
            self.n.request('Set', 'invalid')
        self.assertEqual(len(self.server().samples), 16)
        self.assertEqual(len(self.server().results), 16)
        for side, lua in self.n.peers.items():
            leaf = 'server/Mortis/Diagnostics/ActiveHoursServer.lua' if side == 'S' else 'client/Mortis/Diagnostics/ActiveHoursClient.lua'
            lua.execute((LUA / leaf).read_text())
            lua.globals().mortisActiveHoursTestStart(True)
            self.assertEqual(len(lua.globals().Events.OnZombieUpdate.handlers), 1)


if __name__ == '__main__':
    unittest.main()
