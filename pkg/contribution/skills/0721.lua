local skill = fk.CreateSkill {
  name = "yyfy_0721",
  tags = { Skill.Limited }
}

Fk:loadTranslationTable{
  ["yyfy_0721"] = "0721",
  [":yyfy_0721"] = "限定技，出牌阶段你可以进行一次0721，根据得分摸等量的牌。"
  .."你以此法摸到的牌无距离次数限制，若你得到了21分，此技能下回合视为未发动过。",

  ["@@yyfy_0721"] = "0721",
  ["$yyfy_07211"] = "请收下我的贞洁吧！",
  ["$yyfy_07212"] = "请看看我的0721吧！"
}

skill:addEffect("active", {
  can_use = function (self, player)
    return player and player:hasSkill(skill.name) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_num = 0,
  target_num = 0,
  prompt = "0721：你可以进行一次0721小游戏",
  on_use = function (self, room, skillUseEvent)
    local player = skillUseEvent.from
    local path = "../image/generals/yyfy_TomotakeYoshino"..tostring(math.random(5))..".jpg"
    local random = math.random(2)
    if random == 1 then
      player:chat("请收下我的贞洁吧！")
    else
      player:chat("请看看我的0721吧！")
    end
    -- 调用自定义对话框
    local result = room:askToCustomDialog(player, {
      skill_name = skill.name,
      qml_path = "packages/hidden-clouds/qml/0721.qml",
      extra_data = { imagePath = path } -- 图片路径
    })
    local count = 0
    if type(result) == "table" and result.count then
      count = result.count
    end
    if count > 0 then
      room:doBroadcastNotify("ShowToast", player._splayer:getScreenName().."在5秒钟内0721了"..tostring(count).."次！！")
      player:drawCards(count, skill.name, "top", "@@yyfy_0721")
    end
    if count == 21 then
      room:setPlayerMark(player, "@@yyfy_0721", 1)
    end
  end
})

skill:addEffect("targetmod", {
  bypass_times = function(self, player, skillObj, scope, card)
    return player and player:hasSkill(skill.name) and scope == Player.HistoryPhase and
      card and card:getMark("@@yyfy_0721") > 0
  end,
  bypass_distances = function (self, player, skillObj, card, to)
    return player and player:hasSkill(skill.name) and card and card:getMark("@@yyfy_0721") > 0
  end
})

skill:addEffect(fk.TurnStart, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:getMark("@@yyfy_0721") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player:clearSkillHistory(skill.name)
    player.room:setPlayerMark(player, "@@yyfy_0721", 0)
  end
})

return skill