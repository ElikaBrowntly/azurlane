local extension = Package:new("fate")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/fate/skills")

local CuChulainn = General:new(extension, "CuChulainn", "moon", 4, 4, General.Male):addSkills { "fate_bishi", "fate_luen", "fate_siji" }

Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["CuChulainn"] = "库丘林",
  ["#CuChulainn"] = "光之子",
  ["illustrator:CuChulainn"] = "武内崇",
  ["cv:CuChulainn"] = "神奈延年",
  ["designer:CuChulainn"] = "Manic",
  ["~CuChulainn"] = "失算……了……",
  ["!CuChulainn"] = "什么嘛，真是不堪一击。"
}

local ArchetypeEarth = General:new(extension, "ArchetypeEarth", "moon", 4, 4, General.Female):addSkills { "fate_hongzhimoyan", "fate_xingzhituxi", "fate_FunnyVamp", "fate_kongxiangjvxianhua" }

Fk:loadTranslationTable
{
  ["ArchetypeEarth"] = "爱尔奎特",
  ["#ArchetypeEarth"] = "原初之一",
  ["illustrator:ArchetypeEarth"] = "武内崇",
  ["cv:ArchetypeEarth"] = "长谷川育美",
  ["designer:ArchetypeEarth"] = "夜隐浮云，孤星似梦",
  ["!ArchetypeEarth"] = "已经结束了……期待与希望可没那么容易实现哦。",
  ["~ArchetypeEarth"] = "……意料外的情况，格外有趣……",
}

local Tezcatlipoca = General:new(extension, "Tezcatlipoca", "moon", 4, 4, General.Male):addSkills { "fate_douzhengdemeili", "fate_heizhitaiyang", "fate_shanzhixinzang", "fate_diyitaiyang", "fate_zhanshizhisi" }

Fk:loadTranslationTable
{
  ["Tezcatlipoca"] = "烟雾镜",
  ["#Tezcatlipoca"] = "特斯卡特利波卡",
  ["illustrator:Tezcatlipoca"] = "田岛昭宇",
  ["cv:Tezcatlipoca"] = "三上哲",
  ["designer:Tezcatlipoca"] = "夜隐浮云，孤星似梦",
  ["!Tezcatlipoca"] = "结束了。战士之灵我会欢迎。除此以外的还是重新来过吧。",
  ["~Tezcatlipoca"] = "很快就会回来。我是不灭的。",
}


return extension