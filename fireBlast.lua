--声明技能
fireBlast = class({})

--modifier_fireBlast

LinkLuaModifier("modifier_fireBlast", "fireBlast", LUA_MODIFIER_MOTION_NONE)

function fireBlast:OnSpellStart()
	--获得施法者
	local caster = self:GetCaster()
	--获取鼠标目标
	local target = self:GetCursorTarget()
	--获取伤害数值
	local damage = self:GetSpecialValueFor("spell_damage")
	--获取眩晕数值
	local stuntime = self:GetSpecialValueFor("stun_time")
	--获得施法者属性计算伤害
	damage = caster:GetAgility()*100

	--创建伤害信息表
	local damagetable = {
		victim = target,
		attacker = caster,
		damage = damage,
		--伤害类型，魔法/物理/纯粹
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damagetable)

	--AddNewModifier(施法者， buff技能是什么self， 修饰器名称， {duration = 2})
	target:AddNewModifier(caster, self, "modifier_fireBlast" , {duration = stuntime})

	local particle = "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_fireblast.vpcf"
	--特效管理器，创建一个特效（传入特效文件， 特效作用位置， 作用目标）
	ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, target)
	particle = "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_fireblast_cast.vpcf"
	ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, target)

	caster:EmitSound("fireblast_cast")
end

-------------------------------------------------
--声明修饰器
modifier_fireBlast = class({})
--new一个buff
function modifier_fireBlast:IsDebuff()
	return true
end
--new一个眩晕buff
function modifier_fireBlast:IsStunDebuff()
	return true
end
--给目标一个状态
function modifier_fireBlast:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

-----------------------------------------------------

--声明动作替换
function modifier_fireBlast:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
	return funcs
end
--与载入眩晕动画
function modifier_fireBlast:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end
--眩晕动画显示绑点
function modifier_fireBlast:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
--替换原来动画
function modifier_fireBlast:GetOverrideAnimation( params )
	return ACT_DOTA_DISABLED
end

--用lua配合数据驱动实现技能
function damage( keys )
	local caster = keys.caster
	local target = keys.target
	local damage = caster:GetAgility()

	local position = caster:GetCursorPosition()
	DebugDrawText(position, "火焰爆轰", true, 0.8)

	local damagetable = {
		victim = target,
		attacker = caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
	}
	ApplyDamage(damagetable)
end