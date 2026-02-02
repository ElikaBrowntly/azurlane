local jianjiao = fk.CreateSkill{
  name = "yyfy_jianjiao",
  frequency = Skill.Compulsory,
}

Fk:loadTranslationTable{
  ["yyfy_jianjiao"] = "尖叫",
  ["@@jianjiao_cards"] = "尖叫",
  [":yyfy_jianjiao"] = "锁定技，当你的非「尖叫」实体牌被抵消时，将其置于抵消者的武将牌上并令响应牌无效，然后你获得抵消者一张牌。",
  ["#yyfy_jianjiao-invalid"] = "%from 的「尖叫」效果触发，%arg 的响应无效",
}

local help_functions = require "packages/hidden-clouds/functions"

jianjiao:addEffect(fk.CardEffectCancelledOut, {
  can_trigger = function ()
    return true
  end,
  on_cost = function(self, event, target, player, data)
    if not (player == data.from and player:hasSkill(self.name)) then return false end
    return help_functions.isEnemy(player, data.to) and data.card ~= nil
    and data.card.id > 0 and data.card:getMark("@@jianjiao_cards") == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local responder = data.to -- 抵消者
    -- 将牌置于抵消者的武将牌上
    room:addCardMark(data.card, "@@jianjiao_cards", 1)
    room:moveCardTo(data.card, Player.Special, responder, 0, self.name, "尖叫", false)
    data.isCancellOut = false
    room:sendLog{
      type = "#yyfy_jianjiao-invalid",
      from = data.from.id,
      arg = data.card.trueName,
    }
    
    -- 获得抵消者一张牌
    if not responder:isNude() then
      local cards = room:askToChooseCards(player, {
        target = responder,
        min = 1,
        max = 1,
        flag = "he",
        prompt = "请获得抵消者一张牌",
        skill_name = self.name,
      })
      if #cards > 0 then
        room:obtainCard(player, cards, false, fk.ReasonPrey, player, self.name)
      end
    end
    
    return true
  end,
})

return jianjiao