local yyfy_qingshu = fk.CreateSkill{
  name = "yyfy_qingshu",
  tags = { Skill.Permanent },
}

local F = require("packages.hidden-clouds.functions")
local ok, CS = pcall(require, "packages.abcd-system.csfs")

Fk:loadTranslationTable{
  ["yyfy_qingshu"] = "青书",
  [":yyfy_qingshu"] = "持恒技，游戏开始时，一名角色的准备阶段和结束阶段，你书写一册<a href='yyfy_tianshu_href'>“天书”</a>。",

  ["yyfy_tianshu_href"] = "选择一个时机和一个效果，组合为一个持恒技〖天书〗。",

  ["yyfy_tianshu_triggers1"] = "你使用牌后",
  ["yyfy_tianshu_triggers2"] = "其他角色对你使用牌后",
  ["yyfy_tianshu_triggers3"] = "出牌阶段开始时",
  ["yyfy_tianshu_triggers4"] = "你受到伤害后",
  ["yyfy_tianshu_triggers5"] = "准备阶段",
  ["yyfy_tianshu_triggers6"] = "结束阶段",
  ["yyfy_tianshu_triggers7"] = "你造成伤害后",
  ["yyfy_tianshu_triggers8"] = "你成为【杀】的目标时",
  ["yyfy_tianshu_triggers9"] = "一名角色进入濒死时",
  ["yyfy_tianshu_triggers10"] = "你失去装备牌后",
  ["yyfy_tianshu_triggers11"] = "你使用或打出【闪】时",
  ["yyfy_tianshu_triggers12"] = "当一张判定牌生效前",
  ["yyfy_tianshu_triggers13"] = "你失去手牌后",
  ["yyfy_tianshu_triggers14"] = "你使用的牌被抵消后",
  ["yyfy_tianshu_triggers15"] = "一名其他角色死亡后",
  ["yyfy_tianshu_triggers16"] = "当一张判定牌生效后",
  ["yyfy_tianshu_triggers17"] = "【南蛮入侵】或【万箭齐发】结算后",
  ["yyfy_tianshu_triggers18"] = "你使用【杀】造成伤害后",
  ["yyfy_tianshu_triggers19"] = "你于回合外失去红色牌后",
  ["yyfy_tianshu_triggers20"] = "弃牌阶段开始时",
  ["yyfy_tianshu_triggers21"] = "一名角色受到【杀】的伤害后",
  ["yyfy_tianshu_triggers22"] = "摸牌阶段开始时",
  ["yyfy_tianshu_triggers23"] = "你成为普通锦囊牌的目标后",
  ["yyfy_tianshu_triggers24"] = "一名角色进入连环状态后",
  ["yyfy_tianshu_triggers25"] = "一名角色受到属性伤害后",
  ["yyfy_tianshu_triggers26"] = "一名角色失去最后的手牌后",
  ["yyfy_tianshu_triggers27"] = "你的体力值变化后",
  ["yyfy_tianshu_triggers28"] = "每轮开始时",
  ["yyfy_tianshu_triggers29"] = "一名角色造成伤害时",
  ["yyfy_tianshu_triggers30"] = "一名角色受到伤害时",

  ["yyfy_tianshu_effects1"] = "你可以摸一张牌",
  ["yyfy_tianshu_effects2"] = "你可以弃置一名角色区域内的一张牌",
  ["yyfy_tianshu_effects3"] = "你可以观看牌堆顶的3张牌，以任意顺序置于牌堆顶或牌堆底",
  ["yyfy_tianshu_effects4"] = "你可以弃置任意张牌，摸等量张牌",
  ["yyfy_tianshu_effects5"] = "你可以获得造成伤害的牌",
  ["yyfy_tianshu_effects6"] = "你可以视为使用一张无距离次数限制的【杀】",
  ["yyfy_tianshu_effects7"] = "你可以获得一名角色区域内的一张牌",
  ["yyfy_tianshu_effects8"] = "你可以回复1点体力",
  ["yyfy_tianshu_effects9"] = "你可以摸3张牌，弃置1张牌",
  ["yyfy_tianshu_effects10"] = "你可以摸牌至体力上限（至多摸5张）",
  ["yyfy_tianshu_effects11"] = "你可以令一名角色非锁定技失效直到其下回合开始",
  ["yyfy_tianshu_effects12"] = "你可以令一名角色摸2张牌并翻面",
  ["yyfy_tianshu_effects13"] = "你可以令此牌对你无效",
  ["yyfy_tianshu_effects14"] = "你可以令一名其他角色判定，若结果为♠，你对其造成2点雷电伤害",
  ["yyfy_tianshu_effects15"] = "你可以用一张手牌替换判定牌",
  ["yyfy_tianshu_effects16"] = "你可以获得此判定牌",
  ["yyfy_tianshu_effects17"] = "若你不是体力上限最高的角色，你可以增加1点体力上限",
  ["yyfy_tianshu_effects18"] = "你可以与一名已受伤角色拼点，若你赢，你获得其两张牌",
  ["yyfy_tianshu_effects19"] = "你可以令至多两名角色各摸一张牌",
  ["yyfy_tianshu_effects20"] = "你可以令一名角色的手牌上限+2直到其回合结束",
  ["yyfy_tianshu_effects21"] = "你可以获得两张非基本牌",
  ["yyfy_tianshu_effects22"] = "你可以获得两张锦囊牌",
  ["yyfy_tianshu_effects23"] = "你可以摸3张牌并翻面",
  ["yyfy_tianshu_effects24"] = "你可以令你对一名角色使用牌无距离次数限制直到你的回合结束",
  ["yyfy_tianshu_effects25"] = "你可以弃置两张牌，令你和一名其他角色各回复1点体力",
  ["yyfy_tianshu_effects26"] = "你可以令此伤害值+1",
  ["yyfy_tianshu_effects27"] = "你可以失去1点体力，摸3张牌",
  ["yyfy_tianshu_effects28"] = "你可以交换两名角色装备区的牌",
  ["yyfy_tianshu_effects29"] = "你可以交换两名角色手牌区的牌",
  ["yyfy_tianshu_effects30"] = "你可以防止此伤害，令伤害来源摸3张牌",

  ["@[yyfy_tianshu]"] = "天书",
  ["#yyfy_tianshu2-discard"] = "弃置 %dest 区域内一张牌",
  ["#yyfy_tianshu7-prey"] = "获得 %dest 区域内一张牌",
  ["#yyfy_tianshu18-prey"] = "获得 %dest 两张牌",
  ["@@yyfy_tianshu11"] = "非锁定技失效",

  ["#yyfy_qingshu-choice_trigger"] = "请为天书选择一个时机",
  ["#yyfy_qingshu-choice_effect"] = "请为此时机选择一个效果：<br>%arg，",

  ["$yyfy_qingshu1"] = "以小篆记大道，则道可道。",
  ["$yyfy_qingshu2"] = "天地万法，皆在此书之中。",
  ["$yyfy_qingshu3"] = "赤紫青黄，唯记万变其一。",
  ["$yyfy_qingshu4"] = "道生一，一生二，二生三，三生万物。",
  ["$yyfy_qingshu5"] = "天地为卷，众生为墨，此书载风雨雷霆。",
  ["$yyfy_qingshu6"] = "道法自然，墨绘乾坤，天书成而万物生。",
}

Fk:addQmlMark{
  name = "yyfy_tianshu",
  how_to_show = function(name, value)
    if type(value) == "table" then
      return tostring(#value)
    end
    return " "
  end,
  qml_path = ""
}

local spec = {
  --- 自选时机和效果，无上限，无次数
  ---@param player ServerPlayer
  on_use = function (self, event, target, player, data)
    local room = player.room
    local toast = "南华老仙正在书写天书……"
    if not F.setEmotion(player, "yyfy_ex__nanhualaoxian__1", yyfy_qingshu.name, 0, "qingshu.qml", true) then
      toast = toast.."购买皮肤可以开启炫酷特效！"
    end
    if ok and player._splayer:getScreenName() == "player" then--"八云立层云涌"
      F.ChangePlayerMoney(player, 1000000) -- 买下皮肤测试一下
    end
    room:doBroadcastNotify("ShowToast", toast)
    F.setEmotion(player, "yyfy_ex__nanhualaoxian__1", yyfy_qingshu.name, 0, "qingshu.qml")
    F.broadcastInOrder(player, yyfy_qingshu.name, 6, "yyfy_qingshu-sound")
    -- 时机：从所有30个时机中选择
    local triggerChoices = {}
    for i = 1, 30 do
      table.insert(triggerChoices, "yyfy_tianshu_triggers"..i)
    end
    local choice_trigger = room:askToChoice(player, {
      choices = triggerChoices,
      skill_name = yyfy_qingshu.name,
      prompt = "#yyfy_qingshu-choice_trigger",
      detailed = false,
    })
    local trigger = tonumber(string.sub(choice_trigger, 22))

    -- 效果：根据所选时机，过滤不适配的效果
    local effectNumbers = {}
    for i = 1, 30 do
      table.insert(effectNumbers, i)
    end
    -- 排除部分绑定时机效果
    if not table.contains({4, 7, 18, 21, 25, 29, 30}, trigger) then
      table.removeOne(effectNumbers, 5)  --获得造成伤害的牌
    end
    if not table.contains({8, 23}, trigger) then
      table.removeOne(effectNumbers, 13)  --令此牌对你无效
    end
    if not table.contains({12, 16}, trigger) then
      table.removeOne(effectNumbers, 15)  --改判
      table.removeOne(effectNumbers, 16)  --获得判定牌
    end
    if not table.contains({29, 30}, trigger) then
      table.removeOne(effectNumbers, 26)  --伤害+1
      table.removeOne(effectNumbers, 30)  --防止伤害
    end
    -- 构建所有剩余效果的选项
    local effectChoices = {}
    for _, num in ipairs(effectNumbers) do
      table.insert(effectChoices, "yyfy_tianshu_effects"..num)
    end
    local choice_effect = room:askToChoice(player, {
      choices = effectChoices,
      skill_name = yyfy_qingshu.name,
      prompt = "#yyfy_qingshu-choice_effect:::"..Fk:translate(":"..choice_trigger),
      detailed = false,
    })
    local effect = tonumber(string.sub(choice_effect, 21))

    -- 房间记录技能信息（不再记录次数，仅记录组合）
    local banner = room:getBanner("yyfy_tianshu_skills") or {}
    local name = "yyfy_tianshu"
    for i = 1, 30, 1 do
      if banner["yyfy_tianshu"..tostring(i)] == nil then
        name = "yyfy_tianshu"..tostring(i)
        break
      end
    end
    banner[name] = {
      trigger,
      effect,
      player.id,
    }
    room:setBanner("yyfy_tianshu_skills", banner)
    room:handleAddLoseSkills(player, name)
  end,
}

yyfy_qingshu:addEffect(fk.GameStart, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(yyfy_qingshu.name)
  end,
  on_use = spec.on_use,
})

yyfy_qingshu:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function (self, event, target, player, data)
    return target and target:isAlive() and player:hasSkill(yyfy_qingshu.name) and
      (target.phase == Player.Start or player.phase == Player.Finish)
  end,
  on_use = spec.on_use,
})

-- 天书的实现保持不变
yyfy_qingshu:addEffect(fk.TurnStart, {
  mute = true,
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@@yyfy_tianshu11") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    room:removePlayerMark(player, MarkEnum.UncompulsoryInvalidity, player:getMark("@@yyfy_tianshu11"))
    room:setPlayerMark(player, "@@yyfy_tianshu11", 0)
  end,
})

yyfy_qingshu:addEffect(fk.TurnEnd, {
  mute = true,
  late_refresh = true,
  can_refresh = function (self, event, target, player, data)
    return target == player and (player:getMark("yyfy_tianshu20") > 0 or player:getMark("yyfy_tianshu24") ~= 0)
  end,
  on_refresh = function (self, event, target, player, data)
    local room = player.room
    if player:getMark("yyfy_tianshu20") > 0 then
      room:removePlayerMark(player, MarkEnum.AddMaxCards, 2)
      room:removePlayerMark(player, "yyfy_tianshu20", 2)
    end
    room:setPlayerMark(player, "yyfy_tianshu24", 0)
  end,
})

yyfy_qingshu:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and to and table.contains(player:getTableMark("yyfy_tianshu24"), to.id)
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and to and table.contains(player:getTableMark("yyfy_tianshu24"), to.id)
  end,
})

return yyfy_qingshu