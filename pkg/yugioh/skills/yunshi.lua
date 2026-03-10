local yunshi = fk.CreateSkill {
  name = "yyfy_yunshi",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_yunshi"] = "陨石",
  [":yyfy_yunshi"] = "持恒技，其他角色在一个回合内至少第5次使用技能后，你可以令其将武将牌替换为"..
  "<a href = 'yyfy_yunshi-details'>陨石衍生物</a>。每局游戏限3次，每名角色限1次。",

  ["@yyfy_yunshi"] = "陨石已砸",
  ["@yyfy_yunshi-turn"] = "陨石",
  ["@@yyfy_yunshitoken"] = "已被砸",
  ["#yyfy_yunshi-invoke"] = "陨石：是否要令%dest将武将牌替换为陨石衍生物？",
  ["yyfy_yunshi-details"] = "<b>陨石衍生物 群 11/11</b><br><b>守表 </b>你出场后的第一个自己回合结束前，"..
  "不能使用伤害类牌。<br><br>若目标存在副将，将会移除其副将，将主将变更为陨石衍生物。"
}

local ok, U = pcall(require, "packages.offline.ofl_util")

yunshi:addEffect(fk.AfterSkillEffect, {
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    local to = data.who
    return player and player:hasSkill(self.name) and to ~= player and to and to:isAlive()
    and player:getMark("@yyfy_yunshi") < 3 and to:getMark("@@yyfy_yunshitoken") == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local to = data.who
    room:addPlayerMark(to, "@yyfy_yunshi-turn", 1)
    if to:getMark("@yyfy_yunshi-turn") < 5 then
      return false
    end
    if not room:askToSkillInvoke(player, {
      skill_name = yunshi.name,
      prompt = "#yyfy_yunshi-invoke::"..to.id
    }) then
      return false
    end
    room:setPlayerMark(to, "@@yyfy_yunshitoken", 1)
    room:notifySkillInvoked(player, yunshi.name, "big", {to})
    if to.deputyGeneral then
      room:removeDeputy(to, {})
    end
    room:changeHero(to, "yyfy_yunshitoken", false, false)
    room:addPlayerMark(player, "@yyfy_yunshi", 1)
    room:setPlayerMark(to, "@yyfy_yunshi-turn", 0)
  end
})

return yunshi