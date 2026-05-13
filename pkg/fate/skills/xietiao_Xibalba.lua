local xietiao = fk.CreateSkill {
  name = "yyfy_xietiao_XibalbaORT",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_xietiao_XibalbaORT"] = "血条",
  [":yyfy_xietiao_XibalbaORT"] = "持恒技，你获得6个额外的血条（上限分别为15、20、25、10、30、50）。"
      .. "你获得〖<a href=':yyfy_yitaixuyin'>以太酗饮</a>〗〖<a href=':yyfy_youyiqinlue'>优异的侵略</a>〗"
      .. "〖<a href=':yyfy_yanjunjiehe'>严峻结合</a>〗〖<a href=':yyfy_anwuzhifuyou'>暗物质浮游</a>〗"
      .. "〖<a href=':yyfy_gemingzhuwang'>革命蛛网</a>〗〖<a href=':yyfy_beilunbuchang'>悖论补偿</a>〗"
      .. "〖<a href=':yyfy_fanshipengzhang'>范式膨胀</a>〗。"
}

xietiao:addAcquireEffect(function(self, player, is_start, src)
  player.tag["@yyfy_xietiao_XibalbaORT"] = 6                  -- 0个也有初始的一条血
  player.room:handleAddLoseSkills(player, {"yyfy_yitaixuyin", "yyfy_youyiqinlue", "yyfy_yanjunjiehe",
  "yyfy_anwuzhifuyou", "yyfy_gemingzhuwang", "yyfy_beilunbuchang", "yyfy_fanshipengzhang"})
end)

xietiao:addEffect(fk.BeforeGameOverJudge, {
  priority = 2,
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, true, true) and
    (player.tag["@yyfy_xietiao_XibalbaORT"] or 0) ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local case = player.tag["@yyfy_xietiao_XibalbaORT"] or 0
    room:setTag("SkipGameRule", true)
    player.tag["@yyfy_xietiao_XibalbaORT"] = case - 1
    room:revivePlayer(player, false)
    local max = {15, 20, 25, 10, 30, 50}
    player.maxHp = math.max(player.maxHp, max[7 - case])
    room:broadcastProperty(player, "maxHp")
  end
})

return xietiao