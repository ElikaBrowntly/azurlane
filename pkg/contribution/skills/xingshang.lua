local mouXingshang = fk.CreateSkill({
  name = "lan__xingshang",
})

Fk:loadTranslationTable{
  ["lan__xingshang"] = "行殇",
  [":lan__xingshang"] = "当其他角色死亡时，你可以获得其所有牌。当一名角色受到伤害后（每回合限一次）" ..
  "或死亡时，你获得两枚“颂”标记（你至多拥有9枚“颂”标记）；出牌阶段限两次，你可选择一名角色" ..
  "并移去至少一枚“颂”令其执行对应操作：2枚，复原武将牌或摸三张牌；3枚，增加1点体力上限并回复1点体力，" ..
  "然后随机恢复一个已废除的装备栏；4枚，<a href='memorialize'>追思</a>一名已阵亡的角色"..
  "（你的武将牌上有〖行殇〗时方可选择此项），获得其武将牌上除主公技外的所有技能，然后你失去〖行殇〗。",

  ["memorialize"] = "#<b>追思</b>：被追思过的角色本局游戏不能再成为追思的目标。",
  ["#lan__xingshang"] = "放逐：你可选择一名角色，消耗一定数量的“颂”标记对其进行增益",
  ["$LanXingshang"] = "行殇",
  ["@lan__xingshang_song"] = "颂",
  ["@lan__xingshang_memorialized"] = "行殇",
  ["lan__xingshang_restore"] = "2枚：复原武将牌",
  ["lan__xingshang_draw"] = "2枚：摸三张牌",
  ["lan__xingshang_recover"] = "3枚：恢复体力与区域",
  ["lan__xingshang_memorialize"] = "4枚：追思一名已阵亡的角色",
  ["#xingshang-obtain"] = "行殇：是否获得 %dest 的所有牌？",

  ["$lan__xingshang1"] = "我的是我的，你的还是我的。",
  ["$lan__xingshang2"] = "纵是身死，仍要为我所用。",
  ["$lan__xingshang3"] = "汝九泉之下，定会感朕之情。",
  ["$lan__xingshang4"] = "众士出生入死，孤当敛而奠之。",
  ["$lan__xingshang5"] = "身既死兮神以灵，魂魄毅兮为鬼雄。"
}


mouXingshang:addEffect("active", {
  anim_type = "support",
  prompt = "#lan__xingshang",
  card_num = 0,
  min_target_num = 0,
  max_target_num = 1,
  interaction = function(self, player)
    local choiceList = {
      "lan__xingshang_restore",
      "lan__xingshang_draw",
      "lan__xingshang_recover",
      "lan__xingshang_memorialize",
    }
    local choices = {}
    local markValue = player:getMark("@lan__xingshang_song")
    if markValue > 1 then
      table.insertTable(choices, { choiceList[1], choiceList[2] })
    end
    if markValue > 2 then
      table.insert(choices, choiceList[3])
    end
    if markValue > 3 then
      if table.find(Fk:currentRoom().players, function(p)
        return p.dead and p.rest < 1 and not table.contains(Fk:currentRoom():getBanner("memorializedPlayers") or {}, p.id)
      end) then
        local skills = Fk.generals[player.general]:getSkillNameList()
        if player.deputyGeneral ~= "" then
          table.insertTableIfNeed(skills, Fk.generals[player.deputyGeneral]:getSkillNameList())
        end

        if table.find(skills, function(skillName) return skillName == mouXingshang.name end) then
          table.insert(choices, "lan__xingshang_memorialize")
        end
      end
    end

    return UI.ComboBox { choices = choices, all_choices = choiceList }
  end,
  times = function(self, player)
    return player.phase == Player.Play and 2 - player:usedEffectTimes(self.name, Player.HistoryPhase) or -1
  end,
  can_use = function(self, player)
    return player:usedEffectTimes(self.name, Player.HistoryPhase) < 2 and player:getMark("@lan__xingshang_song") > 1
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then
      return false
    end
    if self.interaction.data == "lan__xingshang_memorialize" then
      return false
    end

    return true
  end,
  feasible = function (self, player, selected, selected_cards, card)
    if self.interaction.data == "lan__xingshang_memorialize" then
      return #selected == 0
    else
      return #selected == 1
    end
  end,
  on_use = function(self, room, effect)
    ---@type string
    local skillName = self.name
    local player = effect.from
    local target = effect.tos[1]

    local choice = self.interaction.data
    if choice == "lan__xingshang_restore" then
      room:removePlayerMark(player, "@lan__xingshang_song", 2)
      target:reset()
    elseif choice:startsWith("lan__xingshang_draw") then
      room:removePlayerMark(player, "@lan__xingshang_song", 2)
      target:drawCards(3, skillName)
    elseif choice == "lan__xingshang_recover" then
      room:changeMaxHp(target, 1)
      room:removePlayerMark(player, "@lan__xingshang_song", 3)
      room:recover({
        who = target,
        num = 1,
        recoverBy = player,
        skillName = skillName,
      })
      if target.dead then return end

      if not target.dead and #target.sealedSlots > 0 then
        room:resumePlayerArea(target, {table.random(target.sealedSlots)})
      end
    elseif choice == "lan__xingshang_memorialize" then
      room:removePlayerMark(player, "@lan__xingshang_song", 4)

      local availablePlayers = table.map(table.filter(room.players, function(p)
        return not p:isAlive() and p.rest < 1 and not table.contains(room:getBanner('memorializedPlayers') or {}, p.id)
      end), Util.IdMapper)
      local toId
      local result = room:askToCustomDialog(player, {
        qml_path = "packages/mougong/qml/ZhuiSiBox.qml",
        skill_name = skillName,
        extra_data = { availablePlayers, "$LanXingshang" }
      })

      if result == "" then
        toId = table.random(availablePlayers)
      else
        toId = result.playerId
      end

      local to = room:getPlayerById(toId)
      local zhuisiPlayers = room:getBanner('memorializedPlayers') or {}
      table.insertIfNeed(zhuisiPlayers, to.id)
      room:setBanner('memorializedPlayers', zhuisiPlayers)
      local skills = Fk.generals[to.general]:getSkillNameList()
      if to.deputyGeneral ~= "" then
        table.insertTableIfNeed(skills, Fk.generals[to.deputyGeneral]:getSkillNameList())
      end
      skills = table.filter(skills, function(skill_name)
        local skill = Fk.skills[skill_name]
        local attachedKingdom = skill:getSkeleton().attached_kingdom or {}
        return not skill:hasTag(Skill.Lord) and not (#attachedKingdom > 0 and not table.contains(attachedKingdom, player.kingdom))
      end)
      if #skills > 0 then
        room:handleAddLoseSkills(player, table.concat(skills, "|"))
      end

      room:setPlayerMark(player, "@lan__xingshang_memorialized", to.deputyGeneral ~= "" and "seat#" .. to.seat or to.general)
      -- 修改：只失去行殇，不放逐和颂威
      room:handleAddLoseSkills(player, "-" .. skillName)
    end
  end,
})

local spec = function (self, event, target, player, data)
  player.room:addPlayerMark(player, "@lan__xingshang_song", math.min(2, 9 - player:getMark("@lan__xingshang_song")))
end

mouXingshang:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return
      player:hasSkill(mouXingshang.name) and
      player:getMark("@lan__xingshang_song") < 9 and
      player:usedEffectTimes(self.name) < 1 and
      data.to:isAlive()
  end,
  on_cost = Util.TrueFunc,
  on_use = spec,
})

mouXingshang:addEffect(fk.Death, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(mouXingshang.name) and player:getMark("@lan__xingshang_song") < 9
  end,
  on_cost = Util.TrueFunc,
  on_use = spec,
})

-- 添加原版行殇的效果：当其他角色死亡时，可以获得其所有牌
mouXingshang:addEffect(fk.Death, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(mouXingshang.name) and not target:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = mouXingshang.name,
      data,
      prompt = "#xingshang-obtain::"..target.id
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, target:getCardIds("he"), false, fk.ReasonPrey, player, mouXingshang.name)
    
    -- 播放原版行殇的音效
    player:broadcastSkillInvoke(mouXingshang.name, 3)
  end,
})

mouXingshang:addLoseEffect(function (self, player)
  player.room:setPlayerMark(player, "@lan__xingshang_song", 0)
end)

return mouXingshang