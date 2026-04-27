---@diagnostic disable: param-type-mismatch
local yongheng = fk.CreateSkill {
  name = "yyfy_hualong_yongheng",
}

Fk:loadTranslationTable {
  ["yyfy_hualong_yongheng"] = "永恒",
  [":yyfy_hualong_yongheng"] = "在你受到<a href='jilve_negativeeffect'>负面效果</a>前，你可将此负面效果" ..
      "改为另一种负面效果，然后将你所有标记及其值调整至发动〖永恒〗前。",

  ["#yyfy_hualong_yongheng-change"] = "是否发动〖永恒〗，将 %arg 改为其他负面效果？",
  ["#yyfy_hualong_yongheng-changeLog"] = "%from 发动〖潜渊〗，将 %arg 改为 %arg2",
  ["damage"] = "受到伤害",
  ["lostHp"] = "失去体力",
  ["lostMaxhp"] = "体力上限减少",
  ["discard"] = "弃置牌",
  ["lostSkills"] = "失去技能",
  ["invalidateSkills"] = "技能失效",
  ["chain"] = "横置",
  ["turnover"] = "翻至背面"

}

local JL = require "packages.jilve_caidog.util"

JL.addBeforeNegativeEffect(yongheng, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (player == target or event == fk.BeforeCardsMove)
        and JL.ConvertToNegativeData(event, player, data) and player.id > 0 -- 防止人机死循环
  end,
  on_cost = function(self, event, target, player, data)
    local negdata = JL.ConvertToNegativeData(event, player, data)
    if player.room:askToSkillInvoke(player, {
          skill_name = yongheng.name,
          prompt = "#yyfy_hualong_yongheng-change:::" .. "jilve_negativeeffect_" .. negdata.type
        }) then
      player.tag[yongheng.name] = table.clone(player.mark)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room ---@type Room
    local negdata = JL.ConvertToNegativeData(event, player, data)
    JL.preventNegativeEffect(player.room, negdata)

    local type = { "damage", "lostHp", "lostMaxhp", "discard", "lostSkills", "invalidateSkills", "chain", "turnover" }
    local choices = table.simpleClone(type)
    table.removeOne(choices, negdata.type)
    local newtype = room:askToChoice(player, {
      choices = choices,
      all_choices = type,
      prompt = "永恒：请将此负面效果改为另一种负面效果"
    })
    room:sendLog {
      type = "#yyfy_hualong_yongheng-changeLog",
      from = player.id,
      arg = "jilve_negativeeffect_" .. negdata.type,
      arg2 = "jilve_negativeeffect_" .. newtype,
      toast = true
    }
    JL.doNegativeEffect(player, newtype, yongheng.name)
    local saved = player.tag[yongheng.name]
    for key, value in pairs(saved) do
      room:setPlayerMark(player, key, value)
    end
  end
})

return yongheng