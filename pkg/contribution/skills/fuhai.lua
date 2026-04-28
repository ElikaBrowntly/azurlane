local fuhai = fk.CreateSkill {
  name = "yyfy_fuhai",
}

Fk:loadTranslationTable{
  ["yyfy_fuhai"] = "浮海",
  [":yyfy_fuhai"] = "游戏开始时，你视为拥有<font color='red'>亚欧大陆</font>。出牌阶段限1次，你可以开辟一条"..
  "通往其他大陆的<a href='yyfy_hanglu'><font color='red'>航路</font></a>。你根据已发现的大陆拥有对应的效果："..
  "<br><font color='red'>亚欧大陆</font>：你的摸牌阶段摸牌数和手牌上限+X"..
  "<br><font color='orangered'>非洲大陆</font>：你造成的伤害+X"..
  "<br><font color='orange'>北美洲</font>：你使用的牌额外结算X次"..
  "<br><font color='green'>南美洲</font>：总计可用X次，你进入濒死时将体力回复至上限"..
  "<br><font color='blue'>大洋洲</font>：你受到的伤害-X"..
  "<br><font color='purple'>南极洲</font>：你可以改变你造成伤害的属性"..
  "<br>X为已发现大陆数量。当你发现所有大陆后，你获得游戏胜利。",

  ["$yyfy_fuhai1"] = "宦海沉浮，生死难料！",
  ["$yyfy_fuhai2"] = "跨海南征，波涛起浮。",

  ["yyfy_hanglu"] = "<br>(仍在开发中)",
  ["@@yyfy_fuhai_AsiaEurope"] = "亚欧",
  ["@@yyfy_fuhai_Africa"] = "非洲",
  ["@@yyfy_fuhai_NorthAmerica"] = "北美",
  ["@@yyfy_fuhai_SouthAmerica"] = "南美",
  ["@@yyfy_fuhai_Oceania"] = "大洋",
  ["@@yyfy_fuhai_Antarctica"] = "南极"
}

fuhai:addEffect(fk.GameStart, {
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:addTableMarkIfNeed(player, fuhai.name, "@@yyfy_fuhai_AsiaEurope")
    room:addPlayerMark(player, "@@yyfy_fuhai_AsiaEurope")
  end
})

fuhai:addEffect("active", {
  card_num = 0,
  anim_type = "support",
  prompt = "浮海：你可以开辟一条通往其他大陆的航路",
  can_use = function(self, player)
    return player:usedSkillTimes(fuhai.name, Player.HistoryPhase) == 0 and
    #player:getTableMark(fuhai.name) < 6
  end,
  target_num = 0,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local n = "@@"..fuhai.name.."_"
    local all = {n.."AsiaEurope", n.."Africa", n.."NorthAmerica", n.."SouthAmerica", n.."Antarctica", n.."Oceania"}
    local already = player:getTableMark(fuhai.name)
    local choices = table.simpleClone(all)
    for _, a in ipairs(already) do
      table.removeOne(choices, a)
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      all_choices = all,
      cancelable = false,
      prompt = "浮海：请选择要通向的大陆"
    })
    room:addTableMarkIfNeed(player, fuhai.name, choice)
    room:addPlayerMark(player, choice)
    if #player:getTableMark(fuhai.name) == 6 then
      local role = (player.role == "lord" or player.role == "loyalist") and "lord+loyalist" or player.role
      room:gameOver(player.role)
    end
  end,
})

-- 亚洲
fuhai:addEffect("maxcards", {
  correct_func = function (self, player)
    if player and player:hasSkill(self) and
    table.contains(player:getTableMark(fuhai.name), "@@yyfy_fuhai_AsiaEurope") then
      return #player:getTableMark(fuhai.name)
    end
  end
})
-- 欧洲
fuhai:addEffect(fk.DrawNCards, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self) and
    table.contains(player:getTableMark(fuhai.name), "@@yyfy_fuhai_AsiaEurope")
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    player.room:notifySkillInvoked(player, "@@yyfy_fuhai_AsiaEurope", "drawcard")
    player:broadcastSkillInvoke(fuhai.name)
    data.n = data.n + #player:getTableMark(fuhai.name)
  end
})
-- 非洲、南极
fuhai:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
    (table.contains(player:getTableMark(fuhai.name), "@@yyfy_fuhai_Africa") or
    table.contains(player:getTableMark(fuhai.name), "@@yyfy_fuhai_Antarctica"))
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if table.contains(player:getTableMark(fuhai.name), "@@yyfy_fuhai_Antarctica") then
      local damageNatures = {}
      for k, v in pairs(Fk:getDamageNatures()) do
        table.insert(damageNatures, v[1])
      end
      local choice = room:askToChoice(player, {
        choices = damageNatures,
        prompt = "南极洲：你可以改变伤害属性",
        cancelable = true
      })
      if choice ~= "Cancel" then
        room:notifySkillInvoked(player, "@@yyfy_fuhai_Antarctica", "offensive")
        ---@diagnostic disable-next-line: assign-type-mismatch
        data.damageType = choice
      end
    end
    if table.contains(player:getTableMark(fuhai.name), "@@yyfy_fuhai_Africa") then
      room:notifySkillInvoked(player, "@@yyfy_fuhai_Africa", "offensive")
      data:changeDamage(#player:getTableMark(fuhai.name))
    end
    player:broadcastSkillInvoke(fuhai.name)
  end,
})
-- 北美
fuhai:addEffect(fk.CardUsing, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and #data.tos > 0 and (data.card:isCommonTrick()
    or data.card.type == Card.TypeBasic and data.card.name ~= "jink") and player:hasSkill(self)
    and table.contains(player:getTableMark(fuhai.name), "@@yyfy_fuhai_NorthAmerica")
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, "@@yyfy_fuhai_NorthAmerica", "control")
    player:broadcastSkillInvoke(fuhai.name)
    data.additionalEffect = (data.additionalEffect or 0) + #player:getTableMark(fuhai.name)
  end,
})
-- 南美
fuhai:addEffect(fk.EnterDying, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, false, true) and
    table.contains(player:getTableMark(fuhai.name), "@@yyfy_fuhai_SouthAmerica")
    and player:usedSkillTimes(fuhai.name, Player.HistoryGame, "SouthAmerica") < #player:getTableMark(fuhai.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:notifySkillInvoked(player, "@@yyfy_fuhai_SouthAmerica", "support")
    player:broadcastSkillInvoke(fuhai.name)
    room:recover({
      who = player,
      num = player.maxHp - player.hp,
      recoverBy = player,
      skillName = fuhai.name
    })
    player:addSkillBranchUseHistory(fuhai.name, "SouthAmerica", 1)
  end,
})
-- 大洋
fuhai:addEffect(fk.DamageInflicted, {
  mute = true,
  on_cost = function(self, event, target, player, data)
    return data.to == player and player:hasSkill(self) and
    table.contains(player:getTableMark(fuhai.name), "@@yyfy_fuhai_Oceania")
  end,
  on_use = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, "@@yyfy_fuhai_Oceania", "defensive")
    player:broadcastSkillInvoke(fuhai.name)
    data:changeDamage(- #player:getTableMark(fuhai.name))
  end,
})

return fuhai