local bingfeng = fk.CreateSkill {
  name = "yyfy_bingfeng",
}

Fk:loadTranslationTable {
  ["yyfy_bingfeng"] = "冰封",
  [":yyfy_bingfeng"] = "当你对其他角色造成伤害时，你摸一张牌，若受伤角色体力值不大于你，你可令其不能使用或打出一种颜色的牌直到其回合结束。",

  ["@yyfy_bingfeng"] = "冰封",
  ["#yyfy_bingfeng"] = "冰封：你可以令%dest不能使用或打出一种颜色的牌",
  ["$yyfy_bingfeng1"] = "你确定它被冻在梦里了吗？",
  ["$yyfy_bingfeng2"] = "看看是谁来救你了"
}

bingfeng:addEffect(fk.DamageCaused, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to ~= player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    room:drawCards(player, 1, bingfeng.name)
    local mark = to:getTableMark("@yyfy_bingfeng")
    if player.dead or to.dead or to.hp > player.hp or #mark == 2 then return end
    local all = { "红色牌", "黑色牌" }
    local choices = table.simpleClone(all)
    if table.contains(mark, "红") then
      table.removeOne(choices, "红色牌")
    end
    if table.contains(mark, "黑") then
      table.removeOne(choices, "黑色牌")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      all_choices = all,
      cancelable = true,
      prompt = "#yyfy_bingfeng::"..to.id,
      skill_name = bingfeng.name
    })
    if not choice or choice == "Cancel" then return end
    room:addTableMark(to, "@yyfy_bingfeng", choice[1])
  end
})

bingfeng:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    local mark = player:getTableMark("@yyfy_bingfeng")
    return
        card.color == Card.Red and table.contains(mark, "红") or
        card.color == Card.Black and table.contains(mark, "黑")
  end,
  prohibit_response = function(self, player, card)
    local mark = player:getTableMark("@yyfy_bingfeng")
    return
        card.color == Card.Red and table.contains(mark, "红") or
        card.color == Card.Black and table.contains(mark, "黑")
  end,
})

bingfeng:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return player and player:hasSkill(self) and target ~= player and #target:getTableMark("@yyfy_bingfeng") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(target, "@yyfy_bingfeng", 0)
  end
})

return bingfeng