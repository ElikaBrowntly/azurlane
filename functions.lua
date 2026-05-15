local functions = {}

local okG, G = pcall(require, "packages.glory_days.utility")

-- 初始化皮肤相关表
functions.Skins = functions.Skins or {}
functions.ExchangeItems = functions.ExchangeItems or {}
functions.PendingSkins = functions.PendingSkins or {}
functions.Initialized = functions.Initialized or false

function functions.resolveSkinData(skinData)
  local generals = { skinData.general }
  local extra = skinData.extra or {}
  if #extra > 0 then
    table.insertTableIfNeed(generals, extra)
  end

  local unprefixs = skinData.unprefixs or {}
  if Fk.generals then
    for name, general in pairs(Fk.generals) do
      if general.trueName == skinData.general and general.package.extensionName ~= "delight" then
        local skip = false
        if #unprefixs > 0 then
          for _, unprefix in pairs(unprefixs) do
            if name == unprefix .. "__" .. skinData.general then
              skip = true
              break
            end
          end
        end
        if not skip then
          table.insertIfNeed(generals, name)
        end
      end
    end
  end

  local mapper = { ["legend"] = 88888, ["epic"] = 40000, ["rare"] = 11111, ["good"] = 900, ["common"] = 400 }
  for _, general in pairs(generals) do
    functions.Skins[general] = functions.Skins[general] or {}
    table.insert(functions.Skins[general], {
      path = skinData.path,
      quality = skinData.quality or "common",
      price = skinData.price or mapper[skinData.quality or "common"]
    })
  end
end

function functions.checkInit()
  if not functions.Initialized and Fk.generals and next(Fk.generals) then
    functions.Initialized = true
    for _, data in ipairs(functions.PendingSkins) do
      functions.resolveSkinData(data)
    end
    functions.PendingSkins = {}
  end
end

-- 判断两个角色之间是否为敌对关系
---@param from Player|ServerPlayer
---@param to Player|ServerPlayer
---@return boolean
function functions.isEnemy(from, to)
  if from.id == to.id then return false end -- 自己不是敌人
  local mode = from.room and from.room:getSettings('gameMode')
  local isHeg = mode == "yyfy_hegemony" or mode == "new_heg_mode"
  if isHeg then
    return from.role ~= to.role
  end
  if from.role == "lord" or from.role == "loyalist" then
    return (to.role ~= "lord" and to.role ~= "loyalist")
  elseif from.role == "rebel" then -- 反贼没必要敌视内奸
    return (to.role == "lord" or to.role == "loyalist")
  elseif from.role == "renegade" then
    return true -- 内奸视所有其他角色为敌人
  end
  return false  -- 默认不是敌人
end

--- 获取 player 的存活队友数量，包括自己
---@param player Player|ServerPlayer 主视角
---@param room Room|AbstractRoom 所在房间
---@return integer --队友数量
function functions.teammatesNum(player, room)
  local count = 0
  for _, p in ipairs(room.alive_players) do
    if not (functions.isEnemy(p, player) or p.role == "renegade" or player.role == "renegade") then
      count = count + 1
    end
  end
  return count
end

-- 从技能名提取卡牌名的泛用函数
-- 支持以下格式：
-- 1. 装备技能直接返回关联装备，确保正确
-- 2. 基本牌和锦囊牌的"xxx_skill"，（如"slash_skill"）→ "slash"
-- 3. "#xxx_skill&"（后缀&仅存在于丈八蛇矛，原因不明。#&虽然当前没有，但考虑兼容性）
---@param skillName string 要提取的技能名
function functions.getCardNameFromSkillName(skillName)
  if not skillName then return nil end
  local skill = Fk.skills[skillName]
  if skill:getSkeleton() and skill:getSkeleton().attached_equip then
    return skill:getSkeleton().attached_equip
  end
  -- 使用模式匹配提取卡牌名
  -- 模式解释：
  -- ^#?        开头可选#
  -- (.-)       非贪婪匹配任意字符（卡牌名）
  -- _skill&?$  以_skill结尾，可选跟着&
  local cardName = skill:getSkeleton().name:match("^#?(.-)_skill&?$")

  -- 如果匹配成功，返回卡牌名，否则返回nil
  return cardName
end

-- 检查一张牌是不是“句”
---@param card Card
function functions.isJv(card)
  local JV_CARDS = {
    ["yyfy_jv_basic"] = true,
    ["yyfy_jv_trick"] = true,
    ["yyfy_jv_weapon"] = true,
    ["yyfy_jv_armor"] = true,
    ["yyfy_jv_defensive"] = true,
    ["yyfy_jv_offensive"] = true,
    ["yyfy_jv_treasure"] = true,
  }
  return JV_CARDS[card.name] or false
end

---用于终贾诩，
---给目标贴帷幕牌。获取的牌如果不是，放到处理区，存到表里面，如果是，贴上去，然后把表里的逆序放回牌堆顶
---@param player ServerPlayer
---@param target ServerPlayer
---@param color integer
---@param skillName string
---@return Card | nil
function functions.getWeimu(player, target, color, skillName)
  local room = player.room
  local num = #room.draw_pile
  local i = 1
  while i <= num do
    if #room.draw_pile == 0 then break end
    local card = Fk:getCardById(room.draw_pile[i])
    if card.color == color then
      room:moveCards({
        ids = { card.id },
        toArea = Card.PlayerSpecial,
        to = target,
        moveReason = fk.ReasonJustMove,
        skillName = skillName,
        specialName = "yyfy_weimu-pile",
        moveVisible = true,
        proposer = player
      })
      return card
    end
    i = i + 1
  end
  return nil
end

-- 数字映射（小写+大写）
local chinese_digits = {
  ["零"] = 0,
  ["一"] = 1,
  ["二"] = 2,
  ["三"] = 3,
  ["四"] = 4,
  ["五"] = 5,
  ["六"] = 6,
  ["七"] = 7,
  ["八"] = 8,
  ["九"] = 9,
  ["壹"] = 1,
  ["贰"] = 2,
  ["叁"] = 3,
  ["肆"] = 4,
  ["伍"] = 5,
  ["陆"] = 6,
  ["柒"] = 7,
  ["捌"] = 8,
  ["玖"] = 9,
}

-- 单位映射（包含大写）
local chinese_units = {
  ["十"] = 10,
  ["百"] = 100,
  ["千"] = 1000,
  ["拾"] = 10,
  ["佰"] = 100,
  ["仟"] = 1000,
  ["万"] = 10000,
  ["亿"] = 100000000,
}

-- 判断字符是否是汉字数字相关（用于提取）
local function is_chinese_num_char(ch)
  return chinese_digits[ch] or chinese_units[ch] or ch == "点"
end

-- 遍历 UTF-8 字符串的每个字符
local function iter_utf8_chars(s)
  local i = 1
  return function()
    if i > #s then return nil end
    local b = s:byte(i)
    local len = (b < 0x80) and 1 or (b < 0xE0) and 2 or (b < 0xF0) and 3 or 4
    local char = s:sub(i, i + len - 1)
    i = i + len
    return char
  end
end

-- 解析不含“万”“亿”的汉字数字段（如“三百二十”）
local function parse_section(sec)
  if #sec == 0 then return 0 end
  local val, cur = 0, 0
  for ch in iter_utf8_chars(sec) do
    local d = chinese_digits[ch]
    local u = chinese_units[ch]
    if d then
      cur = d
    elseif u then
      if u == 10 then
        cur = cur == 0 and 1 or cur
        val = val + cur * u
        cur = 0
      elseif u == 100 or u == 1000 then
        val = val + (cur == 0 and u or cur * u)
        cur = 0
      else -- 万、亿（在段内出现时，作为乘法处理）
        cur = cur == 0 and 1 or cur
        val = val + cur * u
        cur = 0
      end
    end
  end
  return val + cur
end

-- 汉字数字转数字（支持整数、小数、复合单位）
local function chineseToNumber(str)
  if not str or #str == 0 then return nil end

  -- 分离整数和小数部分
  local int_part, dec_part = str:match("^(.+)点(.+)$")
  if not int_part then
    int_part = str
    dec_part = nil
  end

  -- 按“亿”“万”分段
  local parts = {}
  local billion_pos = int_part:find("亿")
  local million_pos = int_part:find("万")

  if billion_pos then
    -- 亿之前
    local before = int_part:sub(1, billion_pos - 1)
    if #before > 0 then table.insert(parts, { val = parse_section(before), mul = 100000000 }) end
    -- 亿之后、万之前
    if million_pos and million_pos > billion_pos then
      local between = int_part:sub(billion_pos + 1, million_pos - 1)
      if #between > 0 then table.insert(parts, { val = parse_section(between), mul = 10000 }) end
      -- 万之后
      local after = int_part:sub(million_pos + 1)
      if #after > 0 then table.insert(parts, { val = parse_section(after), mul = 1 }) end
    else
      -- 只有亿没有万
      local after = int_part:sub(billion_pos + 1)
      if #after > 0 then table.insert(parts, { val = parse_section(after), mul = 1 }) end
    end
  elseif million_pos then
    -- 只有万
    local before = int_part:sub(1, million_pos - 1)
    if #before > 0 then table.insert(parts, { val = parse_section(before), mul = 10000 }) end
    local after = int_part:sub(million_pos + 1)
    if #after > 0 then table.insert(parts, { val = parse_section(after), mul = 1 }) end
  else
    -- 无单位
    table.insert(parts, { val = parse_section(int_part), mul = 1 })
  end

  local total = 0
  for _, p in ipairs(parts) do
    total = total + p.val * p.mul
  end

  -- 处理小数部分
  if dec_part then
    local dec_val = 0
    local scale = 0.1
    for ch in iter_utf8_chars(dec_part) do
      local d = chinese_digits[ch] or 0
      dec_val = dec_val + d * scale
      scale = scale * 0.1
    end
    total = total + dec_val
  end

  return total
end

-- 主函数：提取字符串中所有数字（阿拉伯+汉字）并求和
functions = functions or {}
function functions.sumNumbersInString(str)
  if type(str) ~= "string" or #str == 0 then return 0 end

  local sum = 0
  local i = 1
  local chars = {}
  for ch in iter_utf8_chars(str) do
    chars[#chars + 1] = ch
  end

  local len = #chars
  local pos = 1

  while pos <= len do
    local ch = chars[pos]
    -- 负数
    if ch == "-" then
      local num_str = "-"
      pos = pos + 1
      while pos <= len do
        local c = chars[pos]
        if c:match("%d") or c == "." then
          num_str = num_str .. c
          pos = pos + 1
        else
          break
        end
      end
      local n = tonumber(num_str)
      if n then sum = sum + n end
      goto next
    end

    -- 阿拉伯数字（含小数点）
    if ch:match("%d") then
      local num_str = ""
      while pos <= len do
        local c = chars[pos]
        if c:match("%d") or c == "." then
          num_str = num_str .. c
          pos = pos + 1
        else
          break
        end
      end
      local n = tonumber(num_str)
      if n then sum = sum + n end
      goto next
    end

    -- 汉字数字串
    if is_chinese_num_char(ch) then
      local num_str = ""
      while pos <= len do
        local c = chars[pos]
        if is_chinese_num_char(c) then
          num_str = num_str .. c
          pos = pos + 1
        else
          break
        end
      end
      local n = chineseToNumber(num_str)
      if n then sum = sum + n end
      goto next
    end

    pos = pos + 1
    ::next::
  end

  return sum
end

--- 按顺序播放技能语音
---@param player ServerPlayer 拥有技能的玩家
---@param skillName string 技能名
---@param max integer 最大语音序号
---@param markName string 用来记录的标记名
function functions.broadcastInOrder(player, skillName, max, markName)
  local index = player:getMark(markName)
  if index == 0 then index = 1 end
  player:broadcastSkillInvoke(skillName, index)
  index = index + 1
  if index == max + 1 then index = 1 end
  player.room:setPlayerMark(player, markName, index)
end

--- 弹出成就
--- @param room Room @ 游戏房间
--- @param type? string|AchievementType @ 成就框样式
--- @param width? integer @ 成就框宽度，默认250
--- @param height? integer @ 成就框高度，默认50
--- @param title string @ 成就标题
--- @param context? string @ 成就文本，默认与已注册成就相同
--- @param imgSrc? string|AchievementImgSrc @ 成就图片，默认与已注册成就相同
--- @param players? ServerPlayer[] @ 要弹出成就的玩家们，默认为全员
--- @param repeatable? boolean @ 是否可重复达成，默认不可重复
--- @param packageName? string @ 成就分包名，用于仅填写title时，防止同名成就的读取错误，否则默认读取第一个同名title
function functions.addAchievement(room, type, width, height, title, context, imgSrc, players, repeatable, packageName)
  type = type or "steam"
  width = width or 250
  height = height or width / 5
  title = title or "Hellow World!"
  if not context or not imgSrc then
    local achievements = G.getAchievements()
    if packageName and achievements[packageName] then
      context = context or achievements[packageName].context
      imgSrc = imgSrc or achievements[packageName].imgSrc
    else
      for _, pkg in pairs(achievements) do
        for name, achievement in pairs(pkg) do
          if name == title then
            context = context or achievement.context
            imgSrc = imgSrc or achievement.imgSrc
            break
          end
        end
      end
    end
  end
  players = players or room.players
  repeatable = repeatable or false
  local viewPlayers = {}
  for _, cp in pairs(players) do
    local oldcpData = cp:getGlobalSaveState("glory_days") or {}
    local oldachievements = oldcpData["glory_days_achievements"] or {}
    local achievements = cp:getGlobalSaveState("glory_days_Achieve") or {}
    if oldcpData["glory_days_achievements"] then
      achievements = table.simpleClone(oldachievements)
      oldcpData["glory_days_achievements"] = nil
      cp:saveGlobalState("glory_days", oldcpData)
    end
    if not achievements[title] or not achievements[title].num or repeatable then
      achievements[title] = achievements[title] or {}
      achievements[title].num = (achievements[title].num or 0) + 1
      if achievements[title].num == 1 then
        achievements[title].time = G.getPresentTime(6)
      end
      table.insert(viewPlayers, cp)
      cp:saveGlobalState("glory_days_Achieve", achievements)
    end
  end
  room:doAnimate("SuperLightBox", {
    path = "packages/glory_days/qml/Achievement.qml",
    data = {
      type = type,
      width = width,
      height = height,
      title = title,
      context = context,
      imgSrc = imgSrc
    }
  }, viewPlayers)
end

---获取金币数据
---@param player ServerPlayer|TaskPlayer @ 玩家
---@param task? boolean @ 是否判断taskplayer
---@return table @ 数据
function functions.GetcoinsData(player, task)
  if player.id < 0 then return { gold = 0 } end
  local globalData = player:getGlobalSaveState("CS_System_Data") or {}
  if next(globalData) == nil then
    local data = player:getGlobalSaveState("DR_System_Data") or {}
    globalData.gold = data.gold and data.gold or 0
    globalData.todayReward = 0
    globalData.history = {}
    player:saveGlobalState("CS_System_Data", globalData)
  end
  return globalData
end

--- 改变玩家金币
--- @param player ServerPlayer|TaskPlayer @ 玩家
--- @param num integer @ 变更值
--- @param task? boolean @ 是否判断taskplayer
--- @return integer @ 返回改变后的金币
function functions.ChangePlayerMoney(player, num, task)
  if player.id < 0 then return 0 end
  num = num or 0
  local globalData = player:getGlobalSaveState("CS_System_Data") or {}
  if next(globalData) == nil then
    local data = player:getGlobalSaveState("DR_System_Data") or {}
    globalData.gold = data.gold and data.gold or 0
  end
  globalData.gold = globalData.gold + num
  if num ~= 0 then
    player:saveGlobalState("CS_System_Data", globalData)
    if not task then
      player.room:sendLog {
        type = "#AD_gold_Change_Log",
        arg = player._splayer:getScreenName(),
        arg2 = num > 0 and "获得" or "失去",
        arg3 = math.abs(num),
        toast = true,
      }
    end
  end
  return globalData.gold
end

---@class CSskinsData
---@param skinData CSskinsData @ 皮肤数据
function functions.addSkin(skinData)
  -- if functions.Initialized then
  functions.resolveSkinData(skinData)
  -- else
  --   table.insert(functions.PendingSkins, skinData)
  -- end
end

---获得武将对应的所有皮肤路径（默认排除欢乐将的原画）
---@param general string @ 武将名
---@param name? boolean @ 是否包括武将名本身，默认否
---@param delight? boolean @ 填true包括欢乐将原画
---@param only? boolean @ 排除原版皮肤，默认否
---@return string[] @ 所有皮肤路径
function functions.getSkins(general, name, delight, only)
  functions.checkInit()
  if general == "" then return {} end
  local skins = not only and Fk:getSkinsByGeneral(general) or {}
  if functions.Skins[general] then
    for _, skData in pairs(functions.Skins[general]) do
      table.insertIfNeed(skins, skData.path)
    end
  end
  if name then
    table.insertIfNeed(skins, general)
  end
  if not delight then
    for i = #skins, 1, -1 do
      local skin = skins[i]
      if skin:find("delight/image/generals") then
        table.remove(skins, i)
      end
    end
  end
  return skins
end

---返回对于该玩家来说的信息
---@param player ServerPlayer|TaskPlayer @ 玩家
---@param general? string @ 仅获取general对应的skinInfos，填""则获取玩家主副将的信息
---@param only? boolean @ 排除原版皮肤，默认否
---@return table @ skinInfos, 路径->价格、品质
---@return table @ allSkins, 无general参数时为[有信息的武将名1,有信息的武将名2,...],有则为该武将的所有皮肤路径
function functions.getSkinsInfo(player, general, only)
  functions.checkInit()
  local Save
  if player.id > 0 then
    Save = player:getGlobalSaveState("coins_system_skins") or {}
  else
    Save = {}
  end
  local gskins = {}
  if general ~= nil then
    local prgen = general == "" and player.general or general
    gskins = functions.getSkins(prgen, nil, nil, only)
    if general == "" and player.deputyGeneral and player.deputyGeneral ~= "" then
      local deputySkins = functions.getSkins(player.deputyGeneral, nil, nil, only)
      if #deputySkins > 0 then
        table.insertTableIfNeed(gskins, deputySkins)
      end
    end
  end
  local skinInfos, allSkins = {}, {}
  for gen, skinList in pairs(functions.Skins) do
    local paths = {}
    for _, skinData in pairs(skinList) do
      if general == nil then
        skinInfos[skinData.path] = {
          price = skinData.price or 0,
          quality = skinData.quality or "common",
        }
      elseif table.contains(gskins, skinData.path) then
        table.insertIfNeed(paths, skinData.path)
        skinInfos[skinData.path] = {
          price = skinData.price or 0,
          quality = skinData.quality or "common",
        }
      end
    end
    if general == nil then
      table.insertIfNeed(allSkins, gen)
    elseif #paths > 0 then
      table.insertTableIfNeed(allSkins, paths)
    end
  end
  for k, v in pairs(Save) do
    if skinInfos[k] and type(v) == "number" then
      skinInfos[k].price = v
    end
  end
  return skinInfos, allSkins
end

--- 判断给定日期是否为昨天
--- @param dateStr string 格式 "YYYY-MM-DD"
--- @return boolean
function functions.isYesterday(dateStr)
  local now = os.date("*t")
  local today = os.time({ year = now.year, month = now.month, day = now.day, hour = 0, min = 0, sec = 0 })
  local yesterday = today - 86400
  local yesterdayStr = os.date("%Y-%m-%d", yesterday)
  return dateStr == yesterdayStr
end

--- 改变玩家圣晶石
--- @param player ServerPlayer|TaskPlayer @ 玩家
--- @param num integer @ 变更值
--- @return integer @ 返回改变后的金币
function functions.ChangePlayerSaintQuartz(player, num)
  if player.id < 0 then return 0 end
  num = num or 0
  local globalData = player:getGlobalSaveState("hidden-clouds") or {}
  local quartz = globalData["SaintQuartz"] or {}
  local before = quartz.quartz_num or 30
  quartz.quartz_num = before + num
  globalData["SaintQuartz"] = quartz
  player:saveGlobalState("hidden-clouds", globalData)
  local direction = "获得了" .. tostring(num)
  if num < 0 then
    direction = "失去了" .. tostring(math.abs(num))
  end
  if player.room then
    player.room:sendLog {
      type = player._splayer:getScreenName() .. direction .. "个<font color = 'blue'>圣晶石</font>",
      toast = true,
    }
  end
  return quartz.quartz_num
end

--- 一个字符串str是否以另一个字符串ending结尾
---@param str string 要判断的字符串
---@param ending string 结尾字符串
---@return boolean
function functions.ends_with(str, ending)
  -- 获取s的长度和ending的长度
  local len_s = #str
  local len_ending = #ending

  -- 如果s比ending短，它不可能以ending结尾
  if len_s < len_ending then
    return false
  end

  -- 使用string.sub提取s的末尾部分，并与ending比较
  local end_part = string.sub(str, len_s - len_ending + 1)
  return end_part == ending
end

--player主将或副将的皮肤（无皮肤则判断将名）为name时，播放对应动画
---@param player ServerPlayer @ 角色
---@param names string|string[] 皮肤名
---@param skill_name string 技能名
---@param delay? integer @ 播放后延迟毫秒，默认不延迟
---@param atype? string @ 以.qml结尾则播放全屏大动画，否则在玩家脸上播放emotion：填""是技能名anim，否则是登场动画
---@param judge? boolean @ 仅判断是否可以播放动画，默认false
---@return boolean @ 是否可以播放，人机情况下默认不可以（req为""，获取不到当前皮肤）
function functions.setEmotion(player, names, skill_name, delay, atype, judge)
  local room = player.room
  local name
  if type(names) == "table" then
    name = names[1]
  elseif type(names) == "string" then
    name = names
    names = { name }
  end
  local deputy = player.deputyGeneral
  local extra_data = deputy == "" and { player.general } or { player.general, deputy }
  local req = ""
  if player.id > 0 then
    req = room:askToCustomDialog(player, {
      qml_path = "packages/hidden-clouds/qml/getSkin.qml",
      skill_name = "",
      extra_data = extra_data,
    })
  end
  if #extra_data > 1 and req ~= "" then
    deputy = req[2]
    req = req[1]
  end
  if req == "" then req = player.general end
  if not table.contains(names, req) and not table.contains(names, deputy) then return false end
  local tp = atype or ""
  local path = ""
  if functions.ends_with(tp, ".qml") then
    path = "./packages/hidden-clouds/qml/" .. tp
    room:doSuperLightBox(path)
  else
    path = "./packages/hidden-clouds/image/anim/dengchang_" .. tp
    if not judge then
      if tp ~= "" then
        room:setEmotion(player, path)
      else
        room:setEmotion(player, "./packages/hidden-clouds/image/anim/" .. skill_name)
      end
      delay = delay or 0
      if delay > 0 then
        room:delay(delay)
      end
    end
  end
  return true
end

---获取一个武将的稀有度，OL以外的武将为"其他"
---@param general string
function functions.rareRank(general)
  -- 界一将之前，未分类：界张松，界孙鲁班，界曹休，界全琮，界郭皇后，界辛宪英，界曹节
  local normal = { "ol__menghuo", "ol__sunliang", "ol__gaoshun", "ol__yujin", "ol__guyong",
    "ol_ex__lvmeng", "ol_ex__lidian" }
  local rare = { "ol__caoren", "ol__zhoutai", "ol__dianwei", "ol__masu", "ol__guohuai",
    "ol__caozhen", "ol__quancong", "ol__jikang", "ol__xinxianying", "ol_ex__caocao", "ol_ex__liubei",
    "ol_ex__zhaoyun", "ol_ex__xiaoqiao", "ol_ex__yuji", "ol_ex__wolong", "ol_ex__pangtong",
    "ol_ex__taishici", "ol_ex__yuanshao", "ol_ex__sunjian", "ol_ex__dongzhuo", "ol_ex__jiaxu",
    "ol_ex__liushan", "ol_ex__sunce", "ol_ex__gaoshun", "ol_ex__caozhang" }
  local epic = { "ol__luzhi", "ol__guanqiujian", "ol__zhoufei", "ol__godzhangliao", "ol_ex__huaxiong",
    "ol_ex__xiahouyuan", "ol_ex__huangzhong", "ol_ex__weiyan", "ol_ex__zhangjiao", "ol_ex__dianwei",
    "ol_ex__pangde", "ol_ex__yanliangwenchou", "ol_ex__xuhuang", "ol_ex__zhurong", "ol_ex__menghuo",
    "ol_ex__lusu", "ol_ex__zhanghe", "ol_ex__dengai", "ol_ex__jiangwei", "ol_ex__zhangzhaozhanghong",
    "ol_ex__caiwenji", "ol_ex__yujin", "ol_ex__fazheng", "ol_ex__lingtong", "ol_ex__wuguotai",
    "ol_ex__madai", "ol_ex__liaohua", "ol_ex__guanxingzhangbao", "ol_ex__chengpu", "ol_ex__liubiao",
    "ol_ex__caochong", "ol_ex__guohuai", "ol_ex__yufan", "ol_ex__jianyong", "ol_ex__fuhuanghou",
    "ol_ex__liru", "ol_ex__caifuren", "ol_ex__xiahoushi" }
  local legend = { "ol__godguanyu", "ol__godcaocao", "godsunquan", "ol__godzhangjiao",
    "ol_ex__sunquan", "ol_ex__xunyu", "ol_ex__caozhi", "ol_ex__zhangchunhua", "ol_ex__xusheng",
    "ol_ex__wangyi" }
  local limited = { "ol_ex__zuoci" }
  if table.contains(normal, general) then
    return "普通"
  end
  if table.contains(rare, general) then
    return "稀有"
  end
  if table.contains(epic, general) then
    return "史诗"
  end
  if table.contains(legend, general) then
    return "传说"
  end
  if table.contains(limited, general) then
    return "限定"
  end
  return "其他"
end

---获取比一名玩家更稀有的数量，不包含等于，包括"其他"
---@param player ServerPlayer
---@param rank string?
function functions.rarerCount(player, rank)
  local room = player.room
  local ranks = {
    ["普通"] = 0,
    ["稀有"] = 1,
    ["史诗"] = 2,
    ["传说"] = 3,
    ["限定"] = 4,
    ["其他"] = 5
  }
  local rank0 = rank and ranks[rank] or ranks[functions.rareRank(player.general)]
  local count = 0
  for _, p in ipairs(room:getOtherPlayers(player)) do
    if ranks[functions.rareRank(p.general)] > rank0 then
      count = count + 1
    end
  end
  return count
end

return functions