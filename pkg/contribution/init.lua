local ok, D = pcall(require, "packages.DR-system.record.DRRP")

local extension = Package:new("contribution")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/contribution/skills")

local exgod_zhangliao = General:new(extension, "exgod_zhangliao", "god", 4, 5)
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

local mou_wupu = General:new(extension, "yyfy_mou_wupu", "qun", 4)
mou_wupu:addSkills { "yyfy_duanti", "yyfy_shicao" }
mou_wupu:addRelatedSkill("wuling")
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

local lijueguosi = General:new(extension, "yyfy_lijueguosi", "qun", 4)
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

local caomao = General:new(extension, "lan__caomao", "wei", 4)
caomao:addSkills {"lan__qianlong", "lan__juetao", "lan__fensi", "lan__weitong"}
Fk:loadTranslationTable{
  ["lan__caomao"] = "烂曹髦",
  ["#lan__caomao"] = "曹髦布兰德",
  ["designer:lan__caomao"] = "水上由岐",
  ["!lan__caomao"] = "少康诛寒浞以中兴，朕夷司马未尝不可！",
  ["~lan__caomao"] = "纵不成身死，朕亦为太祖子孙，大魏君王……"
}

local huanggai = General:new(extension, "lan__huanggai", "wu", 4)
huanggai:addSkills {"kurou", "lan__zhaxiang", "lan__lieji", "lan__quzhou"}
Fk:loadTranslationTable{
  ["lan__huanggai"] = "烂黄盖",
  ["#lan__huanggai"] = "盖子布兰德",
  ["designer:lan__huanggai"] = "水上由岐",
  ["~lan__huanggai"] = "哈哈哈哈，公瑾计成，老夫死也无憾了……"
}

local dengai = General:new(extension, "lan__dengai", "wei", 4)
dengai:addSkills {"lan__neyan", "lan__tuntian", "lan__zaoxian", "lan__jixi", "ty__zhouxi"}
Fk:loadTranslationTable{
  ["lan__dengai"] = "烂邓艾",
  ["#lan__dengai"] = "邓艾布兰德",
  ["designer:lan__dengai"] = "水上由岐",
  ["~lan__dengai"] = "钟会！你为何害我！"
}

local pianye = General:new(extension, "yyfy_pianye", "god", 1, 999)
pianye:addSkills {"yyfy_gouyun", "yyfy_haopai", "yyfy_huangdou"}
Fk:loadTranslationTable{
  ["yyfy_pianye"] = "偏✌️",
  ["#yyfy_pianye"] = "偏将军就是✌️",
  ["designer:yyfy_pianye"] = "幻矩",
}

local piangrandpa = General:new(extension, "yyfy_piangrandpa", "god", 4)
piangrandpa:addSkills {"yyfy_gouyun", "yyfy_haopai↓", "yyfy_huangdou"}
Fk:loadTranslationTable{
  ["yyfy_piangrandpa"] = "偏爷",
  ["#yyfy_piangrandpa"] = "偏将军就是爷",
  ["designer:yyfy_piangrandpa"] = "幻矩",
}

local youlewangzi = General:new(extension, "yyfy_youlewangzi", "god", 4)
youlewangzi:addSkills {"yyfy_mianjv", "yyfy_miyu"}
Fk:loadTranslationTable{
  ["yyfy_youlewangzi"] = "游乐王子",
  ["#yyfy_youlewangzi"] = "谜语人",
  ["designer:yyfy_youlewangzi"] = "夜隐浮云，孤星似梦",
}

local ex_simashi = General:new(extension, "yyfy_ex_simashi", "wei", 4)
ex_simashi:addSkills {"yyfy_ex_baiyi", "yyfy_ex_jinglue", "yyfy_ex_shanli"}
Fk:loadTranslationTable{
  ["yyfy_ex_simashi"] = "界司马师",
  ["designer:yyfy_ex_simashi"] = "非电竞恐龙",
  ["~yyfy_ex_simashi"] = "子上，先之则太过，后之则不及……"
}

local gaodaerhao = General:new(extension, "yyfy_gaodaerhao", "god", 3)
gaodaerhao:addSkills {"yyfy_shelie", "yyfy_gongxin"}
Fk:loadTranslationTable{
  ["yyfy_gaodaerhao"] = "高达二号",
  ["~yyfy_gaodaerhao"] = "终是逃不开，追魂索命之咒……"
}

local KusanagiGodou = General:new(extension, "yyfy_KusanagiGodou", "evil", 4)
KusanagiGodou:addSkills {"yyfy_shishen", "yyfy_quanneng"}
Fk:loadTranslationTable{
  ["yyfy_KusanagiGodou"] = "草薙护堂",
  ["#yyfy_KusanagiGodou"] = "弑神者",
  ["designer:yyfy_KusanagiGodou"] = "夜隐浮云，孤星似梦",
}
KusanagiGodou:addRelatedSkills{
  "yyfy_qiangfeng", "yyfy_gongniu", "yyfy_baima", "yyfy_luotuo", "yyfy_shanzhu",
  "yyfy_shaonian", "yyfy_fenghuang", "yyfy_muyang", "yyfy_shanyang", "yyfy_zhanshi"
}

local yueCaocao = General:new(extension, "yyfy_yueCaocao", "wei", 4)
yueCaocao:addSkills {"yyfy_yanjv", "yyfy_hejue"}
Fk:loadTranslationTable{
  ["yyfy_yueCaocao"] = "乐曹操",
  ["designer:yyfy_yueCaocao"] = "幻矩",
  ["illustrator:yyfy_yueCaocao"] = "新三国",
  ["cv:yyfy_yueCaocao"] = "电视剧原声",
  ["$xixiang_yyfy_yueCaocao1"] = "但为，君故，沉吟，至今。",
  ["$xixiang_yyfy_yueCaocao2"] = "但为君故，沉吟至今。",
  ["$zhubei_yyfy_yueCaocao1"] = "我有，嘉宾，鼓瑟，吹笙。",
  ["$zhubei_yyfy_yueCaocao2"] = "我有嘉宾，鼓瑟吹笙。",
  ["$duoyue_yyfy_yueCaocao1"] = "明明，如月，何时，可掇？",
  ["$duoyue_yyfy_yueCaocao2"] = "皎皎如月，何时可辍？",
  ["$guixin_yyfy_yueCaocao1"] = "周公，吐哺，天下，归心。",
  ["$guixin_yyfy_yueCaocao2"] = "周公吐哺，天下归心。",
  ["~yyfy_yueCaocao"] = "安敢败我诗兴？（我...）"
}
yueCaocao:addRelatedSkills({"xixiang", "zhubei", "duoyue", "guixin"})

local zengzhideG = General:new(extension, "yyfy_zengzhideG", "evil", 2)
zengzhideG:addSkill("yyfy_zengzhi")
Fk:loadTranslationTable{
  ["yyfy_zengzhideG"] = "增殖的G",
  ["#yyfy_zengzhideG"] = "王牌怪兽",
  ["designer:yyfy_zengzhideG"] = "夜隐浮云，孤星似梦",
}

local huiliuli = General:new(extension, "yyfy_huiliuli", "evil", 3, 3, General.Female)
huiliuli:addSkill("yyfy_hui")
Fk:loadTranslationTable{
  ["yyfy_huiliuli"] = "灰流丽",
  ["#yyfy_huiliuli"] = "王牌怪兽の宿敌",
  ["designer:yyfy_huiliuli"] = "夜隐浮云，孤星似梦",
}

local caoshuang = General:new(extension, "yyfy_ex_caoshuang", "wei", 4)
caoshuang:addSkills {"yyfy_tuogu", "yyfy_shanzhuan"}
Fk:loadTranslationTable{
  ["yyfy_ex_caoshuang"] = "界曹爽",
  ["#yyfy_ex_caoshuang"] = "托孤辅政",
  ["designer:yyfy_ex_caoshuang"] = "夜隐浮云，孤星似梦",
  ["~yyfy_ex_caoshuang"] = "悔不该降了司马懿……",
  ["$ex__biyue_yyfy_ex_caoshuang1"] = "失礼了～",
  ["$ex__biyue_yyfy_ex_caoshuang2"] = "羡慕吧～",
  ["illustrator:yyfy_ex_caoshuang"] = "君桓文化"
}
caoshuang:addRelatedSkill("ex__biyue")

local end_jiaxu = General:new(extension, "yyfy_end_jiaxu", "qun", 3)
end_jiaxu:addSkills {"yyfy_wansha", "yyfy_weimu", "yyfy_luanwu"}
Fk:loadTranslationTable{
  ["yyfy_end_jiaxu"] = "终贾诩",
  ["#yyfy_end_jiaxu"] = " ",
  ["designer:yyfy_end_jiaxu"] = "一维无限",
  ["~yyfy_end_jiaxu"] = "天下大定，某，亦得功成名就。",
}

local god_zhangfei = General:new(extension, "yyfy_god_zhangfei", "god", 4)
god_zhangfei:addSkills {"yyfy_liyong", "yyfy_zhaifeng", "yyfy_xingshou"}
Fk:loadTranslationTable{
  ["yyfy_god_zhangfei"] = "神张飞",
  ["#yyfy_god_zhangfei"] = "傲凌世间",
  ["~yyfy_god_zhangfei"] = "桃花今又开，不见结义人。",
}

local god_machao = General:new(extension, "yyfy_god_machao", "god", 4)
god_machao:addSkills {"yyfy_xiongji", "yyfy_zhuishi", "yyfy_hengwu"}
Fk:loadTranslationTable{
  ["yyfy_god_machao"] = "神马超",
  ["#yyfy_god_machao"] = "壮志凌云",
  ["!yyfy_god_machao"] = "烽烟擦鞍过，独向玄黄证苍茫，夜驰欲饮天河浪！",
  ["~yyfy_god_machao"] = "七情难掩，六欲难消，何谓之神？",
}

local mingshen = General:new(extension, "yyfy_UnderworldGoddess", "evil", 5, 5, General.Female)
mingshen:addSkills {"yyfy_shiri", "yyfy_mingshen", "yyfy_duixiang"}
Fk:loadTranslationTable{
  ["yyfy_UnderworldGoddess"] = "闭锁世界的冥神",
  ["#yyfy_UnderworldGoddess"] = "牌佬指定对象",
  ["designer:yyfy_UnderworldGoddess"] = "夜隐浮云，孤星似梦"
}

local gaoshou = General:new(extension, "yyfy_gaoshou", "god", 4)
gaoshou:addSkills {"yyfy_konggou"}
Fk:loadTranslationTable{
  ["yyfy_gaoshou"] = "高手",
  ["#yyfy_gaoshou"] = "",
  ["designer:yyfy_gaoshou"] = "幻矩"
}

local woyeyaosima = General:new(extension, "yyfy_woyeyaosima", "god", 4, 4, General.Female)
woyeyaosima:addSkills {"yyfy_woyeyaogeima", "yyfy_woyeyaosima"}
Fk:loadTranslationTable{
  ["yyfy_woyeyaosima"] = "我也要死吗",
  ["#yyfy_woyeyaosima"] = "对！",
  ["designer:yyfy_woyeyaosima"] = "夜隐浮云，孤星似梦"
}

local puni = General:new(extension, "yyfy_shenglingpuni", "god", 1)
puni:addSkills {"yyfy_shenglingfengyin", "yyfy_luofangtianhua", "yyfy_guangrongzhimeng", "yyfy_jiushishenling"}
Fk:loadTranslationTable{
  ["yyfy_shenglingpuni"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni"] = "传说",
  ["designer:yyfy_shenglingpuni"] = "一维无限"
}
puni:addRelatedSkills({"yyfy_xuwu", "yyfy_yuansu", "yyfy_nengliang", "yyfy_shengming", "yyfy_lunhui", "yyfy_yongheng", "yyfy_shengjie"})

local puni1 = General:new(extension, "yyfy_shenglingpuni1", "god", 1)
puni1:addSkills {"yyfy_xuwu"}
Fk:loadTranslationTable{
  ["yyfy_shenglingpuni1"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni1"] = "虚无",
  ["designer:yyfy_shenglingpuni1"] = "一维无限"
}
puni1.total_hidden = true

local puni2 = General:new(extension, "yyfy_shenglingpuni2", "god", 1)
puni2:addSkills {"yyfy_yuansu"}
Fk:loadTranslationTable{
  ["yyfy_shenglingpuni2"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni2"] = "元素",
  ["designer:yyfy_shenglingpuni2"] = "一维无限"
}
puni2.total_hidden = true

local puni3 = General:new(extension, "yyfy_shenglingpuni3", "god", 1)
puni3:addSkills {"yyfy_nengliang"}
Fk:loadTranslationTable{
  ["yyfy_shenglingpuni3"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni3"] = "能量",
  ["designer:yyfy_shenglingpuni3"] = "一维无限"
}
puni3.total_hidden = true

local puni4 = General:new(extension, "yyfy_shenglingpuni4", "god", 1)
puni4:addSkills {"yyfy_shengming"}
Fk:loadTranslationTable{
  ["yyfy_shenglingpuni4"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni4"] = "生命",
  ["designer:yyfy_shenglingpuni4"] = "一维无限"
}
puni4.total_hidden = true

local puni5 = General:new(extension, "yyfy_shenglingpuni5", "god", 1)
puni5:addSkills {"yyfy_lunhui"}
Fk:loadTranslationTable{
  ["yyfy_shenglingpuni5"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni5"] = "轮回",
  ["designer:yyfy_shenglingpuni5"] = "一维无限"
}
puni5.total_hidden = true

local puni6 = General:new(extension, "yyfy_shenglingpuni6", "god", 1)
puni6:addSkills {"yyfy_yongheng"}
Fk:loadTranslationTable{
  ["yyfy_shenglingpuni6"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni6"] = "永恒",
  ["designer:yyfy_shenglingpuni6"] = "一维无限"
}
puni6.total_hidden = true

local puni7 = General:new(extension, "yyfy_shenglingpuni7", "god", 1)
puni7:addSkills {"yyfy_shengjie"}
Fk:loadTranslationTable{
  ["yyfy_shenglingpuni7"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni7"] = "圣洁",
  ["designer:yyfy_shenglingpuni7"] = "一维无限"
}
puni7.total_hidden = true

Fk:loadTranslationTable {
  ["exgod_zhangliao_1"] = "闻风丧胆",
  ["desc:exgod_zhangliao_1"] = "通过〖夺锐〗在一局游戏中获得至少5个技能，并取得胜利。",
  ["yyfy_mou_wupu_1"] = "医脉相承",
  ["desc:yyfy_mou_wupu_1"] = "累计3次通过〖锻体〗获得技能〖五灵〗。",
  ["yyfy_mou_wupu_2"] = "遍尝百草",
  ["desc:yyfy_mou_wupu_2"] = "通过〖识草〗累计获得100张牌。",
  ["lan__tengfanglan_1"] = "一时之宠",
  ["desc:lan__tengfanglan_1"] = "累计3次，在一次〖落宠〗中发动所有效果的最大次数。",
  ["lan__xunyou_1"] = "十二奇策",
  ["desc:lan__xunyou_1"] = "通过〖百出〗在一局游戏中获得至少12张牌，并取得胜利。",
  ["lan__zhonghui_1"] = "今日起兵",
  ["desc:lan__zhonghui_1"] = "累计3次，在一局游戏中获得3张「权」并取得胜利。",
  ["lan__caomao_1"] = "大魏君王",
  ["desc:lan__caomao_1"] = "通过〖潜龙〗在一局游戏中获得3个“大胃菌王”技能，并取得胜利。",
}

local achievements_data = {
  {
    id = "exgod_zhangliao",
    name = "界神张辽",
    achievements = {
      {
        id = "exgod_zhangliao_1",
        target = 1,
        name = "闻风丧胆",
        desc = "通过〖夺锐〗在一局游戏中获得至少5个技能，并取得胜利。"
      },
    },
  },
  {
    id = "yyfy_mou_wupu",
    name = "谋吴普",
    achievements = {
      {
        id = "yyfy_mou_wupu_1",
        target = 3,
        name = "医脉相承",
        desc = "累计3次通过〖锻体〗获得技能〖五灵〗。"
      },
      {
        id = "yyfy_mou_wupu_2",
        target = 100,
        name = "遍尝百草",
        desc = "通过〖识草〗累计获得100张牌。"
      }
    },
  },
  {
    id = "lan__tengfanglan",
    name = "烂滕芳兰",
    achievements = {
      {
        id = "lan__tengfanglan_1",
        target = 3,
        name = "一时之宠",
        desc = "累计3次，在一次〖落宠〗中发动所有效果的最大次数。"
      },
    },
  },
  {
    id = "lan__xunyou",
    name = "烂荀攸",
    achievements = {
      {
        id = "lan__xunyou_1",
        target = 1,
        name = "十二奇策",
        desc = "通过〖百出〗在一局游戏中获得至少12张牌，并取得胜利。",
      },
    },
  },
  {
    id = "lan__zhonghui",
    name = "烂钟会",
    achievements = {
      {
        id = "lan__zhonghui_1",
        target = 3,
        name = "今日起兵",
        desc = "累计3次，在一局游戏中获得3张「权」并取得胜利。",
      },
    },
  },
  {
    id = "lan__caomao",
    name = "烂曹髦",
    achievements = {
      {
        id = "lan__caomao_1",
        target = 1,
        name = "大魏君王",
        desc = "通过〖潜龙〗在一局游戏中获得3个“大胃菌王”技能，并取得胜利。",
      },
    },
  },
}

if ok and D and type(D.RegisterAchievementPackage) == "function" then
  D.RegisterAchievementPackage("夜隐浮云", achievements_data, "hidden-clouds/image/generals")
end

return extension