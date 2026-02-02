local shanzhu = fk.CreateSkill {
  name = "yyfy_shanzhu",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_shanzhu"] = "山猪",
  [":yyfy_shanzhu"] = "获得此技能时，令一名其他角色失去所有体力。若其死亡，视为你杀死了该角色。",
}

shanzhu:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  local to = room:askToChoosePlayers(player, {
    targets = room:getOtherPlayers(player),
    min_num = 1,
    max_num = 1,
    skill_name = self.name,
    prompt = "山猪：请选择一名其他角色，令其失去所有体力"
  })[1]
  room:notifySkillInvoked(player, self.name, "offensive")
  room:addTableMark(player, "yyfy_shanzhu_killer", to.id)
  room:loseHp(to, to.hp, self.name, player)
  if not to.dead then
    room:removeTableMark(player, "yyfy_shanzhu_killer", to.id)
  end
end)

shanzhu:addEffect(fk.Death, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    if player:isAlive() and player:hasSkill(self.name) then
      local mark = player:getTableMark("yyfy_shanzhu_killer")
      return table.contains(mark, target.id)
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data.killer = player
    player.room:removeTableMark(player, "yyfy_shanzhu_killer", target.id)
  end
})

return shanzhu