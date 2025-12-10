local yyfy_fangkong = fk.CreateSkill{
  name = "yyfy_fangkong",
  tags = {Skill.Compulsory},
  anim_type = "defensive",
}

Fk:loadTranslationTable{
  ["yyfy_fangkong"] = "防空",
  [":yyfy_fangkong"] = "锁定技，你成为其他角色使用牌的目标后，若其至你的距离大于1，你可令此牌无效。",
  
  ["#yyfy_fangkong-ask"] = "防空：是否令此牌无效？",
  ["#yyfy_fangkong-invalid"] = "%from 发动「防空」，使 %arg 无效",
  ["$yyfy_fangkong1"] = "这是爱的一击哦！",
  ["$yyfy_fangkong2"] = "啊疼疼疼！……但是，为了亲爱的，我是不会输的！",
}

yyfy_fangkong:addEffect(fk.TargetConfirmed, {
  on_cost = function(self, event, target, player, data)
    if data.from == player then return false end
    if data.from:distanceTo(player) <= 1 then return false end
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#yyfy_fangkong-ask",
    })
  end,
  on_use = function(self, event, target, player, data)
    data.use.nullifiedTargets = table.simpleClone(player.room.alive_players)
    player.room:sendLog{
      type = "#yyfy_fangkong-invalid",
      from = player.id,
      arg = data.card:toLogString(),
    }
    
    return true
  end,
})

return yyfy_fangkong