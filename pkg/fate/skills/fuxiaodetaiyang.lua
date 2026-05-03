local xieitao3 = fk.CreateSkill{
  name = "fate_fuxiaodetaiyang",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["fate_fuxiaodetaiyang"] = "<font color='orangered'>拂晓的太阳</font>",
  [":fate_fuxiaodetaiyang"] = "觉醒技，你死亡后，若你发动过〖正午的太阳〗，你加一点体力上限并复活，然后赋予自身永久的无敌贯通状态。",

  ["fate_fuxiaodetaiyang1"] = "拂晓的太阳",
  ["fate_fuxiaodetaiyang2"] = "特斯卡特利波卡"
}

xieitao3:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  can_trigger = Util.TrueFunc,
  can_wake = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true, true) and player:getMark("@!fate_yili") == 0
    and (player.tag[xieitao3.name] or 0) == 0 and player.tag["yyfy_zhengwudetaiyang"] == 1
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    room:revivePlayer(player, false)
    room:changeMaxHp(player, 1)
    room:changeHp(player, player.maxHp - player.hp, nil, xieitao3.name)
    room:addPlayerMark(player, "fate_wudiguantong")
    player.tag[xieitao3.name] = 1
  end
})

return xieitao3