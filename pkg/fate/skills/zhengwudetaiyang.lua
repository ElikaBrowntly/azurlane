local xieitao2 = fk.CreateSkill{
  name = "yyfy_zhengwudetaiyang",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["yyfy_zhengwudetaiyang"] = "<font color='red'>正午的太阳</font>",
  [":yyfy_zhengwudetaiyang"] = "觉醒技，你死亡后，加一点体力上限并复活，然后获得技能〖拂晓的太阳〗。"..
  "此后，你使用的牌不可被响应。",

  ["yyfy_zhengwudetaiyang1"] = "正午的太阳",
  ["yyfy_zhengwudetaiyang2"] = "特斯卡特利波卡"
}

xieitao2:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  priority = 0.9,
  can_trigger = Util.TrueFunc,
  can_wake = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true, true) and player:getMark("@!fate_yili") == 0
    and (player.tag[xieitao2.name] or 0) == 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    room:revivePlayer(player, false)
    room:changeMaxHp(player, 1)
    room:changeHp(player, player.maxHp - player.hp, nil, xieitao2.name)
    room:handleAddLoseSkills(player, "fate_fuxiaodetaiyang", xieitao2.name)
    room:addPlayerMark(player, "fate_bizhong")
    player.tag[xieitao2.name] = 1
  end
})

return xieitao2