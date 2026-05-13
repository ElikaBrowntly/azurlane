local skill = fk.CreateSkill {
  name = "yyfy_muban",
}

Fk:loadTranslationTable {
  ["yyfy_muban"] = "模板",
  [":yyfy_muban"] = "游戏开始时，你可以选择是否加一点体力上限并回复一点体力、是否获得〖咆哮〗。",

  ["$yyfy_muban1"] = "当以武装换红妆，纵横天地间！",
  ["$yyfy_muban2"] = "天道昭昭，再兴如光武亦可期。"
}

skill:addEffect(fk.GameStart, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_cost = function (self, event, target, player, data)
    local choices = player.room:askToChoices(player, {
      choices = {"加一点体力上限并回复一点体力", "获得标〖咆哮〗"},
      cancelable = true,
      min_num = 0,
      max_num = 2,
      prompt = "模板：你可以选择任意项"
    })
    if #choices == 0 then return false end
    event:setCostData(self, {choices = choices})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = (event:getCostData(self) or {}).choices
    if not choices or #choices == 0 then return end
    if table.contains(choices, "加一点体力上限并回复一点体力") then
      room:changeMaxHp(player, 1)
      room:recover({
        who = player,
        num = 1,
        skillName = skill.name,
        recoverBy = player
      })
    end
    if table.contains(choices, "获得标〖咆哮〗") then
      room:handleAddLoseSkills(player, "paoxiao", skill.name)
    end
  end,
})

return skill