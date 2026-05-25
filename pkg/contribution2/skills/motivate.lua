local yyfy_motivate = fk.CreateSkill {
  name = "yyfy_motivate",
}

Fk:loadTranslationTable{
  ["yyfy_motivate"] = "激励",
  [":yyfy_motivate"] = "一名角色的出牌阶段开始时，你可以令其“<a href='zhengsu_desc'>整肃</a>”；"..
  "你与其共同获得整肃奖励。",

  ["#yyfy_motivate-invoke"] = "激励：你可令 %dest “整肃”，若成功则你与其获得整肃奖励",
  ["@yyfy_motivate-turn"] = "激励",
  ["#yyfy_motivate-choice"] = "激励：为 %dest 选择一项整肃条件",
  ["#yyfy_motivate-reward"] = "激励：整肃成功，你与 %src 共同执行整肃奖励",

  ["$yyfy_motivate1"] = "交汝统领，勿负我望！",
  ["$yyfy_motivate2"] = "有功自当行赏，来人呈上！",
  ["$yyfy_motivate3"] = "叉出去！罚其二十军杖！",
}

local U = require "packages.utility.utility"

yyfy_motivate:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yyfy_motivate.name) and target.phase == Player.Play and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = yyfy_motivate.name,
      prompt = "#yyfy_motivate-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, yyfy_motivate.name, "support", {target.id})
    player:broadcastSkillInvoke(yyfy_motivate.name, 1)
    U.startZhengsu(player, target, yyfy_motivate.name, "#yyfy_motivate-choice::"..target.id)
    room:setPlayerMark(player, "@yyfy_motivate-turn", target.general)
  end,
})

yyfy_motivate:addEffect(fk.EventPhaseEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target.phase == Player.Discard and not target.dead and not player.dead and
      U.checkZhengsu(player, target, yyfy_motivate.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, yyfy_motivate.name)
    player:broadcastSkillInvoke(yyfy_motivate.name, 2)
    local choices = {"draw2"}
    if player:isWounded() or (target:isWounded() and not target.dead) then
      table.insert(choices, 1, "recover")
    end
    local reward = room:askToChoice(target, {
      choices = choices,
      skill_name = yyfy_motivate.name,
      prompt = "#yyfy_motivate-reward:"..player.id,
      all_choices = {"draw2", "recover"},
    })
    U.rewardZhengsu(player, target, reward, yyfy_motivate.name)
    if not player.dead then
      U.rewardZhengsu(player, player, reward, yyfy_motivate.name)
    end
  end,
})

return yyfy_motivate