local zhenrao = fk.CreateSkill {
  name = "lan__zhenrao",
}

Fk:loadTranslationTable{
  ["lan__zhenrao"] = "震扰",
  [":lan__zhenrao"] = "当你使用牌指定其他角色为目标后，或当其他角色使用牌指定你为目标后，你可以选择"..
  "其中一个目标或使用者，对其造成1点伤害。",

  ["#lan__zhenrao-invoke"] = "震扰：是否对 %dest 造成1点伤害？",
  ["#lan__zhenrao-choose"] = "震扰：是否对其中一名角色造成1点伤害？",

  ["$lan__zhenrao1"] = "此病需静养，怎堪兵戈铁马之扰。",
  ["$lan__zhenrao2"] = "孤值有疾，竟为文家小儿所扰。",
  ["$lan__zhenrao3"] = "目有创，僵卧于榻上，逢骁将袭营，踏碎夜阑。",
  ["$lan__zhenrao4"] = "体弱难着铁衣，有杀贼之心而无力，恨也恨也！"
}

zhenrao:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(zhenrao.name) then
      if target == player then
        return data.firstTarget and data.to ~= player and
          table.find(data.use.tos, function (p)
            return not p.dead
          end)
      else
        return data.to == player and not target.dead
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    if target == player then
      targets = table.filter(data.use.tos, function (p)
        return not p.dead
      end)
    else
      targets = {target}
    end
    if #targets == 1 then
      if room:askToSkillInvoke(player, {
        skill_name = zhenrao.name,
        prompt = "#lan__zhenrao-invoke::"..targets[1].id,
      }) then
        event:setCostData(self, {tos = targets})
        return true
      end
    else
      local to = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#lan__zhenrao-choose",
        skill_name = zhenrao.name,
      })
      if #to > 0 then
        event:setCostData(self, {tos = to})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:damage{
      from = player,
      to = to,
      damage = 1,
      skillName = zhenrao.name,
    }
  end,
})

return zhenrao
