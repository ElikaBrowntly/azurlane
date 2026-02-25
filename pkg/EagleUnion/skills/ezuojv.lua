local ezuojv = fk.CreateSkill{
  name = "yyfy_ezuojv",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_ezuojv"] = "恶作剧",
  [":yyfy_ezuojv"] = "你不因此技能而使用【杀】后，可以视为对相同目标再使用一张【杀】，若造成了伤害，你可以"..
  "令其获得〖燃殇〗并对其造成1点火焰伤害。每局游戏你第一次使用【杀】结算结束后，你造成的伤害+1。",

  ["$yyfy_ezuojv1"] = "今天~捉弄~谁~好呢~♪",
  ["$yyfy_ezuojv2"] = "在看哪儿呢，是这边唷~"
}

ezuojv:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    return data.from == player and player:hasSkill(self) and data.card.trueName == "slash"
     and data.card.skillName ~= ezuojv.name
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local target_ids = {}
    for _, to in ipairs(data.tos) do
      table.insert(target_ids, to.id)
    end
    local extra_data = {
      must_targets = target_ids,
      exclusive_targets = target_ids,
      fix_targets = target_ids,
      skillName = ezuojv.name
    }
    local use = room:askToUseVirtualCard(player, {
      name = "slash",
      skill_name = ezuojv.name,
      prompt = "恶作剧：是否要对相同目标再使用一张【杀】？",
      cancelable = true,
      extra_data = extra_data,
    })
    if player.tag[ezuojv.name] == nil then
      player.tag[ezuojv.name] = true
    end
  end
})

ezuojv:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    if not (target == player and data.card and data.card.name == "slash" and
      data.card.skillName == ezuojv.name and data.card:isVirtual() and data.damageDealt) then
      return false
    end
    for _, to in ipairs(data.tos) do
      if to:isAlive() then
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = ezuojv.name,
      prompt = "恶作剧：是否要令目标获得〖燃殇〗并对其造成1点火焰伤害？"
    })
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    for _, to in ipairs(data.tos) do
      room:handleAddLoseSkills(to, "ranshang", ezuojv.name)
      room:damage{
        from = player,
        to = to,
        damage = 1,
        damageType = fk.FireDamage,
        skillName = ezuojv.name,
      }
    end
  end,
})

ezuojv:addEffect(fk.DamageCaused, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(self, true) and player.tag[ezuojv.name]
  end,
  on_refresh = function (self, event, target, player, data)
    data.damage = data.damage + 1
  end
})

return ezuojv