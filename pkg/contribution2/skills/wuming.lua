local wuming = fk.CreateSkill {
  name = "yyfy_wuming",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable{
  ["yyfy_wuming"] = "无名",
  [":yyfy_wuming"] = "持恒技，每名角色的回合开始时，你从随机5个武将中选择至多2个技能获得，或直接获得〖隅泣〗和〖善身〗。",

  ["#yyfy_wuming-choose"] = "无名：请选择两个技能出战（不选会直接获得隅泣和善身）",
  ["@yyfy_wuming_skills"] = "",

  ["$yyfy_wuming1"] = "这么漂亮的雪花，为什么只能在寒冬呢？",
  ["$yyfy_wuming2"] = "得父母之爱，享公主之礼遇。",
  ["$yyfy_wuming3"] = "哼，可不要小瞧女孩子呀。"
}

local U = require "packages.utility.utility"

wuming:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local generals = Fk:getGeneralsRandomly(5, nil, { "yyfy_guanyucaojinyu" })
    local skills = {}
    for _, g in ipairs(generals) do
      table.insert(skills, g:getSkillNameList())
  end
    skills = U.askToChooseGeneralSkills(player, {
      skill_name = wuming.name,
      prompt = "#yyfy_wuming-choose",
      min_num = 0, max_num = 2,
      skills = skills,
      generals = table.map(generals, Util.NameMapper),
      cancelable = true,
    })
    if #skills > 0 then
      local realNames = table.map(skills, Util.TranslateMapper)
      room:setPlayerMark(player, "@yyfy_wuming_skills", "<font color='burlywood'>" .. table.concat(realNames, " ") .. "</font>")
      room:handleAddLoseSkills(player, table.concat(skills, "|"))
      return
    end
    room:handleAddLoseSkills(player, {"lan__yuqi", "lan__shanshen"})
  end,
})

return wuming