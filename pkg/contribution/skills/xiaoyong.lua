local xiaoyong = fk.CreateSkill {
  name = "yyfy_xiaoyong",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["yyfy_xiaoyong"] = "啸咏",
  [":yyfy_xiaoyong"] = "锁定技，当你于回合内使用牌名字数为X的牌时（X为上次〖观骨〗观看牌数），你视为未发动〖观骨〗；当你使用与本回合上一次使用的牌字数相同的牌时，你发动一次〖观骨〗。（未完待续）",
  ["@yyfy_xiaoyong-turn"] = "啸咏",

  ["$yyfy_xiaoyong1"] = "凉风萧条，露沾我衣。",
  ["$yyfy_xiaoyong2"] = "忧来多方，慨然永怀。",
}

local U = require "packages.utility.utility"

xiaoyong:addEffect(fk.CardUsing, {
  mute = true,
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiaoyong.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = data.card:getNameLength(true)
    if n == player:getMark("@yyfy_guangu-phase") and
        player:usedSkillTimes("yyfy_guangu", Player.HistoryPhase) > 0 then
      player:broadcastSkillInvoke(xiaoyong.name)
      player.room:setPlayerMark(player, "@yyfy_guangu-phase", 0)
      player:setSkillUseHistory("yyfy_guangu", 0, Player.HistoryPhase)
    end
    if n == player:getMark("@yyfy_xiaoyong-turn") then
      local status = player:getSwitchSkillState("yyfy_guangu", false, true) or "yang"
      room:notifySkillInvoked(player, "yyfy_guangu", "switch")
      if n ~= player:getMark("@yyfy_guangu-phase") then
        player:broadcastSkillInvoke(xiaoyong.name) -- 前面没放过语音再放语音
      end
      U.SetSwitchSkillState(player, "yyfy_guangu") -- 手动切换转换技状态
      -- 由于真正转换技执行前会切换阴阳状态，观骨里面是需要提前计算的，这里不用提前计算，所以手动实现
      local to
      local ids
      if status == "yin" then
        to = room:askToChoosePlayers(player, {
          targets = room:getAlivePlayers(),
          min_num = 1,
          max_num = 1,
          skill_name = "yyfy_guangu",
          prompt = "观骨：你可以观看一名角色任意张手牌，然后使用其中一张牌",
          cancelable = false
        })
        if #to == 1 then
          ids = room:askToChooseCards(player, {
            target = to[1],
            min = 1,
            max = #to[1]:getCardIds("h"),
            flag = "h",
            skill_name = "yyfy_guangu",
          })
        end
      else
        local x = #room.draw_pile
        if x == 0 then return false end
        local result = room:askToNumber(player, {
          skill_name = "yyfy_guangu",
          min = 1,
          max = x,
          prompt = "观骨：选择你要观看的牌堆顶牌数"
        })
        ids = room:getNCards(result or 1)
      end
      room:setPlayerMark(player, "@yyfy_guangu-phase", #ids)
      --- 观骨特判【酒】
      local to_use = table.filter(ids, function(id)
        local card = Fk:getCardById(id)
        return card.trueName ~= "analeptic" or card.skill:withinTimesLimit(player, Player.HistoryTurn, card)
      end)
      local use = room:askToUseRealCard(player, {
        pattern = to_use,
        skill_name = "yyfy_guangu",
        prompt = "观骨：你可以使用其中一张牌",
        extra_data = {
          bypass_times = true,
          extraUse = true,
          expand_pile = (not to or to[1] ~= player) and ids,
        },
        skip = true
      })
      if use then
        if use.card.trueName == "analeptic" then
          use.extraUse = false
        end
        room:useCard(use)
      end
    else
      room:setPlayerMark(player, "@yyfy_xiaoyong-turn", data.card:getNameLength(true))
    end
  end
})

return xiaoyong