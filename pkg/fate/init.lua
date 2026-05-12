local extension = Package:new("fate")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/fate/skills")

local F = require("packages.hidden-clouds.functions")

-- 获取圣晶石数据
Fk:addTaskDef {
  type = "get_player_SaintQuartz",
  handler = function(task)
    local player = task.player
    if not player then return end
    -- 获取玩家的全局存档数据
    local coinData = player:getGlobalSaveState("CS_System_Data") or {}
    local gold = coinData.gold or 0
    local state = player:getGlobalSaveState("hidden-clouds")
    local shou = state["yyfy_kanbujiandeshou"] or {}
    local kanbujiandeshou = shou.last_date or ""
    local quartz = state["SaintQuartz"] or {}
    local sign_in = quartz.sign_in or false
    local sign_constant = quartz.sign_constant or 0
    local sign_total = quartz.sign_total or 0
    local sign_date = quartz.sign_date or "2026-04-09"
    local quartz_num = quartz.quartz_num or 30
    -- 跨日重置 sign_in
    local today = os.date("%Y-%m-%d")
    if sign_date ~= today then
      sign_in = false
      quartz.sign_in = false
      state["SaintQuartz"] = quartz
      player:saveGlobalState("hidden-clouds", state)
    end
    local data = {
      gold = tostring(gold),
      kanbujiandeshou = kanbujiandeshou,
      sign_in = sign_in,
      sign_constant = sign_constant,
      quartz_num = tostring(quartz_num),
      sign_total = sign_total,
      sign_date = sign_date
    }
    task.player:doNotify("get_player_SaintQuartz_callback", json.encode(data))
  end,
}

Fk:addTaskDef {
  type = "sign_in_SaintQuartz",
  handler = function(task)
    local player = task.player
    if not player then
      task.player:doNotify("sign_in_SaintQuartz_callback", json.encode({ success = false, message = "无效玩家" }))
      return
    end

    local state = player:getGlobalSaveState("hidden-clouds") or {}
    local quartz = state["SaintQuartz"] or {}
    local today = os.date("%Y-%m-%d")
    local sign_date = quartz.sign_date or ""
    local sign_in = quartz.sign_in or false

    --已经签到过
    if sign_in then
      task.player:doNotify("sign_in_SaintQuartz_callback", json.encode({ success = false, message = "今日已签到" }))
      return
    end

    -- 计算连续签到天数
    local sign_constant = quartz.sign_constant or 0
    ---@diagnostic disable-next-line: param-type-mismatch
    if sign_date == "" or not F.isYesterday(sign_date) then
      sign_constant = 1
    else
      sign_constant = sign_constant + 1
    end

    -- 基础奖励
    local reward = 1
    if sign_constant >= 7 then
      reward = 2
    end

    -- 执行增加圣晶石
    local newQuartz = F.ChangePlayerSaintQuartz(player, reward)

    -- 更新累计签到
    local sign_total = (quartz.sign_total or 0) + 1
    local bonus = 0
    if sign_total % 50 == 0 then
      bonus = 30
      newQuartz = F.ChangePlayerSaintQuartz(player, bonus)
    end

    -- 保存签到状态
    quartz.sign_in = true
    quartz.sign_constant = sign_constant
    quartz.sign_total = sign_total
    quartz.sign_date = today
    quartz.quartz_num = newQuartz
    state["SaintQuartz"] = quartz
    player:saveGlobalState("hidden-clouds", state)

    -- 返回数据给前端
    local result = {
      success = true,
      quartz_num = newQuartz,
      sign_constant = sign_constant,
      sign_total = sign_total,
      sign_in = true,
      sign_date = today,
      reward = reward,
      bonus = bonus
    }
    task.player:doNotify("sign_in_SaintQuartz_callback", json.encode(result))
  end,
}

-- 金币换圣晶石 (9305金币 -> 1圣晶石)
Fk:addTaskDef {
  type = "exchange_gold_to_quartz",
  handler = function(task)
    local player = task.player
    if not player then
      task.player:doNotify("exchange_callback", json.encode({ success = false, message = "无效玩家" }))
      return
    end

    -- 获取当前金币和圣晶石
    local coinData = player:getGlobalSaveState("CS_System_Data") or {}
    local gold = coinData.gold or 0
    local state = player:getGlobalSaveState("hidden-clouds") or {}
    local quartz = state["SaintQuartz"] or {}
    local quartzNum = quartz.quartz_num or 0

    if gold < 9305 then
      task.player:doNotify("exchange_callback", json.encode({ success = false, message = "金币不足，需要9305金币" }))
      return
    end

    -- 扣金币
    local newGold = F.ChangePlayerMoney(player, -9305, true)
    -- 加圣晶石
    local newQuartz = F.ChangePlayerSaintQuartz(player, 1)

    -- 更新存档中的圣晶石数量
    quartz.quartz_num = newQuartz
    state["SaintQuartz"] = quartz
    player:saveGlobalState("hidden-clouds", state)

    local result = {
      success = true,
      gold = tostring(newGold),
      quartz_num = tostring(newQuartz),
      message = "兑换成功！消耗9305金币获得1圣晶石。"
    }
    task.player:doNotify("exchange_callback", json.encode(result))
  end,
}

-- 圣晶石兑金币 (1圣晶石 -> 9305金币)
Fk:addTaskDef {
  type = "exchange_quartz_to_gold",
  handler = function(task)
    local player = task.player
    if not player then
      task.player:doNotify("exchange_callback", json.encode({ success = false, message = "无效玩家" }))
      return
    end

    local state = player:getGlobalSaveState("hidden-clouds") or {}
    local quartz = state["SaintQuartz"] or {}
    local quartzNum = quartz.quartz_num or 0

    if quartzNum < 1 then
      task.player:doNotify("exchange_callback", json.encode({ success = false, message = "圣晶石不足，需要1圣晶石" }))
      return
    end

    -- 扣圣晶石
    local newQuartz = F.ChangePlayerSaintQuartz(player, -1)
    -- 加金币
    local newGold = F.ChangePlayerMoney(player, 9305, true)

    -- 更新圣晶石数量
    quartz.quartz_num = newQuartz
    state["SaintQuartz"] = quartz
    player:saveGlobalState("hidden-clouds", state)

    local result = {
      success = true,
      gold = tostring(newGold),
      quartz_num = tostring(newQuartz),
      message = "兑换成功！消耗1圣晶石获得9305金币。"
    }
    task.player:doNotify("exchange_callback", json.encode(result))
  end,
}

-- 获取玩家拥有的概念礼装
Fk:addTaskDef {
  type = "get_concept_clothes",
  handler = function(task)
    local player = task.player
    if not player then return end

    local state = player:getGlobalSaveState("hidden-clouds") or {}
    local quartz = state["SaintQuartz"] or {}
    local clothes = quartz.clothes or {}     -- 键值表 { ["wanhuajing"] = count, ... }

    -- 定义所有可用的礼装（名称、显示名、图片名、单次交换价格（圣晶石））
    local allClothes = {
      { name = "wanhuajing", displayName = "万华镜", price = 250 },
      -- { name = "linghua", displayName = "零化", price = 20 },
      -- { name = "xingchentian", displayName = "星辰天", price = 25 },
      -- 根据需要添加更多
    }

    local resultClothes = {}
    for _, cloth in ipairs(allClothes) do
      local count = clothes[cloth.name] or 0
      table.insert(resultClothes, {
        name = cloth.name,
        displayName = cloth.displayName,
        image = "../image/icon/clothes/" .. cloth.name .. ".jpg",
        count = count,
        price = cloth.price,
      })
    end

    local data = { clothes = resultClothes }
    task.player:doNotify("get_concept_clothes_callback", json.encode(data))
  end,
}

-- 交换概念礼装（增加持有数）
Fk:addTaskDef {
  type = "exchange_concept_clothes",
  handler = function(task)
    local player = task.player
    if not player then
      task.player:doNotify("exchange_concept_clothes_callback", json.encode({ success = false, message = "无效玩家" }))
      return
    end

    local args = task.data     -- 直接使用，无需 decode
    local clothName = args[1]
    local buyCount = args[2]
    local totalCost = args[3]     -- 使用前端计算的消耗

    -- 检查圣晶石余额
    local state = player:getGlobalSaveState("hidden-clouds") or {}
    local quartz = state["SaintQuartz"] or {}
    local quartzNum = quartz.quartz_num or 0
    if quartzNum < totalCost then
      task.player:doNotify("exchange_concept_clothes_callback", json.encode({ success = false, message = "圣晶石不足" }))
      return
    end

    -- 获取当前礼装持有数
    local clothes = quartz.clothes or {}
    local currentCount = clothes[clothName] or 0
    local newCount = currentCount + buyCount
    if newCount > 5 or newCount < 0 then
      task.player:doNotify("exchange_concept_clothes_callback", json.encode({ success = false, message = "超出限制" }))
      return
    end

    -- 扣除圣晶石
    local newQuartz = quartzNum - totalCost
    quartz.quartz_num = newQuartz

    -- 更新礼装数量
    clothes[clothName] = newCount
    quartz.clothes = clothes
    state["SaintQuartz"] = quartz
    player:saveGlobalState("hidden-clouds", state)
    local clothNames = {
      ["wanhuajing"] = "万华镜"
    }
    local result = {
      success = true,
      message = string.format("成功交换 %d 个 %s，消耗 %d 圣晶石", buyCount, clothNames[clothName], totalCost)
    }
    task.player:doNotify("exchange_concept_clothes_callback", json.encode(result))
  end,
}

-- 拓展包注册的额外页面
extension.customPages = {
  {
    name = "Chaldea Gate",
    iconUrl = "../../../hidden-clouds/image/icon/ChaldeaGate.png",
    qml = {
      url = "packages/hidden-clouds/qml/GachaSimulator.qml",
    }
  },
}

local CuChulainn = General:new(extension, "yyfy_CuChulainn", "Lancer", 4, 4, General.Male)
CuChulainn:addSkills { "yyfy_bishi", "yyfy_luen", "yyfy_siji" }
Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["Chaldea Gate"] = "迦勒底之门",
  ["moon"] = "月",
  ["Saber"] = "剑士",
  ["Archer"] = "弓兵",
  ["Lancer"] = "枪兵",
  ["Rider"] = "骑兵",
  ["Caster"] = "魔术师",
  ["Assassin"] = "暗杀者",
  ["Berserker"] = "狂战士",
  ["Foreigner"] = "降临者",
  ["MoonCancer"] = "月之癌",
  ["yyfy_CuChulainn"] = "库丘林",
  ["#yyfy_CuChulainn"] = "光之子",
  ["illustrator:yyfy_CuChulainn"] = "武内崇",
  ["cv:yyfy_CuChulainn"] = "神奈延年",
  ["designer:yyfy_CuChulainn"] = "Manic",
  ["~yyfy_CuChulainn"] = "失算……了……",
  ["!yyfy_CuChulainn"] = "什么嘛，真是不堪一击。"
}

local ArchetypeEarth = General:new(extension, "yyfy_ArchetypeEarth", "MoonCancer", 4, 4, General.Female)
ArchetypeEarth:addSkills { "yyfy_hongzhimoyan", "yyfy_xingzhituxi", "yyfy_FunnyVamp", "yyfy_kongxiangjvxianhua" }
Fk:loadTranslationTable
{
  ["yyfy_ArchetypeEarth"] = "爱尔奎特",
  ["#yyfy_ArchetypeEarth"] = "原初之一",
  ["illustrator:yyfy_ArchetypeEarth"] = "武内崇",
  ["cv:yyfy_ArchetypeEarth"] = "长谷川育美",
  ["designer:yyfy_ArchetypeEarth"] = "夜隐浮云",
  ["!yyfy_ArchetypeEarth"] = "已经结束了……期待与希望可没那么容易实现哦。",
  ["~yyfy_ArchetypeEarth"] = "……意料外的情况，格外有趣……",
}

local Tezcatlipoca = General:new(extension, "yyfy_Tezcatlipoca", "Assassin", 4, 4, General.Male)
Tezcatlipoca:addSkills { "yyfy_douzhengdemeili", "yyfy_heizhitaiyang", "yyfy_shanzhixinzang",
  "yyfy_diyitaiyang", "yyfy_zhanshizhisi", "yyfy_zhengwudetaiyang" }
Fk:loadTranslationTable
{
  ["yyfy_Tezcatlipoca"] = "烟雾镜",
  ["#yyfy_Tezcatlipoca"] = "特斯卡特利波卡",
  ["illustrator:yyfy_Tezcatlipoca"] = "田岛昭宇",
  ["cv:yyfy_Tezcatlipoca"] = "三上哲",
  ["designer:yyfy_Tezcatlipoca"] = "夜隐浮云",
  ["!yyfy_Tezcatlipoca"] = "结束了。战士之灵我会欢迎。除此以外的还是重新来过吧。",
  ["~yyfy_Tezcatlipoca"] = "很快就会回来。我是不灭的。",
}
Tezcatlipoca:addRelatedSkill("fate_fuxiaodetaiyang")

local ORT = General:new(extension, "yyfy_ORT", "Foreigner", 2, 2, General.Agender) -- ORT无性别
ORT:addSkills { "yyfy_yuzhouxian", "yyfy_PPliansuo", "yyfy_baofa", "yyfy_xietiao_ORT" }
Fk:loadTranslationTable
{
  ["yyfy_ORT"] = "O R T",
  ["#yyfy_ORT"] = "人类威胁苏醒",
  ["designer:yyfy_ORT"] = "夜隐浮云",
}

local mobileORT = General:new(extension, "yyfy_mobileORT", "Foreigner", 10, 10, General.Agender) -- ORT无性别
mobileORT:addSkills { "yyfy_bushijianglin", "yyfy_yuzhouxian", "yyfy_PPliansuo",
"yyfy_jiexibianma", "yyfy_baofa", "yyfy_xietiao_mobileORT" }
Fk:loadTranslationTable
{
  ["yyfy_mobileORT"] = "移动O R T",
  ["#yyfy_mobileORT"] = "侵略型移动生命体",
  ["designer:yyfy_mobileORT"] = "夜隐浮云",
}
mobileORT.hidden = true

local flyingORT = General:new(extension, "yyfy_flyingORT", "Foreigner", 12, 12, General.Agender) -- ORT无性别
flyingORT:addSkills { "yyfy_bushijianglin", "yyfy_yuzhouxian", "yyfy_PPliansuo",
"yyfy_shiluoxinxing", "yyfy_xietiao_flyingORT"}
Fk:loadTranslationTable
{
  ["yyfy_flyingORT"] = "飞行O R T",
  ["#yyfy_flyingORT"] = "侵略型飞行生命体",
  ["designer:yyfy_flyingORT"] = "夜隐浮云",
}
flyingORT.hidden = true

local XibalbaORT = General:new(extension, "yyfy_XibalbaORT", "Foreigner", 10, 10, General.Agender) -- ORT无性别
XibalbaORT:addSkills { "yyfy_taiyangfengbao", "yyfy_xietiao_XibalbaORT", "yyfy_disanmiejue",
"yyfy_chuangshiji", "yyfy_huangjinshuhai"}
Fk:loadTranslationTable
{
  ["yyfy_XibalbaORT"] = "O R T希巴尔巴",
  ["#yyfy_XibalbaORT"] = "冠位降临者",
  ["designer:yyfy_XibalbaORT"] = "夜隐浮云",
}
XibalbaORT.hidden = true

local SaintQuartz = General:new(extension, "yyfy_SaintQuartz", "moon", 3, 3, General.Agender)
SaintQuartz:addSkills { "yyfy_ChaldeaGate" }
Fk:loadTranslationTable
{
  ["yyfy_SaintQuartz"] = "圣晶石系统",
  ["#yyfy_SaintQuartz"] = "迦勒底之门",
  ["designer:yyfy_SaintQuartz"] = "夜隐浮云",
}
SaintQuartz.hidden = true

return extension
