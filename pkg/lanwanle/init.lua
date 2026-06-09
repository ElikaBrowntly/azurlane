local ok, U = pcall(require, "packages.glory_days.utility")

local extension = Package:new("lanwanle")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/lanwanle/skills")

local lan__tengfanglan = General:new(extension, "lan__tengfanglan", "wu", 3, 3, General.Female)
lan__tengfanglan:addSkills { "lan__luochong", "lan__aichen" }
Fk:loadTranslationTable
{
  ["lanwanle"] = "烂完了",
  ["lan"] = "烂",
  ["lan__tengfanglan"] = "烂滕芳兰",
  ["#lan__tengfanglan"] = "滕子布兰德",
  ["designer:lan__tengfanglan"] = "水上由岐",
  ["~lan__tengfanglan"] = "封侯归命，夫妻同归。",
}

local lan__xunyou = General:new(extension, "lan__xunyou", "wei", 3)
lan__xunyou:addSkills { "lan__baichu", "yyfy_qice", "lan__zhiyu", "yyfy_daojie" }
Fk:loadTranslationTable
{
  ["lan__xunyou"] = "烂荀攸",
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

local lan__zhonghui = General:new(extension, "lan__zhonghui", "wei", 3, 4)
lan__zhonghui:addSkills { "lan__yuzhi", "lan__xieshu", "lan__quanji", "lan__paiyi", "yyfy_baozu" }
Fk:loadTranslationTable
{
  ["lan__zhonghui"] = "烂钟会",
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

local caomao = General:new(extension, "lan__caomao", "wei", 4)
caomao:addSkills { "lan__qianlong", "lan__juetao", "lan__fensi", "lan__weitong" }
Fk:loadTranslationTable {
  ["lan__caomao"] = "烂曹髦",
  ["#lan__caomao"] = "曹髦布兰德",
  ["designer:lan__caomao"] = "水上由岐",
  ["!lan__caomao"] = "少康诛寒浞以中兴，朕夷司马未尝不可！",
  ["~lan__caomao"] = "纵不成身死，朕亦为太祖子孙，大魏君王……"
}

local huanggai = General:new(extension, "lan__huanggai", "wu", 4)
huanggai:addSkills { "kurou", "lan__zhaxiang", "lan__lieji", "lan__quzhou" }
Fk:loadTranslationTable {
  ["lan__huanggai"] = "烂黄盖",
  ["#lan__huanggai"] = "盖子布兰德",
  ["designer:lan__huanggai"] = "水上由岐",
  ["~lan__huanggai"] = "哈哈哈哈，公瑾计成，老夫死也无憾了……"
}

local dengai = General:new(extension, "lan__dengai", "wei", 4)
dengai:addSkills { "lan__neyan", "lan__tuntian", "lan__zaoxian", "lan__jixi", "ty__zhouxi" }
Fk:loadTranslationTable {
  ["lan__dengai"] = "烂邓艾",
  ["#lan__dengai"] = "邓艾布兰德",
  ["designer:lan__dengai"] = "水上由岐",
  ["~lan__dengai"] = "钟会！你为何害我！"
}

local caoxiancaohua = General:new(extension, "lan__caoxiancaohua", "qun", 3)
caoxiancaohua:addSkills { "lan__huamu", "lan__liangyuan", "lan__jisi", "lan__lingxi",
  "lan__zhifou", "lan__caiyi", "lan__guili" }
Fk:loadTranslationTable {
  ["lan__caoxiancaohua"] = "烂二曹",
  ["#lan__caoxiancaohua"] = "二曹布兰德",
  ["designer:lan__caoxiancaohua"] = "夜隐浮云",
  ["~lan__caoxiancaohua"] = "无情总是帝王家。"
}

local xuncai = General:new(extension, "lan__xuncai", "qun", 3, 3, General.Female)
xuncai:addSkills { "lan__lieshi", "lan__dianzhan", "lan__huanyin", "yyfy_daojie" }
Fk:loadTranslationTable {
  ["lan__xuncai"] = "烂荀采",
  ["#lan__xuncai"] = "荀采布兰德",
  ["designer:lan__xuncai"] = "水上由岐",
  ["~lan__xuncai"] = "苦难已过，世间大好……",
  ["$yyfy_daojie_lan__xuncai1"] = "女子有节，宁死蹈之。",
  ["$yyfy_daojie_lan__xuncai2"] = "荀氏三纲，死不贰嫁。",
}

local sunquan = General:new(extension, "lan__sunquan", "wu", 4)
sunquan:addSkills { "lan__zhiheng", "lan__woheng", "lan__yuhui", "lan__quanyu",
 "lan__tianen", "lan__renxian", "lan__jiuyuan" }
Fk:loadTranslationTable {
  ["lan__sunquan"] = "烂孙权",
  ["#lan__sunquan"] = "孙权布兰德",
  ["designer:lan__sunquan"] = "幻矩",
  ["~lan__sunquan"] = "朕非朕，天下皆朕！",
}

local zhuzhi = General:new(extension, "lan__zhuzhi", "wu", 4)
zhuzhi:addSkills { "lan__anguo", "lan__lingke" }
Fk:loadTranslationTable {
  ["lan__zhuzhi"] = "烂朱治",
  ["#lan__zhuzhi"] = "穷哥们布兰德",
  ["designer:lan__zhuzhi"] = "水上由岐",
  ["~lan__zhuzhi"] = "集毕生之力，保国泰民安。",
}

local machao = General:new(extension, "lan__machao", "qun", 2, 4)
machao.shield = 3
machao:addSkills { "lan__shouli", "lan__hengwu", "lan__zhongtao", "lan__jizhan" ,"dlmou__tieji",
"lan__zhuiji", "ol__shichou", "lan__tingwei", "lan__jimie" }
Fk:loadTranslationTable{
  ["lan__machao"] = "烂马超",
  ["#lan__machao"] = "雄烈盖世",
  ["illustrator:lan__machao"] = "维柯托骑士",
  ["designer:lan__machao"] = "幻矩",
  ["~lan__machao"] = "战马不休，唯死方卧……",
}

local ganfuren = General:new(extension, "lan__ganfurenmifuren", "shu", 3, 3, General.Female)
ganfuren:addSkills { "lan__chanjuan", "lan__xunbie" }
ganfuren:addRelatedSkills{ "dl__shushen", "dl__huangsi", "dl__guixiu", "dl__cunsi", "dl__yongjue" }
Fk:loadTranslationTable{
  ["lan__ganfurenmifuren"] = "烂甘夫人糜夫人",
  ["#lan__ganfurenmifuren"] = "千里婵娟",
  ["illustrator:lan__ganfurenmifuren"] = "七兜豆",
  ["designer:lan__ganfurenmifuren"] = "神狐月",
  ["~lan__ganfurenmifuren"] = "人生百年，奈何于我十不存一……",
}

local lvbu = General:new(extension, "lan__lvbu", "qun", 5)
lvbu:addSkills { "lan__feijiang", "lan__shenji", "lan__zhenguan", "lan__wushuang", "lan__xiuluo", "mashu" }
Fk:loadTranslationTable {
  ["lan__lvbu"] = "烂吕布",
  ["#lan__lvbu"] = "无双飞将",
  ["designer:lan__lvbu"] = "焉民",
  ["~lan__lvbu"] = "且慢，君若不弃，布愿拜为义父啊，义父！",
  ["!lan__lvbu"] = "这大好江山，我何不可一览！",
}

local lvbu2 = General:new(extension, "lan2__lvbu", "qun", 5)
lvbu2:addSkills { "lan__duoqi", "lan__gangquan", "lan__xiaowu", "lan__baguan", "lan__fengzhu", "lan__jingjia" }
Fk:loadTranslationTable {
  ["lan2"] = "烂",
  ["lan2__lvbu"] = "烂吕布",
  ["#lan2__lvbu"] = "吕布布兰德",
  ["designer:lan2__lvbu"] = "幻矩",
  ["~lan2__lvbu"] = "你们的项上人头，我改日再取！"
}

local duyu = General:new(extension, "lan__duyu", "jin", 5)
duyu:addSkills { "lan__wuku", "lan__miewu", "lan__sanchen", "lan__pozhu", "jianguo" }
Fk:loadTranslationTable {
  ["lan__duyu"] = "烂杜预",
  ["#lan__duyu"] = "杜预布兰德",
  ["designer:lan__duyu"] = "夜隐浮云",
  ["~lan__duyu"] = "司马氏得国不正，吾却助纣为虐，此天伐之。"
}

local simashi = General:new(extension, "lan__simashi", "jin", 4)
simashi:addSkills { "lan__taoyin", "lan__yimie", "lan__tairan", "lan__sanshi", "lan__zhenrao",
"lan__chenlue", "lan__baiyi", "lan__jinglue", "lan__shanli", "ruilue" }
Fk:loadTranslationTable {
  ["lan__simashi"] = "烂司马师",
  ["#lan__simashi"] = "一拳超人",
  ["designer:lan__simashi"] = "大闲者八雲紫",
  ["~lan__simashi"] = "心高命薄，天何薄我……"
}

local zhangjiao = General:new(extension, "lan__zhangjiao", "qun", 3)
zhangjiao:addSkills { "lan__leiji", "lan__guidao", "lan__tiangong", "lan__tianjie", "lan__huangtian" }
Fk:loadTranslationTable {
  ["lan__zhangjiao"] = "烂张角",
  ["#lan__zhangjiao"] = "张角布兰德",
  ["designer:lan__zhangjiao"] = "焉民",
  ["~lan__zhangjiao"] = "逆天而行，必遭天谴啊"
}

return extension