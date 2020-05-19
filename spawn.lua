local spawn_config = require("mod_spawn")

if MobSpawner == nil then
    MobSpawner = class({})
end

-- 启动刷怪逻辑
function MobSpawner:Start()
    -- 注册 Thinker
    GameRules:GetGameModeEntity():SetThink("OnThink", self)
    -- 初始化波数，当前第0波
    self.wave = 0
    self.nextTime = 0
end

-- 每1秒判断一次，时间到了就刷怪，然后停止这个 Thinker
function MobSpawner:OnThink()
    print(OnThink)
    -- 拿 Dota 时间
    local now = GameRules:GetDOTATime(false, true)
    if self.wave == 0 and now >= spawn_config.spawn_start_time then
        self:SpawnNextWave(now)
    elseif now >= self.nextTime and self.nextTime ~= 0 then
        self:SpawnNextWave(now)
    else
        nextTime = nil
    end
    if self.wave == 30 then
        return nil
    end
    return 1
end

-- 刷下一波怪
function MobSpawner:SpawnNextWave(now)
    self.wave = self.wave + 1
    local wave_info = spawn_config.waves[self.wave]
    self.nextTime = now + wave_info.spawn_interval
    if wave_info then
        for i = 1, wave_info.num do
            self:SpawnMob(wave_info.name, wave_info.location, wave_info.level, wave_info.path)
        end
    else
        print("game over!")
    end
end

-- 刷单个怪
function MobSpawner:SpawnMob(name, location, level, path)
    -- 找刷怪点实体
    local location_ent = Entities:FindByName(nil, location)
    -- 拿到刷怪点的坐标
    local position = location_ent:GetOrigin()
    -- 创建单位
    local mob = CreateUnitByName(name, position, true, nil, nil, DOTA_TEAM_BADGUYS)
    -- 设置怪物等级
    mob:CreatureLevelUp(level)
    if path then
        -- 设置怪物必须按路线走
        mob:SetMustReachEachGoalEntity(true)
        local path_ent = Entities:FindByName(nil, path)
        -- 设置怪物寻路的第一个路径点
        mob:SetInitialGoalEntity(path_ent)
    end
end