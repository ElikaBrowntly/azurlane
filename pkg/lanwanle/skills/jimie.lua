local jimie = fk.CreateSkill {
  name = "lan__jimie"
}

Fk:loadTranslationTable{
  ["lan__jimie"] = "寂灭",
  [":lan__jimie"] = "出牌阶段，你可以移去8个“霆”，对一名角色造成等于其体力上限的伤害。",

  ["#lan__jimie-choose"] = "寂灭：移去8个“霆”，对一名角色造成其体力上限的伤害！",

  ["$lan__jimie1"] = "此世终末之时，我将再度照临！",
  ["$lan__jimie2"] = "我乃万法之法，戮神之神！",
  ["$lan__jimie3"] = "万物重归于寂，天地唯领我名！",
  ["$lan__jimie4"] = "赐万物寂然，赐万界终灭！",
}

jimie:addEffect("active", {
  anim_type = "offensive",
  prompt = "#lan__jimie-choose",
  can_use = function (self, player)
    return player and player:getMark("@lan__machao_thunder") > 7
  end,
  target_num = 1,
  card_num = 0,
  target_filter = function (self, player, to_select, selected, selected_cards, card, extra_data)
    return #selected == 0 and to_select:isAlive()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    room:removePlayerMark(player, "@lan__machao_thunder", 8)
    room:damage{
      from = player,
      to = to,
      damage = to.maxHp,
      skillName = jimie.name,
    }
  end,
})

return jimie