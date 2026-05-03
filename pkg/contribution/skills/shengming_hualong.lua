local shengming = fk.CreateSkill {
  name = "yyfy_hualong_shengming",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_hualong_shengming"] = "生命",
  [":yyfy_hualong_shengming"] = "持恒技，当你的体力值减少后，你获得等量个“生命”标记。" ..
      "出牌阶段，你可以消耗3个“生命”复活一名角色。当你死亡时，你可消耗5个“生命”复活。",

  ["@yyfy_hualong_shengming"] = "生命"
}

shengming:addEffect(fk.HpChanged, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.num < 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@yyfy_hualong_shengming", -data.num)
  end
})

shengming:addEffect("active", {
  anim_type = "support",
  max_phase_use_time = 1,
  card_num = 0,
  target_num = 0,
  prompt = "生命：你可以令一名角色复活",
  can_use = function(self, player)
    if player:getMark("@yyfy_hualong_shengming") < 3 then return false end
    local players = Fk:currentRoom().players
    local targets = {}
    for _, p in ipairs(players) do
      if p.dead then
        table.insert(targets, p)
      end
    end
    return #targets > 0
  end,
  interaction = function(self, player)
    local players = Fk:currentRoom().players
    local targets = {}
    for _, p in ipairs(players) do
      if p.dead then
        table.insert(targets, tostring(p.seat) .. "号位")
      end
    end
    return UI.ComboBox {
      choices = targets,
      default_choice = "",
    }
  end,
  on_use = function(self, room, data)
    local choice = self.interaction.data
    if choice == "" then return end
    local seat = tonumber(choice[1])
    if not seat then return end
    room:addPlayerMark(data.from, "@yyfy_hualong_shengming", -3)
    local target = room:getPlayerBySeat(seat)
    room:revivePlayer(target, true, shengming.name)
    if target.maxHp <= 0 then -- 不要出现0上限的僵尸
      room:changeMaxHp(target, target:getGeneralMaxHp() - target.maxHp)
    end
  end
})

shengming:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  priority = 3, -- 应该晚于〖造化〗，早于〖化龙〗
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and player:getMark("@yyfy_hualong_shengming") > 4
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
          skill_name = shengming.name,
          prompt = "生命：是否要消耗5个“生命”标记复活？"
        }) then
      room:addPlayerMark(player, "@yyfy_hualong_shengming", -5)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    room:revivePlayer(player, true, shengming.name)
  end
})

return shengming