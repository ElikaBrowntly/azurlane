local xietiao = fk.CreateSkill {
  name = "yyfy_xietiao_flyingORT",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_xietiao_flyingORT"] = "血条",
  [":yyfy_xietiao_flyingORT"] = "持恒技，你获得10个额外的血条。你死亡时，若血条已全被击破，则变更为“ORT希巴尔巴”；"
      .. "否则，你复活并随机变更为{剑、弓、枪、骑、术、杀、狂、降}中的一个势力。"
      .. "若你剩余血条数≥8，你拥有〖<a href=':yyfy_yinhedanti'>银河单体</a>〗；"
      .. "<br>若你不为：术/狂，你拥有〖<a href=':yyfy_fanshipengzhang'>范式膨胀</a>〗；"
      .. "<br>剑/骑/杀，你拥有〖<a href=':yyfy_anwuzhifuyou'>暗物质浮游</a>〗；"
      .. "<br>弓/枪/骑，你拥有〖<a href=':yyfy_beilunbuchang'>悖论补偿</a>〗；"
      .. "<br>剑/杀/狂/降：你拥有〖<a href=':yyfy_yanjunjiehe'>严峻结合</a>〗；"
      .. "<br>弓/枪/术/降：你拥有〖<a href=':yyfy_yitaixuyin'>以太酗饮</a>〗。"
}

local function changeSkills(player)
  local room = player.room
  local k = player.kingdom
  room:handleAddLoseSkills(player, "-yyfy_yinhedanti")
  room:handleAddLoseSkills(player, "-yyfy_fanshipengzhang")
  room:handleAddLoseSkills(player, "-yyfy_anwuzhifuyou")
  room:handleAddLoseSkills(player, "-yyfy_beilunbuchang")
  room:handleAddLoseSkills(player, "-yyfy_yanjunjiehe")
  room:handleAddLoseSkills(player, "-yyfy_yitaixuyin")
  if (player.tag["@yyfy_xietiao_flyingORT"] or 0) >= 8 then
    room:handleAddLoseSkills(player, "yyfy_yinhedanti")
  end
  if not table.contains({ "Caster", "Berserker" }, k) then
    room:handleAddLoseSkills(player, "yyfy_fanshipengzhang")
  end
  if not table.contains({ "Saber", "Rider", "Assassin" }, k) then
    room:handleAddLoseSkills(player, "yyfy_anwuzhifuyou")
  end
  if not table.contains({ "Archer", "Lancer", "Rider" }, k) then
    room:handleAddLoseSkills(player, "yyfy_beilunbuchang")
  end
  if not table.contains({ "Saber", "Assassin", "Berserker", "Foreigner" }, k) then
    room:handleAddLoseSkills(player, "yyfy_yanjunjiehe")
  end
  if not table.contains({ "Archer", "Lancer", "Caster", "Foreigner" }, k) then
    room:handleAddLoseSkills(player, "yyfy_yitaixuyin")
  end
end

xietiao:addAcquireEffect(function(self, player, is_start, src)
  player.tag["@yyfy_xietiao_flyingORT"] = 10
end)

xietiao:addEffect(fk.BeforeGameOverJudge, {
  priority = 2,
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, true, true)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local case = player.tag["@yyfy_xietiao_flyingORT"] or 0
    room:setTag("SkipGameRule", true)
    room:revivePlayer(player, false)
    if case == 0 then
      local isDeputy = player.deputyGeneral == "yyfy_flyingORT" and true or false
      room:changeHero(player, "yyfy_flyingORT", false, isDeputy)
      player.maxHp = math.max(player.maxHp, 12)
      player.hp = player.maxHp
      room:broadcastProperty(player, "maxHp")
      room:broadcastProperty(player, "hp")
      return
    end
    player.tag["@yyfy_xietiao_flyingORT"] = case - 1
    player.maxHp = math.max(player.maxHp, 10)
    local kingdoms = { "Saber", "Archer", "Lancer", "Rider", "Caster", "Assassin", "Berserker", "Foreigner" }
    player.kingdom = kingdoms[math.random(8)]
    room:broadcastProperty(player, "maxHp")
    room:broadcastProperty(player, "kingdom")
    changeSkills(player)
  end
})

xietiao:addEffect(fk.AfterPropertyChange, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true, true) and
    data.kingdom and data.kingdom ~= player.kingdom
  end,
  on_refresh = function (self, event, target, player, data)
    changeSkills(player)
  end
})

return xietiao