local difu = fk.CreateSkill {
  name = "yyfy_difu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["yyfy_difu"] = "敌缚",
  [":yyfy_difu"] = "锁定技，若你有“幻利”牌：①当你造成伤害时，受伤角色用所有手牌与这些牌交换；" ..
      "②当你受到伤害时，你用这些牌和伤害来源所有手牌交换。",

  ["$yyfy_difu1"] = "哈哈哈哈哈哈哈哈！",
  ["$yyfy_difu2"] = "伯符，且看我这一手！",
}

local spec = function(self, event, target, player, data)
  local tos = { data.from, data.to }
  if #tos ~= 2 then return end
  table.removeOne(tos, player)
  if #tos ~= 1 then return end
  local cards1 = player:getTableMark("yyfy_huanli-turn")
  local cards2 = tos[1]:getCardIds("h") or {}
  player.room:swapCards(player, {
    { player, cards1 },
    { tos[1], cards2 }
  }, difu.name, Card.PlayerHand)
end

difu:addEffect(fk.DamageCaused, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to and data.to:isAlive()
        and #player:getTableMark("yyfy_huanli-turn") > 0
  end,
  on_use = spec
})

difu:addEffect(fk.DamageInflicted, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and data.from:isAlive()
        and #player:getTableMark("yyfy_huanli-turn") > 0
  end,
  on_use = spec
})

return difu