local runwei = fk.CreateSkill {
  name = "lan__runwei",
}

Fk:loadTranslationTable {
  ["lan__runwei"] = "润微",
  [":lan__runwei"] = "出牌阶段限一次，你可以展示牌堆顶5张牌，令一名角色获得其中一种颜色的牌。" ..
      "若如此做，你失去X张牌后（X为其因此获得的牌数），该技能可以再次发动。" ..
      "一名角色的弃牌阶段开始时，你可以令其摸/弃置一张牌，然后其手牌上限+1/-1。",

  ["#lan__runwei"] = "润微：你可展示牌堆顶5张牌，令1名角色获得其中一种颜色的牌",
  ["#lan__runwei-choose"] = "润微：选择令1名角色获得其中一种颜色的牌",
  ["#lan__runwei-choice"] = "润微：要让%dest获得其中哪种颜色的牌？",
  ["#lan__runwei-invoke"] = "润微：你可以令 %dest 执行一项",
  ["@lan__runwei-phase"] = "润微",
  
  ["lan__runwei1"] = "令其弃一张牌，手牌上限-1",
  ["lan__runwei2"] = "令其摸一张牌，手牌上限+1",

  ["$lan__runwei1"] = "以妾身微躯，亦可奉叔妹无虞。",
  ["$lan__runwei2"] = "妾力虽微，然足以挑一肩家计。",
  ["$lan__runwei3"] = "君等困顿未解，我岂可半途而废？",
  ["$lan__runwei4"] = "流水不言，泽德万物。",
  ["$lan__runwei5"] = "生如春雨，润物无声。",
  ["$lan__runwei6"] = "艾香绕清荷，可慰千里风尘。"
}

runwei:addEffect("active", {
  anim_type = "support",
  prompt = "#lan__runwei",
  audio_index = { 1, 2 },
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player and player:hasSkill(self) and player:usedEffectTimes(runwei.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local skillName = runwei.name
    local player = effect.from
    local cards = room:getNCards(5)
    local event_id = room.logic.current_event_id
    room:showCards(cards, player)
    if player.dead then return end
    cards = room.logic:moveCardsHoldingAreaCheck(cards, event_id)
    if #cards == 0 then return end

    local color
    local red = {}
    local black = table.filter(cards, function(id)
      color = Fk:getCardById(id).color
      if color == Card.Red then
        table.insert(red, id)
      end
      return color == Card.Black
    end)
    local choices = {}
    if #red > 0 then
      table.insert(choices, "red")
    end
    if #black > 0 then
      table.insert(choices, "black")
    end

    if #choices == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(),
      min_num = 1,
      max_num = 1,
      cancelable = false,
      skill_name = runwei.name,
      prompt = "#lan__runwei-choose"
    })
    if not to or #to ~= 1 then return end
    to = to[1]
    local choice = room:askToChoice(player, {
      choices = { "black", "red" },
      skill_name = runwei.name,
      prompt = "#lan__runwei-choice::" .. to.id,
      cancelable = false
    })
    room:doIndicate(player, { to })

    if choice == "black" then
      red = black
    end

    room:obtainCard(to, red, true, fk.ReasonJustMove, player, skillName)

    if player:hasSkill(skillName, true) then
      room:setPlayerMark(player, "@lan__runwei-phase", #red)
    end
  end,
})

local U = require "packages.utility.utility"

runwei:addEffect(fk.AfterCardsMove, {
  audio_index = 3,
  can_trigger = function(self, event, target, player, data)
    if not player or player:getMark("@lan__runwei-phase") == 0 or not player:hasSkill(runwei.name) then return false end
    local x = #U.getLostCardsFromMove(player, data)
    if x > 0 then
      event:setCostData(self, { number = x, mute = (x < player:getMark("@lan__runwei-phase")) })
      return true
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local x = math.max(0, player:getMark("@lan__runwei-phase") - event:getCostData(self).number)
    player.room:setPlayerMark(player, "@lan__runwei-phase", x)
    if player:getMark("@lan__runwei-phase") == 0 then
      player:clearSkillHistory(runwei.name)
    end
  end
})

runwei:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  audio_index = {4, 5, 6},
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(runwei.name) and target.phase == Player.Discard
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choices = {"lan__runwei2"}
    if not target:isNude() and
      (target ~= player or table.find(player:getCardIds("he"), function (id)
        return not player:prohibitDiscard(id)
      end)) then
        table.insert(choices, 1, "lan__runwei1")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = runwei.name,
      prompt = "#lan__runwei-invoke::"..target.id,
      all_choices = {"lan__runwei1", "lan__runwei2"},
      cancelable = true
    })
    if choice and choice ~= "Cancel" then
      event:setCostData(self, {tos = {target}, choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event:getCostData(self).choice == "lan__runwei1" then
      room:addPlayerMark(target, MarkEnum.MinusMaxCards, 1)
      room:askToDiscard(target, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = runwei.name,
        cancelable = false,
      })
    else
      room:addPlayerMark(target, MarkEnum.AddMaxCards, 1)
      target:drawCards(1, runwei.name)
    end
  end,
})

return runwei