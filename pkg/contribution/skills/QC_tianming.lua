local QingCaiTang = require("packages.hidden-clouds.QingCaiTang")

local QC_tianming = fk.CreateSkill({
  name = "QC_tianming",
  tags = { Skill.Permanent, Skill.Compulsory },
})

local SKILL_NAME = "QC_tianming"
Fk:loadTranslationTable {
  ["QC_tianming"] = "天命",
  [":QC_tianming"] = "持恒技，在你受到<a href='#QC_tianming'>负面效果</a>前，你可将此负面效果改为你指定的另一种<a href='#QC_tianming'>负面效果</a>，然后将你所有标记以及标记的值调整至你发动【天命】前。",
  ["#QC_tianming"] = "（负面效果：受到伤害，失去体力，减体力上限，弃置牌，失去技能，技能失效，横置，翻面）",
  ["@[QC_tianming]"] = "天命",
  ["QC_tianming1"] = "受到伤害",
  ["QC_tianming2"] = "失去体力",
  ["QC_tianming3"] = "减体力上限",
  ["QC_tianming4"] = "弃置牌",
  ["QC_tianming5"] = "失去技能",
  ["QC_tianming6"] = "技能失效",
  ["QC_tianming7"] = "横置",
  ["QC_tianming8"] = "翻面",

  ["#QC_tianming1-invoke"] = "你即将%arg，是否发动【天命】改为其他负面效果？",
  ["#QC_tianmingLog"] = "%from 发动了【天命】，将 %arg 改为了 %arg2",
}

local TianmingMapper = {
  ["damage"] = 1,
  ["lostHp"] = 2,
  ["lostMaxhp"] = 3,
  ["discard"] = 4,
  ["lostSkills"] = 5,
  ["invalidateSkills"] = 6,
  ["chain"] = 7,
  ["turnover"] = 8,
}

local GetTypeByNum = function(num)
  for k, v in pairs(TianmingMapper) do
    if v == num then
      return k
    end
  end
  return "damage"
end

QingCaiTang.addBeforeNegativeEffect(QC_tianming, {
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(SKILL_NAME) and (player == target or event == fk.BeforeCardsMove) then
      local negdata = QingCaiTang.ConvertToNegativeData(event, player, data)
      return negdata
    end
  end,
  on_cost = function (self, event, target, player, data)
    local negdata = QingCaiTang.ConvertToNegativeData(event, player, data)
    if not negdata then return false end
    return player.room:askToSkillInvoke(player, {
      skill_name = SKILL_NAME,
      prompt = "#QC_tianming1-invoke:::".."QC_tianming"..TianmingMapper[negdata.type]
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local negdata = QingCaiTang.ConvertToNegativeData(event, player, data)
    if not negdata then return end

    local savedMarks = QingCaiTang.savePlayerMarks(player)
    QingCaiTang.preventNegativeEffect(room, negdata)

    local validNums = {}
    local choiceNames = {} 
    for i = 1, 8 do
      if i ~= TianmingMapper[negdata.type] then
        table.insert(validNums, i)
        table.insert(choiceNames, "QC_tianming"..i)
      end
    end

    if player:isNude() then
      local idx = table.indexOf(validNums, 4)
      if idx ~= -1 then
        table.remove(validNums, idx)
        table.remove(choiceNames, idx)
      end
    end

    if #validNums == 0 then
      validNums = {1}
      choiceNames = {"QC_tianming1"}
    end

    local selected = room:askToChoice(player, {
      choices = choiceNames,
      skill_name = SKILL_NAME,
    })

    local rand = validNums[1] 
    if selected and type(selected) == "string" then
      for i, name in ipairs(choiceNames) do
        if name == selected then
          rand = validNums[i]
          break
        end
      end
    end

    room:sendLog {
      type = "#QC_tianmingLog",
      from = player.id,
      arg = "QC_tianming"..TianmingMapper[negdata.type],
      arg2 = "QC_tianming"..rand,
      toast = true,
    }

    local newType = GetTypeByNum(rand)
    QingCaiTang.doNegativeEffect(player, newType, SKILL_NAME, 1, negdata.from)

    QingCaiTang.restorePlayerMarks(player, savedMarks)
  end,
})

return QC_tianming