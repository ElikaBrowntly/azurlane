local extension = Package:new("contribution")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/contribution/skills")

local exgod_zhangliao = General:new(extension, "exgod_zhangliao", "god", 4, 5, General.Male)
exgod_zhangliao:addSkills { "yyfy_duorui", "yyfy_zhiti" }
exgod_zhangliao:addRelatedSkill("ty__wangxi")
Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["contribution"] = "投稿",
  ["exgod_zhangliao"] = "界神张辽",
  ["#exgod_zhangliao"] = "美食家",
  ["designer:exgod_zhangliao"] = "投稿者",
  ["~exgod_zhangliao"] = "我也有……被孙仲谋所伤之时",
}

return extension