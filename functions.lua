local functions = {}

local okG, G = pcall(require, "packages.glory_days.utility")

-- 判断两个角色之间是否为敌对关系
---@param from Player|ServerPlayer
---@param to Player|ServerPlayer
---@return boolean
function functions.isEnemy(from, to)
  if from.id == to.id then return false end -- 自己不是敌人

  if from.role == "lord" or from.role == "loyalist" then
    return (to.role ~= "lord" and to.role ~= "loyalist")
  elseif from.role == "rebel" then -- 反贼没必要敌视内奸
    return (to.role == "lord" or to.role == "loyalist")
  elseif from.role == "renegade" then
    return true -- 内奸视所有其他角色为敌人
  end

  return false -- 默认不是敌人
end

--- 获取 player 的存活队友数量
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

return functions
