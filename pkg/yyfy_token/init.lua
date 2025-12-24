-- SPDX-License-Identifier: GPL-3.0-or-later

-- 创建自定义卡牌扩展包
local extension = Package:new("yyfy_token", Package.CardPack)
extension.extensionName = "hidden-clouds"

-- 设置扩展包的游戏模式白名单
-- extension.game_modes_whitelist = { "game_mode" }

-- 加载技能骨架
extension:loadSkillSkelsByPath("./packages/hidden_clouds/pkg/yyfy_token/skills")

-- 加载翻译表
Fk:loadTranslationTable {
  ["yyfy_token"] = "夜隐浮云衍生牌",
  
  ["yyfy_jv"] = "句",
  ["&yyfy_jv"] = "句",
}

-- 创建"句"卡牌
local yyfy_jv = fk.CreateCard{
  name = "&yyfy_jv",
  type = Card.TypeTrick, -- TODO:分成2种“句”，基本锦囊
  skill = "#yyfy_jv_skill&",
  is_passive = true,
}

-- 为卡牌设置描述
Fk:loadTranslationTable {
  [":yyfy_jv"] = "<b>特殊卡牌</b><br/>" ..
  "<b>说明</b>：此牌由「言句」技能产生，原牌为多字手牌，牌名被替换为「句」。<br>"..
  "若此牌为装备牌，可以使用但无任何效果；否则此牌无法使用或打出。",
}

-- 将卡牌添加到扩展包


-- 加载卡牌骨架
extension:loadCardSkels {
  yyfy_jv,
}

-- 返回扩展包
return extension