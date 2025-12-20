local ok, D = pcall(require, "packages.danganronpa.record.DRRP")

Fk:loadTranslationTable {
  ["exgod_zhangliao_1"] = "闻风丧胆",
  ["desc:exgod_zhangliao_1"] = "通过〖夺锐〗在一局游戏中获得至少5个技能，并取得胜利。",
  ["yyfy_mou_wupu_1"] = "医脉相承",
  ["desc:yyfy_mou_wupu_1"] = "累计3次通过〖锻体〗获得技能〖五灵〗。",
  ["yyfy_mou_wupu_2"] = "遍尝百草",
  ["desc:yyfy_mou_wupu_2"] = "通过〖识草〗累计获得100张牌。",
  ["lan__tengfanglan_1"] = "一时之宠",
  ["desc:lan__tengfanglan_1"] = "累计3次，在一次〖落宠〗中发动所有效果的最大次数。",
  ["lan__xunyou_1"] = "十二奇策",
  ["desc:lan__xunyou_1"] = "通过〖百出〗在一局游戏中获得至少12张牌，并取得胜利。",
  ["lan__zhonghui_1"] = "今日起兵",
  ["desc:lan__zhonghui_1"] = "累计3次，在一局游戏中获得3张「权」并取得胜利。",
  ["lan__caomao_1"] = "大魏君王",
  ["desc:lan__caomao_1"] = "通过〖潜龙〗在一局游戏中获得3个“大胃菌王”技能，并取得胜利。",
}

local aaa_data = {
  {
    id = "exgod_zhangliao",
    name = "界神张辽",
    achievements = {
      {
        id = "exgod_zhangliao_1",
        target = 1,
        name = "闻风丧胆",
        desc = "通过〖夺锐〗在一局游戏中获得至少5个技能，并取得胜利。"
      },
    },
  },
  {
    id = "yyfy_mou_wupu",
    name = "谋吴普",
    achievements = {
      {
        id = "yyfy_mou_wupu_1",
        target = 3,
        name = "医脉相承",
        desc = "累计3次通过〖锻体〗获得技能〖五灵〗。"
      },
    },
  },
  {
    id = "yyfy_mou_wupu",
    name = "谋吴普",
    achievements = {
      {
        id = "yyfy_mou_wupu_2",
        target = 100,
        name = "遍尝百草",
        desc = "通过〖识草〗累计获得100张牌。"
      },
    },
  },
  {
    id = "lan__tengfanglan",
    name = "烂滕芳兰",
    achievements = {
      {
        id = "lan__tengfanglan_1",
        target = 3,
        name = "一时之宠",
        desc = "累计3次，在一次〖落宠〗中发动所有效果的最大次数。"
      },
    },
  },
  {
    id = "lan__xunyou",
    name = "烂荀攸",
    achievements = {
      {
        id = "lan__xunyou_1",
        target = 1,
        name = "十二奇策",
        desc = "通过〖百出〗在一局游戏中获得至少12张牌，并取得胜利。",
      },
    },
  },
  {
    id = "lan__zhonghui",
    name = "烂钟会",
    achievements = {
      {
        id = "lan__zhonghui_1",
        target = 3,
        name = "今日起兵",
        desc = "累计3次，在一局游戏中获得3张「权」并取得胜利。",
      },
    },
  },
  {
    id = "lan__caomao",
    name = "烂曹髦",
    achievements = {
      {
        id = "lan__caomao_1",
        target = 1,
        name = "大魏君王",
        desc = "通过〖潜龙〗在一局游戏中获得3个“大胃菌王”技能，并取得胜利。",
      },
    },
  },
}

if ok and D and type(D.RegisterAchievementPackage) == "function" then
  D.RegisterAchievementPackage("夜隐浮云", aaa_data, "hidden-clouds/image/generals")
end
