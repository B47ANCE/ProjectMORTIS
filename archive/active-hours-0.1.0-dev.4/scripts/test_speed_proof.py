"""Offline Lua mocks only. Requires development dependency lupa, never game execution."""
from pathlib import Path
import unittest
import os
import re
if os.environ.get('B47_PROOF_LUA') == '54':
    from lupa.lua54 import LuaRuntime
else:
    from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
LUA = ROOT / 'proof/B47ANCEDActiveHoursSpeedProof/42/media/lua'
MOCK = r'''
Events={}
printed={}
function print(text) printed[#printed+1]=text end
for _,name in ipairs({'OnTick','OnZombieUpdate','OnClientCommand','OnServerCommand','OnKeyPressed'}) do
 local handlers={}
 Events[name]={Add=function(fn) handlers[#handlers+1]=fn end, handlers=handlers}
end
function emit(name,...) for _,fn in ipairs(Events[name].handlers) do fn(...) end end
function require(_) end
function isServer() return mode=='S' end
function isClient() return mode~='S' end
SandboxVars={ZombieLore={ActiveOnly=1}}
Keyboard={KEY_LCONTROL=1,KEY_LSHIFT=2,KEY_F6=6,KEY_F7=7,KEY_F8=8,KEY_F9=9,KEY_F10=10,KEY_F11=11}
function isKeyDown(_) return modifiers or false end
players={}
for _,name in ipairs({'A','B'}) do
 local p={name=name}
 function p:isLocalPlayer() return mode==self.name end
 function p:getAccessLevel() return self.name=='A' and 'admin' or 'none' end
 players[name]=p
end
function getSpecificPlayer(_) return players[mode] end
function newZombie()
 local z={id=7,walk='slow1',category=3,scalar=0.60,owner='A',writes=0,x=0,y=0}
 function z:getOnlineID() return self.id end
 function z:isDead() return self.dead or false end
 function z:isCrawling() return self.crawling or false end
 function z:getOwnerPlayer() return players[self.owner] end
 function z:isRemoteZombie() return mode=='S' or self.owner~=mode end
 function z:getWalkType() return self.walk end
 function z:getSpeedType() return self.category end
 function z:getSpeedMod() return self.scalar end
 function z:isRunning() return self.category==1 end
 function z:getActionStateName() return 'WalkToward' end
 function z:getAnimationStateName() return 'walk' end
 function z:getX() return self.x end
 function z:getY() return self.y end
 function z:setWalkType(v) self.walk=v; self.writes=self.writes+1 end
 function z:setSpeedTypeFromWalkType()
  if self.failOnce then self.failOnce=false; error('mock setter failure') end
  self.category=B47AHProof.category(self.walk)
 end
 function z:setSpeedMod(v) self.scalar=v end
 return z
end
Z=newZombie()
'''


def plain(value):
    if hasattr(value, 'items'):
        return {k: plain(v) for k, v in value.items()}
    return value


class Network:
    def __init__(self):
        self.queue = []
        self.peers = {}
        for name in ('S', 'A', 'B'):
            lua = LuaRuntime(unpack_returned_tuples=True)
            lua.globals().mode = name
            lua.execute(MOCK)
            lua.globals().sendServerCommand = self.from_server
            lua.globals().sendClientCommand = self.from_client
            lua.execute((LUA / 'shared/B47AHProof.lua').read_text())
            side = 'server/B47AHProofServer.lua' if name == 'S' else 'client/B47AHProofClient.lua'
            lua.execute((LUA / side).read_text())
            self.peers[name] = lua

    def from_server(self, *args):
        if len(args) == 3:
            module, cmd, payload = args
            targets = ('A', 'B')
        else:
            player, module, cmd, payload = args
            targets = (player['name'],)
        for target in targets:
            self.queue.append((target, module, cmd, plain(payload), None))

    def from_client(self, player, module, cmd, payload):
        self.queue.append(('S', module, cmd, plain(payload), player['name']))

    def one(self):
        target, module, cmd, payload, sender = self.queue.pop(0)
        lua = self.peers[target]
        # Native GameClient omits empty tables; GameServer passes nil in that case.
        args = lua.table_from(payload, recursive=True) if payload else None
        if target == 'S':
            lua.globals().emit('OnClientCommand', module, cmd, lua.globals().players[sender], args)
        else:
            lua.globals().emit('OnServerCommand', module, cmd, args)

    def flush(self):
        for _ in range(30):
            if not self.queue:
                return
            self.one()
        raise AssertionError('unbounded command cycle')

    def update(self, count=1):
        for _ in range(count):
            for lua in self.peers.values():
                lua.globals().emit('OnZombieUpdate', lua.globals().Z)

    def arm(self):
        self.peers['A'].globals().B47AHProof.select(7)
        self.flush()
        self.update()

    def set(self, speed):
        self.peers['A'].globals().B47AHProof.set(speed)
        self.flush()

    def sync(self):
        # Nominal native transport mock, not verification of engine packet arithmetic.
        owner = self.peers['S'].globals().Z.owner
        source = self.peers[owner].globals().Z
        for lua in self.peers.values():
            for field in ('walk', 'category', 'scalar'):
                lua.globals().Z[field] = source[field]


class SpeedProofTests(unittest.TestCase):
    def setUp(self):
        self.n = Network()
        self.n.arm()

    def test_mapping_transitions_and_restore(self):
        for speed, category in [('FastShambler', 2), ('Sprinter', 1), ('Shambler', 3)]:
            self.n.set(speed)
            self.assertEqual(self.n.peers['A'].globals().Z.category, category)
            self.assertEqual(self.n.peers['B'].globals().Z.writes, 0)
            self.assertEqual(self.n.peers['S'].globals().Z.writes, 0)
            self.n.sync()
        self.n.peers['A'].globals().B47AHProof.restore()
        self.n.flush()
        self.assertEqual(self.n.peers['A'].globals().Z.scalar, 0.60)
        self.assertEqual(self.n.peers['A'].globals().B47AHProof.ClientState.counts.restores, 1)

    def test_nonadmin_and_invalid_requests(self):
        self.n.peers['B'].globals().B47AHProof.set('Sprinter')
        self.n.flush()
        self.n.set('nonsense')
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)

    def test_both_conflict(self):
        self.n.peers['S'].globals().SandboxVars.ZombieLore.ActiveOnly = 2
        self.n.set('Sprinter')
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)

    def test_duplicate_and_stale_owner(self):
        self.n.peers['A'].globals().B47AHProof.set('Sprinter')
        self.n.one()  # server dispatch only
        message = self.n.queue[0]
        for lua in self.n.peers.values():
            lua.globals().Z.owner = 'B'
        self.n.update()
        self.n.flush()  # former owner rejects
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)
        self.n.set('FastShambler')
        # Transfer with an outstanding command freezes subsequent server mutations.
        self.assertEqual(self.n.peers['B'].globals().Z.category, 3)
        self.assertTrue(self.n.peers['S'].globals().B47AHProof.ServerState.invalid)
        self.n.queue.append(message)
        self.n.flush()
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)

    def test_transfer_restores_server_original(self):
        self.n.set('Sprinter')
        self.n.sync()
        for lua in self.n.peers.values():
            lua.globals().Z.owner = 'B'
        self.n.update()
        self.n.peers['A'].globals().B47AHProof.restore()
        self.n.flush()
        self.assertEqual(self.n.peers['B'].globals().Z.scalar, 0.60)
        self.assertEqual(self.n.peers['B'].globals().Z.category, 3)

    def test_partial_setter_failure_rolls_back(self):
        self.n.peers['A'].globals().Z.failOnce = True
        self.n.set('Sprinter')
        state = self.n.peers['A'].globals().B47AHProof.ClientState
        self.assertTrue(state.rollbackOK)
        self.assertTrue(state.invalid)
        self.assertEqual(self.n.peers['A'].globals().Z.walk, 'slow1')

    def test_scalar_unit_mismatch_blocks(self):
        self.n.peers['A'].globals().Z.scalar = 1000
        self.n.set('Sprinter')
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)

    def test_native_drift_never_reapplied(self):
        self.n.set('Sprinter')
        z = self.n.peers['A'].globals().Z
        writes = z.writes
        z.scalar = 0.55
        self.n.update(180)
        self.assertEqual(z.writes, writes)
        self.assertGreater(self.n.peers['A'].globals().B47AHProof.ClientState.counts.drift, 0)

    def test_reused_reference_and_gap_block(self):
        lua = self.n.peers['A']
        lua.execute('Z=newZombie()')
        self.n.update()
        self.n.set('Sprinter')
        self.assertEqual(lua.globals().Z.writes, 0)
        for _ in range(301):
            self.n.peers['S'].globals().emit('OnTick')
        self.assertTrue(self.n.peers['S'].globals().B47AHProof.ServerState.invalid)

    def test_duplicate_live_command(self):
        self.n.peers['A'].globals().B47AHProof.set('Sprinter')
        self.n.one()
        original = self.n.queue[0]
        self.n.queue.append(original)
        self.n.flush()
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 1)

    def test_flat_wire_and_malformed_ack(self):
        self.n.peers['A'].globals().B47AHProof.set('Sprinter')
        self.n.one()
        payload = self.n.queue[0][3]
        self.assertFalse(any(isinstance(v, dict) for v in payload.values()))
        s = self.n.peers['S'].globals().B47AHProof.ServerState
        self.n.queue.clear()
        self.n.queue.append(('S', 'B47AHSpeedProof', 'Ack',
                            {'epoch': s.epoch, 'seq': s.seq, 'ok': True,
                             'resultWalk': 'sprint1', 'resultCategory': 1,
                             'resultScalar': 'bad'}, 'A'))
        self.n.flush()
        self.assertTrue(s.invalid)

    def test_nil_owner_and_single_target(self):
        self.n.peers['S'].globals().Z.owner = None
        self.n.set('Sprinter')
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)
        self.n.peers['A'].globals().B47AHProof.select(8)
        self.n.flush()
        self.assertEqual(self.n.peers['S'].globals().B47AHProof.ServerState.id, 7)

    def test_reload_registers_once(self):
        for name, lua in self.n.peers.items():
            side = 'server/B47AHProofServer.lua' if name == 'S' else 'client/B47AHProofClient.lua'
            lua.execute((LUA / side).read_text())
            self.assertEqual(len(lua.globals().Events.OnZombieUpdate.handlers), 1)

    def test_anomalous_scalar_is_observable_without_mutation(self):
        lua = self.n.peers['B']
        lua.globals().Z.scalar = 1000
        self.n.update(60)
        self.assertEqual(lua.globals().B47AHProof.ClientState.samples[1].scalar, 1000)
        self.assertEqual(lua.globals().Z.writes, 0)

    def test_delayed_authorization_ack_is_not_authoritative(self):
        self.n.peers['A'].globals().B47AHProof.set('Sprinter')
        self.n.one()
        # Native authorization stream may lag on A; only server view changes here.
        self.n.peers['S'].globals().Z.owner = 'B'
        self.n.peers['S'].globals().emit('OnZombieUpdate', self.n.peers['S'].globals().Z)
        self.n.flush()
        state = self.n.peers['S'].globals().B47AHProof.ServerState
        self.assertIsNone(state.applied)
        self.assertGreater(state.counts.rejected, 0)
        # This limitation is intentional evidence: old local view can still write.
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 1)

    def test_operator_key_controls(self):
        lua = self.n.peers['A']
        lua.globals().modifiers = True
        lua.globals().emit('OnKeyPressed', 7)
        self.n.flush()
        self.assertEqual(lua.globals().Z.category, 2)
        self.n.sync()
        lua.globals().emit('OnKeyPressed', 10)
        self.n.flush()
        self.assertEqual(lua.globals().Z.scalar, 0.60)

    def test_snapshot_requires_known_walk_and_category(self):
        lua = self.n.peers['A']
        self.assertFalse(lua.eval('B47AHProof.valid({scalar=0.9})'))
        self.assertFalse(lua.eval('B47AHProof.valid({walk="unknown",scalar=0.9})'))

    def test_restore_has_nonempty_session_payload(self):
        self.n.set('Sprinter')
        self.n.sync()
        self.n.peers['A'].globals().B47AHProof.restore()
        self.assertEqual(self.n.queue[0][3].get('epoch'), 1)
        self.n.flush()
        self.assertEqual(self.n.peers['A'].globals().Z.scalar, 0.60)

    def test_malformed_apply_never_writes(self):
        self.n.peers['A'].globals().B47AHProof.set('Sprinter')
        self.n.one()
        msg = self.n.queue.pop(0)
        del msg[3]['valueWalk']
        del msg[3]['valueCategory']
        self.n.queue.append(msg)
        self.n.flush()
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)

    def test_stale_admin_session_rejected(self):
        self.n.queue.append(('S', 'B47AHSpeedProof', 'Set', {'epoch': 0, 'speed': 'Sprinter'}, 'A'))
        self.n.flush()
        s = self.n.peers['S'].globals().B47AHProof.ServerState
        self.assertEqual(s.counts.staleCommands, 1)
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)

    def test_missing_ack_deadline_is_counted_once(self):
        self.n.peers['A'].globals().B47AHProof.set('Sprinter')
        self.n.one()
        self.n.queue.clear()  # deliberate missing delivery/acknowledgment
        for _ in range(602):
            self.n.peers['S'].globals().emit('OnTick')
            self.n.update()
        s = self.n.peers['S'].globals().B47AHProof.ServerState
        self.assertEqual(s.counts.missingAcks, 1)
        self.assertEqual(s.reason, 'ack-timeout')
        self.n.set('FastShambler')
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)

    def test_restore_timeout_is_failure(self):
        self.n.set('Sprinter')
        self.n.sync()
        self.n.peers['A'].globals().B47AHProof.restore()
        self.n.one()
        self.n.queue.clear()
        for _ in range(301):
            self.n.peers['S'].globals().emit('OnTick')
            self.n.update()
        s = self.n.peers['S'].globals().B47AHProof.ServerState
        self.assertEqual(s.counts.restorationAttempts, 1)
        self.assertEqual(s.counts.restorationFailures, 1)

    def test_spoofed_observer_ack_cannot_freeze_owner(self):
        self.n.peers['A'].globals().B47AHProof.set('Sprinter')
        self.n.one()
        s = self.n.peers['S'].globals().B47AHProof.ServerState
        self.n.queue.insert(0, ('S', 'B47AHSpeedProof', 'Ack',
                               {'epoch': s.epoch, 'seq': s.seq, 'ok': False}, 'B'))
        self.n.flush()
        self.assertFalse(s.invalid)
        self.assertEqual(self.n.peers['A'].globals().Z.category, 1)

    def test_read_only_samples_continue_after_revocation(self):
        self.n.set('Sprinter')
        self.n.sync()
        for lua in self.n.peers.values():
            lua.globals().Z.owner = 'B'
        self.n.update(120)
        a = self.n.peers['A'].globals().B47AHProof.ClientState
        self.assertTrue(a.invalid)
        self.assertEqual(a.reason, 'owner-revoked')
        self.assertGreater(a.counts.samples, 0)
        self.assertEqual(a.counts.observerWrites, 0)

    def test_results_and_samples_are_bounded(self):
        for _ in range(100):
            self.n.set('invalid')
        self.n.update(1200)
        s = self.n.peers['S'].globals().B47AHProof.ServerState
        self.assertEqual(len(s.results), 16)
        self.assertEqual(len(s.samples), 16)

    def test_dump_survives_native_empty_table_semantics(self):
        self.n.peers['A'].globals().B47AHProof.dump()
        self.assertTrue(self.n.queue[0][3])
        self.assertEqual(self.n.queue[0][3]['epoch'], 1)
        self.n.flush()

    def test_missing_snapshot_api_fails_closed(self):
        self.n.peers['A'].execute('Z.getActionStateName=nil')
        self.n.set('Sprinter')
        c = self.n.peers['A'].globals().B47AHProof.ClientState
        self.assertEqual(c.counts.apiErrors, 1)
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)
        self.assertTrue(self.n.peers['S'].globals().B47AHProof.ServerState.invalid)

    def test_nil_native_walk_category_does_not_crash_samples(self):
        lua = self.n.peers['B']
        lua.execute('Z.walk=nil; Z.category=nil')
        self.n.update(60)
        self.assertEqual(lua.globals().B47AHProof.ClientState.counts.apiErrors, 1)

    def test_failed_restore_rolls_back_to_pre_restore_state(self):
        self.n.set('Sprinter')
        self.n.sync()
        lua = self.n.peers['A']
        lua.globals().Z.failOnce = True
        lua.globals().B47AHProof.restore()
        self.n.flush()
        c = lua.globals().B47AHProof.ClientState
        self.assertTrue(c.rollbackOK)
        self.assertEqual(c.counts.restorationFailures, 1)
        self.assertEqual(lua.globals().Z.walk, 'sprint1')

    def test_result_dump_identifies_revision_request_and_observation(self):
        self.n.set('Sprinter')
        self.n.peers['A'].globals().B47AHProof.dump()
        lines = list(self.n.peers['A'].globals().printed.values())
        applied = [line for line in lines if 'result=FIELDS_APPLIED' in line]
        self.assertEqual(len(applied), 1)
        for part in ['session=1', 'seq=', 'requestedCategory=1', 'observedCategory=1', 'requestedScalar=']:
            self.assertIn(part, applied[0])

    def test_key_modifiers_required(self):
        lua = self.n.peers['A']
        lua.globals().emit('OnKeyPressed', 8)
        self.assertFalse(self.n.queue)
        self.assertEqual(lua.globals().Z.writes, 0)

    def test_transport_error_is_explicit_stop(self):
        self.n.peers['S'].execute('function sendServerCommand(...) error("mock send error") end')
        self.n.set('Sprinter')
        s = self.n.peers['S'].globals().B47AHProof.ServerState
        self.assertEqual(s.reason, 'server-send-error')
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)

    def test_duplicate_admin_intent_does_not_dispatch_again(self):
        self.n.peers['A'].globals().B47AHProof.set('Sprinter')
        original = self.n.queue[0]
        self.n.flush()
        self.n.queue.append(original)
        self.n.flush()
        s = self.n.peers['S'].globals().B47AHProof.ServerState
        self.assertEqual(s.counts.duplicates, 1)
        self.assertEqual(s.counts.accepted, 1)
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 1)

    def test_other_admin_cannot_take_over_selected_session(self):
        self.n.peers['S'].execute('function players.B:getAccessLevel() return "admin" end')
        self.n.peers['B'].globals().B47AHProof.set('Sprinter')
        self.n.flush()
        self.assertEqual(self.n.peers['A'].globals().Z.writes, 0)

    def test_layout_require_case_and_lua_only_boundaries(self):
        root = LUA.parents[1]
        metadata = dict(line.split('=', 1) for line in (root / 'mod.info').read_text().splitlines() if '=' in line)
        self.assertEqual(metadata['id'], 'B47ANCEDActiveHoursSpeedProof')
        self.assertTrue((root.parent / 'common').is_dir())
        files = list(LUA.rglob('*.lua'))
        self.assertEqual(len(files), 3)
        for path in files:
            text = path.read_text(encoding='utf-8')
            self.assertIsNone(re.search(
                r'\b(makeInactive|DoZombieStats|doZombieSpeed|doSprinter|doShambler|doFastShambler|'
                r'getZombieList|getZombieInfo|setOwner|setHealth)\s*\(', text), str(path))
            self.assertIsNone(re.search(r'SandboxVars[^\n]*=(?!=)', text.replace('==', '')), str(path))
            for module in re.findall(r'require\s+"([^"]+)"', text):
                self.assertTrue((LUA / 'shared' / (module + '.lua')).is_file())
        paths = [str(f.relative_to(root.parent)).lower() for f in root.parent.rglob('*') if f.is_file()]
        self.assertEqual(len(paths), len(set(paths)))
        self.assertFalse(list(root.parent.rglob('*.jar')))
        self.assertFalse(list(root.parent.rglob('*.java')))

    def test_enrollment_send_error_stops_without_writes(self):
        n = Network()
        n.peers['S'].execute('function sendServerCommand(...) error("mock enroll error") end')
        n.peers['A'].globals().B47AHProof.select(7)
        n.flush()
        s = n.peers['S'].globals().B47AHProof.ServerState
        self.assertEqual(s.reason, 'enrollment-send-error')
        self.assertEqual(n.peers['A'].globals().Z.writes, 0)


if __name__ == '__main__':
    unittest.main()
