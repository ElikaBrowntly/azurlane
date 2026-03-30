local huamu = fk.CreateSkill{
  name = "lan__huamu",
  derived_piles = {"lan__huamu_yushu", "lan__huamu_lingshan"},
}

local F = require("packages.hidden-clouds.functions")

Fk:loadTranslationTable{
  ["lan__huamu"] = "化木",
  [":lan__huamu"] = "当你使用非装备手牌后，你可以将此牌置于你的武将牌上，<font color='blue'>黑</font>/"..
  "<font color='red'>红</font>色牌称为<font color='blue'>「灵杉」</font>/<font color='red'>"..
  "「玉树」</font>。若此牌与本回合被使用的上一张牌颜色不同，你摸一张牌。",

  ["lan__huamu_lingshan"] = "灵杉",
  ["lan__huamu_yushu"] = "玉树",

  ["$lan__huamu1"] = "四月寻春花更香。",
  ["$lan__huamu2"] = "一树樱桃带雨红。",
  ["$lan__huamu3"] = "山重水复，心有灵犀。",
  ["$lan__huamu4"] = "灵之来兮如云。",
  ["$lan__huamu5"] = "山有木兮木有枝，心悦君兮知不知？",
  ["$lan__huamu6"] = "蝶沐芳菲，我见青山多妩媚，万般总是君。",
}

huamu:addEffect(fk.CardUseFinished, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if player ~= target or not player:hasSkill(self) or not data:isUsingHandcard(player) then return end
    local room = player.room
    local card_ids = Card:getIdList(data.card)
    if #card_ids == 0 then return end
    if data.card.type == Card.TypeEquip then
      if not table.every(card_ids, function (id)
        return table.contains(player:getCardIds("e"), id)
      end) then return end
    else
      if not table.every(card_ids, function (id)
        return room:getCardArea(id) == Card.Processing
      end) then return end
    end
    local yes = false
    room.logic:getEventsByRule(GameEvent.UseCard, 1, function (e)
      if e.id < room.logic:getCurrentEvent().id then
        yes = e.data.card.color ~= data.card.color or data.card.color == Card.NoColor
        return true
      end
    end, nil, Player.HistoryTurn)
    if yes then
      local costdata = event:getCostData(self) or {}
      costdata.draw = true
      event:setCostData(self, costdata)
    end
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_ids = Card:getIdList(data.card)
    -- 换个皮肤先
    local skindata = {}
    local path = ""
    if F.setEmotion(player, "lan__caoxiancaohua__2", huamu.name, 0, "", true) then
      path = "packages/hidden-clouds/image/skins/lan__caoxiancaohua__3.gif"
    elseif F.setEmotion(player, "lan__caoxiancaohua__3", huamu.name, 0, "", true) then
      path = "packages/hidden-clouds/image/skins/lan__caoxiancaohua__2.gif"
    end
    if F.ends_with(player.general, "caoxiancaohua") then
      skindata = { player.id, "changeskin", path, "" }
    elseif F.ends_with(player.deputyGeneral, "caoxiancaohua") then
      skindata = { player.id, "changeskin", "", path }
    end
    if skindata ~= {} and path ~= "" then
      room:doBroadcastNotify("ChangeSkin", skindata)
    end
    local reds, blacks = {}, {}
    for _, id in ipairs(card_ids) do
      local color = Fk:getCardById(id).color
      if color == Card.Red then
        table.insert(reds, id)
      elseif color == Card.Black then
        table.insert(blacks, id)
      end
    end
    local moveInfos = {}
    local audio_case = 3
    if #reds > 0 then
      table.insert(moveInfos, {
        ids = reds,
        from = data.card.type == Card.TypeEquip and player or nil,
        to = player,
        toArea = Card.PlayerSpecial,
        moveReason = fk.ReasonJustMove,
        skillName = huamu.name,
        specialName = "lan__huamu_yushu",
        moveVisible = true,
        proposer = player,
      })
      audio_case = audio_case - 2
    end
    if #blacks > 0 then
      table.insert(moveInfos, {
        ids = blacks,
        from = data.card.type == Card.TypeEquip and player or nil,
        to = player,
        toArea = Card.PlayerSpecial,
        moveReason = fk.ReasonJustMove,
        skillName = huamu.name,
        specialName = "lan__huamu_lingshan",
        moveVisible = true,
        proposer = player,
      })
      audio_case = audio_case - 1
    end
    if #moveInfos > 0 then
      room:notifySkillInvoked(player, huamu.name)
      player:broadcastSkillInvoke(huamu.name, audio_case * 2 + math.random(2))
      room:moveCards(table.unpack(moveInfos))
    end
    local costdata = event:getCostData(self) or {}
    if costdata.draw then
      room:drawCards(player, 1, huamu.name)
    end
  end,
})

-- 动皮登场
huamu:addEffect(fk.TurnStart, {
  priority = 11,
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true)
  end,
  on_refresh = function (self, event, target, player, data)
    F.setEmotion(player, "lan__caoxiancaohua__2", huamu.name, 0, "caoxiancaohua2.qml")
    F.setEmotion(player, "lan__caoxiancaohua__3", huamu.name, 0, "caoxiancaohua3.qml")
  end
})

return huamu