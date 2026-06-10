local tiangong = fk.CreateSkill{
  name = "lan__tiangong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__tiangong"] = "天公",
  [":lan__tiangong"] = "锁定技，一名角色的回合开始时，你视为使用一张【<a href=':thunder_god_help'>雷公助我</a>】；"..
  "一名角色的回合结束时，你视为使用一张【<a href=':sharing_risk'>有难同当</a>】。<br>"..
  "一名角色判定后，若为♠，你对另一名角色造成1点雷电伤害。",

  ["#lan__tiangong-choose"] = "天公：对另一名角色造成1点雷电伤害",

  ["$lan__tiangong1"] = "雷霆之威，可破万军之势！",
  ["$lan__tiangong2"] = "乱弃逆党，怎敢犯天公之威？",
}

tiangong:addEffect(fk.TurnStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(tiangong.name) and
      #Fk:cloneCard("thunder_god_help"):getAvailableTargets(player) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("thunder_god_help")
    card.skillName = tiangong.name
    local targets = card:getDefaultTarget(player)
    room:sortByAction(targets)
    room:useVirtualCard("thunder_god_help", nil, player, targets, tiangong.name)
  end,
})

tiangong:addEffect(fk.TurnEnd, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(tiangong.name) and
      #Fk:cloneCard("sharing_risk"):getAvailableTargets(player) > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:cloneCard("sharing_risk")
    card.skillName = tiangong.name
    local targets = card:getDefaultTarget(player)
    room:sortByAction(targets)
    room:useVirtualCard("sharing_risk", nil, player, targets, tiangong.name)
  end,
})

tiangong:addEffect(fk.FinishJudge, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(tiangong.name) and
      data.card and data.card.suit == Card.Spade and
      table.find(player.room.alive_players, function (p)
        return p ~= target
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function (p)
      return p ~= target
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = tiangong.name,
      prompt = "#lan__tiangong-choose",
      cancelable = false,
    })[1]
    room:damage{
      from = player,
      to = to,
      damage = 1,
      damageType = fk.ThunderDamage,
      skillName = tiangong.name,
    }
  end,
})

return tiangong