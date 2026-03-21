local longxi = fk.CreateSkill {
  name = "yyfy_longxi",
}

Fk:loadTranslationTable{
  ["yyfy_longxi"] = "龙息",
  [":yyfy_longxi"] = "出牌阶段限一次，你可对一名角色造成一点伤害。"
}

longxi:addEffect("active", {
  anim_type = "offensive",
  max_phase_use_time = 1,
  target_num = 1,
  target_filter = function (self, player, to_select, selected, selected_cards, card, extra_data)
    return to_select and to_select ~= player and #selected == 0
  end,
  card_num = 0,
  prompt = "你可以选择一名角色，对其造成1点伤害",
  on_use = function (self, room, effect)
    room:damage({
      from = effect.from,
      to = effect.tos[1],
      damage = 1,
      skillName = longxi.name
    })
  end
})

longxi:addAI(Fk.Ltk.AI.newActiveStrategy{
  think = function (self, ai)
    local player = ai.player
    local targets = {}
    local lowest = nil
    local line = 99999
    for _, p in ipairs(player.room:getOtherPlayers(player)) do
      if ai:isEnemy(p) then
        table.insert(targets, p)
        if p.hp <= line then
          lowest = p
          line = p.hp
        end
      end
    end
    if #targets == 0 then return {}, 0 end
    if not lowest then return {{}, {targets[1]}, nil}, 6 end
    return {{}, {lowest}, nil}, 6 -- 可以加伤和集火残血，比一滴血的收益要高一些
  end
})

return longxi