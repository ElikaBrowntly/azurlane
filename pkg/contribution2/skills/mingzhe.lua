local hezhong = fk.CreateSkill {
  name = "yyfy_mingzhe",
}

Fk:loadTranslationTable {
  ["yyfy_mingzhe"] = "明哲",
  [":yyfy_mingzhe"] = "你失去牌后，可以摸1张牌。",

  ["$yyfy_mingzhe1"] = "明以洞察，哲以保身。",
  ["$yyfy_mingzhe2"] = "塞翁失马，焉知非福。",
  ["$yyfy_mingzhe3"] = "明哲维天，临君下土，贵者莫若天子。",
  ["$yyfy_mingzhe4"] = "知事为明智，明智则能有所作为。"
}

hezhong:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (player and player:hasSkill(hezhong.name) and type(data) == "table") then return false end
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, hezhong.name)
  end,
})

return hezhong