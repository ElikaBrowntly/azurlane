local lead = fk.CreateSkill {
  name = "yyfy_lead",
}

Fk:loadTranslationTable{
  ["yyfy_lead"] = "领导",
  [":yyfy_lead"] = "锁定技，你参与议事的意见视为+1。一名角色的回合开始时，你可以令所有角色“<a href='yyfy_yishi'>议事</a>”；"..
  "然后你摸X张牌并回复等量体力（X为红色意见数量）。若结果为红色，你可令意见为黑色的其他角色弃置所有牌并失去一点体力。",

  ["yyfy_yishi"] = "江山如故-起包提出的概念，技能发动者先指定参与议事的其他目标角色，然后所有参与议事的角色提出各自的意见（同时展示一张手牌，展示牌的颜色表示该角色在议事中提出的意见）（没有手牌则不展示），对比两种意见提出者的数量，意见提出者数量最多的颜色将作为本次议事的结果，然后由议事发起者执行结果对应颜色的效果。"..
  "目前涉及议事的武将：<br>"..
  "（1）起王允（起王允本人必定参与议事）<br>（2）起刘宏（起刘宏本人不参与议事……）<br>（3）兴贾南风（荡妇参与的议事没有自主权）<br>",
  ["$yyfy_lead1"] = "何故争论无休？朝堂自有公论！",
  ["$yyfy_lead2"] = "今日之言，无是无非，皆为我大汉社稷！",
  ["$yyfy_lead3"] = "朝野皆论朋党之私，欲置朕于何处！",
  ["$yyfy_lead4"] = "诸卿一心为公，大汉中兴可期！",
}

local U = require "packages.utility.utility"

lead:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = lead.name,
      prompt = "领导：你可以令所有角色议事！",
    }) then
      local tos = table.filter(room:getOtherPlayers(player, false), function(p)
        return not p:isKongcheng()
      end)
      room:sortByAction(tos)
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = event:getCostData(self).tos
    if not targets or #targets == 0 then return end
    table.insert(targets, player)
    local discussion = U.Discussion(player, targets, lead.name)
    local n = 0
    if not player.dead then
      for _, p in ipairs(targets) do
        if discussion.results[p].opinion == "red" then
          n = n + 1
        end
      end
      player:drawCards(math.max(n + 1, 2), lead.name)
      room:recover({
        who = player,
        num = math.max(n + 1, 2),
        recoverBy = player,
        skillName = lead.name,
      })
    end
    if discussion.color == "red" then
      if not room:askToSkillInvoke(player, {
        skill_name = lead.name,
        prompt = "领导：你可以令意见为黑色的角色弃置所有牌并失去1点体力！"
      }) then
        return
      end
      for _, p in ipairs(targets) do
        if p ~= player and not p.dead and discussion.results[p].opinion == "black" then
          room:throwCard(p:getCardIds("he"), lead.name, p, p)
          room:loseHp(p, 1, lead.name)
        end
      end
    end
  end,
})

lead:addEffect(U.DiscussionResultConfirming, {
  can_refresh = function (self, event, target, player, data)
    return player:hasSkill(self) and table.contains(data.tos, player) and
      data.results[player].opinion
  end,
  on_refresh = function (self, event, target, player, data)
    local opinion = data.results[player].opinion
    data.opinions[opinion] = (data.opinions[opinion] or 0) + 1
  end,
})

return lead