local skill = fk.CreateSkill({
  name = "yyfy_0",
  attached_skill_name = "yyfy_0_active&",
})

Fk:loadTranslationTable {
  ["yyfy_0"] = "0",
  [":yyfy_0"] = "你的回合内，其他角色可以将一张牌当【无懈可击】使用。",
}

skill:addAcquireEffect(function(self, player)
  local room = player.room
  for _, p in ipairs(room:getOtherPlayers(player)) do
    room:handleAddLoseSkills(p, "yyfy_0_active&", nil, false, true)
  end
end)

return skill