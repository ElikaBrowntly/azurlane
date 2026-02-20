local zhuanwu = fk.CreateSkill {
  name = "yyfy_zhuanwu_yukikaze",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["yyfy_zhuanwu_yukikaze"] = "专武",
  [":yyfy_zhuanwu_yukikaze"] = "锁定技，你使用【杀】造成伤害后，令其获得持续10回合的「进水」，"..
  "拥有此标记的角色每回合结束时失去1点体力。" ,

  ["@yyfy_jinshui"] = "进水",
  ["$yyfy_zhuanwu_yukikaze1"] = "不要命的话就放马过来吧！",
  ["$yyfy_zhuanwu_yukikaze2"] = "败者就赶紧给我消失吧，HO,HO,HO！"
}

zhuanwu:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash"
  end,
  on_trigger = function (self, event, target, player, data)
    player.room:setPlayerMark(data.to, "@yyfy_jinshui", 10)
  end
})

zhuanwu:addEffect(fk.TurnEnd, {
  mute = true,
  can_refresh = function (self, event, target, player, data)
    if not player:hasSkill(self, true, true) then return false end
    local tos = {}
    for _, p in ipairs(player.room:getAlivePlayers()) do
      if p:getMark("@yyfy_jinshui") > 0 then
        table.insert(tos, p)
      end
    end
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_refresh = function (self, event, target, player, data)
    local tos = event:getCostData(self).tos
    local room = player.room
    if tos == nil then return end
    for _, to in ipairs(tos) do
      room:notifySkillInvoked(to, "@yyfy_jinshui", "negative")
      room:loseHp(to, 1, zhuanwu.name)
      room:addPlayerMark(to, "@yyfy_jinshui", -1)
    end
  end
})

return zhuanwu