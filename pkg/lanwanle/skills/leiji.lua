local leiji = fk.CreateSkill {
  name = "lan__leiji",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["lan__leiji"] = "雷击",
  [":lan__leiji"] = "锁定技，当一名角色使用或打出【闪】或【闪电】时，其进行一次【闪电】判定。当一名角色的判定结果确定后，" ..
      "若结果为：黑色，你对一名角色造成2点雷电伤害；红色，你对一名角色造成1点雷电伤害并回复1点体力。",

  ["#lan__leiji-choose"] = "雷击：你可以对一名角色造成%arg点雷电伤害",

  ["$lan__leiji1"] = "雷击电闪，天下大变！",
  ["$lan__leiji2"] = "太平天术，一统天下！",
}

local judge_data = {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(leiji.name) and
        (data.card.trueName == "jink" or data.card.trueName == "lightning")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = target,
      reason = "lightning",
      pattern = ".|2~9|spade",
    }
    room:judge(judge)
    if target.dead then return end
    if judge:matchPattern() then
      room:damage {
        to = target,
        damage = 3,
        damageType = fk.ThunderDamage,
        skillName = "lightning_skill",
      }
    end
  end,
}

leiji:addEffect(fk.CardUsing, judge_data)
leiji:addEffect(fk.CardResponding, judge_data)

leiji:addEffect(fk.FinishJudge, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(leiji.name) and data.card
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = data.card.color == Card.Black and 2 or 1
    local to = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(false),
      min_num = 1,
      max_num = 1,
      prompt = "#lan__leiji-choose:::" .. x,
      skill_name = leiji.name,
      cancelable = true,
    })
    if to and #to == 1 then
      room:damage {
        from = player,
        to = to[1],
        damage = x,
        damageType = fk.ThunderDamage,
        skillName = leiji.name,
      }
    end
    if x == 2 or not player:isWounded() then return end
    room:recover({
      who = player,
      num = 1,
      recoverBy = player,
      skillName = leiji.name,
    })
  end,
})

return leiji