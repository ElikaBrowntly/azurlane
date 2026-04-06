local extension = Package:new("yyfy_gamemodes", Package.SpecialPack)
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/gamemodes/skills")

local heg_mode = require "packages.hidden-clouds.pkg.gamemodes.new_hegemony_mode"
extension:addGameMode(heg_mode)

Fk:loadTranslationTable{
  ["yyfy_gamemodes"] = "夜隐浮云",
}

return extension