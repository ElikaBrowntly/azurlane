local extension = Package:new("contribution")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/contribution/skills")

local exgod_zhangliao = General:new(extension, "exgod_zhangliao", "god", 4, 5, General.Male)
exgod_zhangliao:addSkills { "yyfy_duorui", "yyfy_zhiti" }
exgod_zhangliao:addRelatedSkill("yyfy_wangxi")
Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["contribution"] = "夜隐浮云-投稿",
  ["exgod_zhangliao"] = "界神张辽",
  ["#exgod_zhangliao"] = "美食家",
  ["designer:exgod_zhangliao"] = "投稿者",
  ["~exgod_zhangliao"] = "我也有……被孙仲谋所伤之时",
}

local mou_wupu = General:new(extension, "yyfy_mou_wupu", "qun", 4, 4, General.Male)
mou_wupu:addSkills { "yyfy_duanti", "yyfy_shicao" }
--mou_wupu:addRelatedSkill("wuling")
Fk:loadTranslationTable
{
  ["yyfy_mou_wupu"] = "谋吴普",
  ["#yyfy_mou_wupu"] = "健体养魄",
  ["designer:yyfy_mou_wupu"] = "夜隐浮云，孤星似梦",
  ["~yyfy_mou_wupu"] = "五禽犹在，此戏传于后来人。",
}

local lan__tengfanglan = General:new(extension, "lan__tengfanglan", "wu", 3, 3, General.Female)
lan__tengfanglan:addSkills { "lan__luochong", "lan__aichen" }
Fk:loadTranslationTable
{
  ["lan"] = "烂",
  ["lan__tengfanglan"] = "滕芳兰",
  ["#lan__tengfanglan"] = "滕子布兰德",
  ["designer:lan__tengfanglan"] = "水上由岐",
  ["~lan__tengfanglan"] = "封侯归命，夫妻同归。",
}

local lan__xunyou = General:new(extension, "lan__xunyou", "wei", 3, 3, General.Male)
lan__xunyou:addSkills { "lan__baichu", "yyfy_qice", "lan__zhiyu", "yyfy_daojie" }
Fk:loadTranslationTable
{
  ["lan__xunyou"] = "荀攸",
  ["#lan__xunyou"] = "荀攸布兰德",
  ["designer:lan__xunyou"] = "水上由岐",
  ["illustrator:lan__xunyou"] = "错落宇宙",
  ["$yyfy_qice_lan__xunyou1"] = "二袁相争，此曹公得利之时",
  ["$yyfy_qice_lan__xunyou2"] = "穷寇宜追，需防死蛇之不僵",
  ["$yyfy_qice_lan__xunyou3"] = "颜良兵围白马，今兵少不敌，分其势乃可",
  ["$yyfy_qice_lan__xunyou4"] = "文丑疲军而来，此所以擒敌，奈何去之",
  ["$yyfy_daojie_lan__xunyou1"] = "秉忠正之心，可抚宁内外",
  ["$yyfy_daojie_lan__xunyou2"] = "贤者，温良恭俭让以得之",
  ["~lan__xunyou"] = "北雁南顾，当折彭䗍之滨……",
}

local lan__zhonghui = General:new(extension, "lan__zhonghui", "wei", 3, 4, General.Male)
lan__zhonghui:addSkills { "lan__yuzhi", "lan__xieshu", "lan__quanji", "lan__paiyi", "yyfy_baozu" }
Fk:loadTranslationTable
{
  ["lan__zhonghui"] = "钟会",
  ["#lan__zhonghui"] = "钟会布兰德",
  ["designer:lan__zhonghui"] = "水上由岐",
  ["~lan__zhonghui"] = "棋差一着，棋差一着呀",
  ["$yyfy_baozu_lan__zhonghui1"] = "吾族恒大，谁敢欺之？",
  ["$yyfy_baozu_lan__zhonghui2"] = "动我钟家的人，哼，你长了几个脑袋？",
  ["$yyfy_baozu_lan__zhonghui3"] = "有我在一日，谁也动不得吾族分毫。",
  ["$yyfy_baozu_lan__zhonghui4"] = "诸位同门，随我钟会赌一遭如何？",
  ["$yyfy_baozu_lan__zhonghui5"] = "钟门三世皆为佐国之臣，彼可取而代之",
  ["$yyfy_baozu_lan__zhonghui6"] = "司马氏已居大，我族岂逊他三分！",
}

local lijueguosi = General:new(extension, "yyfy_lijueguosi", "qun", 4, 4, General.Male)
lijueguosi:addSkills { "yyfy_xiongxi", "yyfy_yisuan" }
Fk:loadTranslationTable{
  ["yyfy_lijueguosi"] = "李傕郭汜",
  ["#yyfy_lijueguosi"] = "犯祚倾祸",
  ["designer:yyfy_lijueguosi"] = "多喝热水",
  ["~yyfy_lijueguosi"] = "一心相争，兵败战损",
}

local zhixushenghua =  General:new(extension, "yyfy_zhixushenghua", "god", 5, 5, General.Female)
zhixushenghua:addSkills { "shengjianchujue", "tianmingyini", "shengshayuduo" }
Fk:loadTranslationTable{
  ["yyfy_zhixushenghua"] = "至序圣华",
  ["designer:yyfy_zhixushenghua"] = "一维无限",
}

local xunshengshouwei = General:new(extension, "yyfy_xunshengshouwei", "god", 4, 4, General.Female)
xunshengshouwei:addSkills { "yyfy_jianjiao", "yyfy_wusheng", "yyfy_huixiang"}
Fk:loadTranslationTable{
  ["yyfy_xunshengshouwei"] = "循声守卫",
  ["designer:yyfy_xunshengshouwei"] = "一维无限",
}

local caomao = General:new(extension, "lan__caomao", "wei", 4, 4, General.Male)
caomao:addSkills {"lan__qianlong", "lan__juetao", "lan__fensi", "lan__weitong"}
Fk:loadTranslationTable{
  ["lan__caomao"] = "曹髦",
  ["#lan__caomao"] = "曹髦布兰德",
  ["designer:lan__caomao"] = "水上由岐",
  ["!lan__caomao"] = "少康诛寒浞以中兴，朕夷司马未尝不可！",
  ["~lan__caomao"] = "纵不成身死，朕亦为太祖子孙，大魏君王……"
}

local huanggai = General:new(extension, "lan__huanggai", "wu", 4, 4, General.Male)
huanggai:addSkills {"kurou", "lan__zhaxiang", "lan__lieji", "lan__quzhou"}
Fk:loadTranslationTable{
  ["lan__huanggai"] = "黄盖",
  ["#lan__huanggai"] = "盖子布兰德",
  ["designer:lan__huanggai"] = "水上由岐",
  ["~lan__huanggai"] = "哈哈哈哈，公瑾计成，老夫死也无憾了……"
}

local dengai = General:new(extension, "lan__dengai", "wei", 4, 4, General.Male)
dengai:addSkills {"lan__neyan", "lan__tuntian", "lan__zaoxian", "lan__jixi", "ty__zhouxi"}
Fk:loadTranslationTable{
  ["lan__dengai"] = "邓艾",
  ["#lan__dengai"] = "邓艾布兰德",
  ["designer:lan__dengai"] = "水上由岐",
  ["~lan__dengai"] = "钟会！你为何害我！"
}

local pianye = General:new(extension, "yyfy_pianye", "god", 1, 999, General.Male)
pianye:addSkills {"yyfy_gouyun", "yyfy_haopai", "yyfy_huangdou"}
Fk:loadTranslationTable{
  ["yyfy_pianye"] = "偏✌️",
  ["#yyfy_pianye"] = "偏将军就是✌️",
  ["designer:yyfy_pianye"] = "幻矩",
}

local piangrandpa = General:new(extension, "yyfy_piangrandpa", "god", 4, 4, General.Male)
piangrandpa:addSkills {"yyfy_gouyun", "yyfy_haopai↓", "yyfy_huangdou"}
Fk:loadTranslationTable{
  ["yyfy_piangrandpa"] = "偏爷",
  ["#yyfy_piangrandpa"] = "偏将军就是爷",
  ["designer:yyfy_piangrandpa"] = "幻矩",
}

local youlewangzi = General:new(extension, "yyfy_youlewangzi", "god", 4, 4, General.Male)
youlewangzi:addSkills {"yyfy_mianjv", "yyfy_miyu"}
Fk:loadTranslationTable{
  ["yyfy_youlewangzi"] = "游乐王子",
  ["#yyfy_youlewangzi"] = "谜语人",
  ["designer:yyfy_youlewangzi"] = "夜隐浮云，孤星似梦",
}

local ex_simashi = General:new(extension, "yyfy_ex_simashi", "wei", 4, 4, General.Male)
ex_simashi:addSkills {"yyfy_ex_baiyi", "yyfy_ex_jinglue", "yyfy_ex_shanli"}
Fk:loadTranslationTable{
  ["yyfy_ex_simashi"] = "界司马师",
  ["designer:yyfy_ex_simashi"] = "非电竞恐龙",
  ["~yyfy_ex_simashi"] = "子上，先之则太过，后之则不及……"
}

return extension