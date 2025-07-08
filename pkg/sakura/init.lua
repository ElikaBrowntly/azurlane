local extension = Package:new("sakura")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/sakura/skills")

local musashi = General:new(extension, "musashi", "moe", 5, 5, General.Female):addSkills {"jinghaijinglei", "wuyingrenhao", "gongfangzhihu"}

Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["sakura"] = "重樱",
  ["musashi"] = "武藏",
  ["#musashi"] = "紫绛槿岚",
  ["illustrator:musashi"] = "dishwasher1910",
  ["cv:musashi"] = "Lynn",
  ["designer:musashi"] = "夜隐浮云，孤星似梦",
  ["~musashi"] = "不要恋战，也不用惊慌。我会保护好大家的——",
}

return extension