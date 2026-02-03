local extension = Package:new("yyfy_token", Package.CardPack)
extension.extensionName = "hidden--clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/yyfy_token/skills")
-- extension.game_modes_whitelist = { "game_mode" }

Fk:loadTranslationTable {
  ["yyfy_token"] = "夜隐浮云衍生牌",

  ["yyfy_jv_basic"] = "句",
  [":yyfy_jv_basic"] = "由多字基本牌被〖言句〗技能转化而来，没有任何效果。",
  ["yyfy_jv_trick"] = "句",
  [":yyfy_jv_trick"] = "由多字锦囊牌被〖言句〗技能转化而来，没有任何效果。",
  ["yyfy_jv_weapon"] = "句",
  [":yyfy_jv_weapon"] = "由多字武器牌被〖言句〗技能转化而来，可以装备，但没有任何效果。",
  ["yyfy_jv_armor"] = "句",
  [":yyfy_jv_armor"] = "由多字防具牌被〖言句〗技能转化而来，可以装备，但没有任何效果。",
  ["yyfy_jv_defensive"] = "句",
  [":yyfy_jv_defensive"] = "由多字防御坐骑被〖言句〗技能转化而来，可以装备，但没有任何效果。",
  ["yyfy_jv_offensive"] = "句",
  [":yyfy_jv_offensive"] = "由多字进攻坐骑被〖言句〗技能转化而来，可以装备，但没有任何效果。",
  ["yyfy_jv_treasure"] = "句",
  [":yyfy_jv_treasure"] = "由多字宝物牌被〖言句〗技能转化而来，可以装备，但没有任何效果。",
}

local jv_basic = fk.CreateCard{
  name = "yyfy_jv_basic",
  type = Card.TypeBasic,
  is_passive = true,
  skill = "yyfy_jv_skill"
}

local jv_trick = fk.CreateCard{
  name = "yyfy_jv_trick",
  type = Card.TypeTrick,
  is_passive = true,
  skill = "yyfy_jv_skill"
}

local jv_weapon = fk.CreateCard{
  name = "yyfy_jv_weapon",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeWeapon,
  attack_range = 1,
}

local jv_armor = fk.CreateCard{
  name = "yyfy_jv_armor",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeArmor,
}

local jv_defensive = fk.CreateCard{
  name = "yyfy_jv_defensive",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeDefensiveRide,
}

local jv_offensive = fk.CreateCard{
  name = "yyfy_jv_offensive",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeOffensiveRide,
}

local jv_treasure = fk.CreateCard{
  name = "yyfy_jv_treasure",
  type = Card.TypeEquip,
  sub_type = Card.SubtypeTreasure
}

extension:addCardSpec("yyfy_jv_basic")
extension:addCardSpec("yyfy_jv_trick")
extension:addCardSpec("yyfy_jv_weapon")
extension:addCardSpec("yyfy_jv_armor")
extension:addCardSpec("yyfy_jv_defensive")
extension:addCardSpec("yyfy_jv_offensive")
extension:addCardSpec("yyfy_jv_treasure")

extension:loadCardSkels {
  jv_basic, jv_trick, jv_weapon, jv_armor, jv_defensive, jv_offensive, jv_treasure
}

return extension