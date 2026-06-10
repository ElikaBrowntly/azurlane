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
  ["~yyfy_zhouyu"] = " ",
}

local guanyucaojinyu = General:new(extension, "yyfy_guanyucaojinyu", "shu", 4, 4, General.Bigender)
guanyucaojinyu.subkingdom = "wei"
guanyucaojinyu:addSkills { "yyfy_weizhen", "yyfy_wuming" }
guanyucaojinyu:addRelatedSkills{"lan__yuqi", "lan__shanshen"}
Fk:loadTranslationTable
{
  ["yyfy_guanyucaojinyu"] = "关羽&曹金玉",
  ["#yyfy_guanyucaojinyu"] = "无名小卒亦可威震天下",
  ["designer:yyfy_guanyucaojinyu"] = "夜隐浮云",
  ["~yyfy_guanyucaojinyu"] = "玉碎不改白，竹焚不毁节。/娘亲，雪人不怕冷吗？",
}

return extension