LinkLuaModifier("bomb_thinker", "bomb_lua.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

bomb= class({})

function bomb:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local team_id = caster:GetTeamNumber()
    local thinker = CreateModifierThinker(caster, self, "bomb_thinker", {}, point, team_id, false)
end

bomb_thinker = class({})

function bomb_thinker:OnCreated()

    self.startup_time = 3
    self:StartIntervalThink(self.startup_time)
end

function bomb_thinker:OnIntervalThink()
    local caster = self:GetParent()
    
    if self.startup_time ~= nil then
        self.startup_time = nil
        self:StartIntervalThink(0)

    elseif self.startup_time == nil then

        local enemies = FindUnitsInRadius(
                caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                600,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
                0,
                1,
                false)
        if #enemies > 0 then
            for i = 0, #enemies do
                local damage_info = {
                    victim = enemies[i],
                    attacker = caster,
                    damage = 400,
                    --伤害类型，魔法/物理/纯粹
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self
                }
                ApplyDamage(damage_info)
            end
            self:Destroy()
        end
    end
end
