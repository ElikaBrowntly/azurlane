local xingshang = fk.CreateSkill({
  name = "yyfy_xingshang",
  tags = { Skill.Permanent },
})

Fk:loadTranslationTable {
  ["yyfy_xingshang"] = "行商",
  [":yyfy_xingshang"] = "持恒技，游戏开始时或出牌阶段，你可以花费货币购买一个技能获得；<br>" ..
      "你以此法获得的技能不会因对局结束而失去，当你获得本技能后获得这些技能。<br>" ..
      "出牌阶段，你可以以一半的价格出售这些技能。",

  ["$yyfy_xingshang1"] = "（叮）",
}

local F = require "packages.hidden-clouds.functions"
local U = require "packages.utility.utility"

--- 购买技能
---@param player ServerPlayer
---@return nil
local function buy(player)
  local room = player.room
  local generals = Fk:getAllGenerals()
  local choice = ""
  if false then --room:getSettings('enableFreeAssign')
    local randomNames = {}
    if #generals > 16 then
      while #randomNames < 16 do
        local index = math.random(#generals)
        local one = table.remove(generals, index) ---@type General
        table.insertIfNeed(randomNames, one.name)
      end
    else
      for _, g in ipairs(generals) do
        table.insert(randomNames, g.name)
      end
    end
    ---@diagnostic disable-next-line: cast-local-type
    choice = room:askToChooseGeneral(player, {
      generals = randomNames,
    })
  else
    local inputReq = Request:new(player, "CustomDialog")
    inputReq.focus_text = xingshang.name
    inputReq:setData(player, {
      skill_name = xingshang.name,
      component = {
        url = "packages/hidden-clouds/qml/InputSearchBox.qml",
        model = {
          url = "packages/hidden-clouds/qml/models/InputSearchModel.qml",
          prop = {
            prompt = "请宣言一个武将名（至少一个字）："
          }
        }
      }
    })
    inputReq:setDefaultReply(player, "")
    local input = inputReq:getResult(player)
    if input == nil or input == "" then
      return nil -- 取消或未输入，结束技能
    end
    local keyword = input:lower()
    local filtered = {}
    for _, gen in ipairs(generals) do
      local translated = Fk:translate(gen.name):lower()
      if translated:find(keyword, 1, true) then
        table.insert(filtered, gen.name)
      end
    end
    if #filtered == 0 then
      room:doBroadcastNotify("ShowToast", "没有符合宣言的武将，请重新查找")
      return
    end
    local req = Request:new(player, "CustomDialog")
    req.focus_text = xingshang.name
    req:setData(player, {
      skill_name = xingshang.name,
      component = {
        url = "packages/hidden-clouds/qml/GeneralChoiceBox.qml",
        model = {
          url = "packages/hidden-clouds/qml/models/GeneralChoiceModel.qml",
          prop = {
            generals = filtered,         -- 每个玩家独立的武将列表
            freeAssign = true,
            prompt = "选择武将"
          }
        }
      }
    })
    req:setDefaultReply(player, "")
    choice = req:getResult(player)
  end
  if choice == nil or choice == "" then
    return nil -- 取消选择
  end
  local skillnames = Fk.generals[choice]:getSkillNameList(true)
  local skills = {}
  for _, s in ipairs(skillnames) do
    if not player:hasSkill(s, true) then
      table.insert(skills, s)
    end
  end
  local choices = U.askToChooseGeneralSkills(player, {
    generals = { choice },
    skills = { skills },
    min_num = 1,
    max_num = #skills,
    skill_name = xingshang.name,
    prompt = "交易：请选择要购买的技能",
    cancelable = true
  })
  if #choices == 0 then
    return nil
  end
  local gold = F.ChangePlayerMoney(player, 0)
  local globalData = player:getGlobalSaveState("hidden-clouds") or {}
  local quartz = globalData["SaintQuartz"] or {}
  local saintQuartz = quartz.quartz_num
  local pay1 = "通过" .. tostring(#choices * 10000) .. "金币支付"
  local pay2 = "通过" .. tostring(#choices) .. "圣晶石支付"
  local usablePay = {}
  if gold >= #choices * 10000 then
    table.insert(usablePay, pay1)
  end
  if saintQuartz >= #choices then
    table.insert(usablePay, pay2)
  end
  if #usablePay == 0 then
    room:doBroadcastNotify("ShowToast", "货币不足！")
    return nil
  end
  choice = room:askToChoice(player, {
    choices = usablePay,
    all_choices = { pay1, pay2 },
    cancelable = true
  })
  if choice == "Cancel" then return nil end
  if choice == pay1 then
    F.ChangePlayerMoney(player, - #choices * 10000)
  end
  if choice == pay2 then
    F.ChangePlayerSaintQuartz(player, - #choices)
  end
  room:handleAddLoseSkills(player, choices)
  local state = player:getGlobalSaveState("hidden-clouds") or {}
  local save = state["yyfy_xingshang"] or {}
  for _, s in ipairs(choices) do
    table.insertIfNeed(save, s)
  end
  state["yyfy_xingshang"] = save
  player:saveGlobalState("hidden-clouds", state)
end

--- 出售技能
---@param player ServerPlayer
local function sell(player)
  local room = player.room
  local state = player:getGlobalSaveState("hidden-clouds") or {}
  local save = state["yyfy_xingshang"] or {}
  if #save == 0 then
    room:doBroadcastNotify("ShowToast", "没有可出售的技能！")
    return
  end
  local sname = room:askToCustomDialog(player, {
    skill_name = xingshang.name,
    component = {
      url = "packages/utility/qml/ChooseSkillBox.qml",
      model = {
        url = "packages/utility/qml/models/ChooseSkillModel.qml",
        prop = {
          skills = save,
          min = 0,
          max = 1,
          prompt = "行商：请选择要出售的技能"
        }
      }
    }
  })
  if not sname or sname == "" or type(sname) == "table" and #table == 0 then return end
  if type(sname) == "table" then
    sname = sname[1]
  end
  room:handleAddLoseSkills(player, "-" .. sname, nil, false, true)
  table.removeOne(save, sname)
  state["yyfy_xingshang"] = save
  player:saveGlobalState("hidden-clouds", state)
  F.ChangePlayerMoney(player, 5000)
end

xingshang:addAcquireEffect(function(self, player, is_start)
  local state = player:getGlobalSaveState("hidden-clouds") or {}
  local save = state["yyfy_xingshang"] or {}
  if #save == 0 then return end
  player.room:handleAddLoseSkills(player, save)
end)

xingshang:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    buy(player)
  end,
})

xingshang:addEffect("active", {
  card_num = 0,
  target_num = 0,
  can_use = Util.TrueFunc,
  prompt = "交易：请选择要进行的操作",
  interaction = function(self, player)
    return UI.ComboBox {
      choices = { "购买技能", "出售技能" },
      default_choice = "购买技能",
    }
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local operation = self.interaction.data
    if operation == "购买技能" then
      buy(player)
      return
    end
    sell(player)
  end,
})

return xingshang