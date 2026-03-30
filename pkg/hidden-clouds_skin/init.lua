local extension = Package:new("hidden-clouds_skin", Package.SkinPack)
extension.extensionName = "hidden-clouds"

local ok, CS = pcall(require, "packages.abcd-system.csfs")

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
  {
    skins = { "lan__caomao__1.gif" },
    enabled_generals = { "lan__caomao", "caomao", "mobile__caomao"}
  },
  {
    skins = { "quyi__bahua.jpg", "quyi__congyu1.jpg", "quyi__congyu2.jpg" },
    enabled_generals = { "quyi" }
  },
  {
    skins = { "lan__caoxiancaohua__1.jpg", "lan__caoxiancaohua__2.gif", "lan__caoxiancaohua__3.gif",
      "lan__caoxiancaohua__4.png", "lan__caoxiancaohua__5.png", "lan__caoxiancaohua__6.png",
      "lan__caoxiancaohua__7.gif"},
    enabled_generals = { "caoxiancaohua", "lan__caoxiancaohua", "caoxian", "caohua" }
  },
  {
    skins = { "yyfy_Cheshire__1.gif" },
    enabled_generals = { "yyfy_Cheshire", "Cheshire", "yyfy_mou__feiyi", "hxdoro__catcat&doro",
      "hxqunyou__dogchaijun", "moesp__cheshire" }
  }
}

extension:addSkinPackage {
  path = "/image/skins",
  content = content
}

if ok and CS then
  CS.addSkin({
    path = "packages/hidden-clouds/image/skins/yyfy_ex__nanhualaoxian__1.gif",
    quality = "legend",
    general = "nanhualaoxian",
    price = 888888,
  })
end

Fk:loadTranslationTable {
  ["hidden-clouds_skin"] = "夜隐浮云",
  ["yyfy_Tezcatlipoca__1"] = "第二再临",
  ["yyfy_Tezcatlipoca__2"] = "第三再临",
  ["yyfy_Tezcatlipoca__3"] = "最终再临",
  ["yyfy_ArchetypeEarth__1"] = "第二再临",
  ["yyfy_ArchetypeEarth__2"] = "第三再临",
  ["yyfy_ArchetypeEarth__3"] = "最终再临",
  ["lan__caomao__1"] = "决进形态",
  ["yyfy_ex__nanhualaoxian__1"] = "着墨山河",
  ["quyi__bahua"] = "御津井芭华",
  ["quyi__congyu1"] = "丛雨（其一）",
  ["quyi__congyu2"] = "丛雨（其二）",
  ["lan__caoxiancaohua__1"] = "曹宪 & 曹华",
  ["lan__caoxiancaohua__2"] = "锦瑟良缘·一",
  ["lan__caoxiancaohua__3"] = "锦瑟良缘·二",
  ["lan__caoxiancaohua__4"] = "真·曹宪曹华",
  ["lan__caoxiancaohua__5"] = "贴贴❤️",
  ["lan__caoxiancaohua__6"] = "响 & 千键",
  ["lan__caoxiancaohua__7"] = "豆包生成动态",
  ["yyfy_Cheshire__1"] = "冰雪公主"
}

return extension