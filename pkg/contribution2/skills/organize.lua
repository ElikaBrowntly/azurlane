local yyfy_organize = fk.CreateSkill{
  name = "yyfy_organize",
  tags = { Skill.Limited },
}

Fk:loadTranslationTable{
  ["yyfy_organize"] = "组织",
  [":yyfy_organize"] = "限定技，出牌阶段，你可以发动一次〖<a href=':zaowang'>造王</a>〗，并获得额外效果："..
  "若其为反贼，其获得一个额外回合；若其为内奸：其公开身份牌且杀死主公以外的角色时获胜。",

  ["#yyfy_organize"] = "组织：令一名角色加1点体力上限、回复1点体力并摸三张牌，根据其身份改变胜利条件！",
  ["@@yyfy_organize"] = "总经理",

  ["$yyfy_organize1"] = "大魏当兴，吾主可王。",
  ["$yyfy_organize2"] = "身加九锡，当君不让。",
}

yyfy_organize:addEffect("active", {
  anim_type = "control",
  prompt = "#yyfy_organize",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(yyfy_organize.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:setPlayerMark(target, "@@yyfy_organize", 1)
    local banner = room:getBanner(yyfy_organize.name) or {}
    if target.role == "loyalist" or target.role == "rebel" or target.role == "renegade" then
      banner[target.role] = banner[target.role] or {}
      table.insertIfNeed(banner[target.role], target.id)
    end
    room:setBanner(yyfy_organize.name, banner)
    room:changeMaxHp(target, 1)
    if target.dead then return end
    if target:isWounded() then
      room:recover{
        who = target,
        num = 1,
        recoverBy = player,
        skillName = yyfy_organize.name,
      }
      if target.dead then return end
    end
    target:drawCards(3, yyfy_organize.name)
    if target.role == "rebel" then
      target:gainAnExtraTurn(true, yyfy_organize.name)
    elseif target.role == "renegade" then
      room:setPlayerProperty(target, "role_shown", true)
      room:broadcastProperty(target, "role")
    end
  end,
})

yyfy_organize:addEffect(fk.GameOverJudge, {
  can_refresh = function(self, event, target, player, data)
    local banner = player.room:getBanner(yyfy_organize.name) or {}
    if table.contains(banner["loyalist"] or {}, player.id) then
      return not player.dead and target.role == "lord"
    elseif table.contains(banner["rebel"] or {}, player.id) then
      return target == player and data.killer and
        (data.killer.role == "lord" or data.killer.role == "loyalist")
    elseif table.contains(banner["renegade"] or {}, player.id) then
      return target.role ~= "lord" and data.killer.role == "renegade"
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local banner = room:getBanner(yyfy_organize.name) or {}
    if table.contains(banner["loyalist"] or {}, player.id) then
      room:setPlayerMark(player, "@@yyfy_organize", 0)
      player.role, target.role = target.role, player.role
      room:setPlayerProperty(player, "role_shown", true)
      room:setPlayerProperty(target, "role_shown", true)
      room:broadcastProperty(player, "role")
      room:broadcastProperty(target, "role")
    elseif table.contains(banner["rebel"] or {}, player.id) then
      room:gameOver("lord+loyalist")
    elseif table.contains(banner["renegade"] or {}, player.id) then
      room:gameOver("renegade")
    end
  end,
})

return yyfy_organize
