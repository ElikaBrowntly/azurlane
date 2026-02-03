local yyfy_ex_shanli = fk.CreateSkill {
  name = "yyfy_ex_shanli",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["yyfy_ex_shanli"] = "擅立",
  [":yyfy_ex_shanli"] = "觉醒技，准备阶段，若你发动过【景略】和【败移】，" ..
  "你减1点体力上限并选择一名角色，你从随机三个带标签的技能中选择一个令其获得。",

  ["#yyfy_ex_shanli-ask"] = "擅立：选择一名角色，令其获得一个技能",
  ["#yyfy_ex_shanli-skill"] = "擅立：选择一个技能令 %src 获得",

  ["$yyfy_ex_shanli1"] = "行伊、霍之事，更天子而立。",
  ["$yyfy_ex_shanli2"] = "今主不可承天下，另立新君可安邦。",
}

yyfy_ex_shanli:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(yyfy_ex_shanli.name) and
      player:usedSkillTimes(yyfy_ex_shanli.name, Player.HistoryGame) == 0 and
      player.phase == Player.Start
  end,
  can_wake = function(self, event, target, player, data)
    return player:usedSkillTimes("yyfy_ex_jinglue", Player.HistoryGame) > 0 and
           player:usedSkillTimes("yyfy_ex_baiyi", Player.HistoryGame) > 0
  end,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = yyfy_ex_shanli.name
    local room = player.room
    room:changeMaxHp(player, -1)
    local to = room:askToChoosePlayers(
      player,
      {
        targets = room:getAlivePlayers(false),
        min_num = 1,
        max_num = 1,
        prompt = "#yyfy_ex_shanli-ask",
        skill_name = skillName,
        cancelable = false,
      }
    )[1]

    -- 收集所有带标签的技能
    local skills = {}
    local tag_list = {
      Skill.Lord,           -- 主公技
      Skill.Compulsory,     -- 锁定技
      Skill.Limited,        -- 限定技
      Skill.Wake,           -- 觉醒技
      Skill.Switch,         -- 转换技
      Skill.Quest,          -- 使命技
      Skill.Permanent,      -- 持恒技
      Skill.Hidden,         -- 隐匿技
      Skill.AttachedKingdom,-- 势力技
      Skill.Charge,         -- 蓄力技
      Skill.Family,         -- 宗族技
      Skill.Combo,          -- 连招技
      Skill.Rhyme,          -- 韵律技
      Skill.Force,          -- 奋武技
      Skill.Spirited,       -- 昂扬技
      Skill.Ambition,       -- 移志技
    }
    
    for _, general in ipairs(Fk:getAllGenerals()) do
      for _, skName in ipairs(general:getSkillNameList(true)) do
        local skill = Fk.skills[skName]
        if skill then
          -- 检查技能是否带有指定标签
          for _, tag in ipairs(tag_list) do
            if skill:hasTag(tag) then
              table.insertIfNeed(skills, skill.name)
              break
            end
          end
        end
      end
    end

    if #skills > 0 then
      -- 随机选择三个技能
      local selected_skills = table.random(skills, math.min(3, #skills))
      local choice = room:askToChoice(
        player,
        {
          choices = selected_skills,
          skill_name = skillName,
          prompt = "#yyfy_ex_shanli-skill:" .. to.id,
          detailed = true,
        }
      )

      room:handleAddLoseSkills(to, choice)
    end
  end,
})

return yyfy_ex_shanli