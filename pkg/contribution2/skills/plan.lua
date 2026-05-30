local plan = fk.CreateSkill {
  name = "yyfy_plan",
}

Fk:loadTranslationTable {
  ["yyfy_plan"] = "计划",
  [":yyfy_plan"] = "一名角色的回合开始时，你可以从三个“<a href='yyfy_shimingji'>使命技</a>”中选择一个令其获得。",

  ["yyfy_shimingji"] = "<b>使命技</b><br>始计篇-信包最先提出的概念，技能的前半部分为普通技能（可以没有，普通技能部分存在" ..
      "强制发动和可选择发动两种类型），后半部分为<b>使命成功</b>与<b>使命失败</b>的条件与对应效果，使命技类似觉醒技，" ..
      "在使命成功或失败之后永远都会失去此技能。<br>使命技目前分为以下几种分支:<br>使命成功+使命失败：<br>" ..
      "（1）王凌<br>" ..
      "普通技能+使命成功+使命失败：<br>" ..
      "（2）神太史慈<br>" ..
      "（3）糜夫人<br>" ..
      "（4）谋诸葛亮<br>" ..
      "（5）周处<br>" ..
      "（6）势魏延<br>" ..
      "普通技能+使命失败：<br>（7）谋孙尚香",
  
  ["$yyfy_plan1"] = "博览群书，融会贯通。",
  ["$yyfy_plan2"] = "博览于文，约之以礼。",
}

plan:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    if not (player and player:hasSkill(self)) then return false end
    local skills = {}
    for _, general in ipairs(Fk:getAllGenerals()) do
      for _, skName in ipairs(general:getSkillNameList(true)) do
        local skill = Fk.skills[skName]
        if skill then
          if skill:hasTag(Skill.Quest) and not
          table.contains(player.room:getBanner(plan.name) or {}, skName) then
            table.insertIfNeed(skills, skill.name)
            if #skills == 10 then
              break
            end
          end
        end
      end
      if #skills == 10 then
        break
      end
    end
    if #skills > 3 then
      skills = table.random(skills, 3)
    end
    if #skills > 0 then
      event:setCostData(self, {skills = skills})
      return true
    end
  end,
  on_cost = function (self, event, target, player, data)
    local skills = (event:getCostData(self) or {}).skills
    local choice = player.room:askToChoice(player, {
      choices = skills,
      cancelable = true,
      detailed = true,
      prompt = "计划：你可以令其获得一个使命技"
    })
    if choice and choice ~= "Cancel" then
      event:setCostData(self, {skill = choice})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local skill = (event:getCostData(self) or {}).skill
    local banner = room:getBanner(plan.name) or {}
    table.insertIfNeed(banner, skill)
    room:setBanner(plan.name, banner)
    player.room:handleAddLoseSkills(target, skill, plan.name)
  end
})

return plan