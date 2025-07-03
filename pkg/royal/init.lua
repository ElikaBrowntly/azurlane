local extension = Package:new("royal")
extension.extensionName = "azurlane"
extension:loadSkillSkelsByPath("./packages/azurlane/pkg/royal/skills")

local unicorn = General:new(extension, "unicorn", "moe", 3, 4, General.Female):addSkills { "hangmutexing", "unicornsupport", "zhihuizhuangtian" }

Fk:loadTranslationTable
{
  ["azurlane"] = "碧蓝航线",
  ["royal"] = "皇家",
  ["unicorn"] = "独角兽",
  ["#unicorn"] = "妹妹",
  ["illustrator:unicorn"] = "梦咲枫",
  ["cv:unicorn"] = "加隈亚衣",
  ["designer:unicorn"] = "夜隐浮云，孤星似梦",
  ["~unicorn"] = "呜呜…在哥哥面前…要坚强…",
}

return extension