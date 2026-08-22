local pingxiang = fk.CreateSkill {
  name = "lan__pingxiang",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable {
  ["lan__pingxiang"] = "平襄",
  [":lan__pingxiang"] = "限定技，出牌阶段，你可以减少任意点体力上限，然后视为使用等量张火【杀】。" ..
      "若有角色因此进入濒死状态，则重置此技能。",

  ["#lan__pingxiang"] = "平襄：请减少任意点体力上限，视为使用等量张火【杀】",
  ["#lan__pingxiang-slash"] = "平襄：你可以视为使用火【杀】（第%arg张，共%arg2张）！",

  ["$lan__pingxiang1"] = "策马纵慷慨，捐躯抗虎豺。",
  ["$lan__pingxiang2"] = "解甲事仇雠，竭力挽狂澜。",
}

pingxiang:addEffect("active", {
  anim_type = "big",
  prompt = "#lan__pingxiang",
  card_num = 0,
  target_num = 0,
  interaction = function(self, player)
    return UI.Spin {
      from = 1,
      to = player.maxHp,
    }
  end,
  can_use = function(self, player)
    return player and player:usedSkillTimes(pingxiang.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local data = self.interaction.data or 0
    room:changeMaxHp(player, -data)
    if player.dead then return end
    for i = 1, data do
      if player.dead or not room:askToUseVirtualCard(player, {
        name = "fire__slash",
        skill_name = pingxiang.name,
        prompt = "#lan__pingxiang-slash:::" .. i..":"..data,
        cancelable = true,
        extra_data = {
          bypass_times = true,
          extraUse = true
        },
      }) then
        break
      end
    end
  end,
})

pingxiang:addEffect(fk.EnterDying, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self) and target ~= player and
    ((data.damage or {}).card or {}).skillName == pingxiang.name
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:clearSkillHistory(pingxiang.name)
  end,
})

return pingxiang