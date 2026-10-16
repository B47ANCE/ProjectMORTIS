Project Version: 0.1.0-dev.4

# Current Lua-only interpretation

The MORTIS diagnostic adds no production balance configuration. Its three manually requested fixed tiers and priority 20 are technical experiment inputs matching Nightfall API use, not hidden production policy. Vanilla Active Only=Both is read/validated, never written; vanilla Speed is recorded/unchanged. Dependencies: ProjectMORTIS and experienceWorks. See MORTIS_SPEED_PROOF.md. Future meaningful gameplay options remain server-authoritative sandbox settings.

Active/Inactive mean custom speed/behavior profiles, never native inactivity. Current 2026-10-14 policy requires server-authoritative sandbox settings for meaningful gameplay options. The earlier readable-Lua design below is historical and needs reconciliation before implementation; no configuration code exists. Core is neutral; both gameplay modules or vanilla ActiveOnly other than Both disable custom gameplay without changing sandbox values. Safe live restoration remains a blocker.

Weighted selection is server-side: one category is 100% and ignores endpoint allocation; two weights normalize proportionally (20/40 becomes 1/3, 2/3); three endpoints 10/40 leave middle 50. Reject invalid categories/order, nonfinite/negative/over-100 weights, endpoint totals above 100 and two zero weights. Precompute CDF once. Proposed stable policy: separate Active/Inactive category rolls per zombie life/config revision; native speed scalar stability and persistent identity remain UNKNOWN. No per-update rerolls. Final validator implementation and ignored-input behavior await the speed proof. No unsupported attribute option is functional merely because it is described below.

# Historical configuration contract (superseded interface policy)

Three selectable mods in one future Workshop item: B47ANCEDActiveHours (Core), B47ANCEDActiveHoursNight (depends on Core), B47ANCEDActiveHoursDay (depends on Core). Actual Build 42.21 dependency metadata is not yet verified. No runnable module/config files are shipped at this research gate.

Planned files: ActiveHours_Config.lua, NightActive_Config.lua, DayActive_Config.lua. The updated user handoff explicitly requests user-editable Lua configuration, overriding the framework preference against substituting Lua configuration for gameplay sandbox settings for these requested interfaces. Final sandbox integration/precedence must be documented; no stable IDs invented. Server loads and validates once; clients do not override server policy.

Core design: DebugLogging=false; WarnVanillaConflict=true. Core alone changes no gameplay. Module defaults WhenActive=Night or Day; accepted Night/Day/Both. ActiveSpeed=Sprinter, InactiveSpeed=Shambler, UseSpeedRange=false are requested target defaults, not currently functional controls. Unsupported dynamic attributes remain unavailable. Each eventual setting needs accepted values, default, applicability/ignored conditions, interactions and confusing examples in comments.

Weighted range requirements: reject unknown/reversed names and weights outside 0–100. One category gets 100% and ignores endpoint weights; no duplicate entries. Two categories normalize proportionally; 20/40 -> 1/3 and 2/3, zero/zero invalid. Three categories retain endpoint percentages and assign remainder to intermediate categories. Endpoint total above 100 is rejected under the handoff's explicit validation rule, including two-category inputs. One-category ignored weights must still be well-formed numeric values; final validation ordering needs a documented implementation contract. Use finite numbers, tolerance-aware totals and precomputed cumulative tables. Fixed settings are ignored when ranges enabled. Never reroll per update.

No invalid configuration may silently select an unrelated preset. Final curve bounds and options await measured native solar endpoints. No arbitrary network/poll/cache settings exposed.
