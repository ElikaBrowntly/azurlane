local xiongji = fk.CreateSkill {
  name = "yyfy_xiongji",
  anim_type = "drawcard"
}

Fk:loadTranslationTable {
  ["yyfy_xiongji"] = "雄骑",
  [":yyfy_xiongji"] = "游戏开始时，你可获得游戏人数张坐骑牌。你可以将手牌或场上的坐骑牌当作任意"..
  "基本牌或普通锦囊牌使用或打出并摸一张牌（无次数限制且不可被响应）。" ,
  ["#yyfy_xiongji-invoke"] = "雄骑：是否要获得 %arg 张坐骑牌？",

  ["$yyfy_xiongji1"] = "赤骊骋疆，巡狩八荒！",
  ["$yyfy_xiongji2"] = "长缨在手，百骥可降！"
}

xiongji:addEffect(fk.GameStart, {
  can_trigger = function (self, event, target, player, data)
    return player and player:isAlive() and player:hasSkill(self.name)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local num = #room:getAllPlayers()
    if room:askToSkillInvoke(player, {
      skill_name = xiongji.name,
      prompt = "#yyfy_xiongji-invoke:::"..num
    }) then
      event:setCostData(self, {num = num})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local num = event:getCostData(self).num
    local cards = {}
    local i = 1
    while #cards < num do
      local card = Fk:getCardById(room.draw_pile[i])
      if card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide then
        table.insert(cards, card)
      end
      i = i + 1
    end
    if player.dead then return end
    room:obtainCard(player, cards, false, fk.ReasonPrey, player, xiongji.name)
  end
})

xiongji:addEffect("viewas", {
  interaction = function(self, player)
    local all_choices = Fk:getAllCardNames("bt")
    if #all_choices == 0 then return end
    return UI.ComboBox {
      choices = all_choices,
      all_choices = all_choices,
      prompt = "雄骑：请选择要转化的牌"
    }
  end,
  card_filter = function(self, player, to_select, selected)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and (card.sub_type == Card.SubtypeOffensiveRide or card.sub_type == Card.SubtypeDefensiveRide)
  end,
  include_equip = true,
  view_as = function (self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    card:addSubcard(cards[1])
    card:addMark("yyfy_xiongji-phase", 1)
    return card
  end,
  enabled_at_play = Util.TrueFunc,
  enabled_at_response = Util.TrueFunc,
  enabled_at_nullification = Util.TrueFunc,
  before_use = function (self, player, use)
    player:drawCards(1, xiongji.name)
    use.extraUse = true
  end
})

xiongji:addEffect("targetmod", {
  mute = true,
  bypass_times = function (self, player, skill, scope, card, to)
    return player and player:hasSkill(self.name) and card and card:getMark("yyfy_xiongji-phase") > 0
  end,
})

xiongji:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self.name) and data.card and data.card:getMark("yyfy_xiongji-phase") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data.unoffsetableList = player.room:getAlivePlayers()
    data.disresponsiveList = player.room:getAlivePlayers()
  end
})
return xiongji