local QC_qingli = fk.CreateSkill({
  name = "QC_qingli",
  tags = { Skill.Permanent },
})

Fk:loadTranslationTable {
  ["QC_qingli"] = "清理",
  [":QC_qingli"] = "出牌阶段，你可以选择一名角色，清除其身上的一项标记。" ..
                      "回合开始和回合结束时，你可发动此技能。",
  ["#QC_qingli-active"] = "你可以发动“清理”",
  ["#QC_qingli-choose"] = "请选择要清除标记的角色",
  ["#QC_qingli-mark"] = "请选择要清除的标记",
  ["#QC_qingli-log"] = "%from 发动了“清理”，清除了 %to 的标记 %arg",
  ["#QC_qingli-noMark"] = "该角色没有可清除的标记",
  ["#QC_qingli-cancel"] = "取消",
  ["#QC_qingli-turn-invoke"] = "是否发动“清理”？",
}

local function doClearMark(player)
  local room = player.room

  local targets = room:askToChoosePlayers(player, {
    min_num = 1,
    max_num = 1,
    targets = room.alive_players,
    skill_name = QC_qingli.name,
    prompt = "#QC_qingli-choose",
  })
  if #targets == 0 then return end
  local to = targets[1]

  local markNames = to:getMarkNames()
  if #markNames == 0 then
    room:sendLog {
      type = "#QC_qingli-noMark",
      from = player.id,
      to = { to.id },
    }
    return
  end

  local mark = room:askToChoice(player, {
    choices = markNames,
    skill_name = QC_qingli.name,
    prompt = "#QC_qingli-mark",
    cancelable = true,
    cancel_text = "#QC_qingli-cancel",
  })
  if not mark then return end

  room:setPlayerMark(to, mark, 0)

  room:sendLog {
    type = "#QC_qingli-log",
    from = player.id,
    to = { to.id },
    arg = mark,
  }
end

QC_qingli:addEffect("active", {
  anim_type = "negative",
  prompt = "#QC_qingli-active",
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return true
  end,
  on_use = function(self, room, effect)
    doClearMark(effect.from)
  end,
})

QC_qingli:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(QC_qingli.name, true, true)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = QC_qingli.name,
      prompt = "#QC_qingli-turn-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    doClearMark(player)
  end,
})

QC_qingli:addEffect(fk.TurnEnd, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(QC_qingli.name, true, true)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = QC_qingli.name,
      prompt = "#QC_qingli-turn-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    doClearMark(player)
  end,
})

return QC_qingli