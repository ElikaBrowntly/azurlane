local jisi = fk.CreateSkill({
  name = "lan__jisi",
})

Fk:loadTranslationTable {
  ["lan__jisi"] = "羁肆",
  [":lan__jisi"] = "准备阶段，你可以令一名其他角色获得你的一个其他技能，" ..
      "然后你可以视为对一名角色使用一张无距离限制的【杀】。",

  ["$lan__jisi1"] = "心若野马，不系璇台。",
  ["$lan__jisi2"] = "唤渡鸳鸯浦，兰桡少驻，蛮姜豆蔻相思味。",
}

jisi:addEffect(fk.EventPhaseStart, {
  anim_type = "big",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player),
      min_num = 1,
      max_num = 1,
      skill_name = jisi.name,
      prompt = "羁肆：你可以令一名角色获得你的一个技能"
    })
    if #tos ~= 1 then return false end
    local costdata = event:getCostData(self) or {}
    costdata.tos = tos
    event:setCostData(self, costdata)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = (event:getCostData(self) or {}).tos
    if not tos or #tos ~= 1 then return end
    local skills = {}
    for _, s in ipairs(player:getSkillNameList()) do
      if s[#s] ~= "&" and s ~= jisi.name then
        table.insert(skills, s)
      end
    end
    if #skills > 0 then
      local result = room:askToCustomDialog(player, {
        skill_name = jisi.name,
        component = {
          url = "packages/utility/qml/ChooseSkillBox.qml",
          model = {
            url = "packages/utility/qml/models/ChooseSkillModel.qml",
            prop = {
              skills = skills,
              min = 0,
              max = 1,
              prompt = "羁肆：请选择1个技能令对方获得"
            }
          }
        }
      })
      room:handleAddLoseSkills(tos[1], result, jisi.name)
    end
    tos = room:askToChoosePlayers(player, {
      targets = room:getOtherPlayers(player),
      min_num = 1,
      max_num = 1,
      skill_name = jisi.name,
      prompt = "羁肆：你可以视为对一名角色使用一张【杀】"
    })
    if #tos ~= 1 then return end
    room:useVirtualCard("slash", nil, player, tos, jisi.name, true)
  end,
})

return jisi