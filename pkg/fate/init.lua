local extension = Package:new("fate")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/fate/skills")

local F = require("packages.hidden-clouds.functions")

-- 定义获取圣晶石数据的任务
Fk:addTaskDef {
  type = "get_player_SaintQuartz",
  handler = function(task)
    local player = task.player
    if not player then return end
    -- 获取玩家的全局存档数据（示例：CS_System_Data）
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
      gold = gold,
      kanbujiandeshou = kanbujiandeshou,
      sign_in = sign_in,
      sign_constant = sign_constant,
      quartz_num = quartz_num,
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

local CuChulainn = General:new(extension, "yyfy_CuChulainn", "moon", 4, 4, General.Male)
CuChulainn:addSkills { "yyfy_bishi", "yyfy_luen", "yyfy_siji" }
Fk:loadTranslationTable
{
  ["hidden-clouds"] = "夜隐浮云",
  ["Chaldea Gate"] = "迦勒底之门",
  ["moon"] = "月",
  ["yyfy_CuChulainn"] = "库丘林",
  ["#yyfy_CuChulainn"] = "光之子",
  ["illustrator:yyfy_CuChulainn"] = "武内崇",
  ["cv:yyfy_CuChulainn"] = "神奈延年",
  ["designer:yyfy_CuChulainn"] = "Manic",
  ["~yyfy_CuChulainn"] = "失算……了……",
  ["!yyfy_CuChulainn"] = "什么嘛，真是不堪一击。"
}

local ArchetypeEarth = General:new(extension, "yyfy_ArchetypeEarth", "moon", 4, 4, General.Female)
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

local Tezcatlipoca = General:new(extension, "yyfy_Tezcatlipoca", "moon", 4, 4, General.Male)
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

local ORT = General:new(extension, "yyfy_ORT", "moon", 2, 2, General.Agender) -- ORT无性别
ORT:addSkills { "yyfy_bushijianglin", "yyfy_yuzhouxian", "yyfy_xietiao" }
Fk:loadTranslationTable
{
  ["yyfy_ORT"] = "O R T",
  ["#yyfy_ORT"] = "人类威胁苏醒",
  ["designer:yyfy_ORT"] = "夜隐浮云",
}
--ORT:addRelatedSkill("fate_fuxiaodetaiyang")

return extension