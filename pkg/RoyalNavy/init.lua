local extension = Package:new("RoyalNavy")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/RoyalNavy/skills")

local unicorn = General:new(extension, "unicorn", "moe", 3, 4, General.Female)
unicorn:addSkills { "hangmutexing", "unicornsupport", "zhihuizhuangtian" }
Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["RoyalNavy"] = "皇家",
  ["unicorn"] = "独角兽",
  ["#unicorn"] = "妹妹",
  ["illustrator:unicorn"] = "梦咲枫",
  ["cv:unicorn"] = "加隈亚衣",
  ["designer:unicorn"] = "夜隐浮云，孤星似梦",
  ["~unicorn"] = "呜呜…在哥哥面前…要坚强…",
  ["!unicorn"] = "比起独角兽，指挥下令的哥哥才是MVP哦…？欸嘿嘿，哥哥，恭喜…！"
}

local Cheshire = General:new(extension, "Cheshire", "moe", 4, 4, General.Female)
Cheshire:addSkills { "yyfy_fangkong", "yyfy_toutu" }
Fk:loadTranslationTable
{
  ["Cheshire"] = "柴郡",
  ["#Cheshire"] = "拿来吧你！焯",
  ["illustrator:Cheshire"] = "全班最菜嘤嘤嘤",
  ["cv:Cheshire"] = "石上静香",
  ["designer:Cheshire"] = "夜隐浮云，孤星似梦",
  ["~Cheshire"] = "趁敌人没注意到的时候，赶紧溜走吧？",
  ["!Cheshire"] = "作战成功~亲爱的，烟花漂亮吗？"
}

return extension