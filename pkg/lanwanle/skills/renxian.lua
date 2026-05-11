local renxian = fk.CreateSkill {
  name = "lan__renxian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__renxian"] = "任贤",
  [":lan__renxian"] = "锁定技，你拥有〖<a href=':dlex__yingzi'>英姿</a>〗和〖<a href= ':dl__guzheng'>固政</a>〗。",
}

renxian:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  if not room:getBanner(renxian.name) then
    local skills = table.filter({"dlex__yingzi", "dl__guzheng"}, function (s)
      return Fk.skills[s] and not player:hasSkill(s, true)
    end)
    if #skills > 0 then
      room:setPlayerMark(player, renxian.name, skills)
      room:handleAddLoseSkills(player, table.concat(skills, "|"), nil, false, true)
    end
  end
end)

renxian:addLoseEffect(function (self, player, is_death)
  local room = player.room
  if player:getMark(renxian.name) ~= 0 then
    room:handleAddLoseSkills(player, "-"..table.concat(player:getTableMark(renxian.name), "|-"), nil, false, true)
    room:setPlayerMark(player, renxian.name, 0)
  end
end)

return renxian