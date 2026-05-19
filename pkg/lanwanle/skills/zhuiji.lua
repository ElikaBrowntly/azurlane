local zhuiji = fk.CreateSkill {
  name = "lan__zhuiji",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["lan__zhuiji"] = "追击",
  [":lan__zhuiji"] = "锁定技，你与其他角色的距离始终为1。当你使用【杀】指定目标后，其弃置一张手牌和装备区里的所有牌。",

  ["#lan__zhuiji-discard"] = "追击：请弃置一张手牌",
  ["$lan__zhuiji1"] = "灭族之恨，不共戴天！",
  ["$lan__zhuiji2"] = "休想跑！",
}

zhuiji:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhuiji.name) and data.card.trueName == "slash" and
        not data.to.dead and not data.to:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player, { data.to })
    local equips = data.to:getCardIds("e")
    if not data.to:isKongcheng() then
      room:askToDiscard(data.to, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = zhuiji.name,
        prompt = "#lan__zhuiji-discard",
        cancelable = false,
      })
    end
    if #equips > 0 then
      room:throwCard(equips, zhuiji.name, data.to, player)
    end
  end,
})

zhuiji:addEffect("distance", {
  fixed_func = function(self, from, to)
    if from:hasSkill(zhuiji.name) then
      return 1
    end
  end,
})

return zhuiji