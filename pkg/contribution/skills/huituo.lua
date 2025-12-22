local huituo = fk.CreateSkill {
  name = "lan__huituo",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["lan__huituo"] = "恢拓",
  [":lan__huituo"] = "持恒技，当你受到伤害后，你可以进行判定，然后指定一名角色，若结果为："..
  "红色，其回复X点体力；黑色，其摸X张牌（X为伤害值）。",

  ["#lan__huituo-judge"] = "恢拓：请进行判定",
  ["#lan__huituo-choose"] = "恢拓：请选择一名角色，红色其回复%arg点体力，黑色其摸%arg张牌",

  ["$lan__huituo1"] = "大展宏图，就在今日！",
  ["$lan__huituo2"] = "富我大魏，扬我国威！",
}

huituo:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = self.name,
      prompt = "#lan__huituo-judge",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local damage = data.damage
    
    -- 先进行判定
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    
    -- 根据判定结果选择目标
    local prompt = "#lan__huituo-choose:::"..damage
    local to = room:askToChoosePlayers(player, {
      skill_name = self.name,
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      prompt = prompt,
      cancelable = false,
    })
    
    if #to == 0 then return end
    local targetPlayer = to[1]
    
    if targetPlayer.dead then return end
    
    if judge.card.color == Card.Red then
      -- 红色：回复X点体力
      room:recover{
        who = targetPlayer,
        num = damage,
        recoverBy = player,
        skillName = self.name,
      }
    elseif judge.card.color == Card.Black then
      -- 黑色：摸X张牌
      targetPlayer:drawCards(damage, self.name)
    end
  end,
})

return huituo