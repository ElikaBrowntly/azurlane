local yyfy_miyu = fk.CreateSkill{
  name = "yyfy_miyu",
}

Fk:loadTranslationTable{
  ["yyfy_miyu"] = "谜语",
  [":yyfy_miyu"] = "出牌阶段，你可以秘密选择一个1到3之间的数字，令一名其他角色进行猜测。若猜对，其可以摸两张牌或回复一点体力，然后此阶段本技能失效；否则你可以摸两张牌或令其失去一点体力",
  
  ["#yyfy_miyu-choose"] = "谜语：请选择一名其他角色",
  ["#yyfy_miyu-number"] = "谜语：请秘密选择一个数字（1-3）",
  ["#yyfy_miyu-guess"] = "谜语：请猜测一个数字（1-3）",
  ["#yyfy_miyu-success"] = "你猜出了谜语人的心思！请选择一项奖励",
  ["#yyfy_miyu-fail"] = "对方没有领悟到真意！请选择一项",
  ["yyfy_miyu_draw2"] = "摸两张牌",
  ["yyfy_miyu_recover"] = "回复1点体力",
  ["yyfy_miyu_losehp"] = "令其失去1点体力",
}

-- 秘密选择数字并让其他角色猜测
yyfy_miyu:addEffect("active", {
  prompt = "#yyfy_miyu-choose",
  card_num = 0,
  target_num = 1,
  target_filter = function(self, player, to_select, selected)
    return to_select:isAlive() and to_select ~= player and #selected == 0
  end,
  can_use = function (self, player)
    return player:getMark("yyfy_miyu_used-phase") == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    
    -- 1. 秘密选择一个数字（1-3）
    local number_choices = {"1", "2", "3"}
    local secret_number = room:askToChoice(player, {
      choices = number_choices,
      skill_name = self.name,
      prompt = "#yyfy_miyu-number",
    })
    
    if not secret_number then return end
    
    -- 2. 让目标角色猜测数字
    local guess_number = room:askToChoice(target, {
      choices = number_choices,
      skill_name = self.name,
      prompt = "#yyfy_miyu-guess",
    })
    
    if not guess_number then return end
    
    -- 3. 判断猜测结果
    if guess_number == secret_number then
      -- 猜对了
      local choices = {
        "yyfy_miyu_draw2",
        "yyfy_miyu_recover"
      }
      
      -- 如果目标没有受伤，则不能选择回复体力
      if not target:isWounded() then
        table.removeOne(choices, "yyfy_miyu_recover")
      end
      
      local choice = room:askToChoice(target, {
        choices = choices,
        skill_name = self.name,
        prompt = "#yyfy_miyu-success",
        all_choices = {"yyfy_miyu_draw2", "yyfy_miyu_recover"}
      })
      
      if choice == "yyfy_miyu_draw2" then
        target:drawCards(2, self.name)
      elseif choice == "yyfy_miyu_recover" then
        room:recover{
          who = target,
          num = 1,
          recoverBy = target,
          skillName = self.name,
        }
      end
      
      -- 此阶段本技能失效
      room:addPlayerMark(player, "yyfy_miyu_used-phase", 1)
      
    else
      -- 猜错了
      local choices = {
        "yyfy_miyu_draw2",
        "yyfy_miyu_losehp"
      }
      
      local choice = room:askToChoice(player, {
        choices = choices,
        skill_name = self.name,
        prompt = "#yyfy_miyu-fail",
        all_choices = {"yyfy_miyu_draw2", "yyfy_miyu_losehp"}
      })
      
      if choice == "yyfy_miyu_draw2" then
        player:drawCards(2, self.name)
      elseif choice == "yyfy_miyu_losehp" then
        room:loseHp(target, 1, self.name)
      end
    end
  end,
})

-- 阶段结束时清除技能失效标记
yyfy_miyu:addEffect(fk.EventPhaseEnd, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("yyfy_miyu_used-phase") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "yyfy_miyu_used-phase", 0)
  end,
})

return yyfy_miyu