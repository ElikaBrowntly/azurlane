local fengyin = fk.CreateSkill{
  name = "yyfy_shenglingfengyin",
  tags = { Skill.Permanent, Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_shenglingfengyin"] = "圣灵封印",
  [":yyfy_shenglingfengyin"] = "永恒技，锁定技，共鸣技，游戏开始时，你获得七张“圣灵谱尼”武将牌并"..
  "<a href = 'yyfy_shenglingfengyin-chuchang'>选择一张出场</a>。"..
  "你死亡时，若存在未出场的武将，则选择一个武将出场并继承此前所有技能。",

  ["@&yyfy_shengling"] = "圣灵",
  ["yyfy_shenglingfengyin-chuchang"] = "<br>七张<b>“圣灵谱尼”</b>武将牌各自拥有不同的技能，分别是："..
  "<br><br>〖虚无〗〖元素〗〖能量〗〖生命〗〖轮回〗〖永恒〗〖圣洁〗。<br>"..
  "<br>选择哪张武将，就拥有哪张武将的技能（具体效果见首页）"
}

fengyin:addLoseEffect(function(self, player, is_death)
  player.room:handleAddLoseSkills(player, self.name, nil, false, true)
end)

local all_generals = {"yyfy_shenglingpuni"}
local j = 1
while j <= 7 do
  table.insert(all_generals, "yyfy_shenglingpuni"..tostring(j))
  j = j + 1
end

fengyin:addEffect(fk.GameStart, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self) and
    (player.general == "yyfy_shenglingpuni" or player.deputyGeneral == "yyfy_shenglingpuni")
  end,
  on_trigger = function (self, event, target, player, data)
    player.tag['yyfy_puni'] = 1 -- 共鸣技
    local room = player.room
    local i = 1
    local generals = {}
    while i <= 3 do
      table.insert(generals, "yyfy_shenglingpuni"..tostring(i))
      i = i + 1
    end
    player.tag["yyfy_shengling"] = generals
    local choice = room:askToChooseGeneral(player, {
      generals = generals,
      n = 1,
      no_convert = true,
      skill_name = fengyin.name,
      prompt = "圣灵封印：请选择一张武将牌出战",
    })
    if type(choice) == "table" then
      choice = choice[1]
    end
    local isDeputy = false
    if player.deputyGeneral == "yyfy_shenglingpuni" then
      isDeputy = true
    end
    table.removeOne(generals, choice)
    player.tag["yyfy_shengling"] = generals
    room:changeHero(player, choice, true, isDeputy)
  end
})

fengyin:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return player and player:hasSkill(self, true, true) and player.tag['yyfy_puni'] > 0
    and target == player
  end,
  on_trigger = function (self, event, target, player, data)
    local room = player.room
    if #player.tag["yyfy_shengling"] == 0 then
      room:setTag("SkipGameRule", nil)
      return
    end
    room:setTag("SkipGameRule", true)
    local skills_snapshot = {}
    for _, s in ipairs(player.player_skills) do
      table.insert(skills_snapshot, s)
    end
    player.tag["yyfy_puni_jicheng"] = skills_snapshot
    room:revivePlayer(player, false)
    local generals = player.tag["yyfy_shengling"]
    local choice = room:askToChooseGeneral(player, {
      generals = generals,
      n = 1,
      no_convert = true,
      skill_name = fengyin.name,
      prompt = "圣灵封印：请选择一张武将牌出战",
    })
    local isDeputy = false
    if table.contains(all_generals, player.deputyGeneral) then
      isDeputy = true
    end
    table.removeOne(generals, choice)
    player.tag["yyfy_shengling"] = generals
    if type(choice) == "table" then
      choice = choice[1]
    end
    if #generals == 0 then
      room:doBroadcastNotify("ShowToast", "请注意，这是最后一张圣灵谱尼武将牌了......")
    end
    room:changeHero(player, choice, true, isDeputy)
    -- 继承所有技能
    for _, s in ipairs(player.tag["yyfy_puni_jicheng"]) do
      if not player:hasSkill(s, true, true) then
        room:handleAddLoseSkills(player, s.name, fengyin.name)
      end
    end
    local logic = player.room.logic
    local e = logic:getCurrentEvent()
    logic:breakEvent(e)
  end
})

return fengyin