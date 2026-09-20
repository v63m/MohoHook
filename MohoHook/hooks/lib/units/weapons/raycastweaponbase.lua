-- Applies the HexTrainer tracer setting to every player weapon as it is
-- created. Swaps the vanilla (barely visible) bullet trail effect for the
-- much brighter trail used by enemy sniper rifles.
local HT_TRACER_EFFECT = Idstring("effects/particles/weapons/sniper_trail")

Hooks:PostHook(RaycastWeaponBase, "init", "HT_RaycastWeaponBase_init_tracers", function(self, unit)
    if not (HT and HT.Dexterity and HT.Dexterity.enableTracers) then
        return
    end
    if not self._trail_effect_table then
        return
    end
    -- Player weapons only; enemy weapons keep their own visuals.
    if type(self.is_npc) == "function" and self:is_npc() then
        return
    end
    self._trail_effect_table.effect = HT_TRACER_EFFECT
end)
