local hezhong = fk.CreateSkill{
  name = "yyfy_hezhong",
}

Fk:loadTranslationTable{
  ["yyfy_hezhong"] = "和衷",
  [":yyfy_hezhong"] = "你于回合外失去牌后，摸1张牌。每回合限2次，你使用的基本牌或普通锦囊牌可以额外结算一次。",

  ["@yyfy_hezhong-turn"] = "和衷",

  ["$yyfy_hezhong1"] = "家和而万事兴，国亦如是。",
  ["$yyfy_hezhong2"] = "你我同殿为臣，理当协力齐心。",
}

hezhong:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player and player:hasSkill(hezhong.name) and type(data) == "table"
    and player.room.current ~= player then
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
    player:drawCards(1, hezhong.name)
  end,
})

hezhong:addEffect(fk.CardUsing, {
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and #data.tos > 0 and (data.card:isCommonTrick()
    or data.card.type == Card.TypeBasic and data.card.name ~= "jink")
    and player:getMark("yyfy_hezhong-turn") < 2 and player:hasSkill(self)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = hezhong.name,
      prompt = "和衷：你可以令此牌多结算一次"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "yyfy_hezhong-turn")
    data.additionalEffect = (data.additionalEffect or 0) + 1
  end,
})

return hezhong