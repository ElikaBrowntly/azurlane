local mingzhe = fk.CreateSkill {
  name = "yyfy_mingzhe",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_mingzhe"] = "明哲",
  [":yyfy_mingzhe"] = "锁定技，你失去牌后，摸等量张牌。",

  ["$yyfy_mingzhe1"] = "明以洞察，哲以保身。",
  ["$yyfy_mingzhe2"] = "塞翁失马，焉知非福。",
  ["$yyfy_mingzhe3"] = "明哲维天，临君下土，贵者莫若天子。",
  ["$yyfy_mingzhe4"] = "既明且哲，以保其身，夙夜匪懈，以事一人。"
}

mingzhe:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (player and player:hasSkill(mingzhe.name) and type(data) == "table") then return false end
    local n = 0
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            n = n + 1
          end
        end
      end
    end
    if n == 0 then return false end
    event:setCostData(self, {num = n})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local num = (event:getCostData(self) or {}).num or 0
    player:drawCards(num, mingzhe.name)
  end,
})

return mingzhe