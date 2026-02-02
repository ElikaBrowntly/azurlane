local jiangchi_active = fk.CreateSkill {
  name = "lan__jiangchi_active",
}

Fk:loadTranslationTable{
  ["lan__jiangchi_active"] = "将驰",
  ["lan__jiangchi_draw2"] = "摸两张牌，出【杀】次数-1",
  ["lan__jiangchi_discard"] = "重铸一张牌，【杀】无距离限制且次数+1",
}

jiangchi_active:addEffect("active", {
  interaction = function(self, player)
    local choices = {"lan__jiangchi_draw2", "draw1"}
    if not player:isNude() then
      table.insert(choices, "lan__jiangchi_discard")
    end
    return UI.ComboBox {
      choices = choices,
      all_choices = {"lan__jiangchi_draw2", "draw1", "lan__jiangchi_discard"},
    }
  end,
  target_num = 0,
  card_filter = function(self, player, to_select, selected)
    if self.interaction.data ==  "lan__jiangchi_discard" then
      return #selected == 0 and not player:prohibitDiscard(to_select)
    else
      return false
    end
  end,
  feasible = function(self, player, selected, selected_cards)
    if #selected == 0 then
      if self.interaction.data == "lan__jiangchi_discard" then
        return #selected_cards == 1
      else
        return #selected_cards == 0
      end
    end
  end,
})

return jiangchi_active