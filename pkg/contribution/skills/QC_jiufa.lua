local QC_jiufa = fk.CreateSkill{
  name = "QC_jiufa",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["QC_jiufa"] = "九伐",
  [":QC_jiufa"] = "持恒技，每有九张牌进入弃牌堆后，你可以获得牌堆顶的九张牌，然后指定一至九名角色，分别造成至多共计九点火焰伤害。",
  ["@QC_jiufa"] = "九伐",
  ["#QC_jiufa-invoke"] = "九伐：是否发动？（摸9张牌并分配至多9点火焰伤害）",
  ["#QC_jiufa-choose"] = "九伐：请选择1至9名角色",
  ["#QC_jiufa-damage"] = "九伐：请选择要对 %arg 造成的火焰伤害值（剩余 %arg2 点）",
}

QC_jiufa:addEffect(fk.AfterCardsMove, {
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(QC_jiufa.name) then
      local count = 0
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          count = count + #move.moveInfo
        end
      end
      if count > 0 then
        event:setCostData(self, { count = count })
        return true
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = event:getCostData(self).count
    local mark = player:getMark("@QC_jiufa") + count

    while mark >= 9 do
      if not room:askToSkillInvoke(player, {
        skill_name = QC_jiufa.name,
        prompt = "#QC_jiufa-invoke",
      }) then
        break
      end

      mark = mark - 9
      room:setPlayerMark(player, "@QC_jiufa", mark)

      local cards = room:getNCards(9, "top")
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, QC_jiufa.name)
      end

      local targets = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 9,
        targets = room.alive_players,
        skill_name = QC_jiufa.name,
        prompt = "#QC_jiufa-choose",
        cancelable = false,
      })
      if #targets > 0 then
        local total = 9
        for _, tar in ipairs(targets) do
          if total <= 0 or tar.dead then break end
          local name = Fk:translate(tar.general)
          local prompt_str = Fk:translate("#QC_jiufa-damage")
          prompt_str = prompt_str:gsub("%%arg2", tostring(total))
          prompt_str = prompt_str:gsub("%%arg", name)
          local damage = room:askToNumber(player, {
            min = 0,
            max = total,
            prompt = prompt_str,
            skill_name = QC_jiufa.name,
          })
          if damage and damage > 0 then
            total = total - damage
            room:damage{
              from = player,
              to = tar,
              damage = damage,
              damageType = fk.FireDamage,
              skillName = QC_jiufa.name,
            }
          end
        end
      end
    end

    room:setPlayerMark(player, "@QC_jiufa", mark)
  end,
})

return QC_jiufa