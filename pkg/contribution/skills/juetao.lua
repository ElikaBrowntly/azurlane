local lan__juetao = fk.CreateSkill {
  name = "lan__juetao",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["lan__juetao"] = "决讨",
  [":lan__juetao"] = "限定技，出牌阶段开始时，你可以依次使用牌堆底的牌直到你无法使用。",

  ["#lan__juetao-ask"] = "决讨：是否使用%arg？",
  ["#lan__juetao-target"] = "决讨：选择你使用%arg的目标",

  ["$lan__juetao1"] = "登车拔剑起，奋跃搏乱臣！",
  ["$lan__juetao2"] = "陵云决心意，登辇讨不臣！"
}

lan__juetao:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lan__juetao.name) and player.phase == Player.Play and
      player:usedSkillTimes(lan__juetao.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    while not player.dead do
      local id = room:getNCards(1, "bottom")[1]
      room:turnOverCardsFromDrawPile(player, {id}, lan__juetao.name)
      local card = Fk:getCardById(id)
      local tos, subTos
      if player:canUse(card, { bypass_times = true, bypass_distances = true }) and not player:prohibitUse(card) then
        local targets = room:getAlivePlayers()
        targets = table.filter(targets, function(p)
          return not player:isProhibited(p, card) and
                 card.skill:modTargetFilter(player, p, {}, card, {bypass_times = true, bypass_distances = true})
        end)
        
        if card.skill:getMinTargetNum(player) == 0 then
          if not card.multiple_targets then
            tos = {}
          else
            tos = targets
          end
          if not room:askToSkillInvoke(player, {
            skill_name = lan__juetao.name,
            prompt = "#lan__juetao-ask:::"..card:toLogString(),
          }) then
            tos = nil
          end
        elseif #targets >= card.skill:getMinTargetNum(player) then
          if #targets == 1 then
            if room:askToSkillInvoke(player, {
              skill_name = lan__juetao.name,
              prompt = "#lan__juetao-target:::"..card:toLogString()
            }) then
              tos = targets
            end
          else
            local temp = room:askToChoosePlayers(player, {
              targets = targets,
              min_num = card.skill:getMinTargetNum(player),
              max_num = card.skill:getMaxTargetNum(player, card),
              prompt = "#lan__juetao-target:::"..card:toLogString(),
              skill_name = lan__juetao.name
            })
            if #temp > 0 then
              tos = temp
            end
          end
        end
      end
      if tos then
        room:useCard{
          card = card,
          from = player,
          tos = tos,
          skillName = lan__juetao.name,
          extraUse = true,
          subTos = subTos,
        }
      else
        room:delay(800)
        room:cleanProcessingArea({id}, lan__juetao.name)
        return
      end
    end
  end,
})

return lan__juetao