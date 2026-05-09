local xietiao = fk.CreateSkill {
  name = "yyfy_xietiao_mobileORT",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_xietiao_mobileORT"] = "血条",
  [":yyfy_xietiao_mobileORT"] = "持恒技，你获得10个额外的血条。你死亡时，若血条已全被击破，则变更为“飞行ORT”；"
      .. "否则，你复活并随机变更为{剑、弓、枪、骑、术、杀、狂、降}中的一个势力。<br>若你不为：术/狂，你拥有"
      .. "〖<a href=':yyfy_youyiqinlue'>优异的侵略</a>〗；<br>剑/骑/杀，你拥有〖<a href=':yyfy_anwuzhifuyou'>"
      .. "暗物质浮游</a>〗；<br>弓/枪/骑，你拥有〖<a href=':yyfy_gemingzhuwang'>革命蛛网</a>〗；<br>剑/杀/狂/降："
      .. "你拥有〖<a href=':yyfy_yanjunjiehe'>严峻结合</a>〗<br>弓/枪/术/降：你拥有〖<a href=':yyfy_yitaixuyin'>以太酗饮</a>〗。",

  [":yyfy_yanjunjiehe"] = "(未实装)",
  [":yyfy_yitaixuyin"] = "(未实装)"
}

local function changeSkills(player)
  local room = player.room
  local k = player.kingdom
  room:handleAddLoseSkills(player, "-yyfy_youyiqinlue")
  room:handleAddLoseSkills(player, "-yyfy_anwuzhifuyou")
  room:handleAddLoseSkills(player, "-yyfy_gemingzhuwang")
  room:handleAddLoseSkills(player, "-yyfy_yanjunjiehe")
  room:handleAddLoseSkills(player, "-yyfy_yitaixuyin")
  if not table.contains({ "Caster", "Berserker" }, k) then
    room:handleAddLoseSkills(player, "yyfy_youyiqinlue")
  end
  if not table.contains({ "Saber", "Rider", "Assassin" }, k) then
    room:handleAddLoseSkills(player, "yyfy_anwuzhifuyou")
  end
  if not table.contains({ "Archer", "Lancer", "Rider" }, k) then
    room:handleAddLoseSkills(player, "yyfy_gemingzhuwang")
  end
  if not table.contains({ "Saber", "Assassin", "Berserker", "Foreigner" }, k) then
    room:handleAddLoseSkills(player, "yyfy_yanjunjiehe")
  end
  if not table.contains({ "Archer", "Lancer", "Caster", "Foreigner" }, k) then
    room:handleAddLoseSkills(player, "yyfy_yitaixuyin")
  end
end

xietiao:addAcquireEffect(function(self, player, is_start, src)
  player.tag["@yyfy_xietiao_mobileORT"] = 10
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
    local case = player.tag["@yyfy_xietiao_mobileORT"] or 0
    room:setTag("SkipGameRule", true)
    room:revivePlayer(player, false)
    if case == 0 then
      local isDeputy = player.deputyGeneral == "yyfy_mobileORT" and true or false
      room:changeHero(player, "yyfy_flyingORT", false, isDeputy)
      player.maxHp = math.max(player.maxHp, 12)
      player.hp = player.maxHp
      room:broadcastProperty(player, "maxHp")
      room:broadcastProperty(player, "hp")
      return
    end
    player.tag["@yyfy_xietiao_mobileORT"] = case - 1
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