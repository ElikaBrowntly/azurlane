local kongquan = fk.CreateSkill {
  name = "yyfy_kongquan",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["yyfy_kongquan"] = "控权",
  [":yyfy_kongquan"] = "转换技，一名角色的回合开始时，你可以令其，阳：执行一个额外的摸牌和出牌阶段；"
  .."阴：跳过摸牌和出牌阶段。",
  ["#yyfy_kongquan-yang"] = "控权：你可以令%dest执行一个额外的摸牌和出牌阶段",
  ["#yyfy_kongquan-yin"] = "控权：你可以令%dest跳过摸牌和出牌阶段"
}

kongquan:addEffect(fk.TurnStart, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(kongquan.name)
  end,
  on_cost = function(self, event, target, player, data)
    local state = player:getSwitchSkillState(kongquan.name, false, true)
    return player.room:askToSkillInvoke(player, {
      skill_name = kongquan.name,
      prompt = "#yyfy_kongquan-"..state.."::"..target.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local state = player:getSwitchSkillState(kongquan.name, true, true)
    if state == "yin" then
      player:chat("难道，相父真的要取而代之？")
      target:skip(Player.Draw)
      target:skip(Player.Play)
      return
    end
    player:chat("相父，全力北伐，还于旧都！")
    target:gainAnExtraPhase(Player.Draw, kongquan.name, false)
    target:gainAnExtraPhase(Player.Play, kongquan.name, false)
  end,
})

return kongquan