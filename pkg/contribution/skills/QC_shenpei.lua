local QC_shenpei = fk.CreateSkill{
  name = "QC_shenpei",
  tags = { Skill.Limited, Skill.Permanent },
}

Fk:loadTranslationTable{
  ["QC_shenpei"] = "神霈",
  [":QC_shenpei"] = "持恒技，限定技，你进入濒死时或出牌阶段，你可增加X点体力上限，回复X点体力值，摸X张牌（X为你本局游戏进入濒死的次数和你的体力上限之和且至少为9），然后对一名角色造成等量点伤害。",
  ["#QC_shenpei-invoke"] = "神霈：你可增加体力上限、回复体力并摸牌，然后对一名角色造成伤害",
  ["#QC_shenpei-choose"] = "神霈：选择一名其他角色，对其造成 %arg 点伤害",
}

local function calculateX(player)
  local room = player.room
  local dyingCount = 0
  room.logic:getEventsOfScope(GameEvent.Dying, 1, function(e)
    if e.data.who == player then
      dyingCount = dyingCount + 1
    end
  end, Player.HistoryGame)
  return math.max(dyingCount + player.maxHp, 9)
end

local function doShenpei(player)
  local room = player.room
  local num = calculateX(player)

  room:changeMaxHp(player, num)
  room:recover{
    who = player,
    num = num,
    recoverBy = player,
    skillName = QC_shenpei.name,
  }
  if player.dead then return end

  player:drawCards(num, QC_shenpei.name)
  if player.dead then return end

  local others = room:getOtherPlayers(player, false)
  if #others == 0 then return end

  local target = room:askToChoosePlayers(player, {
    min_num = 1,
    max_num = 1,
    targets = others,
    skill_name = QC_shenpei.name,
    prompt = "#QC_shenpei-choose:::" .. num,
    cancelable = false,
  })[1]

  room:damage{
    from = player,
    to = target,
    damage = num,
    skillName = QC_shenpei.name,
  }
end

QC_shenpei:addEffect(fk.EnterDying, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and
           player:hasSkill(QC_shenpei.name) and
           player:usedSkillTimes(QC_shenpei.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = QC_shenpei.name,
      prompt = "#QC_shenpei-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    doShenpei(player)
  end,
})

QC_shenpei:addEffect("active", {
  anim_type = "drawcard",
  target_num = 0,
  card_num = 0,
  can_use = function(self, player)
    return player:hasSkill(QC_shenpei.name) and
           player:usedSkillTimes(QC_shenpei.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    if not room:askToSkillInvoke(player, {
      skill_name = QC_shenpei.name,
      prompt = "#QC_shenpei-invoke",
    }) then return end
    doShenpei(player)
  end,
})

return QC_shenpei