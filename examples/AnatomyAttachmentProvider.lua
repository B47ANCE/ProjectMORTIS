local Mortis = require "Mortis/init"

-- Development-only provider example. Consumer mods such as medWorks own real
-- inventory items, fitting procedures, knowledge requirements, and balance.
Mortis.registerAnatomyAttachment({
    id = "Example.LeftHook",
    providerId = "Example.AnatomyAttachments",
    displayName = "Example Left Hook",
    socketTypes = { "humanoid.leftHand" },
    compatibilityTags = { "prosthetic.hand.left" },
    capabilityModifiers = {
        ["grip.left"] = 0.20,
        ["manipulation.left"] = 0.15,
    },
})

-- Querying does not install anything. The socket is part of the topology from
-- entity creation and becomes available only when its natural-state rule is met.
-- local socket = Mortis.AnatomyAttachments.getSocket(entity, "leftHand", "distal")
-- local allowed, reason = Mortis.AnatomyAttachments.canAttach(
--     entity, "leftHand", "distal", "Example.LeftHook")
-- if allowed then
--     Mortis.AnatomyAttachments.attach(entity, "leftHand", "distal", "Example.LeftHook", {
--         operationId = "Example:procedure-instance-0001",
--         data = { fittingQuality = 0.65 },
--     })
-- end
