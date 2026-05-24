local lead = fk.CreateSkill {
  name = "yyfy_lead",
}

Fk:loadTranslationTable{
  ["yyfy_lead"] = "领导",
  [":yyfy_lead"] = "你参与议事时，可以额外展示一张手牌。一名角色的回合开始时，你可以令所有角色“<a href='yyfy_yishi'>议事</a>”；"..
  "然后你摸X张牌并回复等量体力（X为意见为红色的数量）。若结果为红色，你可令意见为黑色的角色弃置所有牌并失去一点体力。（未实装）",

  ["yyfy_yishi"] = "江山如故扩展包的新机制——议事"
}

local U = require "packages.utility.utility"

return lead