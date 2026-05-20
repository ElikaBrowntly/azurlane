local jizhan = fk.CreateSkill {
  name = "lan__jizhan",
  tags = { Skill.Combo },
}

Fk:loadTranslationTable{
  ["lan__jizhan"] = "极斩",
  [":lan__jizhan"] = "连招技（装备牌+黑色牌）你选择一项：1.弃置其他角色共计至多X张牌；2.对一名其他角色造成X点伤害，" ..
  "（X为你本回合发动过“极斩”的次数）。",

  ["lan__jizhan_discard"] = "弃置其他角色共计至多%arg张牌",
  ["lan__jizhan_damage"] = "对一名其他角色造成%arg点伤害",
  ["#lan__jizhan-choose"] = "极斩：你可以依次选择角色，弃置该角色的牌（共计至多%arg张，还剩%arg2张）",
  ["#lan__jizhan-discard"] = "极斩：弃置 %dest 至多%arg张牌",
  ["#lan__jizhan-damage"] = "极斩：请选择一名其他角色，对其造成%arg点伤害",
  ["@@lan__jizhan"] = "极斩 +黑色牌",

  ["$lan__jizhan1"] = "祁连雪未销，战功簿已满！",
  ["$lan__jizhan2"] = "吾不畏死，又岂畏战！",
}

jizhan:addEffect(fk.CardUsing, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return
      target == player and
      player:hasSkill(jizhan.name) and
      data.card.color == Card.Black and
      (data.extra_data or {}).combo_skill and
      data.extra_data.combo_skill[jizhan.name]
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    ---@type string
    local skillName = jizhan.name
    local room = player.room
    room:setPlayerMark(player, "@@lan__jizhan", 0)

    local others = room:getOtherPlayers(player, false)
    if #others == 0 then
      return false
    end

    local usedTimes = player:usedSkillTimes(skillName)
    local choices = { "lan__jizhan_discard:::" .. usedTimes, "lan__jizhan_damage:::" .. usedTimes }
    local allChoices = table.simpleClone(choices)
    if not table.find(others, function(p) return not p:isNude() end) then
      table.remove(choices, 1)
    end

    local choice = room:askToChoice(
      player,
      {
        choices = choices,
        skill_name = skillName,
        all_choices = allChoices,
      }
    )

    if choice:startsWith("lan__jizhan_discard") then
      local total = usedTimes
      local n = total

      repeat
        local targets = table.filter(room:getOtherPlayers(player, false), function(p)
          return not p:isNude()
        end)
        if #targets == 0 then
          break
        end

        targets = room:askToChoosePlayers(
          player,
          {
            targets = targets,
            min_num = 1,
            max_num = 1,
            prompt = "#lan__jizhan-choose:::" .. total .. ":" .. n,
            skill_name = skillName,
            cancelable = true,
          }
        )
        if #targets == 0 then
          break
        end

        local to = targets[1]
        local cards = room:askToChooseCards(player, {
          target = to,
          min = 1,
          max = n,
          flag = "he",
          skill_name = skillName,
          prompt = "#lan__jizhan-discard::" .. to.id .. ":" .. n,
        })
        room:throwCard(cards, skillName, to, player)
        n = n - #cards
        if n <= 0 then
          break
        end
      until total == 0 or not player:isAlive()
    else
      local tos = room:askToChoosePlayers(
        player,
        {
          targets = others,
          min_num = 1,
          max_num = 1,
          prompt = "#lan__jizhan-damage:::" .. usedTimes,
          skill_name = skillName,
          cancelable = true,
        }
      )

      if #tos == 0 then
        return
      end

      room:damage{
        from = player,
        to = tos[1],
        damage = usedTimes,
        skillName = skillName,
      }
    end
  end,
})

jizhan:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function (self, event, target, player, data)
    return target == player and player:hasSkill(jizhan.name, true)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if player:getMark("@@lan__jizhan") > 0 and data.card.color == Card.Black then
      data.extra_data = data.extra_data or {}
      data.extra_data.combo_skill = data.extra_data.combo_skill or {}
      data.extra_data.combo_skill[jizhan.name] = true
    end
    if data.card.type == Card.TypeEquip then
      room:setPlayerMark(player, "@@lan__jizhan", 1)
    else
      room:setPlayerMark(player, "@@lan__jizhan", 0)
    end
  end,
})

jizhan:addLoseEffect(function (self, player)
  player.room:setPlayerMark(player, "@@lan__jizhan", 0)
end)

return jizhan