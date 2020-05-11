function lighting( keys )
	--搜索范围函数(获取施法者队伍信息, 获取范围中心点, 技能本身self, 搜索范围, 作用与目标的队伍 双方/我方/敌方/中立, 添加单位 英雄 + 基础单位)
	local enemies = FindUnitsInRadius(keys.caster:GetTeamNumber(), keys.target:GetOrigin(), self, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	CreateTempTree(keys.target:GetOrigin(), 2)
	for _,enemy in pairs(enemies) do
		local info = {
			EffectName = "particles/econ/items/vengeful/vs_ti8_immortal_shoulder/vs_ti8_immortal_magic_missle.vpcf",
			Ability = keys.ability,
			iMoveSpeed = 900,
			Source = keys.target,
			Target = enemy,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_HITLOCATION,
		}

		ProjectileManager:CreateTrackingProjectile(info)
		break
	end
end
