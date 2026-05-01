local yinguo = fk.CreateSkill {
  name = "yyfy_yinguo",
  frequency = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_yinguo"] = "因果",
  [":yyfy_yinguo"] = "持恒技，出牌阶段，你可以变更一名角色的的势力或身份牌。"..
  "当游戏即将结束时，将你的身份牌变更为胜利方身份。",

  ["#yyfy_yinguo-choose-kingdom"] = "因果：请选择一个势力",
  ["#yyfy_yinguo-choose-target"] = "因果：请选择一名角色改变其势力或身份",
}

-- 获取所有可用势力
local function getAllKingdoms()
  local kingdoms = { "wei", "shu", "wu", "qun" }
  for _, g in pairs(Fk:getAllGenerals()) do
    if not g.total_hidden then
      table.insertIfNeed(kingdoms, g.kingdom)
    end
  end
  return kingdoms
end

--- 执行一次游戏结束判定
---@param room Room
local function gameOverJudge(room)
  local ps = room:getAlivePlayers()
  local winner = ""
  if not table.find(ps, function(p)  -- 没有主公的话
        return p.role == "lord"
      end) then                      -- 虽然不太可能改完势力只有一个活人，但还是写上以防万一
    winner = #ps == 1 and ps[1].role == "renegade" and "renegade" or "rebel"
  elseif not table.find(ps, function(p)
        return p.role == "rebel" or p.role == "renegade" -- 所有的反贼内奸都死亡
      end) then
    winner = "lord+loyalist+civilian"
  end
  if winner == "" then return end  -- 没决出胜负
  room:gameOver(winner)
end

-- 出牌阶段改变势力
yinguo:addEffect("active", {
  prompt = "#lan__qingliu-choose-target",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return to_select:isAlive() and #selected == 0
  end,
  interaction = function(self, player)
    return UI.ComboBox {
      choices = { "改变身份", "改变势力" }
    }
  end,
  can_use = Util.TrueFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local kingdoms = getAllKingdoms()
    local type = self.interaction.data
    if type == "改变身份" then
      target.role = room:askToChoice(player, {
        prompt = "因果：请选择要改为的身份",
        choices = { "lord", "loyalist", "rebel", "renegade" },
        cancelable = false
      })
      room:broadcastProperty(target, "role")
      gameOverJudge(room)
      return
    end
    table.removeOne(kingdoms, target.kingdom) -- 移除当前势力
    if #kingdoms == 0 then return end
    local newKingdom = room:askToChoice(player, {
      choices = kingdoms,
      skill_name = yinguo.name,
      prompt = "#yyfy_yinguo-choose-kingdom",
    })
    if newKingdom ~= target.kingdom then
      room:changeKingdom(target, newKingdom, true)
    end
    local mode = room:getSettings('gameMode')
    if mode == "yyfy_hegemony" or mode == "new_heg_mode" then
      local ps = room:getAlivePlayers()
      local winner = table.find(ps, function (p)
        return p.role ~= ps[1].role
      end) and ps[1].role or ""
      if winner ~= "" then
        room:gameOver(winner)
      end
    end
  end,
})

yinguo:addEffect(fk.GameFinished,{
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and player.room:victoryResult(data, player.role) ~= 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    if data == "" then
      data = player.role -- 没说要管队友，自私一点
      return
    end
    if table.contains(data:split("+"), "lord") or table.contains(data:split("+"), "loyalist") then
      player.role = "loyalist"
    elseif table.contains(data:split("+"), "rebel") then
      player.role = "rebel"
    elseif table.contains(data:split("+"), "renegade") then
      player.role = "renegade"
    end
    player.room:broadcastProperty(player, "role")
  end
})

return yinguo