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

local mou_wupu = General:new(extension, "mou_wupu", "qun", 4, 4, General.Male)
mou_wupu:addSkills { "yyfy_duanti", "yyfy_shicao" }
mou_wupu:addRelatedSkill("wuling")
Fk:loadTranslationTable
{
  ["mou_wupu"] = "谋吴普",
  ["#mou_wupu"] = "健体养魄",
  ["designer:mou_wupu"] = "夜隐浮云，孤星似梦",
  ["~mou_wupu"] = "五禽犹在，此戏传于后来人。",
}

return extension