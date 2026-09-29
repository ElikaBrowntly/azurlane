local extension = Package:new("yyfy_gamemodes", Package.SpecialPack)
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/gamemodes/rule_skills")

-- 麻将模式占位牌包（具体牌面由作者后续补充）
local tiles = require "packages.hidden-clouds.pkg.gamemodes.yyfy_mahjong_tiles"
tiles:install(Fk)

local heg_mode = require "packages.hidden-clouds.pkg.gamemodes.new_hegemony_mode"
extension:addGameMode(heg_mode)

local yyfy_mahjong_mode = require "packages.hidden-clouds.pkg.gamemodes.yyfy_mahjong_mode"
extension:addGameMode(yyfy_mahjong_mode)

Fk:loadTranslationTable{
  ["yyfy_gamemodes"] = "夜隐浮云",
}

return extension
