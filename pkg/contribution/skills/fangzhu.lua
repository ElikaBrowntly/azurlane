local lan__fangzhu = fk.CreateSkill{
  name = "lan__fangzhu",
  frequency = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["lan__fangzhu"] = "放逐",
  [":lan__fangzhu"] = "持恒技，出牌阶段限一次，或当你受到伤害后，可以选择一名其他角色和一种类型，"..
  "令其所有技能失效且只能使用或打出该类型的牌直到其回合结束，然后其翻面、弃置所有手牌并失去一点体力。",

  ["#lan__fangzhu-choose"] = "放逐：请选择一名其他角色",
  ["#lan__fangzhu-type"] = "放逐：请选择一种牌类型",
  ["@@lan__fangzhu_nullify"] = "放逐 技能失效",

  ["@@lan__fangzhu_basic"] = "放逐 限基本",
  ["@@lan__fangzhu_trick"] = "放逐 限锦囊",
  ["@@lan__fangzhu_equip"] = "放逐 限装备",

  ["$lan__fangzhu1"] = "此等过错，不杀已是承了朕恩。",
  ["$lan__fangzhu2"] = "朕于天下无所不容，而况汝乎？",
  ["$lan__fangzhu3"] = "世子之争素来如此，朕予改封已是仁慈！",
  ["$lan__fangzhu4"] = "卿当竭命纳忠，何为此逾矩之举！",
  ["$lan__fangzhu5"] = "朕继文帝风流，亦当效其权略！",
  ["$lan__fangzhu6"] = "赦你死罪，你去吧！"
}

-- 出牌阶段限一次
lan__fangzhu:addEffect("active", {
  prompt = "#lan__fangzhu-choose",
  card_num = 0,
  target_num = 1,
  max_phase_use_time = 1,
  target_filter = function(self, to_select, selected)
    return to_select:isAlive() and #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local to = effect.tos[1]
    
    -- 选择牌类型
    local choices = {
      "@@lan__fangzhu_basic",
      "@@lan__fangzhu_trick", 
      "@@lan__fangzhu_equip",
    }
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = self.name,
      prompt = "#lan__fangzhu-type",
    })
    
    -- 设置技能失效标记
    room:setPlayerMark(to, "@@lan__fangzhu_nullify", 1)
    
    -- 翻面
    to:turnOver()
    
    -- 弃置所有手牌
    if not to:isKongcheng() then
      room:throwCard(to:getCardIds("h"), self.name, to, to)
    end
    
    -- 失去一点体力
    room:loseHp(to, 1, self.name)
  end,
})

-- 受到伤害后触发
lan__fangzhu:addEffect(fk.Damaged, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(lan__fangzhu.name) and target == player 
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player),
      skill_name = lan__fangzhu.name,
      prompt = "#lan__fangzhu-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    
    -- 选择牌类型
    local choices = {
      "@@lan__fangzhu_basic",
      "@@lan__fangzhu_trick", 
      "@@lan__fangzhu_equip",
    }
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = self.name,
      prompt = "#lan__fangzhu-type",
    })
    
    -- 设置技能失效标记
    room:setPlayerMark(to, "@@lan__fangzhu_nullify", 1)
    
    -- 翻面
    to:turnOver()
    
    -- 弃置所有手牌
    if not to:isKongcheng() then
      room:throwCard(to:getCardIds("h"), self.name, to, to)
    end
    
    -- 失去一点体力
    room:loseHp(to, 1, self.name)
  end,
})

-- 回合结束时清除标记
lan__fangzhu:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return target == player and (
      player:getMark("@@lan__fangzhu_basic") ~= 0 or
      player:getMark("@@lan__fangzhu_trick") ~= 0 or
      player:getMark("@@lan__fangzhu_equip") ~= 0 or
      player:getMark("@@lan__fangzhu_nullify") ~= 0
    )
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@lan__fangzhu_basic", 0)
    room:setPlayerMark(player, "@@lan__fangzhu_trick", 0)
    room:setPlayerMark(player, "@@lan__fangzhu_equip", 0)
    room:setPlayerMark(player, "@@lan__fangzhu_nullify", 0)
  end,
})

-- 限牌型
lan__fangzhu:addEffect("prohibit", {
  prohibit_use = function(self, player, card) 
    if player:getMark("@@lan__fangzhu_basic") > 0 then -- 基本牌
      return card.type ~= Card.TypeBasic
    elseif player:getMark("@@lan__fangzhu_trick") > 0 then -- 锦囊牌
      return card.type ~= Card.TypeTrick
    elseif player:getMark("@@lan__fangzhu_equip") > 0 then -- 装备牌
      return card.type ~= Card.TypeEquip
    end
    return false
  end,
  prohibit_response = function(self, player, card)
        if player:getMark("@@lan__fangzhu_basic") > 0 then -- 基本牌
      return card.type ~= Card.TypeBasic
    elseif player:getMark("@@lan__fangzhu_trick") > 0 then -- 锦囊牌
      return card.type ~= Card.TypeTrick
    elseif player:getMark("@@lan__fangzhu_equip") > 0 then -- 装备牌
      return card.type ~= Card.TypeEquip
    end
    return false
  end,
})

-- 技能失效
lan__fangzhu:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    return from:getMark("@@lan__fangzhu_nullify") > 0 and skill:isPlayerSkill(from)
  end,
})

return lan__fangzhu