local shanyang = fk.CreateSkill {
  name = "yyfy_shanyang",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_shanyang"] = "山羊",
  [":yyfy_shanyang"] = "其他角色发动技能时，你可征求全场的意见，然后令一名其他角色失去同意人数等量点体力。",
  ["#yyfy_shanyang-ask"] = "山羊：%dest1 想要令 %dest2 失去体力，你同意吗？",
  ["yyfy_shanyang_agree"] = "同意",
  ["yyfy_shanyang_disagree"] = "拒绝"
}

-- 监听其他角色使用技能
shanyang:addEffect(fk.SkillEffect, {
  is_delay_effect = true,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target and target ~= player and data.skill.name ~= self.name and
           player:hasSkill(self.name) and data.skill:isPlayerSkill(target)
  end,
  on_cost = function(self, event, target, player, data)
      local to = player.room:askToChoosePlayers(player, {
        targets = player.room:getAlivePlayers(),
        min_num = 1,
        max_num = 1,
        skill_name = self.name,
        prompt = "选择一名角色，让全场所有人审判他！"
      })
      if #to == 1 then
        event:setCostData(self, {tos = to})
        return true
      end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local from = player
    local choices = room:askToJointChoice(player, {
      players = room:getAlivePlayers(),
      choices = {"yyfy_shanyang_agree", "yyfy_shanyang_disagree"},
      prompt = "#yyfy_shanyang-ask:" .. from.id .. ":" .. to.id
    })
    local agreeCount = 0
    for _, p in ipairs(room:getAlivePlayers()) do
      if choices[p] == "yyfy_shanyang_agree" then
        room:notifySkillInvoked(p, choices[p], "support")
        agreeCount = agreeCount + 1
      else
        room:notifySkillInvoked(p, choices[p], "negative")
      end
    end
    -- 失去体力
    room:loseHp(to, agreeCount, self.name, from)
  end,
})

return shanyang