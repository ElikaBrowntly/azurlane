local quanyu = fk.CreateSkill {
  name = "lan__quanyu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["lan__quanyu"] = "权御",
  [":lan__quanyu"] = "锁定技，每轮开始时，你获得以下“权御”效果，然后你摸X张牌（X为存活角色数）：" ..
      "白虹，伤害基数+1；青冥，多指定一个目标；辟邪，无视防具；紫电，不能被响应；百里，额外结算一次；流星，不计入次数。" ..
      "当你使用【杀】指定唯一目标时，你可以执行任意项“权御”效果。",

  ["lan__quanyu_baihong"] = "伤害基数+1",
  ["lan__quanyu_qingming"] = "额外指定目标",
  ["lan__quanyu_bixie"] = "无视防具",
  ["lan__quanyu_zidian"] = "不可响应",
  ["lan__quanyu_baili"] = "额外结算",
  ["lan__quanyu_liuxing"] = "不计入次数",

  ["lan__quanyu_baihong_name"] = "白虹",
  ["lan__quanyu_qingming_name"] = "青冥",
  ["lan__quanyu_bixie_name"] = "辟邪",
  ["lan__quanyu_zidian_name"] = "紫电",
  ["lan__quanyu_baili_name"] = "百里",
  ["lan__quanyu_liuxing_name"] = "流星",

  ["@@lan__quanyu_has_all_effects"] = "权御",

  ["#lan__quanyu-choose"] = "请为%arg额外选择一个目标",

  ["$lan__quanyu1"] = "百川奔流入海，却尽入朕之彀中。",
  ["$lan__quanyu2"] = "恩威予取，功过皆在朕心。",
}

local quanyuEffectNames = {
  "lan__quanyu_baihong_name",
  "lan__quanyu_qingming_name",
  "lan__quanyu_bixie_name",
  "lan__quanyu_zidian_name",
  "lan__quanyu_baili_name",
  "lan__quanyu_liuxing_name",
}

-- 执行单个效果
local function applyQuanyuEffect(player, effect, data)
  local room = player.room
  if effect == "lan__quanyu_baihong_name" then
    data.use.additionalDamage = (data.use.additionalDamage or 0) + 1
  elseif effect == "lan__quanyu_qingming_name" then
    if not player:isAlive() then return end
    local targets = data:getExtraTargets({ bypass_times = true })
    if #targets > 0 then
      local tos = room:askToChoosePlayers(
        player,
        {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = quanyu.name,
          prompt = "#lan__quanyu-choose:::" .. data.card:toLogString(),
          cancelable = false,
        }
      )
      data:addTarget(tos[1])
    end
  elseif effect == "lan__quanyu_zidian_name" then
    data.use.disresponsiveList = room:getAllPlayers(false)
  elseif effect == "lan__quanyu_baili_name" then
    data.use.additionalEffect = (data.use.additionalEffect or 0) + 1
  elseif effect == "lan__quanyu_liuxing_name" and not data.use.extraUse then
    data.use.extraUse = true
    player:addCardUseHistory("slash", -1)
  end
end

quanyu:addEffect(fk.RoundStart, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(quanyu.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@lan__quanyu_has_all_effects", 1)
    player:drawCards(#room.alive_players, quanyu.name)
  end,
})

-- 使用【杀】时触发所有权御效果
quanyu:addEffect(fk.TargetSpecifying, {
  can_trigger = function(self, event, target, player, data)
    return target == player
      and data.card.trueName == "slash"
      and player:hasSkill(quanyu.name)
      and data:isOnlyTarget(data.to)
      and player:getMark("@@lan__quanyu_has_all_effects") == 1
  end,
  on_use = function(self, event, target, player, data)
    local results = player.room:askToChoices(
      player,
      {
        choices = quanyuEffectNames,
        min_num = 1,
        max_num = 6,
        cancelable = true,
        skill_name = quanyu.name,
        prompt = "权御：你可以执行任意项效果",
      }
    )
    if #results == 0 then return end
    for _, effectName in ipairs(results) do
      applyQuanyuEffect(player, effectName, data)
    end
  end,
})

-- 流星：不计入次数
quanyu:addEffect("targetmod", {
  bypass_times = function(self, player, skill, scope, card, to)
    return card and card.trueName == "slash"
      and player:hasSkill(quanyu.name)
      and player:getMark("@@lan__quanyu_has_all_effects") == 1
  end,
})

-- 辟邪：无视防具
quanyu:addAcquireEffect(function(self, player)
  local room = player.room
  if not room:hasSkill("#lan__quanyu_bixie") then
    room:addSkill("#lan__quanyu_bixie")
  end
end)

return quanyu