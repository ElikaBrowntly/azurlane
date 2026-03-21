local extension = Package:new("RoyalNavy")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/RoyalNavy/skills")

local unicorn = General:new(extension, "yyfy_unicorn", "moe", 3, 4, General.Female)
unicorn:addSkills { "hangmutexing", "unicornsupport", "zhihuizhuangtian" }
Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["RoyalNavy"] = "皇家",
  ["yyfy_unicorn"] = "独角兽",
  ["#yyfy_unicorn"] = "妹妹",
  ["illustrator:yyfy_unicorn"] = "梦咲枫",
  ["cv:yyfy_unicorn"] = "加隈亚衣",
  ["designer:yyfy_unicorn"] = "夜隐浮云，孤星似梦",
  ["~yyfy_unicorn"] = "呜呜…在哥哥面前…要坚强…",
  ["!yyfy_unicorn"] = "比起独角兽，指挥下令的哥哥才是MVP哦…？欸嘿嘿，哥哥，恭喜…！"
}

local Cheshire = General:new(extension, "yyfy_Cheshire", "moe", 4, 4, General.Female)
Cheshire:addSkills { "yyfy_fangkong", "yyfy_toutu" }
Fk:loadTranslationTable
{
  ["yyfy_Cheshire"] = "柴郡",
  ["#yyfy_Cheshire"] = "拿来吧你！焯",
  ["illustrator:yyfy_Cheshire"] = "全班最菜嘤嘤嘤",
  ["cv:yyfy_Cheshire"] = "石上静香",
  ["designer:yyfy_Cheshire"] = "夜隐浮云，孤星似梦",
  ["~yyfy_Cheshire"] = "趁敌人没注意到的时候，赶紧溜走吧？",
  ["!yyfy_Cheshire"] = "作战成功~亲爱的，烟花漂亮吗？"
}

return extension