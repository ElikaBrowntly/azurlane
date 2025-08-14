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

local lan_tengfanglan = General:new(extension, "lan__tengfanglan", "wu", 3, 3, General.Female)
lan_tengfanglan:addSkills { "lan__luochong", "lan__aichen" }
Fk:loadTranslationTable
{
  ["lan"] = "烂",
  ["lan__tengfanglan"] = "滕芳兰",
  ["#lan__tengfanglan"] = "滕芳兰布兰德",
  ["designer:lan__tengfanglan"] = "水上由岐",
  ["~lan__tengfanglan"] = "封侯归命，夫妻同归。",
}

local lan__xunyou = General:new(extension, "lan__xunyou", "wei", 3, 3, General.Male)
lan__xunyou:addSkills { "lan__baichu", "qice", "lan__zhiyu", "daojie" }
Fk:loadTranslationTable
{
  ["lan__xunyou"] = "荀攸",
  ["#lan__xunyou"] = "荀攸布兰德",
  ["designer:lan__xunyou"] = "水上由岐",
  ["illustrator:olz__xunyou"] = "错落宇宙",
  ["$qice_lan__xunyou1"] = "二袁相争，此曹公得利之时",
  ["$qice_lan__xunyou2"] = "穷寇宜追，需防死蛇之不僵",
  ["$qice_lan__xunyou3"] = "颜良兵围白马，今兵少不敌，分其势乃可",
  ["$qice_lan__xunyou4"] = "文丑疲军而来，此所以擒敌，奈何去之",
  ["$daojie_lan__xunyou1"] = "秉忠正之心，可抚宁内外",
  ["$daojie_lan__xunyou2"] = "贤者，温良恭俭让以得之",
  ["~lan__xunyou"] = "北雁南顾，当折彭䗍之滨……",
}

return extension