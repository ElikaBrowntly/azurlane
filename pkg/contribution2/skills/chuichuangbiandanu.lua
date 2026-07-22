local chuichuangbiandanu = fk.CreateSkill {
  name = "yyfy_chuichuangbiandanu",
}

Fk:loadTranslationTable{
  ["yyfy_chuichuangbiandanu"] = "槌床便大怒",
  [":yyfy_chuichuangbiandanu"] = "出牌阶段限一次，你可以对所有其他角色各造成1点伤害，然后这些角色弃置所有牌，你翻面。",

  ["#yyfy_chuichuangbiandanu"] = "槌床便大怒：对所有其他角色造成伤害并弃牌！",

  ["$yyfy_chuichuangbiandanu"] = "神挡杀神，佛挡杀佛！",
  ["$yyfy_chuichuangbiandanu1"] = "阿母得闻之，槌床便大怒。",
  ["$yyfy_chuichuangbiandanu2"] = "阿母谓府吏，何乃太区区！",
}

chuichuangbiandanu:addEffect("active", {
  anim_type = "big",
  prompt = "#yyfy_chuichuangbiandanu",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(chuichuangbiandanu.name, Player.HistoryPhase) == 0 and #Fk:currentRoom().alive_players > 1
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local tos = room:getOtherPlayers(player)
    room:doIndicate(player, tos)
    for _, p in ipairs(tos) do
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = chuichuangbiandanu.name,
        }
      end
    end
    for _, p in ipairs(tos) do
      if not p.dead then
        p:throwAllCards("he")
      end
    end
    if not player.dead then
      player:turnOver()
    end
  end
})

return chuichuangbiandanu