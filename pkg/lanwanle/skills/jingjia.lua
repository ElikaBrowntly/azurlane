local jingjia = fk.CreateSkill {
  name = "lan__jingjia",
}

Fk:loadTranslationTable {
  ["lan__jingjia"] = "精甲",
  [":lan__jingjia"] = "游戏开始时，将【<a href=':matchless_halberd'><font color='red'>无双方天戟</font></a>】"
  .."【<a href=':lion_belt'><font color='blue'>玲珑狮蛮带</font></a>】"..
  "【<a href=':golden_coronet'><font color='#8300FF'>束发紫金冠</font></a>】置入你的装备区。"
}

jingjia:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jingjia.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local laobu_equip = {
      { "matchless_halberd", Card.Diamond, 12 }, -- 无双方天戟
      { "lion_belt", Card.Spade, 2 }, -- 玲珑狮蛮带
      { "golden_coronet", Card.Diamond, 1 } -- 束发紫金冠
      --{ "red_robe", Card.Club, 1 } 红棉百花袍
    }
    local cards = table.filter(room:prepareDeriveCards(laobu_equip, "laobu_equip"), function(id)
      return room:getCardArea(id) == Card.Void
    end)
    if #cards > 0 then
      room:moveCardIntoEquip(player, cards, jingjia.name, true, player)
    end
  end,
})

return jingjia