local contribution = require "packages.hidden-clouds.pkg.contribution"
local contribution2 = require "packages.hidden-clouds.pkg.contribution2"
local lan = require "packages.hidden-clouds.pkg.lanwanle"
local fate = require "packages.hidden-clouds.pkg.fate"
local RoyalNavy = require "packages.hidden-clouds.pkg.RoyalNavy"
local SakuraEmpire = require "packages.hidden-clouds.pkg.SakuraEmpire"
local EagleUnion = require "packages.hidden-clouds.pkg.EagleUnion"
local yyfy_token = require "packages.hidden-clouds.pkg.yyfy_token"
local yugioh = require "packages.hidden-clouds.pkg.yugioh"
local skin = require "packages.hidden-clouds.pkg.hidden-clouds_skin"
local modes = require "packages.hidden-clouds.pkg.gamemodes"

Fk:appendKingdomMap("god", { "yyfy_moon", "yyfy_Saber", "yyfy_Archer", "yyfy_Lancer", "yyfy_Rider", "yyfy_Caster", "yyfy_Assassin", "yyfy_Berserker", "yyfy_Foreigner", "yyfy_MoonCancer" })
Fk:appendKingdomMap("evil", { "yyfy_moon", "yyfy_Saber", "yyfy_Archer", "yyfy_Lancer", "yyfy_Rider", "yyfy_Caster", "yyfy_Assassin", "yyfy_Berserker", "yyfy_Foreigner", "yyfy_MoonCancer"})

return {
  contribution,
  contribution2,
  lan,
  fate,
  yugioh,
  RoyalNavy,
  SakuraEmpire,
  EagleUnion,
  yyfy_token,
  skin,
  modes
}