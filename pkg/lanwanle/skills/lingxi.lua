local lan__lingxi = fk.CreateSkill {
  name = "lan__lingxi",
  derived_piles = "lingxi_wing",
}

Fk:loadTranslationTable{
  ["lan__lingxi"] = "灵犀",
  [":lan__lingxi"] = "出牌阶段开始时或结束时，你可以将任意张牌置于你的武将牌上，称为“翼”。当“翼”被移去后，你将手牌调整至“翼”花色数的两倍。",

  ["lingxi_wing"] = "翼",
  ["#lan__lingxi-ask"] = "灵犀：你可以将任意张牌置为“翼”",

  ["$lan__lingxi1"] = "灵犀渡清潭，涟漪扰我心。",
  ["$lan__lingxi2"] = "心有玲珑曲，万籁皆空灵。",
}

local spec = {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lan__lingxi.name) and player.phase == Player.Play and
      not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local p = player ---@type ServerPlayer
    local cards = p.room:askToCards(p, {
      min_num = 1,
      max_num = #p:getCardIds("he"),
      include_equip = true,
      skill_name = lan__lingxi.name,
      cancelable = true,
      prompt = "#lan__lingxi-ask",
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("lingxi_wing", event:getCostData(self).cards, true, lan__lingxi.name)
  end,
}

lan__lingxi:addEffect(fk.EventPhaseStart, spec)
lan__lingxi:addEffect(fk.EventPhaseEnd, spec)

lan__lingxi:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(lan__lingxi.name) then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromSpecialName == "lingxi_wing" then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local suits = {}
    for _, id in ipairs(player:getPile("lingxi_wing")) do
      local suit = Fk:getCardById(id).suit
      table.insertIfNeed(suits, suit)
    end
    table.removeOne(suits, Card.NoSuit)
    local x = (2 * #suits) - player:getHandcardNum()
    if x > 0 then
      player:drawCards(x, lan__lingxi.name)
    elseif x < 0 then
      room:askToDiscard(player, {
        min_num = -x,
        max_num = -x,
        include_equip = false,
        skill_name = lan__lingxi.name,
        cancelable = false,
      })
    end
  end,
})

return lan__lingxi
