local extension = Package:new("SakuraEmpire")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/SakuraEmpire/skills")

local musashi = General:new(extension, "yyfy_musashi", "moe", 5, 5, General.Female)
musashi:addSkills {"jinghaijinglei", "wuyingrenhao", "gongfangzhihu"}
Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["SakuraEmpire"] = "重樱",
  ["yyfy_musashi"] = "武藏",
  ["#yyfy_musashi"] = "紫绛槿岚",
  ["illustrator:yyfy_musashi"] = "dishwasher1910",
  ["cv:yyfy_musashi"] = "Lynn",
  ["designer:yyfy_musashi"] = "夜隐浮云，孤星似梦",
  ["~yyfy_musashi"] = "不要恋战，也不用惊慌。我会保护好大家的——",
  ["!yyfy_musashi"] = "恰如其分的胜利。奖励是你的喜悦和安心的话，我亦能接受。"
}

local yukikaze = General:new(extension, "yyfy_yukikaze", "moe", 3, 3, General.Female)
yukikaze:addSkills {"yyfy_xuefeng", "yyfy_buchen", "yyfy_zhuanwu_yukikaze"}
Fk:loadTranslationTable
{
  ["yyfy_yukikaze"] = "雪风",
  ["#yyfy_yukikaze"] = "吴之雪风",
  ["illustrator:yyfy_yukikaze"] = "Saru",
  ["cv:yyfy_yukikaze"] = "优木加奈",
  ["designer:yyfy_yukikaze"] = "夜隐浮云，孤星似梦",
  ["~yyfy_yukikaze"] = "成，成熟的雪风大人早就习，习惯这些了！唔，唔……",
  ["!yyfy_yukikaze"] = "嗯！诶嘿嘿~最喜欢你了~"
}

return extension