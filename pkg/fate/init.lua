local extension = Package:new("fate")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/fate/skills")

local CuChulainn = General:new(extension, "yyfy_CuChulainn", "moon", 4, 4, General.Male)
CuChulainn:addSkills { "fate_bishi", "fate_luen", "fate_siji" }

Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["moon"] = "月",
  ["yyfy_CuChulainn"] = "库丘林",
  ["#yyfy_CuChulainn"] = "光之子",
  ["illustrator:yyfy_CuChulainn"] = "武内崇",
  ["cv:yyfy_CuChulainn"] = "神奈延年",
  ["designer:yyfy_CuChulainn"] = "Manic",
  ["~yyfy_CuChulainn"] = "失算……了……",
  ["!yyfy_CuChulainn"] = "什么嘛，真是不堪一击。"
}

local ArchetypeEarth = General:new(extension, "yyfy_ArchetypeEarth", "moon", 4, 4, General.Female)
ArchetypeEarth:addSkills { "fate_hongzhimoyan", "fate_xingzhituxi", "fate_FunnyVamp", "fate_kongxiangjvxianhua" }

Fk:loadTranslationTable
{
  ["yyfy_ArchetypeEarth"] = "爱尔奎特",
  ["#yyfy_ArchetypeEarth"] = "原初之一",
  ["illustrator:yyfy_ArchetypeEarth"] = "武内崇",
  ["cv:yyfy_ArchetypeEarth"] = "长谷川育美",
  ["designer:yyfy_ArchetypeEarth"] = "夜隐浮云，孤星似梦",
  ["!yyfy_ArchetypeEarth"] = "已经结束了……期待与希望可没那么容易实现哦。",
  ["~yyfy_ArchetypeEarth"] = "……意料外的情况，格外有趣……",
}

local Tezcatlipoca = General:new(extension, "yyfy_Tezcatlipoca", "moon", 4, 4, General.Male)
Tezcatlipoca:addSkills { "fate_douzhengdemeili", "fate_heizhitaiyang", "fate_shanzhixinzang", "fate_diyitaiyang", "fate_zhanshizhisi" }

Fk:loadTranslationTable
{
  ["yyfy_Tezcatlipoca"] = "烟雾镜",
  ["#yyfy_Tezcatlipoca"] = "特斯卡特利波卡",
  ["illustrator:yyfy_Tezcatlipoca"] = "田岛昭宇",
  ["cv:yyfy_Tezcatlipoca"] = "三上哲",
  ["designer:yyfy_Tezcatlipoca"] = "夜隐浮云，孤星似梦",
  ["!yyfy_Tezcatlipoca"] = "结束了。战士之灵我会欢迎。除此以外的还是重新来过吧。",
  ["~yyfy_Tezcatlipoca"] = "很快就会回来。我是不灭的。",
}

return extension