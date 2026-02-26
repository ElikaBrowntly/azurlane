local extension = Package:new("EagleUnion")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/EagleUnion/skills")
local ok, M = pcall(require, "packages.mobile.pkg.mobile_rare")

local LaffeyII = General:new(extension, "yyfy_LaffeyII", "moe", 2, 2, General.Female)
LaffeyII:addSkills {"yyfy_zhanyijizeng", "yyfy_beishuizhizhan"}
Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["EagleUnion"] = "白鹰",
  ["yyfy_LaffeyII"] = "拉菲II",
  ["#yyfy_LaffeyII"] = "星海逐光",
  ["cv:yyfy_LaffeyII"] = "长绳麻理亚 ",
  ["designer:yyfy_LaffeyII"] = "今天也依旧不幸",
  ["~yyfy_LaffeyII"] = "拉菲的战斗……不会就此结束。",
  ["!yyfy_LaffeyII"] = "战斗胜利……拉菲……要继续睡觉去了……",
}

local bilan = General:new(extension, "yyfy_bilan", "moe", 4, 4, General.Female)
if ok then
  bilan:addSkills {"changshi__picai"}
end
bilan:addSkills {"yyfy_gangban", "yyfy_ezuojv"}
Fk:loadTranslationTable
{
  ["yyfy_bilan"] = "毕岚",
  ["#yyfy_bilan"] = "锉刀",
  ["cv:yyfy_bilan"] = "上坂堇",
  ["illustrator:yyfy_bilan"] = "Saru",
  ["~yyfy_bilan"] = "呜哇，大危机！",
  ["!yyfy_bilan"] = "欸嘿嘿~姐姐太忙了，偶尔让我客串下不挺好的嘛~",
}

return extension