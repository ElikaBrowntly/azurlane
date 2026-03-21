local contribution = require "packages.hidden-clouds.pkg.contribution"
local fate = require "packages.hidden-clouds.pkg.fate"
local RoyalNavy = require "packages.hidden-clouds.pkg.RoyalNavy"
local SakuraEmpire = require "packages.hidden-clouds.pkg.SakuraEmpire"
local EagleUnion = require "packages.hidden-clouds.pkg.EagleUnion"
local yyfy_token = require "packages.hidden-clouds.pkg.yyfy_token"
local yugioh = require "packages.hidden-clouds.pkg.yugioh"
local skin = require "packages.hidden-clouds.pkg.hidden-clouds_skin"

Fk:appendKingdomMap("god", { "moon" })

return {
  contribution,
  fate,
  yugioh,
  RoyalNavy,
  SakuraEmpire,
  EagleUnion,
  yyfy_token,
  skin
}