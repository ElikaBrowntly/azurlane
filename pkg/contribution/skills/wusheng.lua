local skill = fk.CreateSkill{
  name = "yyfy_wusheng",
  anim_type = "control",
}
Fk:loadTranslationTable{
  ["yyfy_wusheng"] = "无声",
  [":yyfy_wusheng"] = "锁定技，敌方角色成为牌的目标后，若此牌可以被响应，"..
  "则其响应方式改为用相同花色的手牌转化响应牌。若其未响应，则减一点体力上限",
}
local help_functions = require "packages/hidden-clouds/functions"

skill:addEffect(fk.PreCardEffect, {
  on_cost = function (self, event, target, player, data)
    return player and player:hasSkill(self.name) and data.to ~= nil
    and help_functions.isEnemy(player, data.to) and
    (data.card:isCommonTrick() or data.card.trueName == "slash")
    and not data.disresponsive and data.card.trueName ~= "nullification"
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = data.to
    local suitable_discards = false
    for _, id in ipairs(to:getCardIds()) do
      if Fk:getCardById(id).suit == data.card.suit then
        suitable_discards = true
        break
      end
    end--初始认为没有同花色的牌可弃，执行中有可弃的就跳出循环，否则保持不可弃
    if to:isKongcheng() or not suitable_discards then --空城也是不可弃
      data.disresponsive = true
      player.room:changeMaxHp(to, -1)
    return end
    local result = room:askToChoice(to, {
      skill_name = self.name,
      choices = {"确定", "取消"},
      prompt = "你仅能转化相同花色的手牌来响应，不响应则体力上限-1。是否响应？"
    })
    if result == "取消" then
      data.disresponsive = true
      player.room:changeMaxHp(to, -1)
    return end
    local responseCard = "jink"
    if data.card:isCommonTrick() then responseCard = "nullification" end
    local card_sele = room:askToCards(to, {
      skill_name = self.name,
      max_num = 1,
      min_num = 1,
      include_equip = false,
      cancelable = false,
      pattern = ".|.|"..data.card:getSuitString(),
      prompt = "请用1张相同花色的手牌转化响应牌"
    })
    local use = {}
    local card = Fk:cloneCard(responseCard)
    card:addSubcard(card_sele[1])
    use = {
      from = to,
      skill_name = skill.name,
      card = card,
      toCard = data.card,
      responseToEvent = event
    }
    to.room:useCard(use)
    data.isCancellOut = true
    data:setDisresponsive(to)
  end
})

return skill