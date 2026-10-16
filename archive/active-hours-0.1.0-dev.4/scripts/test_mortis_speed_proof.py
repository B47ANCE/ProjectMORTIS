"""Portable offline boundary tests; framework/native behavior is mocked, never PZ proof."""
from pathlib import Path
import os
import unittest
from test_speed_proof import LuaRuntime, MOCK, plain

ROOT = Path(__file__).resolve().parents[1]
LUA = ROOT / 'proof/B47ANCEDActiveHoursMortisProof/42/media/lua'
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


class Peers:
    def __init__(self, prelude=''):
        self.queue = []
        self.peers = {}
        for side in ('S', 'A', 'B'):
            lua = LuaRuntime(unpack_returned_tuples=True)
            lua.globals().mode = side
            lua.execute(MOCK)
            lua.execute(FRAMEWORK)
            lua.execute(prelude)
            lua.globals().sendServerCommand = self.from_server
            lua.globals().sendClientCommand = self.from_client
            lua.execute((LUA / 'shared/B47AHMortisProof.lua').read_text())
            leaf = 'server/B47AHMortisProofServer.lua' if side == 'S' else 'client/B47AHMortisProofClient.lua'
            lua.execute((LUA / leaf).read_text())
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
        self.peers[side].globals().B47AHMortisProof.request(cmd, value)
        self.flush()

    def select(self):
        self.request('Select', 7)
        self.update()


class MortisProofTests(unittest.TestCase):
    def setUp(self):
        self.n = Peers()
        self.n.select()

    def server(self):
        return self.n.peers['S'].globals().B47AHMortisProof.Server

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
        self.n.peers['A'].globals().B47AHMortisProof.request('Set', 'sprinter')
        duplicate = self.n.queue[0]
        self.n.flush()
        self.n.queue.append(duplicate)
        self.n.flush()
        self.assertEqual(len(self.n.peers['S'].globals().frameworkCalls), 1)

    def test_stale_session_and_bad_tier_rejected(self):
        self.n.peers['A'].globals().B47AHMortisProof.Client.session = 'stale'
        self.n.request('Set', 'sprinter')
        self.assertEqual(self.server().counts.apiAccepted, 0)
        self.n.peers['A'].globals().B47AHMortisProof.Client.session = self.server().session
        self.n.request('Set', 'invalid')
        self.assertEqual(self.server().counts.apiAccepted, 0)

    def test_missing_api_fails_closed(self):
        n = Peers('Mortis=nil')
        n.select()
        n.request('Set', 'sprinter')
        self.assertEqual(n.peers['S'].globals().Z.writes, 0)

    def test_incompatible_api_fails_closed(self):
        n = Peers('incompatible=true')
        n.select()
        n.request('Set', 'sprinter')
        self.assertEqual(n.peers['S'].globals().Z.writes, 0)

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
        lua.globals().emit('OnServerCommand', 'B47AHMortisProof', 'Apply', lua.table_from({'tier': 'sprinter'}))
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

    def test_bounded_rings_and_duplicate_registration(self):
        self.n.update(1200)
        for _ in range(30):
            self.n.request('Set', 'invalid')
        self.assertEqual(len(self.server().samples), 16)
        self.assertEqual(len(self.server().results), 16)
        for side, lua in self.n.peers.items():
            leaf = 'server/B47AHMortisProofServer.lua' if side == 'S' else 'client/B47AHMortisProofClient.lua'
            lua.execute((LUA / leaf).read_text())
            self.assertEqual(len(lua.globals().Events.OnZombieUpdate.handlers), 1)


if __name__ == '__main__':
    unittest.main()
