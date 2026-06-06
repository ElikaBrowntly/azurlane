local taoyin = fk.CreateSkill {
  name = "lan__taoyin",
  tags = { Skill.Hidden },
}

Fk:loadTranslationTable {
  ["lan__taoyin"] = "韬隐",
  [":lan__taoyin"] = "隐匿技，当你于其他角色的回合登场后，你可令其本回合手牌上限减至0。" ..
      "此回合结束时，你获得其弃牌阶段内弃置的牌。",

  ["@@lan__taoyin-turn"] = "韬隐",
  ["#lan__taoyin-invoke"] = "韬隐：你可以令 %dest 本回合手牌上限减至0",

  ["$lan__taoyin1"] = "司马氏善谋、善忍，善置汝于绝境！",
  ["$lan__taoyin2"] = "隐忍数载，亦不坠青云之志！"
}

local U = require "packages.utility.utility"

taoyin:addEffect(U.GeneralAppeared, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasShownSkill(taoyin.name) then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn)
      if turn_event == nil then return end
      local to = turn_event.data.who
      if to ~= player and not to.dead then
        return true
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
          skill_name = taoyin.name,
          prompt = "#lan__taoyin-invoke::" .. room.current.id,
        }) then
      event:setCostData(self, { tos = { room.current } })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local to = (event:getCostData(self) or {}).tos
    if not to or #to ~= 1 then return end
    player.room:addPlayerMark(to[1], "@@lan__taoyin-turn")
  end,
})

taoyin:addEffect("maxcards", {
  fixed_func = function(self, player)
    if player:getMark("@@lan__taoyin-turn") > 0 then
      return 0
    end
  end,
})

taoyin:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, _)
    if player.dead or player:usedSkillTimes(taoyin.name) == 0 then return false end
    local room = player.room
    local discard_ids = {}
    room.logic:getEventsOfScope(GameEvent.Phase, 1, function(e)
      if e.data.phase == Player.Discard then
        table.insert(discard_ids, { e.id, e.end_id })
      end
      return false
    end, Player.HistoryTurn)
    if #discard_ids == 0 then return false end
    local cards = {}
    room.logic:getEventsOfScope(GameEvent.MoveCards, 1, function(e)
      local in_discard = false
      for _, ids in ipairs(discard_ids) do
        if #ids == 2 and e.id > ids[1] and e.id < ids[2] then
          in_discard = true
          break
        end
      end
      if in_discard then
        for _, move in ipairs(e.data) do
          if move.from == target and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
                table.insert(cards, info.cardId)
              end
            end
          end
        end
      end
      return false -- 保证一直查找，遍历本回合所有牌移动事件
    end, Player.HistoryTurn)
    if #cards == 0 then return false end
    event:setCostData(self, { cards = cards })
    return true
  end,
  on_use = function(self, event, _, player, _)
    local cards = (event:getCostData(self) or {}).cards
    if not cards or #cards == 0 then return end
    player.room:obtainCard(player, cards, true, fk.ReasonJustMove, player, taoyin.name)
    -- fk.ReasonPrey 是获得其他玩家的牌，prey是掠夺、猎物的意思，这里从弃牌堆获得所以是JustMove
    -- 顺便，按此道理，另一名角色收回自己装备区里的牌，也应该是fk.ReasonJustMove
  end,
})

taoyin:addAI(Fk.Ltk.AI.newInvokeStrategy{
  think = function(self, ai)
    local to = ai.room.current
    return to and ai:isEnemy(to)
  end,
})

return taoyin