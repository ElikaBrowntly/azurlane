local extension = Package:new("hidden-clouds_skin", Package.SkinPack)
extension.extensionName = "hidden-clouds"

local ok, CS = pcall(require, "packages.abcd-system.csfs")

-- 所有的前缀
local AllPrefixs = { "ex", "hs", "js", "klsp", "mini", "miniex", "mobile", "m_ex", "mou", "ofl", "ol", "ol_js", "ol_ex",
  "olmou", "os", "os_heg", "os_ex", "ty", "ty_ex", "ty_heg", "ty_sp", "sk", "sxfy", "ol_evil", "lan", "dl", "dlmou" }

local zhugeliang = { "zhugeliang" }
for _, prefix in pairs(AllPrefixs) do
  table.insertIfNeed(zhugeliang, prefix .. "__zhugeliang")
end
local simayi = { "simayi" }
for _, prefix in pairs(AllPrefixs) do
  table.insertIfNeed(simayi, prefix .. "__simayi")
end
local luyusheng = { "luyusheng" }
for _, prefix in pairs(AllPrefixs) do
  table.insertIfNeed(luyusheng, prefix .. "__luyusheng")
end
table.insert(luyusheng, "wycf__luyusheng")
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
    skins = { "lan__caoxiancaohua__1.jpg", "lan__caoxiancaohua__2.gif", "lan__caoxiancaohua__3.mp4",
      "lan__caoxiancaohua__4.png", "lan__caoxiancaohua__5.png", "lan__caoxiancaohua__6.png",
      "lan__caoxiancaohua__7.mp4"},
    enabled_generals = { "caoxiancaohua", "lan__caoxiancaohua", "caoxian", "caohua" }
  },
  {
    skins = { "lan__caoxiancaohua__6.png", "lan__caoxiancaohua__7.mp4"},
    enabled_generals = { "caoxiancaohua", "lan__caoxiancaohua", "caoxian", "caohua", "yuantanyuanshang" }
  },
  {
    skins = { "yyfy_Cheshire__1.mp4" },
    enabled_generals = { "yyfy_Cheshire", "Cheshire", "yyfy_mou__feiyi", "hxdoro__catcat&doro",
      "hxqunyou__dogchaijun", "moesp__cheshire" }
  },
  {
    skins = { "yuantanyuanshangyuanxi__chonghuomo.png" },
    enabled_generals = { "yuantanyuanshangyuanxi", "yuantanyuanshang" }
  },
  {
    skins = { "yyfy_Keynes__1.png" },
    enabled_generals = { "yyfy_Keynes" }
  },
  {
    skins = { "zhugeliang__zhugekongming.png", "zhugeliang__El-Melloi.png", "zhugeliang__WaverVelvet.png",
    "zhugeliang__zuizhongzailin.png" },
    enabled_generals = zhugeliang
  },
  {
    skins = { "caoshuang__anyishemi.jpg", "caoshuang__shouzhaozhuanquan.gif" },
    enabled_generals = { "caoshuang", "tymou__caoshuang", "qshm__caoshuang", "yyfy_ex__caoshuang"}
  },
  {
    skins = { "simayi__lainisi1.png", "simayi__lainisi2.png", "simayi__lainisi3.png", "simayi__lainisi4.png"},
    enabled_generals = simayi
  },
  {
    skins = { "yyfy_end__wolongfengchu__1.gif", "yyfy_end__wolongfengchu__2.gif" },
    enabled_generals = {"wolongfengchu", "yyfy_end__wolongfengchu"}
  },
  {
    skins = { "ex__yyfy_yongyimoyi__1.mp4" },
    enabled_generals = {"yyfy_yongyimoyi", "ex__yyfy_yongyimoyi", "olz__yangxiu", "yangxiu"}
  },
  {
    skins = { "lan__xuncai__1.gif" },
    enabled_generals = {"lan__xuncai", "olz__xuncai"}
  },
  {
    skins = { "yyfy_end__zhongyan__1.jpg", "yyfy_end__zhongyan__2.mp4" },
    enabled_generals = {"yyfy_end__zhongyan", "zhongyan", "olz__zhongyan", "1v1_olz__zhongyan"}
  },
  {
    skins = { "lan__luyusheng__1.jpg", "lan__luyusheng__2.jpg", "lan__luyusheng__3.jpg",
    "lan__luyusheng__4.jpg", "lan__luyusheng__5.jpg" },
    enabled_generals = luyusheng
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
  ["yyfy_Cheshire__1"] = "冰雪公主",
  ["yuantanyuanshangyuanxi__chonghuomo"] = "虫惑魔",
  ["yyfy_Keynes__1"] = "青年凯恩斯",
  ["zhugeliang__zhugekongming"] = "诸葛孔明",
  ["zhugeliang__El-Melloi"] = "埃尔梅罗II世",
  ["zhugeliang__WaverVelvet"] = "韦伯·维尔维特",
  ["zhugeliang__zuizhongzailin"] = "最终再临",
  ["caoshuang__anyishemi"] = "安逸奢靡",
  ["caoshuang__shouzhaozhuanquan"] = "受诏专权",
  ["simayi__lainisi1"] = "莱妮丝(一)",
  ["simayi__lainisi2"] = "莱妮丝(二)",
  ["simayi__lainisi3"] = "莱妮丝(三)",
  ["simayi__lainisi4"] = "莱妮丝(终)",
  ["yyfy_end__wolongfengchu__1"] = "赤壁链火",
  ["yyfy_end__wolongfengchu__2"] = "青羽锦绣",
  ["ex__yyfy_yongyimoyi__1"] = "经典形象（动）",
  ["lan__xuncai__1"] = "雅柔映采",
  ["yyfy_end__zhongyan__1"] = "飞鸿惊雪（静）",
  ["yyfy_end__zhongyan__2"] = "飞鸿惊雪（动）",
  ["lan__luyusheng__1"] = "经典形象",
  ["lan__luyusheng__2"] = "粽香芳菲",
  ["lan__luyusheng__3"] = "毓秀钟灵",
  ["lan__luyusheng__4"] = "族陆郁生",
  ["lan__luyusheng__5"] = "黎歌跃竹"
}

return extension