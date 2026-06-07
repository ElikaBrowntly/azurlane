local ok, U = pcall(require, "packages.glory_days.utility")

local extension = Package:new("contribution2")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/contribution2/skills")

local Robbins = General:new(extension, "yyfy__Robbins", "west", 3)
Robbins:addSkills { "yyfy_plan", "yyfy_organize", "yyfy_lead", "yyfy_motivate", "control", "yyfy_coordinate" }
Fk:loadTranslationTable
{
  ["yyfy"] = "",
  ["contribution2"] = "投稿 2",
  ["yyfy__Robbins"] = "罗宾斯",
  ["#yyfy__Robbins"] = "管理学大师",
  ["designer:yyfy__Robbins"] = "夜隐浮云"
}

local liubei = General:new(extension, "yyfy_mou__liubei", "shu", 4)
liubei:addSkills { "yyfy_rende", "yyfy_zhangwu" }
Fk:loadTranslationTable
{
  ["yyfy_mou"] = "谋？",
  ["yyfy_mou__liubei"] = "谋刘备",
  ["#yyfy_mou__liubei"] = "章武大帝",
  ["designer:yyfy_mou__liubei"] = "青菜白玉汤",
  ["~yyfy_mou__liubei"] = "汉室之兴，皆仰望丞相了……",
}

return extension