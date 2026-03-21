local extension = Package:new("yugioh")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/yugioh/skills")

local zengzhideG = General:new(extension, "yyfy_zengzhideG", "evil", 2)
zengzhideG:addSkill("yyfy_zengzhi")
Fk:loadTranslationTable{
  ["yugioh"] = "游戏王",
  ["yyfy_zengzhideG"] = "增殖的G",
  ["#yyfy_zengzhideG"] = "王牌怪兽",
  ["designer:yyfy_zengzhideG"] = "夜隐浮云，孤星似梦",
}

local duoduomibao = General:new(extension, "yyfy_duoduomibao", "qun", 4)
duoduomibao:addSkill("yyfy_shanque")
Fk:loadTranslationTable{
  ["yyfy_duoduomibao"] = "多多迷宝",
  ["#yyfy_duoduomibao"] = "鸟G",
  ["designer:yyfy_duoduomibao"] = "夜隐浮云，孤星似梦",
}

local huiliuli = General:new(extension, "yyfy_huiliuli", "evil", 3, 3, General.Female)
huiliuli:addSkill("yyfy_hui")
Fk:loadTranslationTable{
  ["yyfy_huiliuli"] = "灰流丽",
  ["#yyfy_huiliuli"] = "王牌怪兽の宿敌",
  ["designer:yyfy_huiliuli"] = "夜隐浮云，孤星似梦",
}

local mingshen = General:new(extension, "yyfy_UnderworldGoddess", "evil", 5, 5, General.Female)
mingshen:addSkills {"yyfy_shiri", "yyfy_mingshen", "yyfy_duixiang", "yyfy_ganglie"}
Fk:loadTranslationTable{
  ["yyfy_UnderworldGoddess"] = "闭锁世界的冥神",
  ["#yyfy_UnderworldGoddess"] = "牌佬指定对象",
  ["designer:yyfy_UnderworldGoddess"] = "夜隐浮云，孤星似梦"
}

local hongdie = General:new(extension, "yyfy_zhenhongyanlongqishi", "evil", 8)
hongdie:addSkills {"yyfy_longlin", "yyfy_longxi", "yyfy_longnu"}
Fk:loadTranslationTable{
  ["yyfy_zhenhongyanlongqishi"] = "真红眼龙骑士",
  ["#yyfy_zhenhongyanlongqishi"] = "红爹",
  ["designer:yyfy_zhenhongyanlongqishi"] = "牢天师（Ark）"
}

local yunshi = General:new(extension, "yyfy_yuanshishengmingtai", "qun", 11)
yunshi:addSkill("yyfy_yunshi")
Fk:loadTranslationTable{
  ["yyfy_yuanshishengmingtai"] = "原始生命态",
  ["#yyfy_yuanshishengmingtai"] = "5步了是吧",
  ["designer:yyfy_yuanshishengmingtai"] = "夜隐浮云，孤星似梦"
}

local yunshitoken = General:new(extension, "yyfy_yunshitoken", "qun", 11)
yunshitoken:addSkill("yyfy_shoubiao")
Fk:loadTranslationTable{
  ["yyfy_yunshitoken"] = "陨石衍生物",
  ["#yyfy_yunshitoken"] = "衍生物杀人事件",
  ["designer:yyfy_yunshitoken"] = "夜隐浮云，孤星似梦"
}
yunshitoken.hidden = true

local dacaoreshe = General:new(extension, "yyfy_dacaoreshe", "evil", 4)
dacaoreshe:addSkill("yyfy_dacao")
Fk:loadTranslationTable{
  ["yyfy_dacaoreshe"] = "打草惹蛇",
  ["#yyfy_dacaoreshe"] = "炸自己没用哦",
  ["designer:yyfy_dacaoreshe"] = "夜隐浮云，孤星似梦"
}

return extension