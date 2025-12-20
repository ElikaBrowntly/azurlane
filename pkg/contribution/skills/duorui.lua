local duorui = fk.CreateSkill {
  name = "yyfy_duorui",
}

local D = require "packages.danganronpa.record.DRRP"

Fk:loadTranslationTable{
  ["yyfy_duorui"] = "夺锐",
  [":yyfy_duorui"] = "当你对一名其他角色造成伤害后，你可以获得其一个技能，然后可以令其失去该技能",

  ["#yyfy_duorui-choose"] = "夺锐：是否获得 %dest 的一个技能？",
  ["#yyfy_duorui-skill"] = "夺锐：选择%dest的一个技能",
  ["#yyfy_duorui-lose"] = "夺锐：是否令 %dest 失去技能【%arg】？",

  ["$yyfy_duorui1"] = "夺敌军锐气，杀敌方士气。",
  ["$yyfy_duorui2"] = "尖锐之势，吾亦可一人夺之！",
}

duorui:addEffect(fk.Damage, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.to ~= player and not data.to.dead
  end,
  on_cost = function(self, event, target, player, data)
    local target_player = data.to
    local room = player.room
    --排除夺锐自身
    local skills = {}
    for _, s in ipairs(target_player.player_skills) do
      if s:isPlayerSkill(target_player) and s.name ~= self.name then
        table.insertIfNeed(skills, s.name)
      end
    end
    
    if #skills == 0 then return false end
    
    if not room:askToSkillInvoke(player, {
        skill_name = self.name,
        prompt = "#yyfy_duorui-choose::"..target_player.id}) then
      return false
    end
    
    -- 选择技能
    local choice = room:askToChoice(player, {
      choices = skills,
      skill_name = self.name,
      prompt = "#yyfy_duorui-skill::"..target_player.id,
      detailed = true,
    })
    
    -- 询问是否失去技能
    local lose_choice = room:askToChoice(player, {
        choices = {"确定", "取消"},
        skill_name = self.name,
        prompt = "#yyfy_duorui-lose::"..target_player.id..":"..choice
    })
    
    event:setCostData(self, {
      skill = choice,
      lose = (lose_choice == "确定"),
      target = target_player.id
    })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost_data = event:getCostData(self)
    local skill_name = cost_data.skill
    local target_player = room:getPlayerById(cost_data.target)
    
    -- 自己获得技能
    room:handleAddLoseSkills(player, skill_name, nil, true, true)
    -- 通过标记，记录获得的技能数量，用于游戏获胜时的战功判定
    room:addPlayerMark(player, "exgod_zhangliao-achievements")

    if cost_data.lose then
      room:handleAddLoseSkills(target_player, "-"..skill_name, nil, true, false)
    end
  end,
})

--战功：闻风丧胆
duorui:addEffect(fk.GameFinished, {
  global = true,
  priority = 0.0001,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("exgod_zhangliao-achievements") >= 5 -- 至少获得了5个技能
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local players = room.players
    local winners = data:split("+")
    for _, p in ipairs(players) do
      if table.contains(winners, p.role) then
        D.updateAchievement(room, p, "exgod_zhangliao", "exgod_zhangliao_1", 1)
      end
    end
  end
})

return duorui