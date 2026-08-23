local fuhui = fk.CreateSkill {
  name = "yyfy_fuhui",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable{
  ["yyfy_fuhui"] = "祓秽",
  [":yyfy_fuhui"] = "持恒技，防止你受到的非卡牌伤害。出牌阶段，你可以失去1点体力，令任意名角色的技能失效直到你的下回合开始。",

  ["@@yyfy_fuhui"] = "被祓秽"
}

fuhui:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and not data.card
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:preventDamage()
  end
})

fuhui:addEffect("active", {
  anim_type = "control",
  can_use = function (self, player)
    return player and player:hasSkill(self) and player.phase == Player.Play and player.hp > 0
  end,
  card_num = 0,
  target_filter = function (self, player, to_select, selected, selected_cards, card, extra_data)
    return to_select ~= player
  end,
  prompt = "祓秽：你可以失去一点体力，令任意名角色技能失效",
  feasible = function (self, player, selected, selected_cards, card)
    return #selected > 0
  end,
  on_use = function (self, room, data)
    if #data.tos == 0 then return end
    room:loseHp(data.from, 1, fuhui.name)
    for _, t in ipairs(data.tos) do
      room:setPlayerMark(t, "@@yyfy_fuhui", 1)
      t.tag[fuhui.name] = data.from.id
    end
  end
})

fuhui:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    return (from:getMark("@@yyfy_fuhui") > 0 or (from.tag[fuhui.name] or 0) ~= 0)and skill:isPlayerSkill(from)
  end,
})

fuhui:addEffect(fk.EventTurnChanging, {
  can_refresh = function(self, event, target, player, data)
    return data.to == player and player:hasSkill(self.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room:getAlivePlayers()) do
      if (p.tag[fuhui.name] or 0) == player.id then
        p.tag[fuhui.name] = 0
        room:setPlayerMark(p, "@@yyfy_fuhui", 0)
      end
    end
  end,
})

return fuhui