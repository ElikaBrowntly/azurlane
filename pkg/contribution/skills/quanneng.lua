local quanneng = fk.CreateSkill {
  name = "yyfy_quanneng",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["yyfy_quanneng"] = "权能",
  [":yyfy_quanneng"] = "持恒技，一名角色的回合开始时，你可以获得<a href='Verethragna'>乌鲁斯拉格纳十大化身</a>"..
  "</a>中的最多3个(不能选择上回合获得过的)，直到回合结束。",

  ["Verethragna"] = "<br><font color='red'>强风</font>：你与其他角色的距离-10，你使用牌无次数限制且无法被响应"..
  "<br><font color='#CC3131'>公牛</font>：你对其他角色造成的伤害改为其体力值"..
  "<br><font color='orange'>白马</font>：其他角色造成伤害后，你可以对其造成等量火焰伤害"..
  "<br><font color='yellow'>骆驼</font>：你受到伤害后回复等量体力"..
  "<br><font color='#93DB70'>山猪</font>：获得此化身时，令一名其他角色失去所有体力。若其死亡，视为你杀死了该角色。"..
  "<br><font color='green'>少年</font>：出牌阶段限一次，你可以选择一名其他角色，赐予其一个其他化身。其他角色受到另一名其他角色的伤害后，你可以赐予其一个其他化身。"..
  "<br><font color='cyan'>凤凰</font>：其他角色与你的距离+10，你不是其他角色使用牌的合法目标。此化身结束时，你失去1点体力。"..
  "<br><font color='blue'>牡羊</font>：限定技，你死亡时改为修整一回合"..
  "<br><font color='indigo'>山羊</font>：其他角色发动技能时，你可征求全场的意见，然后令一名其他角色失去X点体力(X为同意的人数)"..
  "<br><font color='purple'>战士</font>：获得此化身时，你可以令一名其他角色失去所有技能直到你的回合结束",

  ["#yyfy_quanneng_trigger"] = "权能：是否发动〖权能〗？从10个技能中选择至多3个",
  ["#yyfy_quanneng_choose"] = "权能：请选择至多3个技能（不可选择上回合获得过的）",
  
  -- 子技能名称翻译
  ["yyfy_qiangfeng"] = "强风",
  ["yyfy_gongniu"] = "公牛",
  ["yyfy_baima"] = "白马",
  ["yyfy_luotuo"] = "骆驼",
  ["yyfy_shanzhu"] = "山猪",
  ["yyfy_shaonian"] = "少年",
  ["yyfy_fenghuang"] = "凤凰",
  ["yyfy_muyang"] = "牡羊",
  ["yyfy_shanyang"] = "山羊",
  ["yyfy_zhanshi"] = "战士",
}

-- 所有可选择的技能列表
local all_skills = {
  "yyfy_qiangfeng", "yyfy_gongniu", "yyfy_baima", "yyfy_luotuo", "yyfy_shanzhu",
  "yyfy_shaonian", "yyfy_fenghuang", "yyfy_muyang", "yyfy_shanyang", "yyfy_zhanshi"
}

quanneng:addEffect(fk.TurnStart, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(quanneng.name) and player:isAlive()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#yyfy_quanneng_trigger",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 获取上回合获得的化身
    local last_round_skills = {}
    local last_skills_mark = player:getMark("yyfy_quanneng_last") or ""
    if last_skills_mark ~= "" then
      for skill_name in string.gmatch(last_skills_mark, "([^,]+)") do
        table.insert(last_round_skills, skill_name)
      end
    end
    -- 排除上回合获得过的化身
    local available_skills = {}
    for _, skill_name in ipairs(all_skills) do
      if not table.contains(last_round_skills, skill_name) then
        table.insert(available_skills, skill_name)
      end
    end
    -- 如果所有技能都不可选，则无法发动
    if #available_skills == 0 then
      room:sendLog{
        type = "#yyfy_quanneng_no_available",
        from = player.id,
        arg = "yyfy_quanneng",
      }
      return false
    end
    -- 让玩家选择至多3个技能
    local chosen_skills = room:askToChoices(player, {
        choices = available_skills,
        min_num = 0,
        max_num = 3,
        prompt = "#yyfy_quanneng_choose"
    })
    -- 如果没选择技能，则不发动
    if not chosen_skills or #chosen_skills == 0 then return false end
    -- 记录当前回合获得的技能
    local current_skills_str = table.concat(chosen_skills, ",")
    room:setPlayerMark(player, "yyfy_quanneng_current", current_skills_str)
    -- 记录选择的技能作为下回合的限制
    room:setPlayerMark(player, "yyfy_quanneng_last", current_skills_str)
    -- 记录当前回合的目标角色
    room:setPlayerMark(player, "yyfy_quanneng_target", target.id)
    -- 获得选择的技能
    for _, skill_name in ipairs(chosen_skills) do
      room:handleAddLoseSkills(player, skill_name)
    end
    -- 记录选择的技能数量
    room:setPlayerMark(player, "yyfy_quanneng_count", #chosen_skills)
    return true
  end,
})

-- 回合结束时失去技能和体力
quanneng:addEffect(fk.TurnEnd, {
  anim_type = "negative",
  can_trigger = function(self, event, target, player, data)
    -- 检查是否是技能持有者记录的回合目标
    if player:getMark("yyfy_quanneng_current") then
      return target.id == player:getMark("yyfy_quanneng_target")
    end
    return false
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 如果主视角的〖战士〗标记记录了其他角色和技能，则先恢复对方失去的技能
    if data.who == player and player:getMark("yyfy_zhanshi_target") ~= 0 then
      local lostSkills = player:getTableMark("yyfy_zhanshi_skills")
      local lostTarget = room:getPlayerById(player:getMark("yyfy_zhanshi_target"))
      if #lostSkills > 0 then -- 不用判断失去技能的人是否存活，因为对方修整时也需要归还
        room:handleAddLoseSkills(lostTarget, lostSkills)
      end
      room:setPlayerMark(player, "yyfy_zhanshi_target", 0) -- 清空这些标记，以便下一次记录
      room:setPlayerMark(player, "yyfy_zhanshi_skills", 0)
    end
    -- 获取当前回合获得的技能
    local current_skills_str = player:getMark("yyfy_quanneng_current")
    local chosen_skills = {}
    if current_skills_str ~= "" then
      for skill_name in string.gmatch(current_skills_str, "([^,]+)") do
        table.insert(chosen_skills, skill_name)
      end
    end
    -- 获取选择的技能数量
    local skill_count = player:getMark("yyfy_quanneng_count") or 0
    -- 失去技能
    if #chosen_skills > 0 then
      for _, skill_name in ipairs(chosen_skills) do
        room:handleAddLoseSkills(player, "-" .. skill_name)
      end
    end
    -- 清除标记（保留yyfy_quanneng_last作为下回合的限制）
    room:setPlayerMark(player, "yyfy_quanneng_current", 0)
    room:setPlayerMark(player, "yyfy_quanneng_target", 0)
    room:setPlayerMark(player, "yyfy_quanneng_count", 0)
  end,
})

return quanneng