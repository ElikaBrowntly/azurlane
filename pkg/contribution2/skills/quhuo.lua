local quhuo = fk.CreateSkill{
  name = "yyfy_quhuo",
  tags = { Skill.Family },
}

Fk:loadTranslationTable{
  ["yyfy_quhuo"] = "去惑",
  [":yyfy_quhuo"] = "宗族技，当你不因使用或打出而失去手牌后，若其中包含【酒】或装备牌，你可以令一名同族角色回复该数量的体力。",

  ["#yyfy_quhuo-choose"] = "去惑：你可以令一名同族角色回复%arg点体力",
}

local U = require "packages.utility.utility"

local function countQuhuoCards(player, data)
  local count = 0
  for _, move in ipairs(data) do
    if move.from == player and
      not table.contains({fk.ReasonUse, fk.ReasonResponse}, move.moveReason) then
      for _, info in ipairs(move.moveInfo) do
        if info.fromArea == Card.PlayerHand and
          (Fk:getCardById(info.cardId).name == "analeptic" or
           Fk:getCardById(info.cardId).type == Card.TypeEquip) then
          count = count + 1
        end
      end
    end
  end
  return count
end

quhuo:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(quhuo.name) then
      local count = countQuhuoCards(player, data)
      if count > 0 then
        return table.find(player.room.alive_players, function (p)
          return U.FamilyMember(player, p) and p:isWounded()
        end) ~= nil
      end
    end
    return false
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local count = countQuhuoCards(player, data)
    local targets = table.filter(room.alive_players, function (p)
      return U.FamilyMember(player, p) and p:isWounded()
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = quhuo.name,
      prompt = "#yyfy_quhuo-choose:::" .. count,
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, { tos = to, count = count })
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost = event:getCostData(self)
    local to = cost.tos[1]
    room:recover{
      who = to,
      num = cost.count,
      recoverBy = player,
      skillName = quhuo.name,
    }
  end,
})

return quhuo