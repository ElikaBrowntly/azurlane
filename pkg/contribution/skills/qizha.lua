local qizha = fk.CreateSkill {
  name = "yyfy_qizha",
  tags = { Skill.Permanent }
}

local U = require "packages.utility.utility"

Fk:loadTranslationTable {
  ["yyfy_qizha"] = "欺诈",
  [":yyfy_qizha"] = "持恒技，出牌阶段限X次，你可与一名角色谋弈。若你嬴，你可获得其任意个技能，然后若你的选项为："
      .. "<br><font color='green'>我从不骗人</font>，则其失去所有技能且当其获得技能时，取消之；<br><font color="
      .. "'red'>我从不相信任何人说的话，包括我自己</font>，则你获得其所有牌并令其发动技能时取消之（X为你的体力值）。",
  ["yyfy_qizha-nocheat1"] = "<br>我从不骗人<br>",
  ["yyfy_qizha-cheat1"] = "我从不相信<br>任何人说的话,<br>包括我自己",
  ["yyfy_qizha-nocheat2"] = "<br>我从不骗人<br>",
  ["yyfy_qizha-cheat2"] = "我从不相信<br>任何人说的话,<br>包括我自己",
  [":yyfy_qizha-nocheat1"] = "令其失去所有技能且不再获得新的技能",
  [":yyfy_qizha-cheat1"] = "获得其所有牌并令其发动技能时取消之",
  [":yyfy_qizha-nocheat2"] = "防止程小实令你失去技能；但若谋弈失败会导致其获得你的所有牌、你无法发动技能",
  [":yyfy_qizha-cheat2"] = "防止程小实获得你的牌、令你无法发动技能；但若谋弈失败会导致你失去所有技能",
  ["#yyfy_qizha-choice"] = "欺诈：%dest正在与你谋弈，请选择一项",
  ["@@yyfy_qizha-nocheat"] = "多疑",
  ["@@yyfy_qizha-cheat"] = "被骗"
}

qizha:addEffect("active", {
  anim_type = "control",
  prompt = "欺诈：你可与一名角色谋弈",
  card_num = 0,
  target_num = 1,
  times = function (self, player)
    return player.hp - player:usedSkillTimes(qizha.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player and player.phase == Player.Play and player:hasSkill(self)
        and player:usedSkillTimes(qizha.name, Player.HistoryPhase) < player.hp
  end,
  target_filter = function(self, player, to_select, selected, selected_cards, card, extra_data)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    local all_choice1 = { "yyfy_qizha-nocheat1", "yyfy_qizha-cheat1" } -- 玩家选项
    local all_choice2 = { "yyfy_qizha-nocheat2", "yyfy_qizha-cheat2" } -- 对方选项
    local choice1 = ""
    local choice2 = ""
    local invoked = false -- 是否发动了破妄
    if player:usedSkillTimes("yyfy_powang", Player.HistoryTurn) == 0
        and room:askToUseActiveSkill(player, {
          skill_name = "yyfy_powang_active",
          cancelable = true,
          skip = true,
          prompt = "破妄：你可以令对方先选择选项，且对你可见",
        }) then
      player:setSkillUseHistory("yyfy_powang", 1, Player.HistoryTurn)
      invoked = true
      choice2 = room:askToChoice(to, {
        choices = all_choice2,
        skill_name = qizha.name,
        prompt = "#yyfy_qizha-choice::" .. player.id,
        detailed = true,
        cancelable = false
      })
      choice1 = room:askToChoice(player, {
        choices = all_choice1,
        skill_name = qizha.name,
        prompt = "对方的选项是“" .. Fk:translate(choice2) .. "”，轮到你选择了",
        cancelable = false,
        detailed = true
      })
    else
      local choices = U.doStrategy(room, player, to, all_choice1, all_choice2, qizha.name, 1)
      choice1 = choices[1]
      choice2 = choices[2]
    end
    local toast = Fk:translate(player.general) .. "对" .. Fk:translate(to.general) .. "的谋弈 "
    if invoked then
      if choice1[12] == choice2[12] then -- 发动者没赢
        room:doBroadcastNotify("ShowToast", toast .. "失败")
        return
      end
      room:doBroadcastNotify("ShowToast", toast .. "成功")
    end
    local skills = to:getSkillNameList()
    local result = room:askToCustomDialog(player, {
      skill_name = qizha.name,
      qml_path = "packages/utility/qml/ChooseSkillBox.qml",
      extra_data = { skills, 0, #skills, "欺诈：请选择对方任意个技能获得" }
    })
    if result ~= {} then
      for _, s in ipairs(result) do
        room:handleAddLoseSkills(player, s, qizha.name)
      end
    end
    if choice1 == "yyfy_qizha-nocheat1" then
      for _, s in ipairs(skills) do
        room:handleAddLoseSkills(to, "-" .. s)
      end
      room:addPlayerMark(to, "@@yyfy_qizha-nocheat")
      return
    end
    room:addPlayerMark(to, "@@yyfy_qizha-cheat")
    room:obtainCard(player, to:getCardIds("he"), false, fk.ReasonPrey, player, qizha.name)
  end,
})

qizha:addEffect(fk.EventAcquireSkill, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target and target:getMark("@@yyfy_qizha-nocheat") > 0 and player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    target.room:handleAddLoseSkills(target, "-" .. data.skill.name)
  end
})

qizha:addEffect(fk.SkillEffect, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target and player and player:hasSkill(self) and target:getMark("@@yyfy_qizha-cheat") > 0
        and table.contains(target:getSkillNameList(), data.skill.name)
        and player:getMark("yyfy_qizha-turn") < 20 then
      player.room:addPlayerMark(player, "yyfy_qizha-turn")
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.SkillEffect, false)
    if e then
      e:shutdown()
    end
  end,
})

return qizha