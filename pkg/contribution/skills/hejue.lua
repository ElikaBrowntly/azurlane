local hejue = fk.CreateSkill{
  name = "yyfy_hejue",
}

Fk:loadTranslationTable{
  ["yyfy_hejue"] = "和绝",
  [":yyfy_hejue"] = "你可以弃置一张装备【句】，于对应时机发动：〖西向〗〖逐北〗〖归心〗〖掇月〗；"..
  "你可以将一张锦囊【句】当作立即判定的【闪电】置于自己的判定区，结算结束后你获得一种颜色的判定牌。"..
  "你每回合失去3张或得到3张【句】后，此技能本阶段失效。",
  
  ["yyfy_hejue_active"] = "发动〖和绝〗效果",
  ["yyfy_hejue_xixiang"] = "西向",
  ["yyfy_hejue_zhubei"] = "逐北",
  ["yyfy_hejue_lightning"] = "将锦囊【句】当作【闪电】",
  ["yyfy_hejue_guixin"] = "归心",
  ["yyfy_hejue_duoyue"] = "掇月",
  
  ["#yyfy_hejue_active_prompt"] = "和绝：请选择一张【句】，并选择要发动的效果",
  ["#yyfy_hejue_ju_equip_choose"] = "和绝：请选择一张装备【句】",
  ["#yyfy_hejue_ju_trick_choose"] = "和绝：请选择一张锦囊【句】",
  ["#yyfy_hejue_effect_choose"] = "和绝：请选择要发动的效果",
  ["#yyfy_hejue_color_choose"] = "和绝：请选择要获得的一种颜色",
  ["#yyfy_hejue_damage_trigger"] = "和绝：受到伤害后，你可以弃置一张【句】装备牌发动〖归心〗",
  ["#yyfy_hejue_start_trigger"] = "和绝：出牌阶段开始时，你可以弃置一张【句】装备牌发动〖掇月〗",
  
  ["$yyfy_hejue1"] = "周公，吐哺，天下，归心。",
  ["$yyfy_hejue2"] = "周公吐哺，天下归心。",
}

-- 检查玩家是否有所有装备牌"句"
local function hasJuEquip(player)
  local equipIds = player:getCardIds("he") or {}
  for _, id in ipairs(equipIds) do
    local card = Fk:getCardById(id)
    if card:getMark("@@yyfy_yanjv-mark") > 0 and card.type == Card.TypeEquip then
      return true
    end
  end
  return false
end

-- 获取玩家所有装备牌"句"
local function getJuEquips(player)
  local juEquips = {}
  local equipIds = player:getCardIds("he") or {}
  for _, id in ipairs(equipIds) do
    local card = Fk:getCardById(id)
    if card:getMark("@@yyfy_yanjv-mark") > 0 and card.type == Card.TypeEquip then
      table.insert(juEquips, {id = id, card = card})
    end
  end
  return juEquips
end

-- 出牌阶段主动发动效果
hejue:addEffect("active", {
  mute = true,
  anim_type = "support",
  prompt = "#yyfy_hejue_active_prompt",
  card_num = 1,
  include_equip = true,
  card_filter = function (self, player, to_select, selected, selected_targets)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and card:getMark("@@yyfy_yanjv-mark") > 0
    and (card.type == Card.TypeEquip or card.type == Card.TypeTrick)
  end,
  target_num = 0,
  can_use = function(self, player)
    return player.phase == Player.Play
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local jv = Fk:getCardById(effect.cards[1])
    local choices = { "Cancel" }
    if jv.type == Card.TypeEquip then
      table.insert(choices, "yyfy_hejue_xixiang")
      table.insert(choices, "yyfy_hejue_zhubei")
    else table.insert(choices, "yyfy_hejue_lightning")
    end
    -- 选择要发动的效果
    local effectChoice = room:askToChoice(player, {
      choices = choices,
      skill_name = "yyfy_hejue",
      prompt = "#yyfy_hejue_effect_choose"
    })
    if effectChoice == "Cancel" then
      return false
    end
    -- 获得“西向”
    if effectChoice == "yyfy_hejue_xixiang" then
      room:throwCard(jv, "yyfy_hejue", player, player)
      room:notifySkillInvoked(player, "yyfy_hejue", "control")
      room:handleAddLoseSkills(player, "xixiang", self, false, true)
    elseif effectChoice == "yyfy_hejue_zhubei" then
      -- 获得"逐北" 
      room:throwCard(jv, "yyfy_hejue", player, player)
      room:notifySkillInvoked(player, "yyfy_hejue", "control")
      room:handleAddLoseSkills(player, "zhubei", self, false, true)
    elseif effectChoice == "yyfy_hejue_lightning" then
      -- 模拟立即判定的闪电
      local lightningCard = Fk:cloneCard("lightning")
      lightningCard:addSubcard(jv)
      lightningCard.skillName = "yyfy_hejue"
      -- 将闪电置入判定区
      room:moveCards{
        from = player,
        to = player,
        toArea = Player.Judge,
        ids = {jv.id},
        moveReason = fk.ReasonJustMove,
        skillName = "yyfy_hejue",
        virtualEquip = lightningCard,
      }
      -- 记录所有判定牌
      local allJudgeCards = {}
      -- 从自己开始，按顺序对全场每个人判定，直到闪电劈下来为止
      local players = room.alive_players
      local startIndex = table.indexOf(players, player)
      local currentIndex = startIndex
      local lightningTriggered = false
      repeat
        local currentPlayer = players[currentIndex]
        -- 进行闪电判定
        local judge = {
          who = currentPlayer,
          reason = "lightning",
          pattern = ".|2~9|spade",
          skillName = "yyfy_hejue",
        }
        room:judge(judge)
        -- 记录判定牌
        table.insert(allJudgeCards, judge.card)
        -- 检查是否判定成功
        if judge.card:matchPattern(".|2~9|spade") and currentPlayer:isAlive() then
          -- 闪电生效，造成伤害
          room:damage{
            to = currentPlayer,
            damage = 3,
            damageType = fk.ThunderDamage,
            skillName = "lightning_skill",
            card = lightningCard,
          }
          lightningTriggered = true
        end
        -- 移动到下一个玩家
        currentIndex = currentIndex + 1
        if currentIndex > #players then
          currentIndex = 1
        end
        -- 如果闪电已经触发，或者玩家死亡，则停止
      until lightningTriggered or currentPlayer.dead or #players == 0
      -- 将闪电从判定区弃置
      local judgeCards = player:getCardIds("j")
      for _, id in ipairs(judgeCards) do
        local card = Fk:getCardById(id)
        if card.trueName == "lightning" or card.name == "闪电" then
          room:throwCard(id, "yyfy_hejue", player, player)
          break
        end
      end
      -- 让玩家从所有判定牌中选择一种颜色获得
      if #allJudgeCards > 0 then
        -- 提取所有判定牌的颜色
        local redCards = {}
        local blackCards = {}
        for _, judgeCard in ipairs(allJudgeCards) do
          if judgeCard.color == Card.Red then
            table.insert(redCards, judgeCard)
          elseif judgeCard.color == Card.Black then
            table.insert(blackCards, judgeCard)
          end
        end
        -- 构建选择项
        local colorChoices = {}
        if #redCards > 0 then
          table.insert(colorChoices, "red")
        end
        if #blackCards > 0 then
          table.insert(colorChoices, "black")
        end
        
        if #colorChoices == 0 then
          return false
        end
        
        -- 如果只有一种颜色，自动选择
        local chosenColor
        if #colorChoices == 1 then
          chosenColor = colorChoices[1]
        else
          chosenColor = room:askToChoice(player, {
            choices = colorChoices,
            skill_name = "yyfy_hejue",
            prompt = "#yyfy_hejue_color_choose",
            cancelable = false
        })
        end
        
        -- 获得对应颜色的所有判定牌
        local cardsToObtain = {}
        if chosenColor == "red" then
          for _, card in ipairs(redCards) do
            table.insert(cardsToObtain, card.id)
          end
        else -- black
          for _, card in ipairs(blackCards) do
            table.insert(cardsToObtain, card.id)
          end
        end
        
        if #cardsToObtain > 0 then
          -- 从弃牌堆中获取这些牌
          local availableCards = {}
          for _, id in ipairs(cardsToObtain) do
            if room:getCardArea(id) == Card.DiscardPile then
              table.insert(availableCards, id)
            end
          end
          
          if #availableCards > 0 then
            room:moveCards{
              ids = availableCards,
              to = player,
              toArea = Card.PlayerHand,
              moveReason = fk.ReasonPrey,
              skillName = "yyfy_hejue",
              proposer = player,
            }
          end
        end
      end
    end
    
    return true
  end,
})

-- 受到伤害后触发"归心"
hejue:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hejue.name) and
      player:isAlive() and hasJuEquip(player)
      and table.find(player.room.alive_players, function (p)
        return p ~= player and not p:isAllNude() -- 至少有一人不空城
      end)
  end,
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  card_num = 1,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = "yyfy_hejue",
      prompt = "#yyfy_hejue_damage_trigger",
    }) then
      event:setCostData(self, {tos = room:getOtherPlayers(player, false)})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 选择一张"句"装备牌
    local juEquips = getJuEquips(player)
    local equipIds = {}
    for _, equip in ipairs(juEquips) do
      table.insert(equipIds, equip.id)
    end
    local chosenEquip = room:askToChooseCardsAndChoice(player, {
      cards = equipIds,
      prompt = "#yyfy_hejue_ju_equip_choose",
      skill_name = "yyfy_hejue"
      })
    if not chosenEquip or #chosenEquip == 0 then
      return false
    end
    -- 弃置选择的装备牌
    room:throwCard(chosenEquip[1], "yyfy_hejue", player, player)
    -- 播放音效
    player:broadcastSkillInvoke("yyfy_hejue", math.random(1, 2))
    -- 发动"归心"技能
    room:notifySkillInvoked(player, "yyfy_hejue", "support")
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead and not p:isAllNude() then
        local id = room:askToChooseCard(player, {
          target = p,
          flag = "hej",
          skill_name = self.name,
        })
        room:obtainCard(player, id, false, fk.ReasonPrey, player, "guixin")
        if player.dead then return end
      end
    end
    player:turnOver()
    return true
  end,
})

-- 出牌阶段开始时触发"掇月"
hejue:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hejue.name) and hasJuEquip(player) and
      player.phase == Player.Play and player:isAlive() and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return player:canPindian(p)
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = "yyfy_hejue",
      prompt = "#yyfy_hejue_start_trigger",
      }) then
      local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return player:canPindian(p)
      end)
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = "duoyue",
        prompt = "#duoyue-choose:::1",
        cancelable = true,
      })
      if #to > 0 then
        event:setCostData(self, {tos = to})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 选择一张"句"装备牌
    local juEquips = getJuEquips(player)
    local equipIds = {}
    for _, equip in ipairs(juEquips) do
      table.insert(equipIds, equip.id)
    end
    
    local chosenEquip = room:askToChooseCardsAndChoice(player, {
      cards = equipIds,
      prompt = "#yyfy_hejue_ju_equip_choose",
      skill_name = "yyfy_hejue"
      })
    
    if not chosenEquip or #chosenEquip == 0 then
      return false
    end
    
    -- 弃置选择的装备牌
    room:throwCard(chosenEquip[1], "yyfy_hejue", player, player)
    
    -- 播放音效
    player:broadcastSkillInvoke("yyfy_hejue", 1)
    
    -- 发动"掇月"技能
    room:notifySkillInvoked(player, "duoyue", "drawcard")
    local to = event:getCostData(self).tos[1]

    for n = 1, 3 do
      local pindian = player:pindian({to}, "duoyue")
      local winner = pindian.results[to].winner
      if winner and not winner.dead then
        if winner == player then
          local victim = room:askToChoosePlayers(player, {
            min_num = 1,
            max_num = 1,
            targets = room.alive_players,
            skill_name = "duoyue",
            prompt = "#duoyue-damage:::" .. n,
            cancelable = true,
          })
          if #victim > 0 then
            victim = victim[1]
            room:damage{
              from = player,
              to = victim,
              damage = 1,
              skillName = "duoyue",
            }
            return
          end
        end

        if
          player:isAlive() and
          room:askToSkillInvoke(
            player,
            { skill_name = "duoyue", prompt = "#duoyue-draw::" .. winner.id .. ":" .. n }
          )
        then
          winner:drawCards(n, "duoyue")
        end
      end
      if n == 3 or player.dead then
        return
      end

      local targets = table.filter(room:getOtherPlayers(player, false), function (p)
        return player:canPindian(p)
      end)
      if #targets == 0 then return end
      local tos = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = "duoyue",
        prompt = "#duoyue-choose:::".. (n + 1),
      })
      if #tos == 0 then
        break
      end
      to = tos[1]
    end
  end,
})

return hejue