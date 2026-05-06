-- QingCaiTang.lua
-- 负面效果转换 + 神灭系列公共档案管理

local QingCaiTang = {}

-- ==================== 负面效果转换部分（原内容） ====================
local NilEvent = TriggerEvent:subclass("NilEvent")
QingCaiTang.QCBeforeLoseSkills = NilEvent:subclass("QC.BeforeLoseSkills")
QingCaiTang.QCBeforeAcquireSkills = NilEvent:subclass("QC.BeforeAcquireSkills")
QingCaiTang.QCBeforeInvalidateSkills = NilEvent:subclass("QC.BeforeInvalidateSkills")
QingCaiTang.QCAfterLoseSkills = NilEvent:subclass("QC.AfterLoseSkills")
QingCaiTang.QCAfterAcquireSkills = NilEvent:subclass("QC.AfterAcquireSkills")
QingCaiTang.QCAfterInvalidateSkills = NilEvent:subclass("QC.AfterInvalidateSkills")

Fk:loadTranslationTable{
  ["QC_negativeeffect_damage"] = "受到伤害",
  ["QC_negativeeffect_lostHp"] = "失去体力",
  ["QC_negativeeffect_lostMaxhp"] = "减体力上限",
  ["QC_negativeeffect_discard"] = "弃置牌",
  ["QC_negativeeffect_lostSkills"] = "失去技能",
  ["QC_negativeeffect_invalidateSkills"] = "无效技能",
  ["QC_negativeeffect_chain"] = "横置",
  ["QC_negativeeffect_turnover"] = "翻至背面",
}

local Room = require "lunarltk.server.room"
local handleAddLoseSkills_origin = Room.handleAddLoseSkills

Room.handleAddLoseSkills = function(self, player, skill_names, source_skill, sendlog, no_trigger)
  if type(skill_names) == "string" then
    skill_names = skill_names:split("|")
  end
  if #skill_names == 0 then return {} end
  if #skill_names == 1 and skill_names[1] == "-" then return {} end
  local room = player.room
  local handletable = {}
  local t = {}
  for _, s in ipairs(skill_names) do
    if #t > 0 and ((string.sub(t[1], 1, 1) == "-" and string.sub(s, 1, 1) ~= "-") or (string.sub(t[1], 1, 1) ~= "-" and string.sub(s, 1, 1) == "-")) then
      table.insert(handletable, table.simpleClone(t))
      t = {}
    end
    table.insert(t, s)
  end
  if #t > 0 then
    table.insert(handletable, table.simpleClone(t))
  end

  local ret = {}
  for _, ht in pairs(handletable) do
    local islost = string.sub(ht[1], 1, 1) == "-"
    local skills = islost and table.map(ht, function (s)
        return string.sub(s, 2, #s)
      end) or ht
    local sdata = {skills = skills, who = player}
    if not no_trigger then
      room.logic:trigger(islost and QingCaiTang.QCBeforeLoseSkills or QingCaiTang.QCBeforeAcquireSkills, player, sdata)
      if sdata.prevented then
        goto continue
      else
        table.insertTableIfNeed(ret, ht)
      end
    end
    handleAddLoseSkills_origin(self, player, ht, source_skill, sendlog, no_trigger)
    if not no_trigger and not player.room:getTag("QC_sanying_changingphase") then
      room.logic:trigger(islost and QingCaiTang.QCAfterLoseSkills or QingCaiTang.QCAfterAcquireSkills, player, sdata)
    end
    ::continue::
  end
  return ret
end

local invalidateSkill_origin = Room.invalidateSkill
Room.invalidateSkill = function(self, player, skill_name, temp, source_skill)
  local room = player.room
  temp = temp or ""
  source_skill = source_skill or skill_name
  local sdata = {who = player, skills = {skill_name}, mark = MarkEnum.InvalidSkills .. temp, source_skill = source_skill}
  room.logic:trigger(QingCaiTang.QCBeforeInvalidateSkills, player, sdata)
  if sdata.prevented then
    return
  end
  invalidateSkill_origin(self, player, skill_name, temp, source_skill)
  room.logic:trigger(QingCaiTang.QCAfterInvalidateSkills, player, sdata)
end

function QingCaiTang.savePlayerMarks(player)
  local marks = {}
  if MarkEnum then
    for name, _ in pairs(MarkEnum) do
      local v = player:getMark(name)
      if v ~= 0 then
        marks[name] = v
      end
    end
  end
  return marks
end

function QingCaiTang.restorePlayerMarks(player, marks)
  for mark, value in pairs(marks) do
    player:setMark(mark, value)
  end
end

function QingCaiTang.ConvertToNegativeData(event, player, data)
  local room = player.room
  local from = player
  local e = room.logic:getCurrentEvent()
  if e and e.event == GameEvent.SkillEffect then
    from = e.data.who
  end
  if table.contains({fk.AfterCardsMove, fk.BeforeCardsMove}, event) then
    local cards = {}
    for _, move in ipairs(data) do
      if move.from == player and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insert(cards, info.cardId)
          end
        end
      end
    end
    if #cards > 0 then
      e = e.parent
      if e then
        if e.event == GameEvent.SkillEffect then
          from = e.data.who
        elseif e.event == GameEvent.Death then
          from = e.data.who
        end
      end
      return {
        type = "discard",
        from = from,
        to = player,
        n = #cards,
        cards = cards,
        oridata = data
      }
    end
  elseif table.contains({fk.DamageInflicted, fk.DetermineDamageInflicted, fk.Damaged}, event) then
    if player == data.to then
      return {
        type = "damage",
        from = data.from,
        to = player,
        n = data.damage,
        damageType = data.damageType,
        oridata = data
      }
    end
  elseif table.contains({fk.PreHpLost, fk.HpLost}, event) then
    if player == data.who and not data.prevented then
      e = e.parent
      if e and e.event == GameEvent.SkillEffect then
        from = e.data.who
      end
      return {
        type = "lostHp",
        from = from,
        to = player,
        n = data.num,
        oridata = data
      }
    end
  elseif table.contains({fk.BeforeMaxHpChanged, fk.MaxHpChanged}, event) then
    if player == data.who and data.num < 0 and not data.prevented then
      e = e.parent
      if e and e.event == GameEvent.SkillEffect then
        from = e.data.who
      end
      return {
        type = "lostMaxhp",
        from = from,
        to = player,
        n = -data.num,
        oridata = data
      }
    end
  elseif table.contains({fk.BeforeChainStateChange, fk.ChainStateChanged}, event) then
    if player == data.who and not data.prevented then
      if player.chained == (event == fk.ChainStateChanged) then
        return {
          type = "chain",
          from = from,
          to = player,
          oridata = data
        }
      end
    end
  elseif table.contains({fk.BeforeTurnOver, fk.TurnedOver}, event) then
    if player == data.who and not data.prevented then
      if player.faceup == (event == fk.BeforeTurnOver) then
        return {
          type = "turnover",
          from = from,
          to = player,
          oridata = data
        }
      end
    end
  elseif table.contains({QingCaiTang.QCBeforeLoseSkills, QingCaiTang.QCAfterLoseSkills}, event) then
    if player == data.who and not data.prevented and data.skills[1] and Fk.skills[data.skills[1]]:isPlayerSkill(player) then
      return {
        type = "lostSkills",
        from = from,
        to = player,
        n = #data.skills,
        oridata = data
      }
    end
  elseif table.contains({QingCaiTang.QCBeforeInvalidateSkills, QingCaiTang.QCAfterInvalidateSkills}, event) then
    if player == data.who and not data.prevented then
      return {
        type = "invalidateSkills",
        from = from,
        to = player,
        oridata = data
      }
    end
  end
  return nil
end

function QingCaiTang.preventNegativeEffect(room, negdata)
  local type = negdata.type
  if type == "discard" then
    room:cancelMove(negdata.oridata, negdata.cards)
  elseif type == "damage" then
    negdata.oridata:preventDamage()
  else
    negdata.oridata.prevented = true
  end
end

function QingCaiTang.doNegativeEffect(to, type, skill_name, n, from, damageType)
  if to.dead then return end
  local room = to.room
  n = n or 1
  if type == "discard" then
    local cards = to:getCardIds("he")
    cards = table.random(cards, n)
    if #cards > 0 then
      room:throwCard(cards, skill_name, to, to)
    end
  elseif type == "damage" then
    room:damage{
      from = from,
      to = to,
      damage = n,
      damageType = damageType,
    }
  elseif type == "lostHp" then
    room:loseHp(to, n, skill_name)
  elseif type == "lostMaxhp" then
    room:changeMaxHp(to, -n)
  elseif type == "chain" then
    if not to.chained then
      to:setChainState(true)
    end
  elseif type == "turnover" then
    if to.faceup then
      to:turnOver()
    end
  elseif type == "lostSkills" then
    local skills = table.map(table.filter(to.player_skills, function(s)
      return s:isPlayerSkill(to) and s.visible
    end), function(s)
      return s.name
    end)
    if #skills > 0 then
      room:handleAddLoseSkills(to, "-" .. table.random(skills), nil, true, false)
    end
  elseif type == "invalidateSkills" then
    room:addSkill("QC__AllSkillsInvalidate")
    room:addPlayerMark(to, "QC__AllSkillsInvalidate-turn")
  end
end

function QingCaiTang.addBeforeNegativeEffect(skill, spec)
  for _, e in ipairs({ fk.BeforeCardsMove, fk.DetermineDamageInflicted, fk.PreHpLost, fk.BeforeMaxHpChanged, fk.BeforeChainStateChange, fk.BeforeTurnOver, QingCaiTang.QCBeforeLoseSkills, QingCaiTang.QCBeforeInvalidateSkills }) do
    skill:addEffect(e, spec)
  end
end

function QingCaiTang.addAfterNegativeEffect(skill, spec)
  for _, e in ipairs({ fk.AfterCardsMove, fk.Damaged, fk.HpLost, fk.MaxHpChanged,
    fk.ChainStateChanged, fk.TurnedOver, QingCaiTang.QCAfterLoseSkills, QingCaiTang.QCAfterInvalidateSkills }) do
    skill:addEffect(e, spec)
  end
end

return QingCaiTang