local extension = Package:new("yyfy_token", Package.CardPack)
extension.extensionName = "hidden-clouds"
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
  ["yyfy_xs__slash"] = "杀",
  [":yyfy_xs_slash"] = "基本牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：攻击范围内的一名角色<br/><b>效果</b>：对目标角色造成1点伤害。",
  ["yyfy_xs_fire__slash"] = "火杀",
  [":yyfy_xs_fire__slash"] = "基本牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：攻击范围内的一名角色<br/><b>效果</b>：对目标角色造成1点火焰伤害。",
  ["yyfy_xs_thunder__slash"] = "雷杀",
  [":yyfy_xs_thunder__slash"] = "基本牌<br/><b>时机</b>：出牌阶段<br/><b>目标</b>：攻击范围内的一名角色<br/><b>效果</b>：对目标角色造成1点雷电伤害。",
  ["yyfy_xs_peach"] = "桃",
  [":yyfy_xs_peach"] = "基本牌<br/><b>时机</b>：出牌阶段/一名角色处于濒死状态时<br/><b>目标</b>：已受伤的你/处于濒死状态的角色<br/><b>效果</b>：目标角色回复1点体力。",
  ["yyfy_xs_analeptic"] = "酒",
  [":yyfy_xs_analeptic"] = "基本牌<br/>加一点体力上限，并回复一点体力，同时获得一层“天意”。",
  ["@yyfy_xs_tianyi"] = "天意",
  ["yyfy_xs_chain"] = "灵魂锁链",
  [":yyfy_xs_chain"] = "锦囊牌<br/>你与一名其他角色进入绑定状态，你死亡后，其在本轮或下轮须杀死杀死你的角色，否则其在下轮结束时死亡"..
  "<b>注：</b>若其是<b>自刎归天！</b>，你直接死亡。",
  ["yyfy_xs_qinshi"] = "天意侵蚀",
  [":yyfy_xs_qinshi"] = "天意侵蚀(无效果)",
  ["yyfy_unexpectation"] = "出其不意",
  [":yyfy_unexpectation"] = "锦囊牌<br/>"..
  "<b>时机</b>：出牌阶段<br/>"..
  "<b>目标</b>：一名有手牌的其他角色<br/>"..
  "<b>效果</b>：展示目标角色的一张手牌，并对其造成1点伤害。",
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

-- 新三（xs）系列卡牌
local slash = fk.CreateCard{
  name = "yyfy_xs__slash", --杀
  true_name = "slash",
  type = Card.TypeBasic,
  is_damage_card = true,
  damage_type = fk.NormalDamage,
  skill = "slash_skill",
}

local fire__slash = fk.CreateCard{
  name = "yyfy_xs_fire__slash", --火杀
  type = Card.TypeBasic,
  is_damage_card = true,
  damage_type = fk.FireDamage,
  skill = "fire__slash_skill",
}

local thunder__slash = fk.CreateCard{
  name = "yyfy_xs_thunder__slash", --雷杀
  type = Card.TypeBasic,
  is_damage_card = true,
  damage_type = fk.ThunderDamage,
  skill = "thunder__slash_skill",
}

local peach = fk.CreateCard{
  name = "yyfy_xs_peach", --桃
  type = Card.TypeBasic,
  skill = "peach_skill",
}

local analeptic = fk.CreateCard{
  name = "yyfy_xs_analeptic", --酒
  type = Card.TypeBasic,
  skill = "yyfy_xs_analeptic_skill",
}

local chain = fk.CreateCard{
  name = "yyfy_xs_chain", --灵魂锁链
  type = Card.TypeTrick,
  skill = "yyfy_xs_chain_skill",
  --special_skills = { "recast" },
}

local qinshi = fk.CreateCard{
  name = "yyfy_xs_qinshi", --天意侵蚀
  type = Card.TypeTrick,
  skill = "yyfy_xs_qinshi_skill",
}

local unexpectation = fk.CreateCard{
  name = "yyfy_unexpectation", --出其不意
  type = Card.TypeTrick,
  skill = "yyfy_unexpectation_skill",
  is_damage_card = true,
}

extension:loadCardSkels {
  jv_basic, jv_trick, jv_weapon, jv_armor, jv_defensive, jv_offensive, jv_treasure,
  slash, fire__slash, thunder__slash, peach, analeptic, chain, qinshi, unexpectation
}

extension:addCardSpec("yyfy_jv_basic")
extension:addCardSpec("yyfy_jv_trick")
extension:addCardSpec("yyfy_jv_weapon")
extension:addCardSpec("yyfy_jv_armor")
extension:addCardSpec("yyfy_jv_defensive")
extension:addCardSpec("yyfy_jv_offensive")
extension:addCardSpec("yyfy_jv_treasure")

extension:addCardSpec("yyfy_xs__slash", Card.Spade, 7)
extension:addCardSpec("yyfy_xs__slash", Card.Spade, 8)
extension:addCardSpec("yyfy_xs__slash", Card.Spade, 8)
extension:addCardSpec("yyfy_xs__slash", Card.Spade, 9)
extension:addCardSpec("yyfy_xs__slash", Card.Spade, 9)
extension:addCardSpec("yyfy_xs__slash", Card.Spade, 10)
extension:addCardSpec("yyfy_xs__slash", Card.Spade, 10)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 2)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 3)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 4)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 5)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 6)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 7)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 8)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 8)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 9)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 9)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 10)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 10)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 11)
extension:addCardSpec("yyfy_xs__slash", Card.Club, 11)
extension:addCardSpec("yyfy_xs__slash", Card.Heart, 10)
extension:addCardSpec("yyfy_xs__slash", Card.Heart, 10)
extension:addCardSpec("yyfy_xs__slash", Card.Heart, 11)
extension:addCardSpec("yyfy_xs__slash", Card.Diamond, 6)
extension:addCardSpec("yyfy_xs__slash", Card.Diamond, 7)
extension:addCardSpec("yyfy_xs__slash", Card.Diamond, 8)
extension:addCardSpec("yyfy_xs__slash", Card.Diamond, 9)
extension:addCardSpec("yyfy_xs__slash", Card.Diamond, 10)
extension:addCardSpec("yyfy_xs__slash", Card.Diamond, 13)

extension:addCardSpec("yyfy_xs_thunder__slash", Card.Club, 5)
extension:addCardSpec("yyfy_xs_thunder__slash", Card.Club, 6)
extension:addCardSpec("yyfy_xs_thunder__slash", Card.Club, 7)
extension:addCardSpec("yyfy_xs_thunder__slash", Card.Club, 8)
extension:addCardSpec("yyfy_xs_thunder__slash", Card.Spade, 4)
extension:addCardSpec("yyfy_xs_thunder__slash", Card.Spade, 5)
extension:addCardSpec("yyfy_xs_thunder__slash", Card.Spade, 6)
extension:addCardSpec("yyfy_xs_thunder__slash", Card.Spade, 7)
extension:addCardSpec("yyfy_xs_thunder__slash", Card.Spade, 8)

extension:addCardSpec("yyfy_xs_fire__slash", Card.Heart, 4)
extension:addCardSpec("yyfy_xs_fire__slash", Card.Heart, 7)
extension:addCardSpec("yyfy_xs_fire__slash", Card.Heart, 10)
extension:addCardSpec("yyfy_xs_fire__slash", Card.Diamond, 4)
extension:addCardSpec("yyfy_xs_fire__slash", Card.Diamond, 5)

extension:addCardSpec("yyfy_xs_peach", Card.Heart, 3)
extension:addCardSpec("yyfy_xs_peach", Card.Heart, 4)
extension:addCardSpec("yyfy_xs_peach", Card.Heart, 6)
extension:addCardSpec("yyfy_xs_peach", Card.Heart, 7)
extension:addCardSpec("yyfy_xs_peach", Card.Heart, 8)
extension:addCardSpec("yyfy_xs_peach", Card.Heart, 9)
extension:addCardSpec("yyfy_xs_peach", Card.Heart, 12)
extension:addCardSpec("yyfy_xs_peach", Card.Diamond, 12)

extension:addCardSpec("yyfy_xs_analeptic", Card.Spade, 3)
extension:addCardSpec("yyfy_xs_analeptic", Card.Spade, 9)
extension:addCardSpec("yyfy_xs_analeptic", Card.Club, 3)
extension:addCardSpec("yyfy_xs_analeptic", Card.Club, 9)
extension:addCardSpec("yyfy_xs_analeptic", Card.Diamond, 9)

extension:addCardSpec("yyfy_xs_chain", Card.Spade, 11)
extension:addCardSpec("yyfy_xs_chain", Card.Spade, 12)
extension:addCardSpec("yyfy_xs_chain", Card.Club, 10)
extension:addCardSpec("yyfy_xs_chain", Card.Club, 11)
extension:addCardSpec("yyfy_xs_chain", Card.Club, 12)
extension:addCardSpec("yyfy_xs_chain", Card.Club, 13)

extension:addCardSpec("yyfy_xs_qinshi", Card.Spade, 11)
extension:addCardSpec("yyfy_xs_qinshi", Card.Spade, 12)
extension:addCardSpec("yyfy_xs_qinshi", Card.Spade, 13)

extension:addCardSpec("yyfy_unexpectation")

return extension