local weitong = fk.CreateSkill {
  name = "lan__weitong",
  tags = { Skill.Lord, Skill.Permanent },
}

Fk:loadTranslationTable{
  ["lan__weitong"] = "卫统",
  [":lan__weitong"] = "持恒技，主公技，若场上有存活的其他魏势力角色，则你的〖潜龙〗于游戏开始时获得的"..
  "道心值改为100点。其他魏势力角色回复体力时，你可以摸一张牌。",

  ["#lan__weitong-invoke"] = "卫统：是否要摸一张牌？",

  ["$lan__weitong1"] = "手无实权难卫统，朦胧成睡，睡去还惊。",
  ["$lan__weitong2"] = "可有爱卿愿助朕讨贼？",
  ["$lan__weitong3"] = "泱泱大魏，忠臣俱亡乎？",
}

weitong:addEffect(fk.HpRecover, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target ~= player and
      target.kingdom == "wei" and not target.dead
  end,
  on_cost = function (self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#lan__weitong-invoke"
    }) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
    player:broadcastSkillInvoke(self.name, math.random(2,3))
  end,
})

return weitong
