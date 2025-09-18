local fensi = fk.CreateSkill {
  name = "lan__fensi",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["lan__fensi"] = "忿肆",
  [":lan__fensi"] = "持恒技，准备阶段，你对一名角色造成1点伤害；若该角色不为你，你可令其视为对你使用一张【杀】。",

  ["#lan__fensi-choose"] = "忿肆：你须对一名角色造成1点伤害，若不为你，可令其对你使用【杀】",

  ["$lan__fensi1"] = "此贼之心，路人皆知！",
  ["$lan__fensi2"] = "孤君烈忿，怒愈秋霜。",
}

fensi:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  on_cost = function(self, event, target, player, data)
    return target == player and player:hasSkill(fensi.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = room.alive_players,
      min_num = 1,
      max_num = 1,
      prompt = "#lan__fensi-choose",
      skill_name = fensi.name,
      cancelable = false,
    })[1]
    room:damage{
      from = player,
      to = to,
      damage = 1,
      skillName = fensi.name,
    }
    if not to.dead and not player.dead and to ~= player then
      if room:askToChoice(player, {
      skill_name = self.name,
      choices = {"确定", "取消"},
      prompt = "是否令"..tostring(to).."视为对你使用一张【杀】？"
      }) == "确定" then
        room:useVirtualCard("slash", nil, to, player, fensi.name, true)
      end
    end
  end,
})

return fensi
