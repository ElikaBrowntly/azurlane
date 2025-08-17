local quanji = fk.CreateSkill {
  name = "lan__quanji",
  derived_piles = "lan__zhonghui_quan",
}

Fk:loadTranslationTable{
  ["lan__quanji"] = "权计",
  [":lan__quanji"] = "出牌阶段结束时，或当你受到1点伤害后，你可以加一点手牌上限，摸一张牌，"..
    "然后将一张牌置于武将牌上，称为「权」。",
  ["lan__zhonghui_quan"] = "权",
  ["#lan__quanji-push"] = "权计：选择1张牌作为「权」置于武将牌上",
  ["$lan__quanji1"] = "备兵驯马，以待战机",
  ["$lan__quanji2"] = "避其锋芒，权且忍让",
  ["$lan__quanji3"] = "缓急不在一时，吾等慢慢来过",
  ["$lan__quanji4"] = "善算轻重，权审其宜",
}

quanji:addEffect(fk.EventPhaseEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and
      player:hasSkill(quanji.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "quanji_max_addition", 1)
    player:drawCards(1, quanji.name)
    if not (player.dead or player:isKongcheng()) then
      local card = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = quanji.name,
        cancelable = false,
        prompt = "#lan__quanji-push",
      })
      player:addToPile("lan__zhonghui_quan", card, true, quanji.name)
    end
  end
})

quanji:addEffect(fk.Damaged, {
  anim_type = "masochism",
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "quanji_max_addition", 1)
    player:drawCards(1, quanji.name)
    if not (player.dead or player:isKongcheng()) then
      local card = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = quanji.name,
        cancelable = false,
        prompt = "#lan__quanji-push",
      })
      player:addToPile("lan__zhonghui_quan", card, true, quanji.name)
    end
  end,
})

quanji:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(quanji.name) then
      return player:getMark("quanji_max_addition")
    else
      return 0
    end
  end,
})

return quanji