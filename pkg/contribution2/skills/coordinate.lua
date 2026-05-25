local coordinate = fk.CreateSkill {
  name = "yyfy_coordinate",
}

Fk:loadTranslationTable {
  ["yyfy_coordinate"] = "协调",
  [":yyfy_coordinate"] =
      "准备阶段，你可以选择一名其他角色，与其进行“<a href='xieli_desc'>协力</a>”。" ..
      "其结束阶段，若你与其“协力”成功，则其回复一点体力并摸2张牌，你获得〖<a href=':heji'>合击</a>〗直到其下回合结束。",
  ["xieli_desc"] = "<b>#协力：</b>" ..
      "<br>协力的发起者从同仇、并进、疏财、勠力中选择一项，并选择一名角色与其一同执行。" ..
      "若发起者与目标角色在目标角色的回合结束前达成了协力条件，则协力成功。" ..
      "<br><b>同仇</b>：造成的伤害之和不小于4点" ..
      "<br><b>并进</b>：摸牌数之和不小于8张" ..
      "<br><b>疏财</b>：弃置的牌包含4种花色" ..
      "<br><b>勠力</b>：使用或打出的牌包含4种花色",

  ["$yyfy_coordinate1"] = "义贯金石，忠以卫上！",
  ["$yyfy_coordinate2"] = "兴汉伟功，从今始成！",
  ["$yyfy_coordinate3"] = "遵奉法度，功效可书！",
}

local U = require "packages/utility/utility"

coordinate:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return
        player:hasSkill(coordinate.name) and
        target == player and
        player.phase == Player.Start and
        player:getMark("@[mou__xieli]") == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      skill_name = coordinate.name,
      prompt = "协调：请选择一名协力目标",
      targets = room:getOtherPlayers(player, false),
      min_num = 1,
      max_num = 1,
    })
    if #tos > 0 then
      event:setCostData(self, { tos = tos })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(coordinate.name, 1)
    room:notifySkillInvoked(player, coordinate.name, "special")

    local to = event:getCostData(self).tos[1]
    local choices = { "xieli_tongchou", "xieli_bingjin", "xieli_shucai", "xieli_luli" }
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = coordinate.name,
      prompt = "协调：请选择一个协力方式",
      detailed = true
    })
    room:setPlayerMark(player, "@[mou__xieli]", { to.id, choice, room.logic:getCurrentEvent().id })
  end,
})

coordinate:addEffect(fk.EventPhaseStart, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return
        player:isAlive() and
        target ~= player and
        target.phase == Player.Finish and
        U.checkXieli(player, target)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover({
      who = target,
      num = 1,
      recoverBy = player,
      skillName = coordinate.name,
    })
    target:drawCards(2, coordinate.name)
    room:handleAddLoseSkills(player, "heji")
    room:setPlayerMark(target, "yyfy_coordinate-heji", player._splayer:getScreenName())
  end,

  late_refresh = true,
  can_refresh = function(self, event, target, player, data)
    local mark = player:getTableMark("@[mou__xieli]")
    return target.phase == Player.Finish and #mark > 0 and mark[1] == target.id
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@[mou__xieli]", 0)
  end,
})

coordinate:addEffect(fk.EventPhaseStart, {
  can_refresh = function (self, event, target, player, data)
    return player and player:hasSkill(self) and target and
    target:getMark("yyfy_coordinate-heji") == player._splayer:getScreenName()
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(target, "yyfy_coordinate-heji", 0)
    room:handleAddLoseSkills(player, "-heji")
  end
})

return coordinate