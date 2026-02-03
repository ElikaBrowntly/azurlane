local huangdou = fk.CreateSkill {
  name = "yyfy_huangdou",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable{
  ["yyfy_huangdou"] = "黄豆",
  [":yyfy_huangdou"] = "持恒技，你每失去一张牌，随机发送一个小黄豆表情。",
}

huangdou:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 随机生成一个0到58的数字
    local randomIndex = math.random(0, 58)
    local emojiString = "{emoji" .. randomIndex .. "}"
    -- 发言
    player:chat(emojiString)
  end,
})

return huangdou