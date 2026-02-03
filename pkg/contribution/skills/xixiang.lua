local xixiang = fk.CreateSkill{
  name = "lan__xixiang",
}

Fk:loadTranslationTable{
  ["lan__xixiang"] = "西向",
  [":lan__xixiang"] = "出牌阶段各限一次，你可以将至少1张牌当【杀】或【决斗】对一名角色使用"..
  "（无距离次数限制）。此牌结算后，你回复1点体力，摸一张牌，然后获得其一张牌。",

  ["#lan__xixiang"] = "西向：将至少1张牌当【杀】或【决斗】使用",
  ["#lan__xixiang-prey"] = "西向：获得 %dest 一张牌",

  ["$lan__xixiang1"] = "挥剑断浮云，诸君共西向！",
  ["$lan__xixiang2"] = "西望故都，何忍君父辱于匹夫之手！",
}

xixiang:addEffect("active", {
  anim_type = "offensive",
  prompt = "#lan__xixiang",
  min_card_num = 1,
  target_num = 1,
  interaction = function(self, player)
    local choices = {}
    for _, name in ipairs({"slash", "duel"}) do
      if player:getMark("lan__xixiang_"..name.."-phase") == 0 then
        table.insert(choices, name)
      end
    end
    return UI.CardNameBox { choices = choices }
  end,
  can_use = function(self, player)
    return player:getMark("lan__xixiang_slash-phase") == 0 or player:getMark("lan__xixiang_duel-phase") == 0
  end,
  card_filter = function(self, player, to_select, selected)
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcards(selected)
    return not player:prohibitUse(card)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 or to_select == player or self.interaction.data == nil then 
      return false 
    end 
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcards(selected_cards)
    return card.skill:targetFilter(player, to_select, {}, {}, card, {bypass_distances = true, bypass_times = true})
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local cardName = self.interaction.data
    room:setPlayerMark(player, "lan__xixiang_"..cardName.."-phase", 1)
    -- 使用虚拟牌
    room:useVirtualCard(cardName, effect.cards, player, target, self.name, true)
    if player.dead then return end
    -- 回复体力
    if player:isWounded() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name,
      }
    end
    -- 摸一张牌
    player:drawCards(1, self.name)
    -- 获得目标一张牌
    if not player.dead and not target.dead and not target:isNude() then
      local card = room:askToChooseCard(player, {
        target = target,
        flag = "he",
        skill_name = self.name,
        prompt = "#lan__xixiang-prey::"..target.id,
      })
      if card then
        room:obtainCard(player, card, false, fk.ReasonPrey)
      end
    end
  end,
})

-- 重置标记
xixiang:addEffect(fk.EventPhaseStart, {
  on_cost = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "lan__xixiang_slash-phase", 0)
    player.room:setPlayerMark(player, "lan__xixiang_duel-phase", 0)
  end,
})

return xixiang