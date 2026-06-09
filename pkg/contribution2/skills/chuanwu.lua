local chuanwu = fk.CreateSkill{
  name = "yyfy_chuanwu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_chuanwu"] = "穿屋",
  [":yyfy_chuanwu"] = "锁定技，当你造成或受到伤害后，你失去武将牌上前X个技能直到回合结束（X为你的攻击范围），然后摸等量张牌并标记之。",

  ["@@yyfy_chuanwu-inhand"] = "穿屋",
  ["$yyfy_chuanwu1"] = "斩蛇穿屋，其志绥远。",
  ["$yyfy_chuanwu2"] = "祝融侵库，剑怀远志。",
  ["$yyfy_chuanwu3"] = "情势危急，故为此举以脱一时之困。"
}

local chuanwu_spec = {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(chuanwu.name) and player:getAttackRange() > 0 then
      local turn_event = player.room.logic:getCurrentEvent():findParent(GameEvent.Turn, true)
      if turn_event == nil then return end
      local skills = Fk.generals[player.general]:getSkillNameList(true)
      if player.deputyGeneral and player.deputyGeneral ~= "" then
        table.insertTableIfNeed(skills, Fk.generals[player.deputyGeneral]:getSkillNameList(true))
      end
      skills = table.filter(skills, function(s)
        return player:hasSkill(s, true)
      end)
      if #skills > 0 then
        event:setCostData(self, {choice = skills})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local skills = table.simpleClone(event:getCostData(self).choice)
    local n = math.min(player:getAttackRange(), #skills)
    skills = table.slice(skills, 1, n + 1)
    local turn_event = room.logic:getCurrentEvent():findParent(GameEvent.Turn)
    if turn_event ~= nil then
      turn_event:addCleaner(function()
        room:handleAddLoseSkills(player, skills)
      end)
      player.room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"))
      local cards = player:drawCards(n, chuanwu.name, "top", "@@yyfy_chuanwu-inhand")
      for _, id in ipairs(cards) do
        room:addTableMarkIfNeed(player, "yyfy_chuanwu", id)
      end
    end
  end,
}

chuanwu:addEffect(fk.Damage, chuanwu_spec)
chuanwu:addEffect(fk.Damaged, chuanwu_spec)

return chuanwu
