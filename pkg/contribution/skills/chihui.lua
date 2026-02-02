local chihui = fk.CreateSkill {
  name = "lan__chihui",
}

Fk:loadTranslationTable{
  ["lan__chihui"] = "炽灰",
  [":lan__chihui"] = "其他角色的回合开始时，你可以选择：1.弃置其区域里的一张牌；"..
  "2.将牌堆里的一张指定副类别的牌置入其装备区。若如此做，你可以先选择是否失去1点体力，"..
  "然后可以摸X张牌（X为你已损失的体力值）。",

  ["#lan__chihui-choice"] = "炽灰：对 %dest 执行一项",
  ["#lan__chihui-losehp"] = "炽灰：是否要失去1点体力？",

  ["lan__chihui_discard"] = "弃置%dest区域里的一张牌",
  ["lan__chihui_putequip"] = "将%arg置入%dest的装备区",

  ["$lan__chihui1"] = "愿舍身以照长夜，助父亲突破重围！",
  ["$lan__chihui2"] = "冷夜孤光，亦怀炽焰于心。",
  ["$lan__chihui3"] = "欲成王业，蜡炬成灰终无悔！",
  ["$lan__chihui4"] = "但为大魏社稷，又何顾此身！",
}

chihui:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(chihui.name) and target ~= player and not target.dead
  end,
  on_cost = function (self, event, target, player, data)
    local all_choices = {
      "WeaponSlot",
      "ArmorSlot",
      "DefensiveRideSlot",
      "OffensiveRideSlot",
      "TreasureSlot"
    }
    local subtypes = {
      Card.SubtypeWeapon,
      Card.SubtypeArmor,
      Card.SubtypeDefensiveRide,
      Card.SubtypeOffensiveRide,
      Card.SubtypeTreasure
    }
    
    local choices = {}
    for i = 1, 5, 1 do
      table.insert(choices, all_choices[i])
    end
    table.insert(all_choices, "Cancel")
    table.insert(choices, "Cancel")
    
    local choice = player.room:askToChoice(player, {
      choices = choices,
      skill_name = chihui.name,
      prompt = "#lan__chihui-choice::" .. target.id,
      all_choices = all_choices,
    })
    
    if choice ~= "Cancel" then
      event:setCostData(self, {tos = {target}, choice = choice})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local subtype = Util.convertSubtypeAndEquipSlot(event:getCostData(self).choice)
    local mapper = {
      [Card.SubtypeWeapon] = "weapon",
      [Card.SubtypeArmor] = "armor",
      [Card.SubtypeOffensiveRide] = "offensive_horse",
      [Card.SubtypeDefensiveRide] = "defensive_horse",
      [Card.SubtypeTreasure] = "treasure",
    }
    
    local all_choices = {
      "lan__chihui_discard::" .. target.id,
      "lan__chihui_putequip::" .. target.id .. ":" .. mapper[subtype],
    }
    local choices = {}
    
    if not target:isAllNude() then
      table.insert(choices, all_choices[1])
    end
    if target:hasEmptyEquipSlot(subtype) then
      table.insert(choices, all_choices[2])
    end
    
    if #choices == 0 then return false end
    
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = chihui.name,
      all_choices = all_choices,
    })
    
    if choice == all_choices[1] then
      local card = room:askToChooseCard(player, {
        target = target,
        flag = "hej",
        skill_name = chihui.name
      })
      room:throwCard(card, chihui.name, target, player)
    else
      local cards = table.filter(room.draw_pile, function(id)
        return Fk:getCardById(id).sub_type == subtype
      end)
      if #cards > 0 then
        room:moveCardIntoEquip(target, table.random(cards), chihui.name, false, player)
      end
    end
    
    -- 询问是否失去体力并摸牌
    if not player.dead then
      if room:askToSkillInvoke(player, {
        skill_name = chihui.name,
        prompt = "#lan__chihui-losehp",
      }) then
        room:loseHp(player, 1, chihui.name)

      end
    end
    if player.dead then return end
    local newLostHp = player:getLostHp()
    if room:askToSkillInvoke(player, {
      skill_name = chihui.name,
      prompt = "炽灰：是否要摸"..tostring(newLostHp).."张牌？" ,
    })  then
      if newLostHp > 0 then
        room:drawCards(player, newLostHp, chihui.name)
      end
    end
  end
})

return chihui