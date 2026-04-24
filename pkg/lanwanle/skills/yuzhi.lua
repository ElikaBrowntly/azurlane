local yuzhi = fk.CreateSkill{
  name = "lan__yuzhi",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__yuzhi"] = "迂志",
  [":lan__yuzhi"] = "锁定技，每回合开始时，你展示一张手牌，摸X张牌（X为此牌牌名字数）",

  ["#lan__yuzhi-card"] = "迂志：展示一张手牌，摸其牌名字数的牌",

  ["$lan__yuzhi1"] = "我欲行夏禹旧事，为天下人。",
  ["$lan__yuzhi2"] = "汉鹿已失，魏牛犹在，吾欲执其耳。",
  ["$lan__yuzhi3"] = "风水轮流转，轮到我钟某问鼎重几何了。",
  ["$lan__yuzhi4"] = "空将宝地赠他人，某怎会心甘情愿？",
  ["$lan__yuzhi5"] = "入宝山而空手回，其与匹夫何异？",
  ["$lan__yuzhi6"] = "天降大任于斯，不受必遭其殃。",
  ["$lan__yuzhi7"] = "与君相逢恨晚，数语难道天下谊",
  ["$lan__yuzhi8"] = "会不轻易信人，唯不疑伯约",
}

yuzhi:addEffect(fk.TurnStart, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(yuzhi.name) and not player:isKongcheng()
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = yuzhi.name,
      prompt = "#lan__yuzhi-card",
      cancelable = false,
    })
    local n = Fk:translate(Fk:getCardById(cards[1]).trueName, "zh_CN"):len()
    player:showCards(cards)
    if player.dead then return false end
    player:drawCards(n, yuzhi.name)
  end,
})

return yuzhi