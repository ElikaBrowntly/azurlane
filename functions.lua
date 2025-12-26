local functions = {}

-- 判断两个角色之间是否为敌对关系
---@param from Player|ServerPlayer
---@param to Player|ServerPlayer
---@return boolean
function functions.isEnemy(from, to)
  if from.id == to.id then return false end -- 自己不是敌人
  
  if from.role == "lord" or from.role == "loyalist" then
    return (to.role ~= "lord" and to.role ~= "loyalist")
  elseif from.role == "rebel" then
    return (to.role == "lord" or to.role == "loyalist")
  elseif from.role == "renegade" then
    return true -- 内奸视所有其他角色为敌人
  end
  
  return false -- 默认不是敌人
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

return functions