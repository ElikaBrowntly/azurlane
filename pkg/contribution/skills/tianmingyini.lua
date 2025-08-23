local tianmingyini = fk.CreateSkill{
  name = "tianmingyini",
}

Fk:loadTranslationTable{
  ["tianmingyini"] = "天命已拟",
  [":tianmingyini"] = "当你受到伤害时，若伤害来源有「处决」，你可以防止此伤害并令其失去所有「处决」；"
  .."否则你可以对其造成1点伤害。",
  
  ["#tianmingyini-prevent"] = "天命已拟：是否防止此伤害并移除其所有「处决」？",
  ["#tianmingyini-damage"] = "天命已拟：是否对伤害来源造成1点伤害？",

  ["#TianmingyiniPrevent"] = "%from 发动了「%arg」，防止了来自 %to 的伤害并移除了其所有「处决」标记",
  ["#TianmingyiniDamage"] = "%from 发动了「%arg」，对 %to 造成了1点伤害",
}

tianmingyini:addEffect(fk.DetermineDamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.from and not data.from.dead
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local source = data.from
    if source == nil then return false end

    if source:getMark("@chujue") > 0 then

      return room:askToSkillInvoke(player, {
        skill_name = self.name, data, "#tianmingyini-prevent"})
    else

      return room:askToSkillInvoke(player, {
        skill_name = self.name, data, "#tianmingyini-damage"})
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local source = data.from
    if source == nil then return false end

    if source:getMark("@chujue") > 0 then

      data.damage = 0
      room:setPlayerMark(source, "@chujue", 0)
      room:sendLog{
        type = "#TianmingyiniPrevent",
        from = player.id,
        to = {source.id},
        arg = self.name,
      }
    else

      room:damage{
        from = player,
        to = source,
        damage = 1,
        skillName = self.name,
      }
      room:sendLog{
        type = "#TianmingyiniDamage",
        from = player.id,
        to = {source.id},
        arg = self.name,
      }
    end
  end,
})

return tianmingyini