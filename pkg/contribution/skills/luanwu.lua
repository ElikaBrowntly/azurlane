local luanwu = fk.CreateSkill{
  name = "yyfy_luanwu",
  anim_type = "control"
}

Fk:loadTranslationTable{
  ["yyfy_luanwu"] = "乱武",
  [":yyfy_luanwu"] = "一名角色的：1.体力值；2.手牌数；3.<a href = 'yyfy_luanwu_3'>「帷幕」牌数</a>，"..
  "不因此技能而变化时，你可以弃置1张牌，令其对应数值向相同方向调整X，另外两项数值向相反方向调整X(X为此牌点数)。",
  
  ["yyfy_luanwu_3"] = "获得红色牌视为增加，获得黑色牌视为减少。",
  ["#yyfy_luanwu-draw"] = "乱武：你可以弃置一张牌，根据点数令%dest摸牌",
  ["#yyfy_luanwu-discard"] = "乱武：你可以弃置一张牌，根据点数令%dest弃牌",

  ["$yyfy_luanwu1"] = "汝等若心存隐忍，顷刻便尸骨无存！",
  ["$yyfy_luanwu2"] = "在下所谋之法，唯恐天下不乱！"
}

local F = require("packages.hidden-clouds.functions")

luanwu:addEffect(fk.HpChanged, {
  can_trigger = function (self, event, target, player, data)
    return target and target:isAlive() and player and player:hasSkill(self.name)
    and data.skillName ~= luanwu.name and player.rest == 0 and not player:isNude()
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local direction = "回复体力"
    if data.num < 0 then direction = "失去体力" end
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = luanwu.name,
      include_equip = false,
      cancelable = true,
      prompt = "乱武：你可以弃置一张牌，根据点数令"..tostring(target.seat).."号位"..direction
    })
    if #card > 0 then
      room:throwCard(card, luanwu.name, player, player)
      event:setCostData(self, {number = Fk:getCardById(card[1]).number})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local number = event:getCostData(self).number
    if number == 0 then return end
    if data.num > 0 then -- 增加了体力，另外两项减少
      room:recover({
        who = target,
        num = number,
        recoverBy = player,
        skillName = luanwu.name
      })
      if #target:getCardIds("h") <= number then
        room:throwCard(target:getCardIds("h"), luanwu.name, target, player)
      else
        room:askToDiscard(target, {
          min_num = number,
          max_num = number,
          skill_name = luanwu.name,
          cancelable = false,
        })
      end
      for i = 1, number, 1 do
        F.getWeimu(player, target, Card.Black, luanwu.name)
      end
    else -- 失去了体力，另外两项增加
      room:loseHp(target, number, luanwu.name, player)
      room:drawCards(target, number, luanwu.name)
      for i = 1, number, 1 do
        F.getWeimu(player, target, Card.Red, luanwu.name)
      end
    end
  end
})

-- 获得牌，另外两项减少
luanwu:addEffect(fk.AfterCardsMove, {
  can_trigger = function (self, event, target, player, data)
    if player and player:hasSkill(luanwu.name) and player.rest == 0 and not player:isNude() then
      for _, move in ipairs(data) do
        if move.to ~= nil and move.to:isAlive() and move.toArea == Card.PlayerHand
        and move.skillName ~= luanwu.name then
          event:setCostData(self, {tos = {move.to}})
          return true
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = luanwu.name,
      cancelable = true,
      prompt = "#yyfy_luanwu-draw::"..to.id
    })
    if #card == 0 then return false end
    local number = Fk:getCardById(card[1]).number
    if not (to and to:isAlive()) then return end
    room:moveCardTo(card, Card.DiscardPile, nil, 1, luanwu.name)
    room:drawCards(to, number, luanwu.name)
    room:loseHp(to, number, luanwu.name, player)
    for i = 1, number, 1 do
      F.getWeimu(player, to, Card.Black, luanwu.name)
    end
  end
})

-- 失去手牌，另外两项增加
luanwu:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(luanwu.name) and player.rest == 0 and not player:isNude())then return end
    for _, move in ipairs(data) do
      if move.from ~= nil and move.skillName ~= luanwu.name and move.from:isAlive() then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            event:setCostData(self, {tos = {move.from}})
            return true
          end
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = luanwu.name,
      cancelable = true,
      prompt = "#yyfy_luanwu-discard::"..to.id
    })
    if #card == 0 then return false end
    room:moveCardTo(card, Card.DiscardPile, nil, 1, luanwu.name)
    local number = Fk:getCardById(card[1]).number
    if not (to and to:isAlive()) then return end
    if #to:getCardIds("h") < number then
      room:throwCard(to:getCardIds("h"), luanwu.name, to, player)
    else
      room:askToDiscard(to, {
        min_num = number,
        max_num = number,
        skill_name = luanwu.name,
        cancelable = false
      })
    end
    room:recover({
      who = to,
      num = number,
      recoverBy = player,
      skillName = luanwu.name
    })
    for i = 1, number, 1 do
      F.getWeimu(player, to, Card.Red, luanwu.name)
    end
  end,
})

-- 获得「帷幕」牌时
luanwu:addEffect(fk.AfterCardsMove, {
  can_trigger = function (self, event, target, player, data)
    if player and player:hasSkill(luanwu.name) and player.rest == 0 and not player:isNude() then
      for _, move in ipairs(data) do
        if move.to ~= nil and move.to:isAlive() and move.toArea == Card.PlayerSpecial
        and move.skillName ~= luanwu.name and move.specialName == "yyfy_weimu-pile" then
          event:setCostData(self, {tos = {move.to}, id = move.moveInfo[1].cardId})
          return true
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local color = Fk:getCardById(event:getCostData(self).id).color
    local to = event:getCostData(self).tos[1]
    local direction = "红色"
    if color == Card.Black then direction = "黑色" end
    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      skill_name = luanwu.name,
      cancelable = true,
      prompt = "乱武：你可以弃置一张牌，根据点数令"..tostring(to.seat).."号位获得"..direction.."「帷幕」"
    })
    if #card == 0 then return false end
    local number = Fk:getCardById(card[1]).number
    if number <= 0 then return end
    if not (to and to:isAlive()) then return end
    for i = 1, number, 1 do
      F.getWeimu(player, to, color, luanwu.name)
    end
    if color == Card.Red then
      room:loseHp(to, number, luanwu.name, player)
      if to.dead then return end
      if #to:getCardIds("h") < number then
        room:throwCard(to:getCardIds("h"), luanwu.name, to, player)
      else
        room:askToDiscard(to, {
          min_num = number,
          max_num = number,
          skill_name = luanwu.name,
          cancelable = false
        })
      end
    else
      room:recover({
        who = to,
        num = number,
        recoverBy = player,
        skillName = luanwu.name
        })
      room:drawCards(to, number, luanwu.name)
    end
  end
})

return luanwu