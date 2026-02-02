local shanzhuan = fk.CreateSkill{
  name = "yyfy_shanzhuan",
}

Fk:loadTranslationTable{
  ["yyfy_shanzhuan"] = "擅专",
  [":yyfy_shanzhuan"] = "你获得技能〖闭月〗。当你对一名其他角色造成伤害后，若其判定区没有牌，"..
  "你可以将其一张牌置于其判定区，若此牌不是延时锦囊牌，则红色牌视为【乐不思蜀】，黑色牌视为【兵粮寸断】。",

  ["#yyfy_shanzhuan-invoke"] = "擅专：你可以将 %dest 一张牌置于其判定区，红色视为【乐不思蜀】，黑色视为【兵粮寸断】",

  ["$yyfy_shanzhuan1"] = "打入冷宫，禁足绝食。",
  ["$yyfy_shanzhuan2"] = "我言既出，谁敢不从？",
  ["$yyfy_shanzhuan3"] = "擅专独断，人不敢欺。"
}

shanzhuan:addEffect(fk.Damage, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.to ~= player and not data.to.dead and not data.to:isNude() and
      not table.contains(data.to.sealedSlots, Player.JudgeSlot) and #data.to:getCardIds("j") == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#yyfy_shanzhuan-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = room:askToChooseCard(player, {
      target = data.to,
      flag = "he",
      skill_name = self.name,
    })
    if Fk:getCardById(id, true).sub_type == Card.SubtypeDelayedTrick then
      room:moveCardTo(Fk:getCardById(id, true), Player.Judge, data.to, fk.ReasonJustMove, self.name)
    else
      local card = Fk:cloneCard("indulgence")
      if Fk:getCardById(id, true).color == Card.Black then
        card = Fk:cloneCard("supply_shortage")
      end
      card:addSubcard(id)
      card.skillName = self.name
      room:moveCards{
        from = data.to,
        to = data.to,
        toArea = Player.Judge,
        ids = {id},
        moveReason = fk.ReasonJustMove,
        skillName = self.name,
        virtualEquip = card,
      } --无视合法性检测
    end
  end,
})

shanzhuan:addAcquireEffect(function (self, player, is_start)
  player.room:handleAddLoseSkills(player, "ex__biyue", self.name)
end)

return shanzhuan
