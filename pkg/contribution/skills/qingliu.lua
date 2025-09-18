local lan__qingliu = fk.CreateSkill{
  name = "lan__qingliu",
  frequency = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__qingliu"] = "清流",
  [":lan__qingliu"] = "锁定技，游戏开始时，你选择一个势力加入。出牌阶段限一次，或当有角色进入濒死状态时，你可以改变一名角色的势力。",

  ["#lan__qingliu-choose-kingdom"] = "清流：请选择一个势力",
  ["#lan__qingliu-choose-target"] = "清流：请选择一名角色改变其势力",
  ["#lan__qingliu-change"] = "%from 发动「清流」，将 %to 的势力变更为 %arg",

  ["$lan__qingliu1"] = "谁说这宦官，皆是大奸大恶之人？",
  ["$lan__qingliu2"] = "咱家要让这天下人知道，宦亦有贤。",
}

-- 获取所有可用势力
local function getAllKingdoms()
  local kingdoms = { "wei", "shu", "wu", "qun" }
    for _, g in pairs(Fk.generals) do
      if not g.total_hidden then
        table.insertIfNeed(kingdoms, g.kingdom)
      end
    end
  return kingdoms
end

-- 游戏开始时选择势力
lan__qingliu:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(lan__qingliu.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local kingdoms = getAllKingdoms()
    
    local kingdom = room:askToChoice(player, {
      choices = kingdoms,
      skill_name = lan__qingliu.name,
      prompt = "#lan__qingliu-choose-kingdom",
    })
    
    if kingdom ~= player.kingdom then
      room:changeKingdom(player, kingdom, true)
    end
  end,
})

-- 出牌阶段限一次改变势力
lan__qingliu:addEffect("active", {
  prompt = "#lan__qingliu-choose-target",
  card_num = 0,
  target_num = 1,
  max_phase_use_time = 1,
  target_filter = function(self, to_select, selected)
    return to_select:isAlive() and #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    
    local kingdoms = getAllKingdoms()
    table.removeOne(kingdoms, target.kingdom) -- 移除当前势力
    
    if #kingdoms == 0 then return end
    
    local newKingdom = room:askToChoice(player, {
      choices = kingdoms,
      skill_name = lan__qingliu.name,
      prompt = "#lan__qingliu-choose-kingdom",
    })
    
    if newKingdom ~= target.kingdom then
      room:changeKingdom(target, newKingdom, true)
      
      room:sendLog{
        type = "#lan__qingliu-change",
        from = player.id,
        to = {target.id},
        arg = newKingdom,
      }
    end
  end,
})

-- 当有角色进入濒死状态时改变势力
lan__qingliu:addEffect(fk.Dying, {
  global = true,
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self.name)
  end,
  on_cost = function(self, event, target, player, data)
    -- 询问是否改变势力
    local targetPlayer = player.room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = player.room:getAlivePlayers(),
      skill_name = lan__qingliu.name,
      prompt = "#lan__qingliu-choose-target",
      cancelable = true,
    })
    event:setCostData(self, {tos = targetPlayer})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event:getCostData(self).tos == nil then return end
    local to = event:getCostData(self).tos[1]
    -- 选择新势力
    local kingdoms = getAllKingdoms()
    table.removeOne(kingdoms, to.kingdom) -- 移除当前势力
    
    if #kingdoms == 0 then return end
    
    local newKingdom = room:askToChoice(player, {
      choices = kingdoms,
      skill_name = lan__qingliu.name,
      prompt = "#lan__qingliu-choose-kingdom",
    })
    
    if newKingdom ~= to.kingdom then
      room:changeKingdom(to, newKingdom, true)
      
      room:sendLog{
        type = "#lan__qingliu-change",
        from = to.id,
        to = {to.id},
        arg = newKingdom,
      }
    end
  end,
})

return lan__qingliu