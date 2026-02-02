local hongzhimoyan = fk.CreateSkill{
  name = "fate_hongzhimoyan",
  anim_type = "control",
  limit_mark = "@fate_hongzhimoyan_used-turn",
}

Fk:loadTranslationTable{
  ["fate_hongzhimoyan"] = "虹之魔眼",
  [":fate_hongzhimoyan"] = "出牌阶段限一次，你可以令任意名其他角色技能失效、受到的伤害+1"..
  "直到其下个回合结束。本回合内，你造成的伤害+1。",
  
  ["#fate_hongzhimoyan-choose"] = "虹之魔眼：请选择任意名其他角色",
  ["#fate_hongzhimoyan-add"] = "由于「虹之魔眼」的效果，%from 受到的伤害+%arg2",
  ["#fate_hongzhimoyan-add2"] = "由于「虹之魔眼」的效果，%from 造成的伤害+%arg2",
  ["@@fate_hongzhimoyan_nullify"] = "魔眼：技能封印",
  ["@@fate_hongzhimoyan_debuff"] = "魔眼：防御-1",
  ["@@fate_hongzhimoyan_self_damage-turn"] = "魔眼：攻击+1",

  ["$fate_hongzhimoyan1"] = "勇敢还是值得评价的。",
  ["$fate_hongzhimoyan2"] = "能承受吗？",
  ["$fate_hongzhimoyan3"] = "光，化为剑。",

}

hongzhimoyan:addEffect("active", {
  prompt = "#fate_hongzhimoyan-choose",
  card_num = 0,
  max_phase_use_time = 1,
  target_filter = function(self, player, to_select, selected)
    return to_select:isAlive() and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local targets = effect.tos
    
    -- 给使用者添加伤害+1标记
    room:setPlayerMark(player, "@@fate_hongzhimoyan_self_damage-turn", 1)
    
    -- 给目标添加技能失效和易伤标记
    for _, target in ipairs(targets) do
      room:setPlayerMark(target, "@@fate_hongzhimoyan_nullify", 1)
      room:setPlayerMark(target, "@@fate_hongzhimoyan_debuff", 1)
    end
  end,
})

-- 技能失效
hongzhimoyan:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    return from:getMark("@@fate_hongzhimoyan_nullify") > 0 and skill:isPlayerSkill(from)
  end,
})

-- 受伤+1
hongzhimoyan:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self.name) and
    data.to:getMark("@@fate_hongzhimoyan_debuff") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = target.room
    room:sendLog{
      type = "#fate_hongzhimoyan-add",
      from = target.id,
      arg = self.name,
      arg2 = 1
    }
    data:changeDamage(1)
  end,
})

-- 使用者造成伤害+1
hongzhimoyan:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self.name) and data.from and
    data.from:getMark("@@fate_hongzhimoyan_self_damage-turn") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:sendLog{
      type = "#fate_hongzhimoyan-add2",
      from = player.id,
      arg = self.name,
      arg2 = 1
    }
    data:changeDamage(1)
  end,
})

-- 在目标下个回合结束时清除标记
hongzhimoyan:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return target == player and (
      player:getMark("@@fate_hongzhimoyan_nullify") > 0 or
      player:getMark("@@fate_hongzhimoyan_debuff") > 0
    )
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@fate_hongzhimoyan_nullify", 0)
    room:setPlayerMark(player, "@@fate_hongzhimoyan_debuff", 0)
  end,
})

return hongzhimoyan