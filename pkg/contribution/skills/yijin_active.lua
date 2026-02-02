local yijinActive = fk.CreateSkill {
  name = "lan__yijin_active",
}

Fk:loadTranslationTable{
  ["lan__yijin_active"] = "亿金",
}

yijinActive:addEffect("active", {
  card_num = 0,
  target_num = 1,
  interaction = function(self, player)
    return UI.ComboBox { choices = player:getTableMark("@[:]lan__yijin_owner") }
  end,
  prompt = function (self)
    return self.interaction.data and Fk:translate(":" .. self.interaction.data) or ""
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, cards)
    return #selected == 0 and to_select ~= player and to_select:getMark("@[:]lan__yijin") == 0
  end,
})

return yijinActive
