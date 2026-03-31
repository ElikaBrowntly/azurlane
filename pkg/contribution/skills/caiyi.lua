local caiyi = fk.CreateSkill {
  name = "lan__caiyi",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["lan__caiyi"] = "彩翼",
  [":lan__caiyi"] = "转换技，结束阶段，你可以令一名角色选择一项：阳：1.回复4点体力；2.摸4张牌；"
  .."3.复原武将牌；阴：1.失去4点体力；2.弃置4张牌；3.翻面并横置。",

  ["#lan__caiyi_yang-choose"] = "彩翼：你可以令一名角色执行一个正面选项",
  ["#lan__caiyi_yin-choose"] = "彩翼：你可以令一名角色执行一个负面选项",
  ["#lan__caiyi-choice"] = "彩翼：选择执行的一项",
  ["lan__caiyi_yang1"] = "回复4点体力",
  ["lan__caiyi_yang2"] = "摸4张牌",
  ["lan__caiyi_yang3"] = "复原武将牌",
  ["lan__caiyi_yin1"] = "失去4点体力",
  ["lan__caiyi_yin2"] = "弃置4张牌",
  ["lan__caiyi_yin3"] = "翻面并横置",
  ["$lan__caiyi1"] = "凰凤化越，彩翼犹存。",
  ["$lan__caiyi2"] = "身披彩翼，心有灵犀。",
}

local function doCaiyi(player, target, state, choice)
  local room = player.room ---@type Room
  if state == "yang" then
    if choice == 1 then
      if target:isWounded() then
        room:recover{
          who = target,
          num = math.min(4, target.maxHp - target.hp),
          recoverBy = player,
          skillName = caiyi.name,
        }
      end
    elseif choice == 2 then
      target:drawCards(4, caiyi.name)
    else
      target:reset()
    end
  else
    if choice == 1 then
      room:loseHp(target, 4, caiyi.name)
    elseif choice == 2 then
      local cards = target:getCardIds("he")
      if #cards > 4 then
        room:askToDiscard(target, {
          min_num = 4,
          max_num = 4,
          include_equip = true,
          skill_name = caiyi.name,
          cancelable = false,
        })
      else
        room:throwCard(cards, caiyi.name, target, player)
      end
    else
      target:turnOver()
      if not target.chained and not target.dead then
        target:setChainState(true)
      end
    end
  end
end

caiyi:addEffect(fk.EventPhaseStart, {
  anim_type = "switch",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(caiyi.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      skill_name = caiyi.name,
      prompt = "#lan__caiyi_"..player:getSwitchSkillState(caiyi.name, false, true).."-choose",
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local state = player:getSwitchSkillState(caiyi.name, true, true)
    local choices = {
      "lan__caiyi_"..state.."1",
      "lan__caiyi_"..state.."2",
      "lan__caiyi_"..state.."3",
    }
    -- 阴选项2需要目标有牌
    local all_choices = {
      "lan__caiyi_yang1", "lan__caiyi_yang2", "lan__caiyi_yang3",
      "lan__caiyi_yin1", "lan__caiyi_yin2", "lan__caiyi_yin3",
    }
    local available_choices = table.simpleClone(choices)
    if state == "yin" and to:isAllNude() then
      table.removeOne(available_choices, "lan__caiyi_yin2")
    end
    if #available_choices == 0 then return end
    local choice = room:askToChoice(player, {
      choices = available_choices,
      skill_name = caiyi.name,
      prompt = "#lan__caiyi-choice",
      all_choices = all_choices,
    })
    doCaiyi(player, to, state, table.indexOf(all_choices, choice))
  end,
})

return caiyi