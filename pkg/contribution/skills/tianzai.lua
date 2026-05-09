local tianzai = fk.CreateSkill {
  name = "yyfy_tianzai",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_tianzai"] = "天灾",
  [":yyfy_tianzai"] = "持恒技，当你获得此技能时和游戏开始时，你可令一名角色获得“灾”标记，"..
  "拥有“灾”标记的角色发动技能前取消之。",

  ["@@yyfy_tianzai"] = "灾"
}

tianzai:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  local tos = room:askToChoosePlayers(player, {
    targets = room:getAlivePlayers(),
    min_num = 1,
    max_num = 1,
    skill_name = self.name,
    prompt = "天灾：你可以令一名角色获得“灾”标记",
    cancelable = true
  })
  if #tos ~= 1 then return end
  room:notifySkillInvoked(player, tianzai.name, "control")
  room:setPlayerMark(tos[1], "@@yyfy_tianzai", 1)
end)

tianzai:addEffect(fk.GameStart, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(),
      max_num = 1,
      min_num = 1,
      cancelable = true,
      prompt = "天灾：你可以令一名角色获得“灾”标记",
      skill_name = tianzai.name
    })
    if #tos == 1 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local tos = (event:getCostData(self) or {}).tos
    if not tos or #tos ~= 1 or tos[1].dead then return end
    player.room:setPlayerMark(tos[1], "@@yyfy_tianzai", 1)
  end
})

tianzai:addEffect(fk.SkillEffect, {
  can_refresh = function(self, event, target, player, data)
    if target and player and player:hasSkill(self, true, true) and target:getMark("@@yyfy_tianzai") > 0
    and table.contains(target:getSkillNameList(), (data.skill:getSkeleton() or {}).name)
    and (player.tag[tianzai.name] or 0) < 20 then
      local n = player.tag[tianzai.name] or 0
      player.tag[tianzai.name] = n + 1
      return true
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect)
    if e then
      e:shutdown()
    end
  end,
})

return tianzai