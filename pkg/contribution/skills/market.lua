local skill = fk.CreateSkill({
  name = "yyfy_market",
  tags = { Skill.Permanent },
})

local ok, CS = pcall(require, "packages.coins-system.csfs")

Fk:loadTranslationTable {
  ["yyfy_market"] = "市场",
  [":yyfy_market"] = "持恒技，你的所有技能变为持恒技。当你获得此技能后，令所有没有此技能的其他角色获得此技能。" ..
    "你拥有“包裹”，你视为拥有“包裹”内的技能且这些技能不会因为对局结束而失去。" ..
    "出牌阶段，你可以选择其他角色的一个技能，花费金币购买并将其放入包裹。出牌阶段可扔掉包裹技能。",

  ["@yyfy_market-count"] = "包裹",
  ["#yyfy_market-buy"] = "市场：选择要购买的技能",
  ["yyfy_market_choice"] = "市场：请选择操作",
  ["yyfy_market_buy"] = "收购技能",
  ["yyfy_market_throw"] = "丢弃技能",
}

-- 过滤可购买技能
local function getBuyableSkills(player)
  local skills = {}
  for _, skillName in ipairs(player:getSkillNameList()) do
    local s = Fk.skills[skillName]
    if s and not s.attached_equip and not skillName:endsWith("&") and not skillName:startsWith("#") and
        not s.cardSkill and s:isPlayerSkill() and skillName ~= skill.name then
      table.insertIfNeed(skills, skillName)
    end
  end
  return skills
end

-- 获得市场时，加载存档中的包裹技能
skill:addAcquireEffect(function (self, player)
  local data = player:getGlobalSaveState("yyfy_market") or {}
  data.skills = data.skills or {}
  player.room:setPlayerMark(player, "@yyfy_market-count", #data.skills)
  player.room:handleAddLoseSkills(player, table.concat(data.skills, "|"), nil, false, true)
  -- 将玩家所有技能标记为持恒技
  for _, s in ipairs(player.player_skills) do
    if s:isPlayerSkill(player, false) then
      table.insertIfNeed(s.skeleton.tags, Skill.Permanent)
    end
  end
  -- 全员获得市场
  local room = player.room
  for _, p in ipairs(room:getAllPlayers()) do
    if p ~= player and not p:hasSkill(skill.name, true) then
      room:handleAddLoseSkills(p, skill.name, skill.name)
    end
  end
end)

-- 主动技能（支持人机）
skill:addEffect("active", {
  name = "yyfy_market_act",
  anim_type = "control",
  prompt = "yyfy_market_choice",
  can_use = function(self, player)
    return player:hasSkill(skill.name)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local choice = room:askToChoice(player, {
      choices = { "yyfy_market_buy", "yyfy_market_throw" },
      skill_name = skill.name
    })
    if not choice then return end
    -- 购买技能，支持人机 AI
    if choice == "yyfy_market_buy" then
      local targets = room:getOtherPlayers(player)
      if #targets < 1 then return end

      -- 选择目标（玩家/人机都可以）
      local target = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 0,
        max_num = 1,
        skill_name = skill.name,
        prompt = "市场：请选择要购买技能的目标"
      })
      if #target == 0 then return end
      target = target[1]
      local skills = getBuyableSkills(target)
      if #skills < 1 then return end

      -- 选择技能
      local sname = room:askToChoice(player, {
        choices = skills,
        skill_name = skill.name,
        prompt = "#yyfy_market-buy"
      })
      if not sname then return end

      -- 价格（人机自动 1000）
      local price = 1000
      local coinsData = CS.GetcoinsData(player)
      local gold = coinsData.gold or 0
      -- 扣费
      if not ok or gold < price then
        room:doBroadcastNotify("ShowToast", "金币不足，无法购买")
        return
      end
      CS.ChangePlayerMoney(player, -price)
      CS.ChangePlayerMoney(target, price)

      -- 存档
      local data = player:getGlobalSaveState("yyfy_market") or {}
      data.skills = data.skills or {}
      table.insertIfNeed(data.skills, sname)
      player:saveGlobalState("yyfy_market", data)

      room:handleAddLoseSkills(player, sname, nil, false, true)
      room:setPlayerMark(player, "@yyfy_market-count", #data.skills)

      -- 丢弃技能
    elseif choice == "yyfy_market_throw" then
      local data = player:getGlobalSaveState("yyfy_market") or {}
      data.skills = data.skills or {}
      if #data.skills < 1 then return end

      local sname = room:askToChoice(player, {
        choices = data.skills,
        skill_name = skill.name,
        prompt = "选择要丢弃的技能"
      })
      if not sname then return end

      table.removeOne(data.skills, sname)
      player:saveGlobalState("yyfy_market", data)
      room:handleAddLoseSkills(player, "-" .. sname, nil, false, true)
      room:setPlayerMark(player, "@yyfy_market-count", #data.skills)
    end
  end
})

return skill