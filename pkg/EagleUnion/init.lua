local extension = Package:new("EagleUnion")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/EagleUnion/skills")

local LaffeyII = General:new(extension, "LaffeyII", "moe", 2, 2, General.Female):addSkills {"yyfy_zhanyijizeng", "yyfy_beishuizhizhan"}

Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["EagleUnion"] = "白鹰",
  ["LaffeyII"] = "拉菲II ",
  ["#LaffeyII"] = "星海逐光",
  ["cv:LaffeyII"] = "长绳麻理亚 ",
  ["designer:LaffeyII"] = "今天也依旧不幸",
  ["~LaffeyII"] = "拉菲的战斗……不会就此结束。",
  ["!LaffeyII"] = "战斗胜利……拉菲……要继续睡觉去了……",
}

return extension