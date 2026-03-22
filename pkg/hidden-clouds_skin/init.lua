local extension = Package:new("hidden-clouds_skin", Package.SkinPack)
extension.extensionName = "hidden-clouds"

--- 武将皮肤集合
--- skins SkinFile[] 皮肤文件列表
--- enabled_generals GeneralID[] 启用此皮肤的武将ID列表

---@type SkinPackageContent[]
local content = {
  {
    skins = { "yyfy_Tezcatlipoca__1.jpg", "yyfy_Tezcatlipoca__2.jpg", "yyfy_Tezcatlipoca__3.jpg" },
    enabled_generals = { "yyfy_Tezcatlipoca" }
  },
  {
    skins = { "yyfy_ArchetypeEarth__1.jpg", "yyfy_ArchetypeEarth__2.jpg", "yyfy_ArchetypeEarth__3.jpg" },
    enabled_generals = { "yyfy_ArchetypeEarth" }
  },
}

extension:addSkinPackage {
  path = "/image/skins",
  content = content
}

Fk:loadTranslationTable {
  ["hidden-clouds_skin"]="夜隐浮云",
  ["yyfy_Tezcatlipoca__1"] = "第二再临",
  ["yyfy_Tezcatlipoca__2"] = "第三再临",
  ["yyfy_Tezcatlipoca__3"] = "最终再临",
  ["yyfy_ArchetypeEarth__1"] = "第二再临",
  ["yyfy_ArchetypeEarth__2"] = "第三再临",
  ["yyfy_ArchetypeEarth__3"] = "最终再临",
}

return extension