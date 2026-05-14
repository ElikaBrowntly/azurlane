local anguo = fk.CreateSkill {
  name = "lan__anguo",
}

Fk:loadTranslationTable {
  ["lan__anguo"] = "安国",
  [":lan__anguo"] = "出牌阶段限一次，你可以选择任意项令一名其他角色执行，然后你执行任意项：" ..
      "<br>①摸1张牌；②回复1点体力；③随机使用1张装备牌。",

  ["#lan__anguo"] = "安国：令一名角色执行任意项效果，然后你执行任意项",

  ["$lan__anguo1"] = "止干戈，休战事。",
  ["$lan__anguo2"] = "安邦定国，臣子分内之事。",
}

local F = require("packages.hidden-clouds.functions")

---执行安国选项
---@param player ServerPlayer
---@param anguo_type string[]
---@param source ServerPlayer
local function doAnguo(player, anguo_type, source)
  if not (player and player:isAlive()) then return end
  local room = player.room
  local n = source:hasSkill("lan__lingke") and 1 + F.rarerCount(source, "稀有") or 1
  if table.contains(anguo_type, "摸牌") then
    player:drawCards(n, anguo.name)
  end
  if table.contains(anguo_type, "回复体力") then
    room:recover {
      who = player,
      num = n,
      recoverBy = source,
      skillName = anguo.name,
    }
  end
  if table.contains(anguo_type, "使用装备牌") then
    while n > 0 do
      local cards = {}
      for _, id in ipairs(room.draw_pile) do
        local card = Fk:getCardById(id)
        if card.type == Card.TypeEquip and player:canUseTo(card, player) then
          table.insert(cards, card)
        end
      end
      if #cards > 0 then
        room:useCard({
          from = player,
          tos = { player },
          card = room:tableRandomPick(cards),
        })
      end
      n = n - 1
      room:delay(500)
    end
    -- 执行太快会不显示装备，所以需要延迟？
  end
end

anguo:addEffect("active", {
  anim_type = "support",
  prompt = "#lan__anguo",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(anguo.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local choices = { "摸牌", "回复体力", "使用装备牌", "全选" }
    local sayings = {
      "这些充钱也勾可真难对付",
      "富哥们玩三国杀真精彩",
      "这武将直接说你赢了得了",
      "你知道我要说什么吧",
      "我也充钱了！"
    }
    local selected = room:askToChoices(player, {
      choices = choices,
      min_num = 1,
      max_num = 3,
      skill_name = anguo.name,
      prompt = "安国：请选择让对方执行的效果",
      cancelable = true
    })
    player:chat(sayings[math.random(5)])
    if selected and #selected ~= 0 then
      if table.contains(choices, "全选") then
        selected = { "摸牌", "回复体力", "使用装备牌" }
      end
      doAnguo(target, selected, player)
    end
    selected = room:askToChoices(player, {
      choices = choices,
      min_num = 1,
      max_num = 3,
      skill_name = anguo.name,
      prompt = "安国：请选择让自己执行的效果",
      cancelable = true
    })
    if not selected or #selected == 0 then return end
    if table.contains(choices, "全选") then
      selected = { "摸牌", "回复体力", "使用装备牌" }
    end
    doAnguo(player, selected, player)
  end,
})

return anguo