local tiantao = fk.CreateSkill {
  name = "lan__tiantao"
}

Fk:loadTranslationTable {
  ["lan__tiantao"] = "天涛",
  [":lan__tiantao"] = "结束阶段，你可以选择一个区域并弃置其中所有牌，再依次弃置任意名其他角色相同区域各一张牌，" ..
      "因此弃置牌的角色失去1点体力。",

  ["#lan__tiantao-choice"] = "天涛：你可以弃置1个区域中的所有牌",
  ["#lan__tiantao-choose"] = "天涛：选择任意名其他角色，弃置这些角色的%arg各1张牌",

  ["$lan__tiantao1"] = "以此天穹之水，涤瑕荡秽！",
  ["$lan__tiantao2"] = "心怀浊恶之徒，岂能承神雨之清？",
}

tiantao:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tiantao.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local choice = player.room:askToChoice(player, {
      choices = { "$Hand", "$Equip", "$Judge" },
      cancelable = true,
      skill_name = tiantao.name,
      prompt = "#lan__tiantao-choice",
    })
    if (choice or "") ~= "Cancel" then
      local cost = event:getCostData(self) or {}
      cost.field = choice
      event:setCostData(self, cost)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = (event:getCostData(self) or {}).field or ""
    local areaMapper = {
      ["$Hand"] = "h",
      ["$Equip"] = "e",
      ["$Judge"] = "j",
    }
    local area = areaMapper[choice]
    local card
    local loseHp = { player }
    local cards = table.filter(player:getCardIds(area), function(id)
      card = Fk:getCardById(id)
      if not player:prohibitDiscard(card) then
        return true
      end
    end)
    if #cards > 0 then
      room:throwCard(cards, tiantao.name, player, player)
      if player.dead then return end
    else
      loseHp = {}
    end

    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and #p:getCardIds(area) > 0
    end)
    if #targets > 0 then
      targets = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 998,
        targets = targets,
        skill_name = tiantao.name,
        prompt = "#lan__tiantao-choose:::" .. choice,
        cancelable = false,
      })
      for _, p in ipairs(targets) do
        if not (player.dead or p.dead or #p:getCardIds(area) == 0) then
          local id = room:askToChooseCard(player, {
            target = p,
            skill_name = tiantao.name,
            flag = area,
          })
          table.insert(loseHp, p)
          room:throwCard(id, tiantao.name, p, player)
        end
      end
    end

    for _, p in ipairs(loseHp) do
      if not p.dead then
        room:loseHp(p, 1, tiantao.name, player)
      end
    end
  end,
})

return tiantao