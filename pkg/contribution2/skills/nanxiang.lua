local nanxiang = fk.CreateSkill {
  name = "yyfy_nanxiang",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_nanxiang"] = "难祥",
  [":yyfy_nanxiang"] = "你失去〖穿屋〗标记牌后，以倒序获得并重置等量未拥有的武将牌上的技能。",

  ["$yyfy_nanxiang1"] = "斗牛间常有紫气，其兆如何，还请阁下解之。",
  ["$yyfy_nanxiang2"] = "桑化为柏，此非不祥乎？",
  ["$yyfy_nanxiang3"] = "若当下之围不解，何以图千秋之惠？"
}

nanxiang:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (player and player:hasSkill(nanxiang.name) and type(data) == "table") then return false end
    local cards = {}
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip)
              and table.contains(player:getTableMark("yyfy_chuanwu"), info.cardId) then
            table.insert(cards, info.cardId)
          end
        end
      end
    end
    if #cards == 0 then return false end
    for _, id in ipairs(cards) do
      player.room:removeTableMark(player, "yyfy_chuanwu", id)
    end
    local skills = Fk.generals[player.general]:getSkillNameList(true)
    if player.deputyGeneral and player.deputyGeneral ~= "" then
      table.insertTable(skills, Fk.generals[player.deputyGeneral]:getSkillNameList(true))
    end
    skills = table.filter(skills, function(s)
      return not player:hasSkill(s, true)
    end)
    if #skills == 0 then return false end
    event:setCostData(self, { num = #cards, skills = skills })
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = (event:getCostData(self) or {}).num or 0
    local skills = (event:getCostData(self) or {}).skills or {}
    if num == 0 or #skills == 0 then return end
    local len, t = #skills, {}
    local start = len - num + 1
    if start < 1 then start = 1 end
    for i = len, start, -1 do
      t[#t + 1] = skills[i]
    end
    room:handleAddLoseSkills(player, t)
    for _, s in ipairs(t) do
      player:clearSkillHistory(s)
    end
    room:setPlayerMark(player, "yyfy_jianhe-turn", 0)
  end,
})

return nanxiang