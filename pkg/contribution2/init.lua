local ok, U = pcall(require, "packages.glory_days.utility")

local extension = Package:new("contribution2")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/contribution2/skills")

local Robbins = General:new(extension, "yyfy__Robbins", "west", 3)
Robbins:addSkills { "yyfy_plan", "yyfy_organize", "yyfy_lead", "yyfy_motivate", "yyfy_control", "yyfy_coordinate" }
Fk:loadTranslationTable
{
  ["yyfy"] = "",
  ["contribution2"] = "投稿 2",
  ["yyfy__Robbins"] = "罗宾斯",
  ["#yyfy__Robbins"] = "管理学大师",
  ["designer:yyfy__Robbins"] = "夜隐浮云"
}

local liubei = General:new(extension, "yyfy_mou__liubei", "shu", 4)
liubei:addSkills { "yyfy_rende", "yyfy_zhangwu" }
Fk:loadTranslationTable
{
  ["yyfy_mou"] = "谋？",
  ["yyfy_mou__liubei"] = "谋刘备",
  ["#yyfy_mou__liubei"] = "章武大帝",
  ["designer:yyfy_mou__liubei"] = "青菜白玉汤",
  ["~yyfy_mou__liubei"] = "汉室之兴，皆仰望丞相了……",
}

local zhanghua = General:new(extension, "yyfy_ex__zhanghua", "jin", 3)
zhanghua:addSkills { "yyfy_bihun", "yyfy_jianhe", "yyfy_chuanwu", "yyfy_nanxiang" }
Fk:loadTranslationTable
{
  ["yyfy_ex__zhanghua"] = "界张华",
  ["#yyfy_ex__zhanghua"] = "双剑化龙",
  ["designer:yyfy_ex__zhanghua"] = "幻矩",
  ["~yyfy_ex__zhanghua"] = "式乾之议，臣谏事具存，非不谏也……",
}

local zhouyu = General:new(extension, "yyfy_zhouyu", "wu", 4)
zhouyu:addSkills { "yyfy_huanli", "yyfy_difu" }
Fk:loadTranslationTable
{
  ["yyfy_zhouyu"] = "周瑜",
  ["#yyfy_zhouyu"] = "缚耳利群",
  ["designer:yyfy_zhouyu"] = "名字加载中……",
  ["~yyfy_zhouyu"] = "既生瑜，何生亮；既生瑜，何生亮！",
}

local guanyucaojinyu = General:new(extension, "yyfy_guanyucaojinyu", "shu", 4, 4, General.Bigender)
guanyucaojinyu.subkingdom = "wei"
guanyucaojinyu:addSkills { "yyfy_weizhen", "yyfy_wuming" }
guanyucaojinyu:addRelatedSkills{"lan__yuqi", "lan__shanshen"}
Fk:loadTranslationTable
{
  ["yyfy_guanyucaojinyu"] = "关羽&曹金玉",
  ["#yyfy_guanyucaojinyu"] = "威,红,历,牌",
  ["designer:yyfy_guanyucaojinyu"] = "夜隐浮云",
  ["~yyfy_guanyucaojinyu"] = "玉碎不改白，竹焚不毁节。/娘亲，雪人不怕冷吗？",
}

local luyusheng = General:new(extension, "yyfy_mou__luyusheng", "wu", 3, 3, General.Female)
luyusheng:addSkills { "yyfy_shixi", "jianbai", "zelie" }
Fk:loadTranslationTable
{
  ["yyfy_mou__luyusheng"] = "族陆郁生",
  ["#yyfy_mou__luyusheng"] = "精心坚白",
  ["designer:yyfy_mou__luyusheng"] = "幻矩",
  ["~yyfy_mou__luyusheng"] = "拉钩拉钩，明天见~",
  ["$zelie_yyfy_mou__luyusheng1"] = "不许哭，要做个大人。",
  ["$zelie_yyfy_mou__luyusheng2"] = "孔融让梨，是因为不爱吃梨子吗？"
}

local lvmeng = General:new(extension, "yyfy_mou__lvmeng", "wu", 4)
lvmeng:addSkills { "yyfy_hengye", "yyfy_yingbo" }
Fk:loadTranslationTable
{
  ["yyfy_mou__lvmeng"] = "谋吕蒙",
  ["#yyfy_mou__lvmeng"] = "",
  ["designer:yyfy_mou__lvmeng"] = "名字加载中……",
  ["~yyfy_mou__lvmeng"] = "愎而不备，岂罪于我？",
}

local longzhousanfei = General:new(extension, "yyfy_longzhousanfei", "wei", 4)
longzhousanfei.subkingdom = "wu"
longzhousanfei:addSkills { "xingzhao", "dianhu", "jianji", "lianpian" }
longzhousanfei:addRelatedSkill("xunxun")
Fk:loadTranslationTable
{
  ["yyfy_longzhousanfei"] = "龙舟三废",
  ["#yyfy_longzhousanfei"] = "龙舟三废",
  ["designer:yyfy_longzhousanfei"] = "夜隐浮云",
  ["~yyfy_longzhousanfei"] = "偷工减料要不得啊……/魏王厚待于我，降魏又有何错？/恐不能再与兴霸兄……并肩奋战了……",
}

local qinluofu = General:new(extension, "yyfy_qinluofu", "han", 3)
qinluofu:addSkills { "yyfy_moshangsang", "yyfy_guose", "jilve__tianxiang", "yyfy_biyue", "yyfy_xiuhua", "jilve__chenyu", "jilve__luoyan" }
Fk:loadTranslationTable
{
  ["yyfy_qinluofu"] = "秦罗敷",
  ["#yyfy_qinluofu"] = "秦氏有好女",
  ["designer:yyfy_qinluofu"] = "夜隐浮云",
  ["~yyfy_qinluofu"] = "同心而离居，忧伤以终老。"
}

local jiaozhongqing = General:new(extension, "yyfy_jiaozhongqing", "han", 3)
jiaozhongqing:addSkills { "yyfy_tangshangqiamu", "yyfy_ziguadongnanzhi" }
Fk:loadTranslationTable
{
  ["yyfy_jiaozhongqing"] = "焦仲卿",
  ["#yyfy_jiaozhongqing"] = "孔雀东南飞",
  ["designer:yyfy_jiaozhongqing"] = "夜隐浮云"
}

local zhongqingmu = General:new(extension, "yyfy_zhongqingmu", "han", 3, 3, General.Female)
zhongqingmu:addSkills { "yyfy_chuichuangbiandanu", "yyfy_amuweiruqiu" }
zhongqingmu:addRelatedSkills{ "meiyan", "shuoyu", "zuobao" }
Fk:loadTranslationTable
{
  ["yyfy_zhongqingmu"] = "仲卿母",
  ["#yyfy_zhongqingmu"] = "封建家长典范",
  ["designer:yyfy_zhongqingmu"] = "夜隐浮云"
}

local weiyan = General:new(extension, "yyfy_shiqiang__weiyan", "shu", 4)
weiyan:addSkills { "zhuangshi", "yinzhan", "zhongao", "m_shiqiang" }
Fk:loadTranslationTable
{
  ["yyfy_shiqiang"] = "",
  ["yyfy_shiqiang__weiyan"] = "恃强魏延",
  ["#yyfy_shiqiang__weiyan"] = "矜忠跨万山",
  ["designer:yyfy_shiqiang__weiyan"] = "名字加载中……",

  ["~yyfy_shiqiang__weiyan"] = "志为大汉献身，纵死又有何恨？",
  ["!yyfy_shiqiang__weiyan"] = "延一腔赤血，终不负主公之恩。",
}

local Mako = General:new(extension, "yyfy_HitachiMako", "moe", 4, 4, General.Female)
Mako:addSkills { "yyfy_ciallo", "yyfy_renfa", "jiange__weizhu" }
Fk:loadTranslationTable
{
  ["yyfy_HitachiMako"] = "常陆茉子",
  ["#yyfy_HitachiMako"] = "调皮的忍者",
  ["designer:yyfy_HitachiMako"] = "夜隐浮云"
}

local Aya = General:new(extension, "yyfy_Aya", "moe", 3, 3, General.Female)
Aya:addSkills { "yyfy_bingruo", "yyfy_jipin" }
Fk:loadTranslationTable
{
  ["yyfy_Aya"] = "绫",
  ["#yyfy_Aya"] = "500年前的女孩",
  ["designer:yyfy_Aya"] = "夜隐浮云"
}

local Murasame = General:new(extension, "yyfy_Murasame", "moe", 3, 3, General.Female)
Murasame:addSkills { "yyfy_ciallo", "yyfy_shendao" }
Murasame.hidden = true
Fk:loadTranslationTable
{
  ["yyfy_Murasame"] = "丛雨",
  ["#yyfy_Murasame"] = "神刀的管理者",
  ["designer:yyfy_Murasame"] = "夜隐浮云"
}

local caiwenji = General:new(extension, "yyfy_mu__caiwenji", "qun", 3, 3, General.Female)
caiwenji:addSkills { "yyfy_shuangjia" }
Fk:loadTranslationTable
{
  ["yyfy_mu"] = "",
  ["yyfy_mu__caiwenji"] = "界乐蔡文姬",
  ["#yyfy_mu__caiwenji"] = "胡笳十八拍",
  ["designer:yyfy_mu__caiwenji"] = "名字加载中……"
}

return extension