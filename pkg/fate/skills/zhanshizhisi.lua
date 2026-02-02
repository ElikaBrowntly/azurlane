local zhanshizhisi = fk.CreateSkill {
  name = "fate_zhanshizhisi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["fate_zhanshizhisi"] = "战士之司",
  [":fate_zhanshizhisi"] = "锁定技，游戏开始时，你的出牌时间+5秒。",
}

zhanshizhisi:addEffect(fk.GameStart, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self.name)
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local banner = room:getBanner("Timeout") or {}
    -- 获取当前出牌时间（如果不存在则使用房间默认值）
    local currentTimeout = banner[tostring(player.id)]
    if not currentTimeout then
      -- 如果没有设置过，则使用房间的默认出牌时间
      currentTimeout = room.timeout or 30
    end
    -- 增加5秒
    banner[tostring(player.id)] = currentTimeout + 5
    room:setBanner("Timeout", banner)
  end,
})

return zhanshizhisi