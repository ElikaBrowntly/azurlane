local gonglue = fk.CreateSkill {
  name = "yyfy_gonglue",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_gonglue"] = "攻略",
  [":yyfy_gonglue"] = "持恒技，获得此技能时，你开启一条<a href='yyfy_gonglue-mingyunxian'><font color='#8300FF'>" ..
      "穗织命运线</font></a>。你将在其中作出若干选择，合理的选择将为你解锁一名可攻略角色；你拥有已解锁角色的所有技能。" ..
      "出牌阶段限一次，你可以开启一条穗织命运线。",

  ["yyfy_gonglue-mingyunxian"] = "<br>一种恋爱文字冒险游戏（galgame），在分歧点进行选择，从而进入可攻略角色的个人路线，" ..
      "并达成相应结局。<br><br>目前的可攻略角色有：朝武芳乃，常陆茉子，丛雨，蕾娜。<br><br>点击角色的“已攻略”标记，可查看当前解锁的角色。",
  ["@&yyfy_gonglue"] = "已攻略"
}

Fk:addMiniGame {
  name = "Qianlian＊Wanhua",
  qml_path = "packages/hidden-clouds/qml/Qianlian＊WanhuaBox",
  default_choice = function(player, data)
    return "false"
  end,
  update_func = function(player, data)
    for _, p in ipairs(player.room.players) do
      p:doNotify("UpdateMiniGame", data)
    end
  end,
}

local function buildDataTable(player)
  local room = player.room
  local alive = room:getAlivePlayers(false)
  local data_table = {}
  for _, p in ipairs(alive) do
    data_table[p.id] = {
      can = (p == player and 1 or 0),
    }
  end
  return data_table
end

gonglue:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local unlocked = player:getTableMark("@&yyfy_gonglue")
    local req = room:askToMiniGame(room:getAlivePlayers(false), {
      skill_name = gonglue.name,
      game_type = "Qianlian＊Wanhua",
      data_table = buildDataTable(player),
      timeout = 60
    })
    room:delay(2000)
    local character = req:getResult(player) ---@type string
    if character ~= "false" then
      room:doBroadcastNotify("ShowToast", "恭喜你解锁了 <font color='red'>"..Fk:translate(character).."</font>")
      table.insertIfNeed(unlocked, req:getResult(player))
      room:handleAddLoseSkills(player, Fk.generals[character]:getSkillNameList())
    else
      room:doBroadcastNotify("ShowToast", "<font color='red'>单身结局：</font>你只得到了好基友鞍马廉太郎")
    end
    room:setPlayerMark(player, "@&yyfy_gonglue", unlocked)
  end
})

gonglue:addEffect("active", {
  can_use = function(self, player)
    return player and player:hasSkill(self) and player:usedSkillTimes(gonglue.name, Player.HistoryPhase) == 0
  end,
  target_num = 0,
  target_filter = Util.FalseFunc,
  card_num = 0,
  card_filter = Util.FalseFunc,
  prompt = "攻略：你可以开启一条穗织命运线",
  on_use = function(self, room, effect)
    local player = effect.from
    local unlocked = player:getTableMark("@&yyfy_gonglue")
    local req = room:askToMiniGame(room:getAlivePlayers(false), {
      skill_name = gonglue.name,
      game_type = "Qianlian＊Wanhua",
      data_table = buildDataTable(player),
      timeout = 60
    })
    room:delay(2000)
    local character = req:getResult(player) ---@type string
    if character ~= "false" then
      room:doBroadcastNotify("ShowToast", "恭喜你解锁了 <font color='red'>"..Fk:translate(character).."</font>")
      table.insertIfNeed(unlocked, req:getResult(player))
      room:handleAddLoseSkills(player, Fk.generals[character]:getSkillNameList())
    else
      room:doBroadcastNotify("ShowToast", "<font color='red'>单身结局：</font>你只得到了好基友鞍马廉太郎")
    end
    room:setPlayerMark(player, "@&yyfy_gonglue", unlocked)
  end
})

return gonglue