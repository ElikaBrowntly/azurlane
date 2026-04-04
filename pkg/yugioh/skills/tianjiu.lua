local tianjiu = fk.CreateSkill {
  name = "yyfy_tianjiu",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_tianjiu"] = "天救",
  [":yyfy_tianjiu"] = "持恒技，每回合限一次，敌方角色发动技能时，你可以根据场上友方角色数量执行对应的效果："..
    "<br>①2个以上：召唤一个阵营与你相同的NPC加入游戏；<br>②6个以上：令一名敌方角色死亡。"
}

local F = require("packages.hidden-clouds.functions")

-- 监听其他角色使用技能
tianjiu:addEffect(fk.SkillEffect, {
  is_delay_effect = true,
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target and target ~= player and data.skill.name ~= self.name and
        player:hasSkill(self) and table.contains(target:getSkillNameList(), data.skill.name)
        and player:usedSkillTimes(tianjiu.name, Player.HistoryTurn) < 1
        and F.teammatesNum(player, player.room) >= 2 and F.isEnemy(player, target)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = tianjiu.name,
      prompt = "天救：是否要根据友方角色数量执行对应的效果？"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = F.teammatesNum(player, room)
    if num < 2 then return end
    local next = room:getPlayerById(target:getNextAlive().id)
    local role = player.role
    if role == "lord" then
      role = "loyalist"
    end
    local npc = room:addNpc(next, {
      role = role,
      role_shown = player.role_shown
    })
    player:control(npc)
    local targets = {}
    for _, p in ipairs(room:getAllPlayers()) do
      if not p.dead and F.isEnemy(player, p) then
        table.insert(targets, p)
      end
    end
    if num >= 6 and #targets > 0 then
      local choice = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        skill_name = tianjiu.name,
        prompt = "天救：选择一名敌方角色，令其死亡"
      })
      if #choice ~= 1 then return end
      room:killPlayer({
        who = choice[1],
        killer = player
      })
    end
  end
})

return tianjiu