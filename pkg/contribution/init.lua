local ok, U = pcall(require, "packages.glory_days.utility")

local extension = Package:new("contribution")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/contribution/skills")

local exgod_zhangliao = General:new(extension, "yyfy_exgod_zhangliao", "god", 4, 5)
exgod_zhangliao:addSkills { "yyfy_duorui", "yyfy_zhiti" }
exgod_zhangliao:addRelatedSkill("yyfy_wangxi")
Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["contribution"] = "投稿 1",
  ["yyfy"] = "",
  ["yyfy_exgod_zhangliao"] = "界神张辽",
  ["#yyfy_exgod_zhangliao"] = "美食家",
  ["designer:yyfy_exgod_zhangliao"] = "水上由岐",
  ["~yyfy_exgod_zhangliao"] = "我也有……被孙仲谋所伤之时",
}

local mou_wupu = General:new(extension, "yyfy_mou__wupu", "qun", 4)
mou_wupu:addSkills { "yyfy_duanti", "yyfy_shicao" }
mou_wupu:addRelatedSkill("wuling")
Fk:loadTranslationTable
{
  ["yyfy_mou__wupu"] = "谋吴普",
  ["#yyfy_mou__wupu"] = "健体养魄",
  ["designer:yyfy_mou__wupu"] = "夜隐浮云",
  ["~yyfy_mou__wupu"] = "五禽犹在，此戏传于后来人。",
}

local lijueguosi = General:new(extension, "yyfy_lijueguosi", "qun", 4)
lijueguosi:addSkills { "yyfy_xiongxi", "yyfy_yisuan" }
Fk:loadTranslationTable {
  ["yyfy_lijueguosi"] = "李傕郭汜",
  ["#yyfy_lijueguosi"] = "犯祚倾祸",
  ["designer:yyfy_lijueguosi"] = "多喝热水",
  ["~yyfy_lijueguosi"] = "一心相争，兵败战损",
}

local zhixushenghua = General:new(extension, "yyfy_zhixushenghua", "god", 5, 5, General.Female)
zhixushenghua:addSkills { "yyfy_shengjianchujue", "yyfy_tianmingyini", "yyfy_shengshayuduo" }
Fk:loadTranslationTable {
  ["yyfy_zhixushenghua"] = "至序圣华",
  ["designer:yyfy_zhixushenghua"] = "一维无限",
}

local xunshengshouwei = General:new(extension, "yyfy_xunshengshouwei", "god", 4, 4, General.Female)
xunshengshouwei:addSkills { "yyfy_jianjiao", "yyfy_wusheng", "yyfy_huixiang" }
Fk:loadTranslationTable {
  ["yyfy_xunshengshouwei"] = "循声守卫",
  ["designer:yyfy_xunshengshouwei"] = "一维无限",
}

local pianye = General:new(extension, "yyfy_pianye", "god", 1, 999)
pianye:addSkills { "yyfy_gouyun", "yyfy_haopai", "yyfy_huangdou" }
Fk:loadTranslationTable {
  ["yyfy_pianye"] = "偏✌️",
  ["#yyfy_pianye"] = "偏将军就是✌️",
  ["designer:yyfy_pianye"] = "幻矩",
}

local piangrandpa = General:new(extension, "yyfy_piangrandpa", "god", 4)
piangrandpa:addSkills { "yyfy_gouyun", "yyfy_haopai↓", "yyfy_huangdou" }
Fk:loadTranslationTable {
  ["yyfy_piangrandpa"] = "偏爷",
  ["#yyfy_piangrandpa"] = "偏将军就是爷",
  ["designer:yyfy_piangrandpa"] = "幻矩",
}

local guohujun = General:new(extension, "yyfy_guohujun", "god", 6, 7)
guohujun:addSkills { "yyfy_zuiying" }
Fk:loadTranslationTable {
  ["yyfy_guohujun"] = "国护军",
  ["#yyfy_guohujun"] = "国护军就是爷",
  ["designer:yyfy_guohujun"] = "幻矩",
}

local youlewangzi = General:new(extension, "yyfy_youlewangzi", "god", 4)
youlewangzi:addSkills { "yyfy_mianjv", "yyfy_miyu" }
Fk:loadTranslationTable {
  ["yyfy_youlewangzi"] = "游乐王子",
  ["#yyfy_youlewangzi"] = "谜语人",
  ["designer:yyfy_youlewangzi"] = "夜隐浮云",
}

-- local ex_simashi = General:new(extension, "yyfy_ex__simashi", "wei", 4)
-- ex_simashi:addSkills { "yyfy_ex_baiyi", "yyfy_ex_jinglue", "yyfy_ex_shanli" }
-- Fk:loadTranslationTable {
--   ["yyfy_ex__simashi"] = "界司马师",
--   ["designer:yyfy_ex__simashi"] = "非电竞恐龙",
--   ["~yyfy_ex__simashi"] = "子上，先之则太过，后之则不及……"
-- }

-- local gaodaerhao = General:new(extension, "yyfy_gaodaerhao", "god", 3)
-- gaodaerhao:addSkills { "yyfy_shelie", "yyfy_gongxin" }
-- Fk:loadTranslationTable {
--   ["yyfy_gaodaerhao"] = "高达二号",
--   ["~yyfy_gaodaerhao"] = "终是逃不开，追魂索命之咒……"
-- }

local KusanagiGodou = General:new(extension, "yyfy_KusanagiGodou", "evil", 4)
KusanagiGodou:addSkills { "yyfy_shishen", "yyfy_quanneng" }
Fk:loadTranslationTable {
  ["yyfy_KusanagiGodou"] = "草薙护堂",
  ["#yyfy_KusanagiGodou"] = "弑神者",
  ["designer:yyfy_KusanagiGodou"] = "夜隐浮云",
}
KusanagiGodou:addRelatedSkills {
  "yyfy_qiangfeng", "yyfy_gongniu", "yyfy_baima", "yyfy_luotuo", "yyfy_shanzhu",
  "yyfy_shaonian", "yyfy_fenghuang", "yyfy_muyang", "yyfy_shanyang", "yyfy_zhanshi"
}

local yueCaocao = General:new(extension, "yyfy_yue__caocao", "wei", 4)
yueCaocao:addSkills { "yyfy_yanjv", "yyfy_hejue" }
Fk:loadTranslationTable {
  ["yyfy_yue"] = "",
  ["yyfy_yue__caocao"] = "乐曹操",
  ["designer:yyfy_yue__caocao"] = "幻矩",
  ["illustrator:yyfy_yue__caocao"] = "新三国",
  ["cv:yyfy_yue__caocao"] = "电视剧原声",
  ["$xixiang_yyfy_yue__caocao1"] = "但为，君故，沉吟，至今。",
  ["$xixiang_yyfy_yue__caocao2"] = "但为君故，沉吟至今。",
  ["$zhubei_yyfy_yue__caocao1"] = "我有，嘉宾，鼓瑟，吹笙。",
  ["$zhubei_yyfy_yue__caocao2"] = "我有嘉宾，鼓瑟吹笙。",
  ["$duoyue_yyfy_yue__caocao1"] = "明明，如月，何时，可掇？",
  ["$duoyue_yyfy_yue__caocao2"] = "皎皎如月，何时可辍？",
  ["$guixin_yyfy_yue__caocao1"] = "周公，吐哺，天下，归心。",
  ["$guixin_yyfy_yue__caocao2"] = "周公吐哺，天下归心。",
  ["~yyfy_yue__caocao"] = "安敢败我诗兴？（我...）"
}
yueCaocao:addRelatedSkills({ "xixiang", "zhubei", "duoyue", "guixin" })

local caoshuang = General:new(extension, "yyfy_ex__caoshuang", "wei", 4)
caoshuang:addSkills { "yyfy_tuogu", "yyfy_shanzhuan" }
Fk:loadTranslationTable {
  ["yyfy_ex__caoshuang"] = "界曹爽",
  ["#yyfy_ex__caoshuang"] = "托孤辅政",
  ["designer:yyfy_ex__caoshuang"] = "夜隐浮云",
  ["~yyfy_ex__caoshuang"] = "悔不该降了司马懿……",
  ["$ex__biyue_yyfy_ex__caoshuang1"] = "失礼了～",
  ["$ex__biyue_yyfy_ex__caoshuang2"] = "羡慕吧～",
  ["illustrator:yyfy_ex__caoshuang"] = "君桓文化"
}
caoshuang:addRelatedSkill("ex__biyue")

local end_jiaxu = General:new(extension, "yyfy_end__jiaxu", "qun", 3)
end_jiaxu:addSkills { "yyfy_wansha", "yyfy_weimu", "yyfy_luanwu" }
Fk:loadTranslationTable {
  ["yyfy_end"] = "终",
  ["yyfy_end__jiaxu"] = "终贾诩",
  ["#yyfy_end__jiaxu"] = " ",
  ["designer:yyfy_end__jiaxu"] = "一维无限",
  ["~yyfy_end__jiaxu"] = "天下大定，某，亦得功成名就。",
}

-- local god_zhangfei = General:new(extension, "yyfy__godzhangfei", "god", 4)
-- god_zhangfei:addSkills { "yyfy_liyong", "yyfy_zhaifeng", "yyfy_xingshou" }
-- Fk:loadTranslationTable {
--   ["yyfy__godzhangfei"] = "神张飞",
--   ["#yyfy__godzhangfei"] = "傲凌世间",
--   ["~yyfy__godzhangfei"] = "桃花今又开，不见结义人。",
-- }

-- local god_machao = General:new(extension, "yyfy__godmachao", "god", 4)
-- god_machao:addSkills { "yyfy_xiongji", "yyfy_zhuishi", "yyfy_hengwu" }
-- Fk:loadTranslationTable {
--   ["yyfy__godmachao"] = "神马超",
--   ["#yyfy__godmachao"] = "壮志凌云",
--   ["!yyfy__godmachao"] = "烽烟擦鞍过，独向玄黄证苍茫，夜驰欲饮天河浪！",
--   ["~yyfy__godmachao"] = "汉升！人间新酒如何？",
-- }

local gaoshou = General:new(extension, "yyfy_gaoshou", "god", 4)
gaoshou:addSkills { "yyfy_konggou" }
Fk:loadTranslationTable {
  ["yyfy_gaoshou"] = "高手",
  ["#yyfy_gaoshou"] = "",
  ["designer:yyfy_gaoshou"] = "幻矩"
}

local woyeyaosima = General:new(extension, "yyfy_woyeyaosima", "god", 4, 4, General.Female)
woyeyaosima:addSkills { "yyfy_woyeyaogeima", "yyfy_woyeyaosima" }
Fk:loadTranslationTable {
  ["yyfy_woyeyaosima"] = "我也要死吗",
  ["#yyfy_woyeyaosima"] = "对！",
  ["designer:yyfy_woyeyaosima"] = "夜隐浮云"
}

local puni = General:new(extension, "yyfy_shenglingpuni", "god", 1)
puni:addSkills { "yyfy_shenglingfengyin", "yyfy_luofangtianhua", "yyfy_guangrongzhimeng", "yyfy_jiushishenling" }
Fk:loadTranslationTable {
  ["yyfy_shenglingpuni"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni"] = "传说",
  ["designer:yyfy_shenglingpuni"] = "一维无限"
}
puni:addRelatedSkills({ "yyfy_xuwu", "yyfy_yuansu", "yyfy_nengliang", "yyfy_shengming", "yyfy_lunhui", "yyfy_yongheng",
  "yyfy_shengjie" })

local puni1 = General:new(extension, "yyfy_shenglingpuni1", "god", 1)
puni1:addSkills { "yyfy_xuwu" }
Fk:loadTranslationTable {
  ["yyfy_shenglingpuni1"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni1"] = "虚无",
  ["designer:yyfy_shenglingpuni1"] = "一维无限"
}
puni1.total_hidden = true

local puni2 = General:new(extension, "yyfy_shenglingpuni2", "god", 1)
puni2:addSkills { "yyfy_yuansu" }
Fk:loadTranslationTable {
  ["yyfy_shenglingpuni2"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni2"] = "元素",
  ["designer:yyfy_shenglingpuni2"] = "一维无限"
}
puni2.total_hidden = true

local puni3 = General:new(extension, "yyfy_shenglingpuni3", "god", 1)
puni3:addSkills { "yyfy_nengliang" }
Fk:loadTranslationTable {
  ["yyfy_shenglingpuni3"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni3"] = "能量",
  ["designer:yyfy_shenglingpuni3"] = "一维无限"
}
puni3.total_hidden = true

local puni4 = General:new(extension, "yyfy_shenglingpuni4", "god", 1)
puni4:addSkills { "yyfy_shengming" }
Fk:loadTranslationTable {
  ["yyfy_shenglingpuni4"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni4"] = "生命",
  ["designer:yyfy_shenglingpuni4"] = "一维无限"
}
puni4.total_hidden = true

local puni5 = General:new(extension, "yyfy_shenglingpuni5", "god", 1)
puni5:addSkills { "yyfy_lunhui" }
Fk:loadTranslationTable {
  ["yyfy_shenglingpuni5"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni5"] = "轮回",
  ["designer:yyfy_shenglingpuni5"] = "一维无限"
}
puni5.total_hidden = true

local puni6 = General:new(extension, "yyfy_shenglingpuni6", "god", 1)
puni6:addSkills { "yyfy_yongheng" }
Fk:loadTranslationTable {
  ["yyfy_shenglingpuni6"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni6"] = "永恒",
  ["designer:yyfy_shenglingpuni6"] = "一维无限"
}
puni6.total_hidden = true

local puni7 = General:new(extension, "yyfy_shenglingpuni7", "god", 1)
puni7:addSkills { "yyfy_shengjie" }
Fk:loadTranslationTable {
  ["yyfy_shenglingpuni7"] = "圣灵谱尼",
  ["#yyfy_shenglingpuni7"] = "圣洁",
  ["designer:yyfy_shenglingpuni7"] = "一维无限"
}
puni7.total_hidden = true

local AdamSmith = General:new(extension, "yyfy_AdamSmith", "west", 3)
AdamSmith:addSkills { "yyfy_kanbujiandeshou" }
Fk:loadTranslationTable {
  ["yyfy_AdamSmith"] = "亚当·斯密",
  ["#yyfy_AdamSmith"] = "古典经济学之父",
  ["designer:yyfy_AdamSmith"] = "夜隐浮云"
}

local maoyidawang = General:new(extension, "yyfy_maoyidawang", "qun", 3)
maoyidawang:addSkills { "yyfy_market" }
Fk:loadTranslationTable {
  ["yyfy_maoyidawang"] = "贸易大王",
  ["#yyfy_maoyidawang"] = "",
  ["designer:yyfy_maoyidawang"] = "曹宪咬我"
}

local yuan__zhangliao = General:new(extension, "yyfy_yuan__zhangliao", "wei", 4)
yuan__zhangliao:addSkills { "yyfy_xizhen" }
Fk:loadTranslationTable {
  ["yyfy_yuan"] = "缘？",
  ["yyfy_yuan__zhangliao"] = "缘张辽",
  ["#yyfy_yuan__zhangliao"] = "破阵十万",
  ["designer:yyfy_yuan__zhangliao"] = "牢天师（Ark）",
  ["~yyfy_yuan__zhangliao"] = "骨埋大魏土，魂壮逍遥津！"
}

local tianshu_skels = require("packages.hidden-clouds.pkg.contribution.skills.tianshu.tianshu")
for _, skel in ipairs(tianshu_skels) do
  table.insert(extension.skill_skels, skel)
end
local nanhualaoxian = General:new(extension, "yyfy_ex__nanhualaoxian", "god", 4)
nanhualaoxian:addSkills { "yyfy_qingshu", "yyfy_shoushu", "yyfy_hedao" }
Fk:loadTranslationTable {
  ["yyfy_ex"] = "",
  ["yyfy_mou"] = "",
  ["yyfy_ex__nanhualaoxian"] = "界南华老仙",
  ["#yyfy_ex__nanhualaoxian"] = "道法自然",
  ["designer:yyfy_ex__nanhualaoxian"] = "水上由岐",
  ["!yyfy_ex__nanhualaoxian"] = "因果开茅塞，轮回似醍醐。",
  ["~yyfy_ex__nanhualaoxian"] = "尔生异心，必获恶报。"
}

-- 太逆天了，737个技能，不能上线
local mou_nanhualaoxian = General:new(extension, "yyfy_mou__nanhualaoxian", "god", 4)
mou_nanhualaoxian:addSkills { "yyfy_mou_qingshu", "yyfy_shoushu" }
Fk:loadTranslationTable {
  ["yyfy_mou__nanhualaoxian"] = "谋南华老仙",
  ["#yyfy_mou__nanhualaoxian"] = "终成正果",
  ["designer:yyfy_mou__nanhualaoxian"] = "水上由岐"
}
mou_nanhualaoxian.hidden = true

local chengxiaoshi = General:new(extension, "qc__chengxiaoshi", "qun", 3)
chengxiaoshi:addSkills { "yyfy_qizha", "yyfy_powang", "yyfy_chengzhen" }
Fk:loadTranslationTable {
  ["qc__chengxiaoshi"] = "程小实",
  ["#qc__chengxiaoshi"] = "我从不骗人",
  ["designer:qc__chengxiaoshi"] = "青菜白玉汤"
}

local feiyi = General:new(extension, "yyfy_mou__feiyi", "shu", 3)
feiyi:addSkills { "yyfy_yanru", "yyfy_hezhong" }
Fk:loadTranslationTable {
  ["yyfy_mou__feiyi"] = "谋费祎",
  ["#yyfy_mou__feiyi"] = "志虑忠纯",
  ["designer:yyfy_mou__feiyi"] = "夜隐浮云/幻矩",
  ["~yyfy_mou__feiyi"] = "今为小人所伤，皆酒醉之误……"
}

local guanyu = General:new(extension, "yyfy_mou__guanyu", "shu", 4)
guanyu:addSkills { "yyfy_zhejiao", "yyfy_aozhan", "yyfy_yishi" }
Fk:loadTranslationTable {
  ["yyfy_mou__guanyu"] = "谋关羽",
  ["#yyfy_mou__guanyu"] = "从风傲苍穹",
  ["designer:yyfy_mou__guanyu"] = "牢天师（Ark）",
  ["~yyfy_mou__guanyu"] = "今为小人所伤，皆酒醉之误……"
}

local wolongfengchu = General:new(extension, "yyfy_end__wolongfengchu", "shu", 3)
wolongfengchu:addSkills { "yyfy_tiansuo", "yyfy_longfeng", "yyfy_qizhen" }
Fk:loadTranslationTable {
  ["yyfy_end__wolongfengchu"] = "终卧龙凤雏",
  ["#yyfy_end__wolongfengchu"] = "一匡天下",
  ["designer:yyfy_end__wolongfengchu"] = "一维无限",
  ["~yyfy_end__wolongfengchu"] = "天意难违，卧龙凤雏兼得又如何……"
}

local Keynes = General:new(extension, "yyfy_Keynes", "west", 3)
Keynes:addSkills { "yyfy_hongguanganyu" }
Fk:loadTranslationTable {
  ["yyfy_Keynes"] = "凯恩斯",
  ["#yyfy_Keynes"] = "宏观经济学之父",
  ["designer:yyfy_Keynes"] = "夜隐浮云",
}

local longchen = General:new(extension, "yyfy_longchen", "god", 3)
longchen:addSkills { "yyfy_hualong", "yyfy_tian" }
Fk:loadTranslationTable {
  ["yyfy_longchen"] = "龙辰",
  ["#yyfy_longchens"] = "祖龙武者",
  ["designer:yyfy_longchen"] = "青菜白玉汤",
}
longchen:addRelatedSkills { "yyfy_qiyuan", "yyfy_linghun", "yyfy_yuanshi", "yyfy_zaohua",
  "yyfy_hualong_yongheng", "yyfy_mingyun", "yyfy_yinguo", "yyfy_hualong_shengming",
  "yyfy_tianzai", "yyfy_xieshi", "yyfy_tianyou", "yyfy_tunshi" }

local longchen1 = General:new(extension, "yyfy_longchen1", "god", 3)
longchen1:addSkills { "yyfy_qiyuan", "yyfy_linghun" }
Fk:loadTranslationTable {
  ["yyfy_longchen1"] = "起源天龙",
}
longchen1.total_hidden = true
local longchen2 = General:new(extension, "yyfy_longchen2", "god", 3)
longchen2:addSkills { "yyfy_yuanshi", "yyfy_zaohua" }
Fk:loadTranslationTable {
  ["yyfy_longchen2"] = "元始祭龙",
}
longchen2.total_hidden = true
local longchen3 = General:new(extension, "yyfy_longchen3", "god", 3)
longchen3:addSkills { "yyfy_hualong_yongheng" }
Fk:loadTranslationTable {
  ["yyfy_longchen3"] = "太虚宙龙",
}
longchen3.total_hidden = true
local longchen4 = General:new(extension, "yyfy_longchen4", "god", 3)
longchen4:addSkills { "yyfy_mingyun" }
Fk:loadTranslationTable {
  ["yyfy_longchen4"] = "混元天命龙",
}
longchen4.total_hidden = true
local longchen5 = General:new(extension, "yyfy_longchen5", "god", 3)
longchen5:addSkills { "yyfy_yinguo" }
Fk:loadTranslationTable {
  ["yyfy_longchen5"] = "神道炼心龙",
}
longchen5.total_hidden = true
local longchen6 = General:new(extension, "yyfy_longchen6", "god", 3)
longchen6:addSkills { "yyfy_hualong_shengming" }
Fk:loadTranslationTable {
  ["yyfy_longchen6"] = "太极生灵龙",
}
longchen6.total_hidden = true
local longchen7 = General:new(extension, "yyfy_longchen7", "god", 3)
longchen7:addSkills { "yyfy_tianzai" }
Fk:loadTranslationTable {
  ["yyfy_longchen7"] = "宇宙洪荒卍劫龙",
}
longchen7.total_hidden = true
local longchen8 = General:new(extension, "yyfy_longchen8", "god", 3)
longchen8:addSkills { "yyfy_xieshi" }
Fk:loadTranslationTable {
  ["yyfy_longchen8"] = "太古血灵龙",
}
longchen8.total_hidden = true
local longchen9 = General:new(extension, "yyfy_longchen9", "god", 3)
longchen9:addSkills { "yyfy_tianyou" }
Fk:loadTranslationTable {
  ["yyfy_longchen9"] = "幽影梦魅龙",
}
longchen9.total_hidden = true
local longchen10 = General:new(extension, "yyfy_longchen10", "god", 3)
longchen10:addSkills { "yyfy_tunshi" }
Fk:loadTranslationTable {
  ["yyfy_longchen10"] = "混沌吞天龙",
}
longchen10.total_hidden = true

local yuanxingshangren = General:new(extension, "yyfy_yuanxingshangren", "god", 4)
yuanxingshangren:addSkills { "yyfy_xingshang" }
Fk:loadTranslationTable {
  ["yyfy_yuanxingshangren"] = "远行商人",
  ["#yyfy_yuanxingshangren"] = "",
  ["designer:yyfy_yuanxingshangren"] = "曹宪咬我",
}

local weiwenzhugezhi = General:new(extension, "yyfy_dream__weiwenzhugezhi", "wu", 4)
weiwenzhugezhi:addSkill("yyfy_fuhai")
Fk:loadTranslationTable {
  ["yyfy_dream"] = "梦",
  ["yyfy_dream__weiwenzhugezhi"] = "梦卫温诸葛直",
  ["#yyfy_dream__weiwenzhugezhi"] = "新航路的开辟",
  ["designer:yyfy_dream__weiwenzhugezhi"] = "水上由岐",
  ["~yyfy_dream__weiwenzhugezhi"] = "吾皆海岱清士，岂料生死易逝。"
}

local guihuangzhong = General:new(extension, "yyfy_guihuangzhong", "evil", 5)
guihuangzhong:addSkill("yyfy_shengong")
Fk:loadTranslationTable {
  ["yyfy_guihuangzhong"] = "鬼黄忠",
  ["#yyfy_guihuangzhong"] = "索命神射",
  ["designer:yyfy_guihuangzhong"] = "大闲者八雲紫",
  ["~yyfy_guihuangzhong"] = ""
}

local yongyimoyi = General:new(extension, "yyfy_yongyimoyi", "wei", 3)
yongyimoyi:addSkills{"yyfy_jiewu"}
Fk:loadTranslationTable {
  ["yyfy_yongyimoyi"] = "用一摸一",
  ["#yyfy_yongyimoyi"] = "原画为族杨修",
  ["designer:yyfy_yongyimoyi"] = "夜隐浮云",
  ["~yyfy_yongyimoyi"] = "空晓事而未见老，枉少作而愧对君……"
}

local ex__yongyimoyi = General:new(extension, "ex__yyfy_yongyimoyi", "wei", 4)
ex__yongyimoyi:addSkills{"yyfy_guopai", "paoxiao"}
Fk:loadTranslationTable {
  ["ex__yyfy_yongyimoyi"] = "界用一摸一",
  ["#ex__yyfy_yongyimoyi"] = "四血过牌多刀",
  ["designer:ex__yyfy_yongyimoyi"] = "夜隐浮云",
  ["~ex__yyfy_yongyimoyi"] = "葬得青山一抔土，销尽宏图万古愁。"
}

local mou__yongyimoyi = General:new(extension, "mou__yyfy_yongyimoyi", "god", 4, 4)
mou__yongyimoyi:addSkills { "yyfy_guopai", "beifen" }
Fk:loadTranslationTable
{
  ["mou__yyfy_yongyimoyi"] = "谋用一摸一",
  ["#mou__yyfy_yongyimoyi"] = "四血过牌悲愤",
  ["designer:mou__yyfy_yongyimoyi"] = "名字加载中……",
  ["~mou__yyfy_yongyimoyi"] = "空晓事而未见老，枉少作而愧对君……",
}

local shi__yongyimoyi = General:new(extension, "lost__yyfy_yongyimoyi", "god", 4, 4)
shi__yongyimoyi:addSkills { "yyfy_mingzhe", "beifen" }
Fk:loadTranslationTable
{
  ["lost"] = "",
  ["lost__yyfy_yongyimoyi"] = "失一摸一",
  ["#lost__yyfy_yongyimoyi"] = "诸葛瑾（",
  ["designer:lost__yyfy_yongyimoyi"] = "名字加载中……",
  ["~lost__yyfy_yongyimoyi"] = "臣一心向吴，忠心青天可鉴。",
}

local zhongyan = General:new(extension, "yyfy_end__zhongyan", "jin", 3, 3, General.Female)
zhongyan:addSkills { "yyfy_guangu",  "yyfy_xiaoyong", "yyfy_bolan", "yyfy_yifa"}
Fk:loadTranslationTable
{
  ["yyfy_end__zhongyan"] = "终钟琰",
  ["#yyfy_end__zhongyan"] = "紫闼飞莺",
  ["designer:yyfy_end__zhongyan"] = "一维无限",
  ["~yyfy_end__zhongyan"] = "此间天下人，皆分一斗之才……",
}

local suode = General:new(extension, "yyfy_suode", "qun", 5)
suode:addSkills { "yyfy_bingfeng", "yyfy_jisu", "yyfy_hanbao" }
Fk:loadTranslationTable
{
  ["yyfy_suode"] = "索德",
  ["#yyfy_suode"] = "寒冰巨兽",
  ["designer:yyfy_suode"] = "名字加载中……"
}

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
    id = "yyfy_exgod_zhangliao",
    name = "界神张辽",
    achievements = {
      {
        id = "yyfy_exgod_zhangliao_1",
        target = 1,
        name = "闻风丧胆",
        desc = "通过〖夺锐〗在一局游戏中获得至少5个技能，并取得胜利。",
        context = "张辽虽病，不可挡也，慎之！ ——孙权"
      },
    },
  },
  {
    id = "yyfy_mou_wupu",
    name = "谋吴普",
    achievements = {
      {
        id = "yyfy_mou_wupu_1",
        target = 1,
        name = "医脉相承",
        desc = "通过〖锻体〗获得技能〖五灵〗。",
        context = "人同于兽，奇经八脉、吐息参合，不宜异同。"
      },
      {
        id = "yyfy_mou_wupu_2",
        target = 100,
        name = "遍尝百草",
        desc = "通过〖识草〗累计获得100张牌。",
        context = "此药名白术，形如栉草，可解热清毒。"
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
        desc = "累计3次，在一次〖落宠〗中发动所有效果的最大次数。",
        context = "宠至莫言非，恩移难恃貌。"
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
        context = "公达前后凡画十二奇策，唯繇知之。繇撰集未就，会薨，故世不得以尽闻也。"
      },
    },
  },
  {
    id = "lan__zhonghui",
    name = "烂钟会",
    achievements = {
      {
        id = "lan__zhonghui_1",
        target = 1,
        name = "今日起兵",
        desc = "在一局游戏中获得3张「权」并取得胜利。",
        context = "时机已到，今日起兵！"
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
        context = "朕为太祖子孙，大魏君王!"
      },
    },
  },
}

if ok and U and type(U.RegisterAchievement) == "function" then
  for _, a in ipairs(achievements_data) do
    local data = a.achievements
    for _, achievement in ipairs(data) do
      local title = achievement.name
      local desc = achievement.desc
      local context = achievement.context or ""
      U.RegisterAchievement("夜隐浮云", title, context, desc, "general:" .. a.id, false, {}, true)
    end
  end
end

return extension
