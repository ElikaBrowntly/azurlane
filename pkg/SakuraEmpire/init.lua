local extension = Package:new("SakuraEmpire")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/SakuraEmpire/skills")

local musashi = General:new(extension, "musashi", "moe", 5, 5, General.Female):addSkills {"jinghaijinglei", "wuyingrenhao", "gongfangzhihu"}

Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["SakuraEmpire"] = "重樱",
  ["musashi"] = "武藏",
  ["#musashi"] = "紫绛槿岚",
  ["illustrator:musashi"] = "dishwasher1910",
  ["cv:musashi"] = "Lynn",
  ["designer:musashi"] = "夜隐浮云，孤星似梦",
  ["~musashi"] = "不要恋战，也不用惊慌。我会保护好大家的——",
  ["!musashi"] = "恰如其分的胜利。奖励是你的喜悦和安心的话，我亦能接受。"
}

return extension