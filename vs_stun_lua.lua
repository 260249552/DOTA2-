vs_stun_lua = class({})

function vs_stun_lua:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local location = self:GetCursorPosition()

	if self.instance == nil then
		self.instance = 0
		self.jump_count = {}
		self.target = {}
	else
		self.instance = self.instance + 1
	end

	self.target[self.instance] = target
	self.jump_count[self.instance] = 4

	local info = {
		EffectName = "particles/econ/items/vengeful/vs_ti8_immortal_shoulder/vs_ti8_immortal_magic_missle.vpcf",
		Ability = self,
		iMoveSpeed = 500,
		Source = caster,
		Target = target,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_HITLOCATION,
	}

	ProjectileManager:CreateTrackingProjectile(info)
end



function vs_stun_lua:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	local current 
	--用于判断当前的技能是第几次
	for i=0,self.instance do
		if self.target[i] ~= nil then
			if self.target[i] == hTarget then
				current = i
			end
		end
	end

	--减少一次技能的计数
	self.jump_count[current] = self.jump_count[current] - 1

	--创建目标的hit记录
	if hTarget.hit == nil then
		hTarget.hit = {}
	end
	--对象已经被第几次技能命中了
	hTarget.hit[current] = true

	if self.jump_count[current] > 0 then
		local next_target

		--搜索范围函数(获取施法者队伍信息, 获取范围中心点, 技能本身self, 搜索范围, 作用与目标的队伍 双方/我方/敌方/中立, 添加单位 英雄 + 基础单位)
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), vLocation, self, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 1, false)

		--找到满足条件的对象
		for _,enemy in pairs(enemies) do
			if enemy ~= hTarget then
				if enemy.hit == nil then
					next_target = enemy
					break
				elseif enemy.hit[current] == nil then
					next_target = enemy
					break
				end
			end
		end

		--如果存在一个这样满足条件的目标，就发射投射物next_target	
		if next_target ~= nil then

			--将实例化对象进行修改
			self.target[current] = next_target

			local info = {
			EffectName = "particles/econ/items/vengeful/vs_ti8_immortal_shoulder/vs_ti8_immortal_magic_missle.vpcf",
			Ability = self,
			iMoveSpeed = 900,
			Source = hTarget,
			Target = next_target,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_HITLOCATION,
			}

			ProjectileManager:CreateTrackingProjectile(info)

		--如果没有下一个目标了就释放技能对象
		else
			self.target[current] = nil
		end
	--如果没有次数就释放技能对象内存
	else
		self.target[current] = nil
	end
end