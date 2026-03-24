local xizhen = fk.CreateSkill {
  name = "yyfy_xizhen",
}

Fk:loadTranslationTable {
  ["yyfy_xizhen"] = "袭阵",
  [":yyfy_xizhen"] = "①其他角色于摸牌阶段外摸牌时，其获得一枚“阵”标记；当一名角色的“阵”达到10的倍数" ..
      "或你的回合结束时，你可弃置一名角色的X张牌（X为其“阵”的一半，向上取整）。<br>" ..
      "②你的回合开始时，你可获得一名角色区域内至多Y张牌（Y为其技能描述中所有数字的总和）。",

  ["@yyfy_xizhen"] = "阵",
  ["$yyfy_xizhen1"] = "🐒🐺🐍🐯？😒，🐯🐬🐒🐺！",
  ["$yyfy_xizhen2"] = "召虎踏风至，誓擒碧眼儿！"
}

local F = require("packages.hidden-clouds.functions")

--- ①效果的弃别人牌
---@param from ServerPlayer
---@param to ServerPlayer
local function throwCards(from, to, num)
  local room = from.room
  local cards = to:getCardIds("hej")
  if #cards > num then -- 多了，选择弃哪几张，类似破军
    cards = room:askToChooseCards(from, {
    min = num,
    max = num,
    target = to,
    flag = "hej",
    skill_name = xizhen.name,
    cancelable = true
  })
  end
  if #cards == 0 then return end
  room:throwCard(cards, xizhen.name, to, from) --不足则全弃
end

xizhen:addEffect(fk.AfterCardsMove, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, datas)
    if not (player and player:hasSkill(self)) then return false end
    local current = player.room.current
    if current and current.phase == Player.Draw then return false end
    local ids = {}
    local tos = {}
    for _, data in ipairs(datas) do
      if data.to and data.to ~= player then
        for _, info in ipairs(data.moveInfo) do
          if info.fromArea == Card.DrawPile then
            table.insertIfNeed(ids, info.cardId)
            tos = { data.to }
          end
        end
      end
    end
    if #ids > 0 then
      local cost = event:getCostData(self) or {}
      cost.cards = ids
      cost.tos = tos
      event:setCostData(self, cost)
      return true
    end
    return false
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost = event:getCostData(self)
    if not cost.tos then return end
    local to = cost.tos[1]
    if cost and to and cost.cards then
      room:addPlayerMark(to, "@yyfy_xizhen")
    end
    local num = to:getMark("@yyfy_xizhen")
    if num % 10 == 0 then
      num = math.ceil(num / 2) -- 向上取整
      if room:askToSkillInvoke(player, {
        skill_name = xizhen.name,
        prompt = "袭阵：是否要弃置"..to.seat.."号位的"..num.."张牌？"
      }) then
        throwCards(player, to, num)
      end
    end
  end
})

xizhen:addEffect(fk.TurnEnd, {
  can_trigger = function (self, event, target, player, data)
    local targets = {}
    for _, p in ipairs(player.room:getOtherPlayers(player)) do
      if p:getMark("@yyfy_xizhen") > 0 then
        table.insert(targets, p)
      end
    end
    if target == player and player:hasSkill(self) and #targets > 0 then
      event:setCostData(self, {tos = targets})
      return true
    end
  end,
  on_cost = function (self, event, target, player, data)
    local cost = event:getCostData(self) or {}
    if cost == {} or cost.tos == {} then return false end
    local to = player.room:askToChoosePlayers(player, {
      targets = cost.tos,
      min_num = 1,
      max_num = 1,
      skill_name = xizhen.name,
      cancelable = true,
      prompt = "袭阵：你可以弃置一名角色“阵”数量的一半张牌"
    })
    if #to == 1 then
      cost.tos = to
      event:setCostData(self, cost)
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local to = event:getCostData(self).tos
    if not to or #to ~= 1 then return end
    to = to[1]
    local num = to:getMark("@yyfy_xizhen")
    num = math.ceil(num / 2)
    throwCards(player, to, num)
  end
})

xizhen:addEffect(fk.TurnStart, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player),
      min_num = 1,
      max_num = 1,
      cancelable = true,
      skill_name = xizhen.name,
      target_tip_name = "yyfy_xizhen-tip",
      prompt = "袭阵：你可以获得一名角色的Y张牌"
    })
    if #to ~= 1 then return end
    event:setCostData(self, {tos = to})
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos
    if not to or #to ~= 1 then return end
    local skills = to[1]:getSkillNameList()
    local y = 0
    for _, name in ipairs(skills) do
      local description = Fk:translate(":"..name)
      y = y + F.sumNumbersInString(description)
    end
    local cards = room:askToChooseCards(player, {
      min = 0,
      max = math.floor(y),
      target = to[1],
      flag = "hej",
      skill_name = xizhen.name
    })
    room:moveCardTo(cards, Player.Hand, player, fk.ReasonPrey, xizhen.name)
  end
})

Fk:addTargetTip{
  name = "yyfy_xizhen-tip",
  target_tip = function(room, from, to_select)
    local skills = to_select:getSkillNameList()
    local y = 0
    for _, name in ipairs(skills) do
      local description = Fk:translate(":"..name)
      y = y + F.sumNumbersInString(description)
    end
    y = math.floor(y)
    return "可获得" .. y .. "张牌"
  end,
}

return xizhen