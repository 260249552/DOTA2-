vs_stun_value = class({})

LinkLuaModifier("modifier_vs_stun_value", "vs_stun_value", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vs_stun_value_continuous_damage", "vs_stun_value", LUA_MODIFIER_MOTION_NONE)

function vs_stun_value:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local location = self:GetCursorPosition()
	local info = {
		EffectName = "particles/econ/items/vengeful/vs_ti8_immortal_shoulder/vs_ti8_immortal_magic_missle.vpcf",
		Ability = self,
		iMoveSpeed = 900,
		Source = caster,
		Target = target,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_HITLOCATION,
	}

	ProjectileManager:CreateTrackingProjectile(info)
end



function vs_stun_value:OnProjectileHit( hTarget, vLocation )
		local target = hTarget
		local caster = self:GetCaster()
		local stuntime = self:GetSpecialValueFor("stun_time")
		local damage = self:GetSpecialValueFor("spell_damage")
	
		local damagetable = {
		victim = target,
		attacker = caster,
		damage = damage,
		--伤害类型，魔法/物理/纯粹
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	--ApplyDamage(damagetable)

	--AddNewModifier(施法者， buff技能是什么self， 修饰器名称， {duration = 2})
	target:AddNewModifier(caster, self, "modifier_vs_stun_value" , {duration = stuntime})
	--搜索范围函数(获取施法者队伍信息, 获取范围中心点, 技能本身self, 搜索范围, 作用与目标的队伍 双方/我方/敌方/中立, 添加单位 英雄 + 基础单位)
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetOrigin(), self, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	--判断施放范围是否有对象
	if #enemies > 0 then
		--解包
		for a,enemy in pairs(enemies) do
			--判断是否为空，是否魔法免疫，是否无敌
			if enemy ~= nil and (not enemy:IsMagicImmune()) and (not enemy:IsInvulnerable()) then
				--这里的enemy 等价于 target
				enemy:AddNewModifier(caster, self, "modifier_vs_stun_value_continuous_damage" , {duration = 10})
			end
		end
	end
end

---------------------------------------------------
--声明修饰器
modifier_vs_stun_value_continuous_damage = class({})
 
function modifier_vs_stun_value_continuous_damage:OnCreated()
	print('OnCreated')
	self.ApplyDamage = ApplyDamage
	--在修饰器中取到kv表中键值
	self.continous_damage = self:GetAbility():GetSpecialValueFor("continous_damage")
	--设置计时器
	self:StartIntervalThink(1)
	--启动计时器
	self:OnIntervalThink()
end

function modifier_vs_stun_value_continuous_damage:OnIntervalThink()
	local damagetable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = self.continous_damage,
		--伤害类型，魔法/物理/纯粹
		damage_type = DAMAGE_TYPE_PHYSICAL,
	}
	--print('=====================')
	--print(damagetable.damage)
	--print(damagetable.damage_type)
	if damagetable.damage_type then
		self.ApplyDamage(damagetable)
	end
end

function modifier_vs_stun_value_continuous_damage:IsDebuff()
	return true
end

--声明修饰器
modifier_vs_stun_value = class({})
--new一个buff
function modifier_vs_stun_value:IsDebuff()
	return true
end
--new一个眩晕buff
function modifier_vs_stun_value:IsStunDebuff()
	return true
end
--给目标一个状态
function modifier_vs_stun_value:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end
--声明动作替换
function modifier_vs_stun_value:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end
--与载入眩晕动画
function modifier_vs_stun_value:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end
--眩晕动画显示绑点
function modifier_vs_stun_value:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
--替换原来动画
function modifier_vs_stun_value:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end