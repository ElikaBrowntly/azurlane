local heg_description = [==[
# 双阴国战简介

本模式基于经典的国战模式，融合了狐狸服（现超银河传说）的特色玩法，重点如下：

## 准备游戏

**挑选武将：**

发给每位玩家的若干张武将牌，是从身份模式的武将中进行选择的。玩家选出两张势力相同的武将牌并背面朝上放置，称为“暗置”。

特别的，神/魔势力武将可以搭配任意势力武将并变为相同势力。若主将/副将均为神/魔势力，则在游戏开始时需要选择一个势力加入（其他人不可见）。

你也可以在设置中调整，使得主将为神将时可以任选势力。

**分发体力牌：**

每位玩家的体力上限，为两张武将牌的体力上限的平均数（向下取整）。

注：**若进行了向下取整，则当该角色的两张武将牌第一次均明置时，其获得一枚“阴阳鱼”。例如，司马懿3上限，张辽4上限，平均3.5上限，体力上限为3，获得一枚“阴阳鱼”。

奖惩方式：

1. **已经确定势力的角色杀死相同势力的角色须弃置所有手牌和装备区的牌**；
2. **已经确定势力的角色杀死不同势力的角色，摸等同于该势力人数（包括刚刚杀死的角色）张牌**；
3. 特别地，野心家击杀奖励为摸三张牌。

例：“蜀”势力角色杀死了一名“魏”势力角色，此时还有其他两名“魏”势力角色存活，则该“蜀”势力角色摸三张牌。

注：若被杀死的角色还没有明置武将牌（即没确定势力），则须明置所有武将牌，验明势力。 没有势力的角色（即武将牌没有明置的角色）杀死其他角色没有奖惩。

## 胜负结算

玩家的游戏目标与势力有关：**消灭所有与自己不同势力的角色**。

特殊的：野心家需要消灭所有其他角色。

当全场所有角色均确定势力后, 才可以进行胜利条件的判断:
当全场只剩下一种势力存活时, 该势力的角色获胜( 没有确定势力的角色无法取得游戏胜利, 即使与存活的其他角色为同一势力)。

## 暗将规则

**处于暗置状态的武将牌没有任何武将技能、性别以及势力**。当暗置的武将牌发动技能时，将武将牌明置，然后发动相应的技能。

一般地，**暗置的武将牌只有两个时机可以将武将牌明置：1. 回合开始时；2. 发动武将牌的技能时。**

例：郭嘉、司马懿等，受到伤害后发动技能时明置武将牌；
马超、黄忠等，使用【杀】指定一名角色为目标后，发动技能并明置武将牌；
孙权、甘宁等，在出牌阶段发动技能时明置武将牌；

（在网杀中，你需要“预亮”某些触发技，即点击技能到“预亮”状态，来让系统在相应的时机询问你是否发动技能亮将，如预亮郭嘉、马超等的遗计、铁骑。不“预亮”的技能不会询问。）

另外，**拥有锁定技的武将，可以在出牌阶段明置。** 例如：有〖咆哮〗的张飞、有〖马术〗的马超。

**全场游戏第一个明置武将的角色获得一枚“先驱”标记（参见段落“标记牌”）。

没有明置武将牌的角色没有性别，任何与性别有关的技能和武器效果均不能对其发动。

有一张武将牌明置时，角色性别与明置的武将牌相同。当一名角色的两张武将牌均亮明后，性别与主将的武将牌相同。

没有明置武将牌的角色没有势力，明置一张武将牌后确定势力：与武将牌左上角所示的势力相同，或成为野心家。野心家用“野心家牌”表示。（参见下一段“野心家规则”）。

野心家规则：

**当一名角色明置武将牌确定势力时，若该势力的角色超过了游戏总玩家数的一半，则他成为野心家**，拿取一张野心家牌表示。若之后仍然有该势力的角色明置武将牌，均视为野心家。**野心家为单独的一种势力**，与其他角色的势力均不同。他（们）需要杀死所有其他角色，成为唯一的存活者。

注意：野心家与野心家之间也是不同势力。

例：

★ 6 人、7 人游戏时，当出现第四名同势力角色时，该角色及之后明置的该势力角色均成为野心家。

★ 8 人、9 人游戏时，当出现第五名同势力角色时，该角色及之后明置的该势力角色均成为野心家。


## 标记牌

**阴阳鱼**：出牌阶段，你可弃一枚“阴阳鱼”，摸一张牌；弃牌阶段开始时，你可弃一枚“阴阳鱼”，此回合手牌上限+2。

**先驱**：出牌阶段，你可弃一枚“先驱”，将手牌摸至4张，观看一名其他角色的一张暗置武将牌。

## 鏖战

当游戏中仅剩4名或更少角色时（7人以下游戏时为3名或更少），若此时全场没有超过一名势力相同的角色，则从一个新的回合开始，游戏进入鏖战模式。

鏖战模式下，所有的【桃】只能当【杀】或【闪】使用或打出，不能用于回复体力。

]==]

local H = require "packages.hegemony.util"
local W = require "ui_emu.preferences"

local heg

---@class HegLogic: GameLogic
local HegLogic = {}

function HegLogic:assignRoles()
  local room = self.room
  for _, p in ipairs(room.players) do
    room:setPlayerProperty(p, "role_shown", false)
    p.role = "hidden"
    room:broadcastProperty(p, "role")
  end

  -- for adjustSeats
  room.players[1].role = "lord"
end

function HegLogic:chooseGenerals()
  local room = self.room
  local lord = room:getLord() --[[@as ServerPlayer]]
  room:setCurrent(lord)
  lord.role = "hidden"

  local allKingdoms = {} ---@type string[]
  table.forEach(room.general_pile, function(name)
    table.insertIfNeed(allKingdoms, Fk.generals[name].kingdom) -- 假设不会有只出现在副势力的势力
  end)

  if #allKingdoms > 4 and not room:getSettings("notBanToFourKingdoms") then -- 是否要禁至四个势力
    allKingdoms = table.random(allKingdoms, 4)
  end

  local generalNum = math.max(room:getSettings('generalNum'), #allKingdoms + 1) -- 抽屉原理
  room:doBroadcastNotify("ShowToast", Fk:translate("#yyfy_HegInitialNotice"))
  table.removeOne(allKingdoms, "wild")                                          -- 野心家势力不包括

  table.sort(allKingdoms)
  room:setBanner("all_kingdoms", allKingdoms)

  local players = room.players
  local generalNames = {}
  for _, g in ipairs(Fk:getAllGenerals()) do
    table.insertIfNeed(generalNames, g.name)
  end
  local generals = table.random(generalNames, #players * generalNum) ---@type string[]

  table.shuffle(generals)



  -- local req = Request:new(players, "AskForGeneral")
  -- req.timeout = self.room:getSettings('generalTimeout')

  -- 假设 generals 已经生成（全局武将列表），generalNum 已定义
  local playerGeneralPool = {}
  local playerGeneralsInfo = {}

  for k, p in ipairs(players) do
    local arg = table.slice(generals, (k - 1) * generalNum + 1, k * generalNum + 1)
    table.sort(arg, function(a, b) return Fk.generals[a].kingdom > Fk.generals[b].kingdom end)
    playerGeneralPool[p.id] = arg
    local info = {}
    for _, name in ipairs(arg) do
      local g = Fk.generals[name]
      table.insert(info, { name = name, kingdom = g.kingdom, subkingdom = g.subkingdom or "" })
    end
    playerGeneralsInfo[p.id] = info
  end

  -- 辅助函数：找默认组合
  local function getDefaultPair(cardList)
    for i = 1, #cardList - 1 do
      local g1 = Fk.generals[cardList[i]]
      local g2 = Fk.generals[cardList[i + 1]]
      if (g1.kingdom == "god" or g1.kingdom == "evil" or g2.kingdom == "god" or g2.kingdom == "evil") or
          (g1.kingdom == g2.kingdom and g1.kingdom ~= "wild") or
          (g1.subkingdom and g1.subkingdom == g2.kingdom) or
          (g2.subkingdom and g2.subkingdom == g1.kingdom) or
          (g1.subkingdom and g2.subkingdom and g1.subkingdom == g2.subkingdom) then
        return { cardList[i], cardList[i + 1] }
      end
    end
    return { cardList[1], cardList[2] }
  end

  -- 处理 AI：直接分配默认组合
  for _, p in ipairs(players) do
    if p.id < 0 then -- AI
      local defaultPair = getDefaultPair(playerGeneralPool[p.id])
      room:setPlayerMark(p, "__heg_general", defaultPair[1])
      room:setPlayerMark(p, "__heg_deputy", defaultPair[2])
      room:setPlayerGeneral(p, "anjiang", true)
      room:setDeputyGeneral(p, "anjiang")
    end
  end

  -- 处理人类玩家
  local humanPlayers = table.filter(players, function(p) return p.id > 0 end)

  local req = Request:new(humanPlayers, "CustomDialog")
  req.timeout = room:getSettings('generalTimeout')
  for _, p in ipairs(humanPlayers) do
    req:setData(p, {
      path = "packages/hidden-clouds/qml/HegemonyGeneralChoose.qml", -- 根据实际路径调整
      data = {
        generals = playerGeneralsInfo[p.id],
        prompt = "请选择主将"
      }
    })
    req:setDefaultReply(p, getDefaultPair(playerGeneralPool[p.id]))
  end
  req:ask()
  for _, p in ipairs(humanPlayers) do
    local result = req:getResult(p)
    if type(result) ~= "table" or #result < 2 then
      result = req.default_reply[p.id]
    end
    local general, deputy = result[1], result[2]
    room:setPlayerMark(p, "__heg_general", general)
    room:setPlayerMark(p, "__heg_deputy", deputy)
    room:setPlayerGeneral(p, "anjiang", true)
    room:setDeputyGeneral(p, "anjiang")
  end

  req = Request:new(players, "AskForChoice")
  req.focus_text = "AskForKingdom"
  req.receive_decode = false

  -- 确保 allKingdoms 包含所有玩家武将的势力（避免遗漏自定义势力）
  local function ensureAllKingdomsContainsPlayerKingdoms(room, players, allKingdoms)
    for _, p in ipairs(players) do
      local mainName = p:getMark("__heg_general")
      local deputyName = p:getMark("__heg_deputy")
      if mainName and mainName ~= "anjiang" then
        local g = Fk.generals[mainName]
        if g then
          table.insertIfNeed(allKingdoms, g.kingdom)
          if g.subkingdom then table.insertIfNeed(allKingdoms, g.subkingdom) end
        end
      end
      if deputyName and deputyName ~= "anjiang" then
        local g = Fk.generals[deputyName]
        if g then
          table.insertIfNeed(allKingdoms, g.kingdom)
          if g.subkingdom then table.insertIfNeed(allKingdoms, g.subkingdom) end
        end
      end
    end
    table.removeOne(allKingdoms, "wild")
    table.sort(allKingdoms)
  end

  -- 在调用 ensureAllKingdomsContainsPlayerKingdoms 之前，先确保 allKingdoms 已包含基础势力
  -- 原代码中 allKingdoms 已从 room.general_pile 获取，这里再补充玩家武将中的势力
  ensureAllKingdomsContainsPlayerKingdoms(room, players, allKingdoms)

  for _, p in ipairs(players) do
    local mainGen = Fk.generals[p:getMark("__heg_general")]
    local deputyGen = Fk.generals[p:getMark("__heg_deputy")]
    -- 收集主将势力列表（去 nil）
    local mainKingdoms = {}
    if mainGen.kingdom then table.insert(mainKingdoms, mainGen.kingdom) end
    if mainGen.subkingdom then table.insert(mainKingdoms, mainGen.subkingdom) end

    -- 收集副将势力列表（去 nil）
    local deputyKingdoms = {}
    if deputyGen.kingdom then table.insert(deputyKingdoms, deputyGen.kingdom) end
    if deputyGen.subkingdom then table.insert(deputyKingdoms, deputyGen.subkingdom) end

    local kingdoms = {}

    -- 野心家处理（主将为 wild 时，使用副将势力列表）
    if mainGen.kingdom == "wild" then
      room:setPlayerMark(p, "__heg_wild", 1)
      kingdoms = deputyKingdoms
      -- 神/魔主将：看设置是否允许任选势力
    elseif mainGen.kingdom == "god" or mainGen.kingdom == "evil" then
      if room:getSettings("no_limit_god_kingdom")  -- 没限制的话，神将任选势力
      or deputyGen.kingdom == "god" or deputyGen.kingdom == "evil"
      or deputyGen.kingdom == "wild" then -- 有限制但副将也是万能势力的话，允许任选势力
        kingdoms = table.simpleClone(allKingdoms)
      else
        kingdoms = table.simpleClone(deputyKingdoms) -- 否则，势力跟着副将势力走
      end
      
    else
      -- 普通情况：取主将与副将的势力交集
      for _, mk in ipairs(mainKingdoms) do
        if table.contains(deputyKingdoms, mk) then
          table.insertIfNeed(kingdoms, mk)
        end
      end
      -- 如果交集为空（比如说副将是神/魔），回退到主将势力列表
      if #kingdoms == 0 then
        kingdoms = mainKingdoms
      end
    end

    -- 特殊测试：如果包含谋徐盛，加入 wu 势力
    if not table.contains(allKingdoms, "wu") and
        (p:getMark("__heg_deputy") == "mouxusheng" or p:getMark("__heg_general") == "mouxusheng") then
      table.insert(kingdoms, "wu")
      table.insert(allKingdoms, "wu")
    end

    -- 如果 kingdoms 仍然为空（例如势力信息没有成功加载），则给予一个默认值（allKingdoms）
    if #kingdoms == 0 then
      kingdoms = table.clone(allKingdoms)
    end
    req:setData(p, { kingdoms, allKingdoms, "AskForKingdom", "#ChooseHegInitialKingdom" })
    req:setDefaultReply(p, kingdoms[1])
  end

  for _, p in ipairs(players) do
    local kingdomChosen = req:getResult(p)
    room:setPlayerMark(p, "__heg_kingdom", kingdomChosen)      -- 变野后变为wild
    room:setPlayerMark(p, "__heg_init_kingdom", kingdomChosen) -- 保存初始势力
    -- p.kingdom = kingdomChosen
    --room:notifyProperty(p, p, "kingdom")
  end
end

function HegLogic:broadcastGeneral()
  local room = self.room
  local players = room.players

  for _, p in ipairs(players) do
    assert(p.general ~= "")
    local general = Fk.generals[p:getMark("__heg_general")]
    local deputy = Fk.generals[p:getMark("__heg_deputy")]
    local dmaxHp = deputy.maxHp + deputy.deputyMaxHpAdjustedValue
    local gmaxHp = general.maxHp + general.mainMaxHpAdjustedValue
    p.maxHp = (dmaxHp + gmaxHp) // 2
    -- p.hp = math.floor((deputy.hp + general.hp) / 2)
    p.hp = p.maxHp
    -- p.shield = math.min(general.shield + deputy.shield, 5)
    p.shield = 0
    -- TODO: setup AI here

    room:broadcastProperty(p, "general")
    room:broadcastProperty(p, "deputyGeneral")
    room:broadcastProperty(p, "maxHp")
    room:broadcastProperty(p, "hp")
    room:broadcastProperty(p, "shield")

    p.role = p:getMark("__heg_wild") == 1 and "wild" or p:getMark("__heg_kingdom") -- general.kingdom -- 为了死亡时log有势力提示

    if (dmaxHp + gmaxHp) % 2 == 1 then
      p:setMark("HalfMaxHpLeft", 1)
      p:doNotify("SetPlayerMark", { p.id, "HalfMaxHpLeft", 1 })
    end
    if general:isCompanionWith(deputy) then
      p:setMark("CompanionEffect", 1)
      p:doNotify("SetPlayerMark", { p.id, "CompanionEffect", 1 })
    end
  end
end

function HegLogic:prepareDrawPile()
  GameLogic.prepareDrawPile(self)

  local room = self.room
  local allianceCards = table.clone(H.allianceCards)
  local addAllianceMark = function(c)
    for i = #allianceCards, 1, -1 do
      local cc = allianceCards[i]
      if c.name == cc[1] and c.suit == cc[2] and c.number == cc[3] then
        room:setCardMark(c, "@@alliance-public", 1)
        table.remove(allianceCards, i)
        break
      end
    end
  end
  for _, cid in ipairs(room.draw_pile) do
    addAllianceMark(Fk:getCardById(cid))
  end
  for _, cid in ipairs(room.void) do
    addAllianceMark(Fk:getCardById(cid))
  end
end

local function addHegSkill(player, skill, room)
  player:addFakeSkill(skill)
  local toget = { table.unpack(skill.related_skills) }
  table.insert(toget, skill)
  for _, s in ipairs(toget) do
    if s:isInstanceOf(TriggerSkill) then
      room.logic:addTriggerSkill(s)
    end
  end
end

function HegLogic:attachSkillToPlayers()
  local room = self.room
  local players = room.alive_players
  for _, p in ipairs(players) do
    -- UI
    p:setMark("@seat", "seat#" .. tostring(p.seat))
    p:doNotify("SetPlayerMark", { p.id, "@seat", "seat#" .. tostring(p.seat) })

    local general = Fk.generals[p:getMark("__heg_general")]
    local skills = general:getSkillNameList(true)
    local hasRevealSkill = false
    for _, sn in ipairs(skills) do
      local s = Fk.skills[sn]
      if not s:hasTag(Skill.DeputyPlace) then
        addHegSkill(p, s, room)
        if not hasRevealSkill and s:hasTag(Skill.Compulsory) then
          hasRevealSkill = true
        end
      end
    end

    local deputy = Fk.generals[p:getMark("__heg_deputy")]
    if deputy then
      skills = deputy:getSkillNameList(true)
      for _, sn in ipairs(skills) do
        local s = Fk.skills[sn]
        if not s:hasTag(Skill.MainPlace) then
          addHegSkill(p, s, room)
          if not hasRevealSkill and s:hasTag(Skill.Compulsory) then
            hasRevealSkill = true
          end
        end
      end
    end

    if hasRevealSkill then
      p:addFakeSkill("reveal_skill&")
    end
  end

  -- 观看下家副将
  if room:getSettings("watchNextDeputy") and not room:getSettings("revealAllOnStart") then
    room:sendLog {
      type = "#WatchNextPlayerDeputyLog",
    }
    local req = Request:new(players, "CustomDialog")
    req.focus_text = "heg_watch_next_deputy"
    local path = "packages/hegemony/qml/KnownBothBox.qml"
    for _, p in ipairs(players) do
      local next = p:getNextAlive()
      local dat = { next.general, next:getMark("__heg_deputy"), tostring(next.seat) }
      req:setData(p, {
        path = path,
        data = dat,
      })
      p:doNotify("GameLog", {
        type = "#WatchGeneral",
        from = p.id,
        to = { next.id },
        arg = "deputyGeneral",
        arg2 = next:getMark("__heg_deputy"),
      })
    end
    req:ask()
  end

  room:doBroadcastNotify("ShowToast", Fk:translate("#yyfy_HegInitialNotice"))
end

local heg_getLogic = function()
  local h = GameLogic:subclass("HegLogic")
  for k, v in pairs(HegLogic) do
    h[k] = v
  end
  return h
end

local settings = {
  W.PreferenceGroup {
    title = "hegemony_additional_rule",

    W.SwitchRow {
      _settingsKey = "watchNextDeputy",
      title = "heg_watch_next_deputy",
    },

    W.SwitchRow {
      _settingsKey = "notBanToFourKingdoms",
      title = "heg_not_ban_to_four_kingdoms",
    },

    W.SwitchRow {
      _settingsKey = "enterBattleRoyalOnFirstShuffle",
      title = "heg_enter_battle_royal_on_first_shuffle",
    },

    W.SpinRow {
      _settingsKey = "deckThickness",
      title = "牌堆倍数",
      from = 1,
      to = 10
    },
  },

  W.PreferenceGroup {
    title = "hegemony_special_rule",

    W.SwitchRow {
      _settingsKey = "revealAllOnStart",
      title = "heg_reveal_all_on_start",
    },
    W.SwitchRow {
      _settingsKey = "no_limit_god_kingdom",
      title = "no_limit_god_kingdom",
    }
  }
}

heg = fk.CreateGameMode {
  name = "yyfy_hegemony",
  minPlayer = 2,
  maxPlayer = 10,
  rule = "heg_rule",
  logic = heg_getLogic,
  is_counted = function(self, room)
    return #room.players >= 6
  end,
  whitelist = function(self, pkg)
    return pkg.name == "hegemony_cards" or pkg.type ~= Package.CardPack
  end,
  blacklist = { -- ban掉原本的国战将
    "hegemony_standard",
    "formation",
    "momentum",
    "transformation",
    "power",
    "strategic_advantage",
    "tenyear_heg",
    "overseas_heg",
    "lord_ex",
    "offline_heg",
    "zqdl",
    "jyzs",
    "mobile_heg",
    "online_heg",
  },
  winner_getter = function(self, victim)
    local room = victim.room
    local alive = table.filter(room.alive_players, function(p)
      return not p.surrendered
    end)
    local kingdom = ""
    if #alive == 1 then
      kingdom = alive[1].role
    end
    local winner -- = alive[1]
    for _, p in ipairs(alive) do
      if p.kingdom ~= "unknown" then
        winner = p
        break
      end
    end
    if not winner then return "" end
    kingdom = H.getKingdom(winner)
    local i = H.getKingdomPlayersNum(room, true)[kingdom]
    for _, p in ipairs(alive) do
      if not H.compareExpectedKingdomWith(p, winner) then
        return ""
      end
      if p.kingdom == "unknown" then
        i = i + 1
      end
    end
    if i > #room.players // 2 and not H.getHegLord(room, winner) then return "" end
    for _, p in ipairs(room.players) do
      if p.general == "anjiang" then
        room:setPlayerProperty(p, "general", p:getMark("__heg_general"))
      end
      if p.deputyGeneral == "anjiang" then
        room:setPlayerProperty(p, "deputyGeneral", p:getMark("__heg_deputy"))
      end
    end
    return kingdom
  end,
  surrender_func = function(self, playedTime)
    local winner
    local kingdomCheck = true
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      -- 场上有未明置的主将时不能投降
      if p.general == "anjiang" then
        kingdomCheck = false
        break
      end
      if p ~= Self then
        if not winner then
          winner = p
        elseif not H.compareKingdomWith(winner, p) then
          kingdomCheck = false
          break
        end
      end
    end
    return { { text = "heg: besieged on all sides", passed = kingdomCheck } }
  end,

  build_draw_pile = function(self)
    local room = Fk:currentRoom()
    local draw, void = GameMode.buildDrawPile(self)
    if not Fk.packages["hegemony_cards"] then return draw, void end
    local thickness = room:getSettings('deckThickness')
    local cards = table.simpleClone(Fk.packages["hegemony_cards"].cards)
    if Fk.packages["lord_cards"] and table.contains(room.disabled_packs, "lord_cards") then
      table.insertTable(cards, Fk.packages["lord_cards"].cards)
    end
    table.removeOne(Fk:currentRoom().disabled_packs, "hegemony_cards")
    local printed = table.simpleClone(cards)
    while thickness > 1 do
      for _, c in ipairs(cards) do
        local new_card = room:printCard(c.name, c.suit, c.number)
        table.insert(printed, new_card)
      end
      thickness = thickness - 1
    end
    for _, c in ipairs(printed) do
      table.insert(draw, c.id)
    end
    return draw, void
  end,

  reward_punish = function(self, victim, killer)
    local room = victim.room
    if killer then
      if killer.kingdom ~= "unknown" and not killer.dead then
        local times = 1
        if room:getBanner("additional_reward") then
          times = 1 + room:getBanner("additional_reward")
        end
        -- 因为建国，修改奖惩；如果还没建国
        if killer.kingdom == "wild" and killer:getMark("__heg_construct_wild") == 0 and killer:getMark("__heg_join_wild") == 0 then
          killer:drawCards(times * 3, "kill")
        elseif H.compareKingdomWith(killer, victim) and not (room.logic:getCurrentEvent():findParent(GameEvent.Death, true).data.extra_data or {}).ignorePunishment then --朱灵
          killer:throwAllCards("he")
        else
          killer:drawCards(times * (H.getSameKingdomPlayersNum(room, victim) + 1), "kill")
        end
      end
    end
    if string.find(victim.general, "lord") then
      local players = (table.filter(room.players, function(p)
        return
            (p:getMark("__heg_kingdom") == victim.kingdom or (p.dead and p.kingdom == victim.kingdom)) and p ~= victim and
            p.kingdom ~= "wild"
      end))
      room:sortByAction(players)
      local function wildChooseKingdom(player, generalName)
        local allKingdoms = room:getBanner("all_kingdoms")
        table.insertTable(allKingdoms, { "unknown", "hidden" })

        local choice
        local all_choices = table.clone(H.wildKingdoms)
        local choices = table.clone(all_choices)
        for _, p in ipairs(room.players) do
          table.removeOne(choices, p.role)
        end
        if player.general == generalName and H.kingdomMapper[generalName] and H.kingdomMapper[generalName] ~= player.role then -- 野心家钦定
          if table.contains(choices, H.kingdomMapper[generalName]) then
            choice = H.kingdomMapper[generalName]
          else
            choice = room:askToChoice(player, {
              choices = choices,
              skill_name = "heg_rule",
              prompt = "#wild-choose",
              cancelable = false,
              all_choices = all_choices,
            })
          end
        elseif table.contains(allKingdoms, player.role) then
          choice = room:askToChoice(player, {
            choices = choices,
            skill_name = "heg_rule",
            prompt = "#wild-choose",
            cancelable = false,
            all_choices = all_choices,
          })
        end
        if choice then
          player.role = choice
          room:setPlayerProperty(player, "role_shown", true)
          room:broadcastProperty(player, "role")
          room:sendLog {
            type = "#WildChooseKingdom",
            from = player.id,
            arg = choice,
            arg2 = "wild",
          }
        end
      end
      for _, p in ipairs(players) do
        local oldKingdom = p.kingdom
        room:setPlayerMark(p, "__heg_kingdom", "wild")
        if oldKingdom ~= "unknown" then
          room:setPlayerProperty(p, "kingdom", "wild")
          if not p.dead then
            wildChooseKingdom(p, p.general)
          end
        end
      end
    end
  end,
  friend_enemy_judge = function(self, targetOne, targetTwo)
    return H.compareExpectedKingdomWith(targetOne, targetTwo)
  end,
  ui_settings = settings,
}

Fk:loadTranslationTable {
  ["yyfy_hegemony"] = "双阴国战(测试版)",
  [":yyfy_hegemony"] = heg_description,
  ["#KingdomFiltered"] = "本局移除 %arg，使用 %arg2 4个势力",
  ["#ChooseHegInitialKingdom"] = "国战规则：选择你的初始势力",
  ["wild"] = "野心家",
  ["heg_rule"] = "国战规则",
  ["revealAll"] = "全部明置",
  ["#EnterBattleRoyalMode"] = "游戏进入 <font color=\"red\"><b>鏖战模式</b></font>，所有的【<font color=\"#3598E8\"><b>桃</b></font>】" ..
      "只能当【<font color=\"#3598E8\"><b>杀</b></font>】或【<font color=\"#3598E8\"><b>闪</b></font>】使用或打出，不能用于回复体力",
  ["#EnterBattleRoyalModeLog"] = "游戏进入 <font color=\"#CC3131\"><b>鏖战模式</b></font>",
  ["@[:]BattleRoyalDummy"] = "", -- 额
  ["BattleRoyalMode"] = "鏖战模式",
  [":BattleRoyalMode"] = "所有的【<font color=\"#3598E8\"><b>桃</b></font>】" ..
      "只能当【<font color=\"#3598E8\"><b>杀</b></font>】或【<font color=\"#3598E8\"><b>闪</b></font>】使用或打出，不能用于回复体力",
  ["#wild-choose"] = "野心家建国：选择你要成为的势力！",
  ["heg_qin"] = "秦",
  ["heg_qi"] = "齐",
  ["heg_chu"] = "楚",
  ["heg_yan"] = "燕",
  ["heg_zhao"] = "赵",
  ["heg_hanr"] = "韩",
  ["heg_jin"] = "晋", -- 和真的晋是两个势力
  ["heg_han"] = "汉",
  ["heg_xia"] = "夏",
  ["heg_shang"] = "商",
  ["heg_zhou"] = "周",
  ["heg_liang"] = "凉",
  ["#WildChooseKingdom"] = "%from 成为 %arg2 ，选择了势力 %arg",
  ["heg: besieged on all sides"] = "四面楚歌，被同一势力围观；所有主将都已亮",
  ["@@alliance"] = "合",
  ["@@alliance-public"] = "合",
  ["@@alliance-inhand"] = "合",
  ["@@alliance-inhand-turn"] = "合",
  ["@seat"] = "",
  ["stack"] = "叠置",

  ["hegemony_additional_rule"] = "国战附加规则",
  ["heg_watch_next_deputy"] = "观看下家副将",
  ["help: heg_watch_next_deputy"] = "游戏开始前观看下家的副将",
  ["heg_enter_battle_royal_on_first_shuffle"] = "第一次洗牌进入鏖战",
  ["heg_not_ban_to_four_kingdoms"] = "不禁用至四个势力",
  ["help: heg_not_ban_to_four_kingdoms"] = "保留所有势力。请确认选将数量和将池以保证至少有一对武将可选",
  ["deckThickness"] = "牌堆厚度",
  ["help: deckThickness"] = "调整牌堆倍数，默认为1",
  ["no_limit_god_kingdom"] = "神将任选势力",
  ["help: no_limit_god_kingdom"] = "开启后，仅限主将为神将时，可以任选势力加入",

  ["hegemony_special_rule"] = "特殊规则",
  ["heg_reveal_all_on_start"] = "全亮国战",
  ["help: heg_reveal_all_on_start"] = "游戏开始时所有角色依次亮出所有武将",

  ["#SuccessBuildCountry"] = "%from 成功建立国家，国号 %arg ，队友是 %arg2",
  ["heg_rule_join_country"] = "加入 <b><font color='purple'>%src</font></b> 的阵营 <b><font color='purple'>%arg</font></b>，回复1点体力，将手牌摸至4张",
  ["heg_build_country"] = "拉拢人心，询问其他角色加入 <b><font color='purple'>%arg</font></b>",

  ["#WatchNextPlayerDeputyLog"] = "每名角色观看下家的副将",

  ["#yyfy_HegInitialNotice"] = "提示：<b><font color='purple'>模式规则</font></b><b>已上线</b>，请在创建房间页面中查看",
}

return heg
