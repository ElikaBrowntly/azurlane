local liangyuan = fk.CreateSkill{
  name = "lan__liangyuan",
  attached_skill_name = "lan__liangyuan&",
}

Fk:loadTranslationTable{
  ["lan__liangyuan"] = "良缘",
  [":lan__liangyuan"] = "你可以将一张<font color='red'>「玉树」</font>当<font color='red'>【桃】</font>"
  .."使用；任意角色的出牌阶段或濒死结算中，你可以令其将一张<font color='blue'>「灵杉」</font>当"..
  "<font color='blue'>【酒】</font>使用。",

  ["#lan__liangyuan"] = "良缘：将一张「玉树」当【桃】使用",

  ["$lan__liangyuan1"] = "金玉良缘，来日方长。",
  ["$lan__liangyuan2"] = "青鸟载锦书，衔来野陌一枝春。",
  ["$lan__liangyuan3"] = "雎鸠鸣河洲，花灿缤纷，女儿心思付瑶琴。",
}

liangyuan:addEffect("viewas", {
  anim_type = "support",
  pattern = "peach",
  prompt = "#lan__liangyuan",
  card_num = 1,
  expand_pile = "lan__huamu_yushu",
  card_filter = function (self, player, to_select, selected, selected_targets)
    return #selected == 0 and table.contains(player:getPile("lan__huamu_yushu"), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("peach")
    card.skillName = liangyuan.name
    card:addSubcards(cards)
    return card
  end,
  enabled_at_play = function (self, player)
    local subcards = player:getPile("lan__huamu_yushu")
    return #subcards > 0 and #player:getViewAsCardNames(liangyuan.name, {"peach"}, subcards) > 0
  end,
  enabled_at_response = function (self, player, response)
    if response then return false end
    local subcards = player:getPile("lan__huamu_yushu")
    return #subcards > 0 and #player:getViewAsCardNames(liangyuan.name, {"peach"}, subcards) > 0
  end,
})

liangyuan:addAcquireEffect(function (self, player, is_start, src)
  player.room:handleAddLoseSkills(player, "lan__liangyuan&")
end)

return liangyuan