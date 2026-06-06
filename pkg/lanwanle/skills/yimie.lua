local yimie = fk.CreateSkill{
  name = "lan__yimie",
}

Fk:loadTranslationTable{
  ["lan__yimie"] = "夷灭",
  [":lan__yimie"] = "当你对其他角色造成伤害时，你可以令此伤害值+X（X为其体力值减去伤害值）。",

  ["#lan__yimie-invoke"] = "夷灭：你可以令你对 %dest 造成的伤害增加至其体力值！",

  ["$lan__yimie1"] = "汝大逆不道，当死无赦！",
  ["$lan__yimie2"] = "斩草除根，灭其退路！",
  ["$lan__yimie3"] = "夷此僚三族，以儆效尤！",
  ["$lan__yimie4"] = "逆我司马氏者，罪无可恕！",
}

yimie:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yimie.name) and
      data.to ~= player and data.to.hp > data.damage
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = yimie.name,
      prompt = "#lan__yimie-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data:changeDamage(data.to.hp - data.damage)
  end,
})

yimie:addAI(Fk.Ltk.AI.newInvokeStrategy{
  think = function(self, ai)
    local to = ai.data.to
    return to and ai:isEnemy(to)
  end,
})

return yimie