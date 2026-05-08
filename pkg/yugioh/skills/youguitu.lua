local tu = fk.CreateSkill {
  name = "yyfy_tu",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_tu"] = "幽鬼兔",
  [":yyfy_tu"] = "持恒技，正面朝上的敌方角色发动技能时，你可以令其失去该技能。",
}

local F = require "packages.hidden-clouds.functions"

tu:addEffect(fk.SkillEffect, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target and player and F.isEnemy(player, target) and data.skill.name ~= self.name and
        player:hasSkill(self.name) and table.contains(target:getSkillNameList(), data.skill.name)
        and target.faceup and data.skill.name ~= tu.name
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = tu.name,
      prompt = "幽鬼兔：你可以令其失去此次发动的技能"
    })
  end,
  on_use = function(self, event, target, player, data)
    local name = data.skill:getSkeleton() and data.skill:getSkeleton().name or data.skill.name
    if not name then return end
    player.room:handleAddLoseSkills(target, "-"..name)
  end,
})

return tu