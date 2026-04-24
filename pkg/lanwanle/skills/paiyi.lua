local paiyi = fk.CreateSkill {
  name = "lan__paiyi",
  derived_piles = "lan__zhonghui_quan",
}

Fk:loadTranslationTable{
  ["lan__paiyi"] = "排异",
  [":lan__paiyi"] = "出牌阶段，你可以移去一张「权」,令一名角色摸X张牌，然后选择一项："..
  "1.对至多X名其他角色各造成1点伤害；2.令至多X名角色各回复1点体力（X为「权」数且至少为1）",
  ["lan__zhonghui_quan"] = "权",
  ["#lan__paiyi-invoke"] = "排异：请选择一张「权」移去",
  ["#lan__paiyi_draw"] = "排异：请选择一名角色摸%arg张牌",
  ["#lan__paiyi_choice"] = "排异：请选择一项效果",
  ["damage"] = "造成1点伤害",
  ["#lan__paiyi_damage"] = "排异：请选择至多%arg名其他角色造成伤害",
  ["#lan__paiyi_recover"] = "排异：请选择至多%arg名角色回复体力",
  ["$lan__paiyi1"] = "艾命不遵，死有余辜",
  ["$lan__paiyi2"] = "非我族类，其心必异",
}

paiyi:addEffect("active", {
  anim_type = "offensive",
  expand_pile = "lan__zhonghui_quan",
  prompt = "#lan__paiyi-invoke",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return #player:getPile("lan__zhonghui_quan") > 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(player:getPile("lan__zhonghui_quan"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local card = effect.cards[1]
    
    -- 移去选择的权
    room:moveCards({
      from = player,
      ids = {card},
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = paiyi.name,
    })
    
    local x = math.max(#player:getPile("lan__zhonghui_quan"), 1)
    
    --摸牌
    local drawTargets = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      prompt = "#lan__paiyi_draw:::"..x,
      skill_name = paiyi.name,
      cancelable = true})
    
    if #drawTargets == 0 then return end
    local drawTarget = drawTargets[1]
    if not drawTarget.dead then
      drawTarget:drawCards(x, paiyi.name)
    end
    
    --选择一项效果
    local choice = room:askToChoice(player, {
      choices = {"damage", "recover"},
      prompt = "#lan__paiyi_choice",
      skill_name = paiyi.name,
    })
    
    if choice == "damage" then
      --造成伤害
      local damageTargets = room:askToChoosePlayers(player, {
        targets = table.filter(room.alive_players, function(p) return p ~= drawTarget end),
        min_num = 0,
        max_num = x,
        prompt = "#lan__paiyi_damage:::"..x,
        skill_name = paiyi.name,
        cancelable = true
      })
      if #damageTargets > 0 then
        for _, p in ipairs(damageTargets) do
          if not p.dead then
            room:damage{
              from = player,
              to = p,
              damage = 1,
              skillName = paiyi.name,
            }
          end
        end
      end
    elseif choice == "recover" then
      -- 回复体力
      local recoverTargets = room:askToChoosePlayers(player, {
        targets = room.alive_players,
        min_num = 0,
        max_num = x,
        prompt = "#lan__paiyi_recover:::"..x,
        skill_name = paiyi.name,
        cancelable = true
      })
      if #recoverTargets > 0 then
        for _, p in ipairs(recoverTargets) do
          if not p.dead then
            room:recover{
              who = p,
              num = 1,
              recoverBy = player,
              skillName = paiyi.name,
            }
          end
        end
      end
    end
  end,
})

return paiyi