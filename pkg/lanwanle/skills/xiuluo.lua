local xiuluo = fk.CreateSkill {
  name = "lan__xiuluo",
}

Fk:loadTranslationTable{
  ["lan__xiuluo"] = "修罗",
  [":lan__xiuluo"] = "当你使用【杀】或普通锦囊牌指定目标后，或成为这些牌的目标后，你可以获得一张【杀】，将此牌效果改为【决斗】。",

  ['#lan__xiuluo'] = '修罗：是否获得一张【杀】，将 %arg 的效果改为【决斗】？',

  ["$lan__xiuluo1"] = "胆敢与我决斗，果不愧豪杰之名",
  ["$lan__xiuluo2"] = "若成军计，何待三日，布今便可施",
}

local ok, JL = pcall(require, "packages.jilve_caidog.util")

xiuluo:addEffect(fk.TargetConfirmed, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiuluo.name) and (data.card.trueName == "slash" or data.card:isCommonTrick()) and
      ok and JL.canChangeCardName(data, xiuluo.name)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xiuluo.name,
      prompt = "#lan__xiuluo:::"..data.card:toLogString()
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getCardsFromPileByRule("slash", 1)
    if #cards > 0 then
      room:obtainCard(player, cards, true, fk.ReasonPrey, player, xiuluo.name)
    end
    JL.changeCardName(data, "duel", xiuluo.name, room)
  end,
})

xiuluo:addEffect(fk.TargetSpecified, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiuluo.name) and (data.card.trueName == "slash" or data.card:isCommonTrick()) and
      ok and JL.canChangeCardName(data, xiuluo.name)
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xiuluo.name,
      prompt = "#lan__xiuluo:::"..data.card:toLogString()
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getCardsFromPileByRule("slash", 1)
    if #cards > 0 then
      room:obtainCard(player, cards, true, fk.ReasonPrey, player, xiuluo.name)
    end
    JL.changeCardName(data, "duel", xiuluo.name, room)
  end,
})

return xiuluo