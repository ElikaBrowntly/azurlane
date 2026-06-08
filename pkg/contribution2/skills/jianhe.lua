local jianhe = fk.CreateSkill {
  name = "yyfy_jianhe",
}

Fk:loadTranslationTable {
  ["yyfy_jianhe"] = "剑合",
  [":yyfy_jianhe"] = "每回合每名角色限一次，出牌阶段，或当你成为牌的目标后，你可以重铸至少两张同名牌或装备牌，" ..
      "令一名角色选择一项：1.重铸等量张与之类型相同的牌；2.受到你造成的1点属性伤害。若指定了你自己，此技能视为未对其他角色发动过。",

  ["#yyfy_jianhe"] = "剑合：重铸至少两张同名牌，令一名角色选择重铸等量同类别牌或对其造成1点属性伤害",
  ["#yyfy_jianhe-choose"] = "剑合：你需重铸%arg张%arg2，否则受到1点属性伤害",

  ["$yyfy_jianhe1"] = "身临朝阙，腰悬太阿。",
  ["$yyfy_jianhe2"] = "位登三事，当配龙泉。",
}

local function spec(player, target, cards)
  local room = player.room
  room:addTableMark(player, "yyfy_jianhe-turn", target.id)
  local n, type = #cards, Fk:getCardById(cards[1]):getTypeString()
  room:recastCard(cards, player, jianhe.name)
  if target.dead then return end
  -- 若指定了自己，则已发动列表只剩自己
  if target == player then
    room:setPlayerMark(player, "yyfy_jianhe-turn", {player.id})
  end
  if #target:getCardIds("he") >= n then
    cards = room:askToCards(target, {
      min_num = n,
      max_num = n,
      include_equip = true,
      skill_name = jianhe.name,
      pattern = ".|.|.|.|.|" .. type,
      prompt = "#yyfy_jianhe-choose:::" .. n .. ":" .. type,
      cancelable = true,
    })
    if #cards > 0 then
      room:recastCard(cards, target, jianhe.name)
      return
    end
  end
  local choice = room:askToChoice(player, {
    choices = {"雷电伤害", "火焰伤害", "冰冻伤害"},
    skill_name = jianhe.name,
    prompt = "剑合：请选择该伤害的属性",
    cancelable = false
  })
  local t = {
    ["雷电伤害"] = fk.ThunderDamage,
    ["火焰伤害"] = fk.FireDamage,
    ["冰冻伤害"] = fk.IceDamage,
  }
  room:damage {
    from = player,
    to = target,
    damage = 1,
    damageType = t[choice],
    skillName = jianhe.name,
  }
end

jianhe:addEffect("active", {
  anim_type = "offensive",
  prompt = "#yyfy_jianhe",
  min_card_num = 2,
  target_num = 1,
  can_use = Util.TrueFunc,
  card_filter = function(self, player, to_select, selected)
    if #selected == 0 then
      return true
    else
      if Fk:getCardById(selected[1]).type == Card.TypeEquip then
        return Fk:getCardById(to_select).type == Card.TypeEquip
      end
      return Fk:getCardById(to_select).trueName == Fk:getCardById(selected[1]).trueName
    end
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and not table.contains(player:getTableMark("yyfy_jianhe-turn"), to_select.id)
  end,
  on_use = function(self, room, effect)
    spec(effect.from, effect.tos[1], effect.cards)
  end
})

-- --- 判断当前状态下能否继续选牌加入selected
-- ---@param cards Card[] 待选牌
-- ---@param selected Card[] 已选牌
-- ---@return boolean
-- local function canSelect(cards, selected)
--   -- 检查当前 selected 是否合法的函数
--   local function isValid(list)
--     if #list <= 1 then return true end
--     -- 检查是否全部同名
--     local firstName = list[1].name
--     local allSameName = true
--     for i = 2, #list do
--       if list[i].name ~= firstName then
--         allSameName = false
--         break
--       end
--     end
--     if allSameName then return true end
--     -- 检查是否全部是装备牌
--     for i = 1, #list do
--       if list[i].type ~= Card.TypeEquip then
--         return false
--       end
--     end
--     return true
--   end
--   -- 先检查当前 selected 是否合法
--   if not isValid(selected) then
--     return false
--   end
--   -- 尝试从 cards 中找一张牌，加入后仍然合法
--   for _, card in ipairs(cards) do
--     local newList = {}
--     for _, c in ipairs(selected) do
--       table.insert(newList, c)
--     end
--     table.insert(newList, card)
--     if isValid(newList) then
--       return true
--     end
--   end
--   return false
-- end

jianhe:addEffect(fk.TargetConfirmed, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and table.find(player.room:getAlivePlayers(), function(p)
      return not table.contains(player:getTableMark("yyfy_jianhe-turn"), p.id)
    end)
  end,
  -- on_cost = function(self, event, target, player, data)
  --   local room = player.room
  --   local ids = player:getCardIds(player, "he")
  --   local selected = {}
  --   local cards = {} ---@type Card[]
  --   for _, id in ipairs(ids) do
  --     table.insert(cards, Fk:getCardById(id))
  --   end
  --   if not canSelect(cards, selected) or not room:askToSkillInvoke(player, {
  --         skill_name = jianhe.name,
  --         prompt = "剑合：是否要重铸两张同名牌或装备牌"
  --       }) then
  --     return false
  --   end
  --   while canSelect(cards, selected) do
  --     local id = player.room:askToCards(player, {
  --       min_num = 1,
  --       max_num = 1,
  --       skill_name = jianhe.name,
  --       include_equip = true,
  --       prompt = "剑合：请逐张选牌，不要选择选过的牌或不符合条件的牌"
  --     })
  --     if not id or #id ~= 1 then return false end
  --     local card = Fk:getCardById(id[1])
  --     if table.contains(selected, card) then return false end
  --     table.removeOne(cards, card)
  --     table.insert(selected, card)
  --   end
  --   local targets = table.filter(room:getAlivePlayers(), function (p)
  --     return not table.contains(player:getTableMark("yyfy_jianhe-turn"), p.id)
  --   end)
  --   if #selected < 2 then return false end
  --   local tos = room:askToChoosePlayers(player, {
  --     targets = targets,
  --     min_num = 1,
  --     max_num = 1,
  --     cancelable = false,
  --     skill_name = jianhe.name,
  --     prompt = "剑合：请选择要重铸牌的角色"
  --   })
  --   if not tos or #tos ~= 1 then return false end
  --   event:setCostData(self, {tos = tos, cards = selected})
  --   return true
  -- end,
  on_use = function (self, event, target, player, data)
    -- local tos = (event:getCostData(self) or {}).tos or {}
    -- local cards = (event:getCostData(self) or {}).cards or {}
    -- if #tos ~= 1 or #cards < 2 then return end
    -- spec(player, tos[1], cards)
    player.room:askToUseActiveSkill(player, {
      skill_name = jianhe.name,
      cancelable = true
    })
  end
})

return jianhe