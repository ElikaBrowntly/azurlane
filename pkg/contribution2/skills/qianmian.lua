local qianmian = fk.CreateSkill {
  name = "yyfy_qianmian",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["yyfy_qianmian"] = "千面",
  [":yyfy_qianmian"] = "锁定技，每轮开始时，若你不为主公，随机修改你的身份（主公除外）。出牌阶段开始时，<a href='yyfy_qianmian-change'>随机替换</a>你的武将牌直到本回合结束。",
  ["yyfy_qianmian-change"] = "<br>将池范围 为 当前房间的将池。"
}

qianmian:addEffect(fk.RoundStart, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and player.role ~= "lord"
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local roles = {"loyalist", "rebel", "renegade"}
    room:setPlayerProperty(player, "role", room:tableRandomPick(roles))
  end
})

qianmian:addEffect(fk.EventPhaseStart, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(self) and data.who == player and data.phase == Player.Play and player:getMark("yyfy_qianmian_morphed") == 0
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local generals = room:getNGenerals(1) or {"blank_nvshibing"}
    if #generals == 0 then generals = {"blank_nvshibing"} end
    local deputy = (player.deputyGeneral or "") == "yyfy_naiyazi" and true or false
    local original = {deputy, deputy and player.deputyGeneral or player.general}
    room:setPlayerMark(player, "yyfy_qianmian_original", original)
    room:setPlayerMark(player, "yyfy_qianmian_morphed", 1)
    room:changeHero(player, generals[1], false, deputy, true)
  end
})

qianmian:addEffect(fk.TurnEnd, {
  anim_type = "switch",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:getMark("yyfy_qianmian_morphed") == 1
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("yyfy_qianmian_original")
    if not mark or #mark ~= 2 then return end
    local isDeputy = mark[1]
    local originalGeneral = mark[2]
    room:changeHero(player, originalGeneral, false, isDeputy, true)
    room:setPlayerMark(player, "yyfy_qianmian_original", 0)
    room:setPlayerMark(player, "yyfy_qianmian_morphed", 0)
  end
})

return qianmian