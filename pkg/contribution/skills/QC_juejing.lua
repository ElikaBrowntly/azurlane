local QC_juejing = fk.CreateSkill{
  name = "QC_juejing",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["QC_juejing"] = "绝境",
  [":QC_juejing"] = "持恒技，当你的体力变化后，回复0-X点体力，摸1张牌，获得X个<a href='#QC_juejing'>特定武将</a>的技能。"..
                    "出牌阶段，你可以失去任意个因此技能获得的技能，然后摸等量的牌。（X为本次变化的值）",
  ["#QC_juejing"] = "关羽，张飞，赵云，马超，黄忠，诸葛亮，曹操，张辽，司马"..
                    "懿，曹髦，司马昭，陆逊，黄盖，吕蒙，魏延，张角，钟会，国"..
                    "渊，邓艾，姜维，龙辰，曹丕，孙权，曹爽，司马师，程小实，"..
                    "刘渊，郭嘉，荀彧，甘宁，孙策...",
  ["#QC_juejing-lose"] = "绝境：你可以选择失去已获得的技能（摸等量牌）",
  ["@QC_juejing_count"] = "绝境",
}

local BANNER_NAME = "QC_juejing_skillpool"

local function initSkillPool(player)
  local room = Fk:currentRoom()
  if room:getBanner(BANNER_NAME) then return end

  local skills = {}
  local sgMapper = {}
  local targetNames = { "guanyu", "zhangfei", "zhaoyun", "machao", "huangzhong", "zhugeliang"
  , "caocao" , "zhangliao" , "simayi" , "caomao" , "simazhao" , "luxun" , "huanggai" , "lvmeng"
  , "weiyan" , "zhangjiao", "zhonghui" , "guoyuan" , "dengai" , "jiangwei" , "longchen","caopi"
  ,"sunquan","caoshuang","simashi","chengxiaoshi","liuyuan","guojia","xunyu","ganning","sunce"
  ,"zerocosmosrise"}

  for _, general in pairs(Fk.generals) do
    if general.trueName then
      local ok = false
      for _, suffix in ipairs(targetNames) do
        if general.trueName:endsWith(suffix) then
          ok = true
          break
        end
      end
      if ok or general.trueName == "gundam" or general.trueName == "yin__gundam" or general.trueName == "o__gundam" then
        for _, s in ipairs(general:getSkillNameList(true)) do
          table.insert(skills, s)
          sgMapper[s] = general.name
        end
      end
    end
  end

  room:setBanner(BANNER_NAME, {skills, sgMapper})
end

local function gainJuejingSkills(player, num)
  local room = player.room
  initSkillPool(player)
  local banner = room:getBanner(BANNER_NAME)
  if not banner or #banner[1] == 0 then return end

  local available = table.filter(banner[1], function(s)
    return not player:hasSkill(s, true)
  end)
  if #available == 0 then return end

  table.shuffle(available)
  local count = math.min(num, #available)
  for i = 1, count do
    local skill = available[i]
    room:addTableMark(player, QC_juejing.name, skill)
    room:handleAddLoseSkills(player, skill)
  end
  room:setPlayerMark(player, "@QC_juejing_count", #player:getTableMark(QC_juejing.name))
end

QC_juejing:addEffect(fk.HpChanged, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(QC_juejing.name) and data.num ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = math.abs(data.num)

    player:drawCards(1, QC_juejing.name)

    local recover_num = math.random(0, x)
    if recover_num > 0 and player:isWounded() then
      room:recover{
        who = player,
        num = recover_num,
        recoverBy = player,
        skillName = QC_juejing.name,
      }
    end

    gainJuejingSkills(player, x)
  end,
})

QC_juejing:addEffect("active", {
  anim_type = "support",
  card_num = 0,
  target_num = 0,
  prompt = "#QC_juejing-lose",
  can_use = function(self, player)
    return #player:getTableMark(QC_juejing.name) > 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local owned = player:getTableMark(QC_juejing.name)
    if #owned == 0 then return end

    local banner = room:getBanner(BANNER_NAME)
    local generals = {}
    if banner then
      for _, s in ipairs(owned) do table.insert(generals, banner[2][s] or "") end
    end

    local result = room:askToCustomDialog(player, {
      skill_name = QC_juejing.name,
      qml_path = "packages/utility/qml/ChooseSkillBox.qml",
      extra_data = { owned, 0, #owned, "#QC_juejing-lose", generals },
    })
    if result == "" or #result == 0 then return end

    for _, skillname in ipairs(result) do
      room:removeTableMark(player, QC_juejing.name, skillname)
      room:handleAddLoseSkills(player, "-"..skillname)
    end
    room:setPlayerMark(player, "@QC_juejing_count", #player:getTableMark(QC_juejing.name))
    room:drawCards(player, #result, QC_juejing.name)
  end,
})

return QC_juejing