local tangshangqiamu = fk.CreateSkill{
  name = "yyfy_tangshangqiamu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_tangshangqiamu"] = "堂上启阿母",
  [":yyfy_tangshangqiamu"] = "锁定技，准备阶段，你摸三张牌，拜一名其他女性角色为“阿母”。",

  ["#yyfy_tangshangqiamu-mother"] = "堂上启阿母：拜一名女性角色为“阿母”",
  ["@@yyfy_tangshangqiamu_mother"] = "阿母",

  ["$yyfy_tangshangqiamu"] = "吕布飘零半生，只恨未逢明主，公若不弃，布愿拜为义父！",
}

tangshangqiamu:addLoseEffect(function (self, player, is_death)
  local room = player.room
  for _, id in ipairs(player:getTableMark(tangshangqiamu.name)) do
    local mother = room:getPlayerById(id)
    if not table.find(room.alive_players, function (p)
      return p:hasSkill(self.name) and not table.contains(p:getTableMark(tangshangqiamu.name), mother.id)
    end) then
      room:setPlayerMark(mother, "@@yyfy_tangshangqiamu_mother", 0)
    end
    room:setPlayerMark(player, tangshangqiamu.name, 0)
  end
end)

tangshangqiamu:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(3, tangshangqiamu.name)
    local mothers = table.filter(room:getOtherPlayers(player, false), function (p)
      return p:isFemale() and not table.contains(player:getTableMark(tangshangqiamu.name), p.id)
    end)
    if #mothers == 0 then return end
    local mother = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = mothers,
      skill_name = tangshangqiamu.name,
      prompt = "#yyfy_tangshangqiamu-mother",
      cancelable = false,
    })[1]
    room:setPlayerMark(mother, "@@yyfy_tangshangqiamu_mother", 1)
    room:addTableMark(player, tangshangqiamu.name, mother.id)
  end,
})

return tangshangqiamu