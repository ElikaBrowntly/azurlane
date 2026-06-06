local zhangwu = fk.CreateSkill {
  name = "yyfy_zhangwu",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_zhangwu"] = "章武",
  [":yyfy_zhangwu"] = "持恒技，每轮每项各限X次（X为你的体力上限）：<br>1）当你使用或打出红色牌时，随机获得关羽的一个技能；" ..
      "<br>2）当你使用或打出杀时，随机获得张飞的一个技能；<br>3）当你使用锦囊牌时，随机获得诸葛亮的一个技能；" ..
      "<br>4）当你使用或打出黑色牌时，随机获得马超的一个技能；<br>5）当你的杀被闪响应，以及使用或打出闪时，随机获得赵云的一个技能；" ..
      "<br>6）当你使用牌时或成为其他角色使用牌的目标后，若此牌花色未被记录，则记录之并随机获得黄忠的一个技能，当记录四种花色后，清除记录的花色。" ..
      "<br>出牌阶段，或回合结束时，你可以选择失去任意个技能，然后摸等量张牌。",

  ["@yyfy_zhangwu"] = "章武",
  ["$yyfy_zhangwu1"] = "众将皆言君恩，今当献身以报！",
  ["$yyfy_zhangwu2"] = "汉贼不两立，王业不偏安！"
}

--- 筛选该武将的技能
---@param name string 要获得哪个武将的技能
---@return string[]
local function filter(name)
  local result = {}
  local length = name:len() + 1
  for _, g in ipairs(Fk:getAllGenerals()) do
    local s = g.name
    if s == name or s == "god" .. name then
      table.insertTableIfNeed(result, g:getSkillNameList())
    elseif #s >= length and s:sub(-length) == "_" .. name then
      table.insertTableIfNeed(result, g:getSkillNameList())
    elseif #s >= length + 3 and s:sub(-length - 3) == "_god" .. name then
      table.insertTableIfNeed(result, g:getSkillNameList())
    end
  end
  return result
end

zhangwu:addAcquireEffect(function(self, player, is_start, src)
  local banner = {}
  banner.guanyu = filter("guanyu")
  banner.zhangfei = filter("zhangfei")
  banner.zhugeliang = filter("zhugeliang")
  banner.machao = filter("machao")
  banner.zhaoyun = filter("zhaoyun")
  banner.huangzhong = filter("huangzhong")
  player.room:setBanner(zhangwu.name, banner)
end)

local function spec(player, data)
  local room = player.room
  local card = data.card
  local mark = player:getTableMark("yyfy_zhangwu-turn")
  local banner = room:getBanner(zhangwu.name)
  if (mark.guanyu or 0) < player.maxHp and card.color == Card.Red then
    local skills = table.filter(banner.guanyu, function(s)
      return not player:hasSkill(s, true)
    end)
    room:handleAddLoseSkills(player, room:tableRandomPick(skills))
    mark.guanyu = (mark.guanyu or 0) + 1
  end
  if (mark.zhangfei or 0) < player.maxHp and card.trueName == "slash" then
    local skills = table.filter(banner.zhangfei, function(s)
      return not player:hasSkill(s, true)
    end)
    room:handleAddLoseSkills(player, room:tableRandomPick(skills))
    mark.zhangfei = (mark.zhangfei or 0) + 1
  end
  if (mark.machao or 0) < player.maxHp and card.color == Card.Black then
    local skills = table.filter(banner.machao, function(s)
      return not player:hasSkill(s, true)
    end)
    room:handleAddLoseSkills(player, room:tableRandomPick(skills))
    mark.machao = (mark.machao or 0) + 1
  end
  if (mark.zhaoyun or 0) < player.maxHp and card.name == "jink" then
    local skills = table.filter(banner.zhaoyun, function(s)
      return not player:hasSkill(s, true)
    end)
    room:handleAddLoseSkills(player, room:tableRandomPick(skills))
    mark.zhaoyun = (mark.zhaoyun or 0) + 1
  end
  return mark
end

zhangwu:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(self) and player.room:getBanner(zhangwu.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.card
    local mark = player:getTableMark("yyfy_zhangwu-turn")
    local banner = room:getBanner(zhangwu.name)
    mark = spec(player, data)
    if (mark.zhugeliang or 0) < player.maxHp and card.type == Card.TypeTrick then
      local skills = table.filter(banner.zhugeliang, function(s)
        return not player:hasSkill(s, true)
      end)
      room:handleAddLoseSkills(player, room:tableRandomPick(skills))
      mark.zhugeliang = (mark.zhugeliang or 0) + 1
    end
    if (mark.huangzhong or 0) < player.maxHp and
        not table.contains(player:getTableMark("@yyfy_zhangwu"), card:getSuitString(true)) then
      local skills = table.filter(banner.huangzhong, function(s)
        return not player:hasSkill(s, true)
      end)
      room:addTableMarkIfNeed(player, "@yyfy_zhangwu", card:getSuitString(true))
      if #player:getTableMark("@yyfy_zhangwu") > 3 then
        room:setPlayerMark(player, "@yyfy_zhangwu", 0)
      end
      room:handleAddLoseSkills(player, room:tableRandomPick(skills))
      mark.huangzhong = (mark.huangzhong or 0) + 1
    end

    room:setPlayerMark(player, "yyfy_zhangwu-turn", mark)
  end,
})

zhangwu:addEffect(fk.CardResponding, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and player.room:getBanner(zhangwu.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local mark = spec(player, data)
    player.room:setPlayerMark(player, "yyfy_zhangwu-turn", mark)
  end,
})

zhangwu:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return player and player:hasSkill(self) and data.responseToEvent and data.responseToEvent.from == player
        and data.card.trueName == "jink" and data.toCard and data.toCard.trueName == "slash" and
        (player:getTableMark("yyfy_zhangwu-turn").zhaoyun or 0) < player.maxHp
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("yyfy_zhangwu-turn")
    local banner = room:getBanner(zhangwu.name)
    local skills = table.filter(banner.zhaoyun, function(s)
      return not player:hasSkill(s, true)
    end)
    room:handleAddLoseSkills(player, room:tableRandomPick(skills))
    mark.zhaoyun = (mark.zhaoyun or 0) + 1
    room:setPlayerMark(player, "yyfy_zhangwu-turn", mark)
  end,
})

zhangwu:addEffect(fk.TargetConfirmed, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from ~= player and
        not table.contains(player:getTableMark("@yyfy_zhangwu"), data.card:getSuitString(true))
        and (player:getTableMark("yyfy_zhangwu-turn").huangzhong or 0) < player.maxHp
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("yyfy_zhangwu-turn")
    local banner = room:getBanner(zhangwu.name)
    local skills = table.filter(banner.huangzhong, function(s)
      return not player:hasSkill(s, true)
    end)
    room:addTableMarkIfNeed(player, "@yyfy_zhangwu", data.card:getSuitString(true))
    if #player:getTableMark("@yyfy_zhangwu") > 3 then
      room:setPlayerMark(player, "@yyfy_zhangwu", 0)
    end
    room:handleAddLoseSkills(player, room:tableRandomPick(skills))
    mark.huangzhong = (mark.huangzhong or 0) + 1
    room:setPlayerMark(player, "yyfy_zhangwu-turn", mark)
  end,
})

local function spec2(player)
  local room = player.room
  local skills = {}
  for _, s in ipairs(player.player_skills) do
    if not (s.attached_equip or s.name[#s.name] == "&") and not string.find(s.name, "#") then
      table.insertIfNeed(skills, s.name)
    end
  end
  skills = room:askToCustomDialog(player, {
    skill_name = zhangwu.name,
    component = {
      url = "packages/utility/qml/ChooseSkillBox.qml",
      model = {
        url = "packages/utility/qml/models/ChooseSkillModel.qml",
        prop = {
          skills = skills,
          min = 1,
          max = #skills,
          prompt = "章武：请选择要失去的技能",
          cancelable = false,
        }
      }
    },
  })
  if not skills or #skills == 0 then return end
  for _, s in ipairs(skills) do
    room:handleAddLoseSkills(player, "-"..s)
  end
  room:drawCards(player, #skills, zhangwu.name)
end

zhangwu:addEffect("active", {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  prompt = "章武：你可以失去任意个技能，摸等量的牌",
  can_use = function(self, player)
    return player and player:hasSkill(self)
  end,
  on_use = function(self, room, effect)
    spec2(effect.from)
  end
})

zhangwu:addEffect(fk.TurnEnd, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhangwu.name,
      prompt = "章武：你可以失去任意个技能，摸等量的牌"
    })
  end,
  on_use = function(self, event, target, player, data)
    spec2(player)
  end
})

return zhangwu