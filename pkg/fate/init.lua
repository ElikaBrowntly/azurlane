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
}

return extension