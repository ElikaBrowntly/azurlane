local shanli = fk.CreateSkill {
  name = "lan__shanli"
}

Fk:loadTranslationTable {
  ["lan__shanli"] = "擅立",
  [":lan__shanli"] = "准备阶段，你可令一名角色挑选一个主公技并获得。",

  ["$lan__shanli1"] = "行伊、霍之事，更天子而立。",
  ["$lan__shanli2"] = "今主不可承天下，另立新君可安邦。",
}

shanli:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and data.phase == Player.Start) then return false end
    local skills = {}
    for _, general in ipairs(Fk:getAllGenerals()) do
      for _, skName in ipairs(general:getSkillNameList(true)) do
        local skill = Fk.skills[skName]
        if skill then
          if skill:hasTag(Skill.Lord) then
            table.insertIfNeed(skills, skill.name)
          end
        end
      end
    end
    if #skills > 0 then
      event:setCostData(self, { skills = skills })
      return true
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local skills = (event:getCostData(self) or {}).skills
    local to = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(),
      max_num = 1,
      min_num = 1,
      skill_name = shanli.name,
      prompt = "擅立：请选择要获得技能的角色"
    })
    if #to ~= 1 then return end
    to = to[1]
    skills = table.filter(skills, function (s)
      return not to:hasSkill(s, true)
    end)
    local choice = room:askToCustomDialog(to, {
      skill_name = shanli.name,
      component = {
        url = "packages/utility/qml/ChooseSkillBox.qml",
        model = {
          url = "packages/utility/qml/models/ChooseSkillModel.qml",
          prop = {
            skills = skills,
            min = 1,
            max = 1,
            prompt = "擅立：请选择一个主公技获得",
            cancelable = false,
          }
        }
      },
    })
    if choice and choice ~= "" then
      event:setCostData(self, { skill = choice, tos = {to} })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skill = (event:getCostData(self) or {}).skill
    local to = (event:getCostData(self) or {}).tos[1]
    player.room:handleAddLoseSkills(to, skill, shanli.name)
  end
})

return shanli