# Persistent staged wounds

Status: repository implementation, not deployed or multiplayer-certified.

`Mortis.Trauma.promote(entity, context)` adds an authority-owned, idempotent
promotion interface alongside existing additive `Mortis.Trauma.apply`.

Required context:

```lua
{
    region = "leftArm",       -- canonical species region or supported alias
    woundId = "Consumer.WoundType",
    stage = 2,                -- positive integer, monotonically increasing
    magnitude = 80,            -- CUMULATIVE channel trauma, not HP or per-call damage
    channel = "burn",          -- existing registered trauma channel
}
```

Values above illustrate the API, not balance defaults. Optional ordinary trauma
context (source, attacker, transmit, etc.) follows `Trauma.apply`.

Each anatomical region persists named wounds containing stage, cumulative
magnitude and channel. A higher stage applies only the increase in magnitude
through the existing trauma-channel and anatomical consequence calculation.
Repeating an equal/lower stage succeeds with `unchanged=true` and does not publish
trauma effects again, including after anatomy reconstruction. Higher-stage
requests cannot lower cumulative magnitude or change a wound's channel.

Regional trauma and wound records are saved together before consequence events.
If local persistence fails, both are rolled back and no consequences are emitted.
This ordering also applies to additive `Trauma.apply`. Non-finite magnitudes and
structural overflow are rejected. Old anatomy saves without wounds initialize an
empty wound map; supported wound records survive anatomy restore.

The API does not choose UV thresholds, clothing protection, radiation dose,
hibernation, healing, burn artwork or zombie types. Nightfall owns UV policy and
must not equate dose with channel magnitude. Critical-region destruction still
dispatches existing generalized consequence callbacks; it does not introduce an
unverified native zombie BodyDamage mutation.

## Integration boundaries

- Client promotion attempts are rejected. Host tests exercise this authority
  gate; they do not prove network transport/reconnect synchronization.
- `transmit=true` uses the existing anatomy transmission mechanism; transport
  delivery is not a local persistence transaction or a certified MP guarantee.
- Consumers must commit dose only in coordination with successful wound updates.
  This API provides one-region transactions, not an atomic multi-region batch.
- Native body-part rendering, environmental occlusion and persistent dose remain
  separate work. Do not enable Nightfall's new UV pipeline on this API alone.

Regression coverage: `tests/test_wound_promotion.lua` tests localization,
cumulative deltas, replay after reload, client rejection, persistence rollback,
post-commit callbacks, critical-destruction transition and invalid magnitudes.

## Progressive functional view

`Mortis.AnatomyCapabilities.functionalSnapshot(entity)` opt-in scales each
available natural region's capability contribution by remaining/max integrity.
Disabled, destroyed or detached regions contribute zero. Installed attachment
contributions retain their existing rules. The result includes intact natural
`baseline`, per-region `regionFunction`, and sorted `criticalDestroyed` IDs.
These are factual/anatomical inputs to consumer policy, not automatic movement
changes or a death command. The existing `snapshot`/`get` binary capability
behavior remains unchanged. Linear integrity weighting is an initial generalized
model, not a claim about medical physiology. Invalid integrity rejects the
functional snapshot instead of propagating NaN into movement calculations.

Movement integration audit: `LocomotionOverrides` selects named owners by priority;
Nightfall currently uses BaseSpeed, UVSlow and FeralSprint owners. Releasing and
clearing owners now enforce the same authority gate as acquisition, before native
restoration or request mutation. Nil entities/owners, malformed definitions and
non-finite priorities reject without changing the active owner stack. Injury
policy integration remains pending; this fixes the prerequisite authority boundary
without silently changing Nightfall's current movement priorities.

Installed native locomotion audit: `IsoZombie.DoZombieSpeeds(float)` initializes
speed with random variation, changes walk variant and adjusts animation-frame
state. It is not a deterministic multiplier of the current movement speed.
Repeated injury scaling must not call this initializer. The existing profile
adapter retains legacy behavior but now rejects NaN/infinite inputs before native
calls. Tier setters also choose native variants, so any injury tier change must
be signature-gated and composed with current owners, not reasserted every tick.
`IsoZombie.getSpeedType()` exists in the inspected class (1 sprinter, 2 fast
shambler, 3 shambler); native Lua binding verification remains required before
depending on that getter for baseline restoration. Planned injury handling should
use a restrictive tier ceiling so it cannot accelerate a zombie already slowed
by another owner.

`LocomotionOverrides.setCeiling(entity, owner, tier)` and `releaseCeiling` now
implement that constraint. The most restrictive active ceiling limits the winning
ordinary tier request, regardless of its priority. A slower request is preserved.
Unchanged effective requests do not repeat native speed initialization. Removing
a ceiling restores the still-active owner; clearing removes both request kinds.
Where no tier request exists, the adapter probes native baseline speed type and
rejects unknown baselines. Custom walk-type requests cannot be safely ordered and
are rejected while a ceiling applies. Failed application restores request records
(not a guarantee of rollback of a partially failed native engine call).
All operations are authority-gated. Nightfall injury policy has not enabled these
ceilings in live gameplay yet; native/in-game validation remains outstanding.

## Systemic critical failure

`Mortis.SystemicTrauma.resolveCriticalFailure(entity, {allowDeath=true})` now
provides an explicit generalized infected-only consequence. It requires committed
anatomy and a destroyed/detached critical region before requesting native health
zero through the existing combat adapter. Noncritical limb injury alone does not
qualify. Authority, entity kind and explicit policy permission are checked first;
the setter result is read back and already-zero health is idempotent.

This is trauma-to-systemic-failure, not irradiance-to-HP damage. No default event
handler invokes it and no sunlight/artificial policy lives in MORTIS. Nightfall
must supply its source-specific permission; that integration is unfinished. Native
death/corpse callbacks remain engine-owned. Health-zero readback is not proof of
correct corpse creation, kill credit, multiplayer replication or in-game behavior.
