local lieshi = fk.CreateSkill {
  name = "lan__lieshi",
}

Fk:loadTranslationTable {
  ["lan__lieshi"] = "烈誓",
  [":lan__lieshi"] = "出牌阶段，你可以分别选择一项：1.废除判定区；2.受到你的1点火焰伤害；3.弃置" ..
      "<font color='red'>一张</font>/<font color='blue'>所有</font>【闪】；4.弃置<font color='red'>一张" ..
      "</font>/<font color='blue'>所有</font>【杀】，令<font color='red'>你</font>/<font color='blue'>" ..
      "一名其他角色</font>执行。",

  ["#lan__lieshi"] = "烈誓：执行一项效果，然后选择一项效果令一名角色执行",
  ["#lan__lieshi-choose"] = "烈誓：选择一名角色，令其执行你选择的一条效果",
  ["#lan__lieshi-choice"] = "烈誓：令其废除判定区或受到你的1点火焰伤害，或弃置手牌中所有【杀】或【闪】",
  ["lan__lieshi_abolish"] = "废除判定区",
  ["lan__lieshi_damage"] = "受到1点火焰伤害",
  ["lan__lieshi_slash"] = "弃置所有【杀】",
  ["lan__lieshi_jink"] = "弃置所有【闪】",
  ["lan__lieshi_slash1"] = "弃置一张【杀】",
  ["lan__lieshi_jink1"] = "弃置一张【闪】",

  ["$lan__lieshi1"] = "拭刃为誓，女无二夫。",
  ["$lan__lieshi2"] = "霜刃证言，宁死不贰。",
}

lieshi:addEffect("active", {
  anim_type = "offensive",
  prompt = "#lan__lieshi",
  interaction = function(self, player)
    local choices = { "lan__lieshi_damage" }
    if not table.contains(player.sealedSlots, Player.JudgeSlot) then
      table.insert(choices, "lan__lieshi_abolish")
    end
    if table.find(player:getCardIds("h"), function(id)
          return Fk:getCardById(id).trueName == "slash" and not player:prohibitDiscard(id)
        end) then
      table.insert(choices, "lan__lieshi_slash1")
    end
    if table.find(player:getCardIds("h"), function(id)
          return Fk:getCardById(id).trueName == "jink" and not player:prohibitDiscard(id)
        end) then
      table.insert(choices, "lan__lieshi_jink1")
    end
    return UI.ComboBox {
      choices = choices,
      all_choices = { "lan__lieshi_abolish", "lan__lieshi_damage", "lan__lieshi_slash1", "lan__lieshi_jink1" }
    }
  end,
  card_num = 0,
  target_num = 0,
  can_use = Util.TrueFunc,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local choice = self.interaction.data
    local to = player
    for i = 1, 2, 1 do
      if i == 2 then
        if player.dead then return end
        to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = room.alive_players,
          skill_name = lieshi.name,
          prompt = "#lan__lieshi-choose",
          cancelable = false,
        })[1]
        local choices, all_choices = { "lan__lieshi_damage" },
            { "lan__lieshi_abolish", "lan__lieshi_damage", "lan__lieshi_slash", "lan__lieshi_jink" }
        if not table.contains(to.sealedSlots, Player.JudgeSlot) then
          table.insert(choices, "lan__lieshi_abolish")
        end
        if table.find(to:getCardIds("h"), function(id)
              return Fk:getCardById(id).trueName == "slash" and not to:prohibitDiscard(id)
            end) then
          table.insert(choices, "lan__lieshi_slash")
        end
        if table.find(to:getCardIds("h"), function(id)
              return Fk:getCardById(id).trueName == "jink" and not to:prohibitDiscard(id)
            end) then
          table.insert(choices, "lan__lieshi_jink")
        end
        if #choices == 0 then return end
        choice = room:askToChoice(player, {
          choices = choices,
          skill_name = lieshi.name,
          prompt = "#lan__lieshi-choice:" .. player.id,
          all_choices = all_choices,
        })
      end
      if choice == "lan__lieshi_abolish" then
        room:abortPlayerArea(to, Player.JudgeSlot)
      elseif choice == "lan__lieshi_damage" then
        if not to.dead then
          room:damage {
            from = player,
            to = to,
            damage = 1,
            damageType = fk.FireDamage,
            skillName = lieshi.name,
          }
        end
      elseif choice == "lan__lieshi_slash" then
        local cards = table.filter(to:getCardIds("h"), function(id)
          return Fk:getCardById(id).trueName == "slash" and not to:prohibitDiscard(id)
        end)
        if #cards > 0 then
          room:throwCard(cards, lieshi.name, to, to)
        end
      elseif choice == "lan__lieshi_jink" then
        local cards = table.filter(to:getCardIds("h"), function(id)
          return Fk:getCardById(id).trueName == "jink" and not to:prohibitDiscard(id)
        end)
        if #cards > 0 then
          room:throwCard(cards, lieshi.name, to, to)
        end
      elseif choice == "lan__lieshi_slash1" then
        room:askToDiscard(player, {
          min_num = 1,
          max_num = 1,
          skill_name = lieshi.name,
          pattern = "slash|.|.|hand"
        })
      elseif choice == "lan__lieshi_jink1" then
        room:askToDiscard(player, {
          min_num = 1,
          max_num = 1,
          skill_name = lieshi.name,
          pattern = "jink|.|.|hand"
        })
      end
    end
  end,
})

return lieshi