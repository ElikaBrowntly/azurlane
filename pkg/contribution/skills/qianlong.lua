local qianlong = fk.CreateSkill {
  name = "lan__qianlong",
  tags = { Skill.Permanent },
}

local ok, D = pcall(require, "packages.DR-system.record.DRRP")

Fk:loadTranslationTable{
  ["lan__qianlong"] = "潜龙",
  [":lan__qianlong"] = "持恒技，游戏开始时，你获得20点道心值；如下情况时，你获得对应数量的道心值：" ..
  "当你受到1点伤害后——10点；当你造成1点伤害后——15点；当你获得牌后——5点。<br>你根据道心值视为拥有以下技能" ..
  "：<br>30点-<a href=':lan__yongzu'>〖拥族〗</a>；40点-<a href=':lan__lilu'>〖礼赂〗</a>；"..
  "50点-<a href=':lan__qingzheng'>〖清正〗</a>；60点-<a href=':lan__jiushi'>〖酒诗〗</a>；"..
  "70点-<a href=':lan__fangzhu'>〖放逐〗</a>；80点-<a href=':lan__huituo'>〖恢拓〗</a>；"..
  "90点-<a href=':zhimin'>〖置民〗</a>；100点-<a href=':lan__juejin'>〖决进〗</a>。"..
  "当你获得以上所有技能后，每造成或受到伤害共计2次，则随机获得一个<a href='lord_of_wei'>大胃菌王</a>技能。",

  ["@lan__qianlong_daoxin"] = "道心值",

  ["lord_of_wei"] = "#<b>大胃菌王</b> 技能：即曹魏王室武将技能，包括<br><a href=':lan__qingliu'>〖清流〗</a>，"..
  "<a href=':lan__yizheng'>〖翊正〗</a>，<a href=':lan__yijin'>〖亿金〗</a>，<a href=':lan__jianxiong'>〖奸雄〗</a>，"..
  "<a href=':lan__xixiang'>〖西向〗</a>，<a href=':lan__aige'>〖哀歌〗</a>，<a href=':lan__zhenglue'>〖政略〗</a>，"..
  "<a href=':lan__dingxi'>〖定西〗</a>，<a href=':hx__kangkai'>〖慷忾〗</a>，<a href=':lan__chihui'>〖炽灰〗</a>，"..
  "<a href=':lan__fuxi'>〖赴曦〗</a>，<a href=':lan__xingshang'>〖行殇〗</a>，<a href=':dl__luoying'>〖落英〗</a>，"..
  "<a href=':lan__chengxiang'>〖称象〗</a>，<a href=':ol_ex__renxin'>〖仁心〗</a>，<a href=':lan__jiangchi'>〖将驰〗</a>，"..
  "<a href=':mingjian'>〖明鉴〗</a>，<a href=':lan__zhaotu'>〖招图〗</a>，<a href=':jingju'>〖惊惧〗</a>。",

  ["$lan__qianlong1"] = "暗蓄忠君之士，以待破局之机！",
  ["$lan__qianlong2"] = "若安司马于外，或则皇权可收！",
  ["$lan__qianlong3"] = "朕为天子，岂忍威权日去！",
  ["$lan__qianlong4"] = "假以时日，必讨司马一族！",
  ["$lan__qianlong5"] = "权臣震主，竟视天子于无物！",
  ["$lan__qianlong6"] = "朕行之决矣！正使死又何惧？",
}
-- 由于道心值变化而动态获得技能的函数
local function daoxin_handle_skills(player)
    local room = player.room
    if player:getMark("@lan__qianlong_daoxin") >= 30 and not player:hasSkill("lan__yongzu") then
    room:handleAddLoseSkills(player, "lan__yongzu")
  end
  if player:getMark("@lan__qianlong_daoxin") >= 40 and not player:hasSkill("lan__lilu") then
    room:handleAddLoseSkills(player, "lan__lilu")
  end
  if player:getMark("@lan__qianlong_daoxin") >= 50 and not player:hasSkill("lan__qingzheng") then
    room:handleAddLoseSkills(player, "lan__qingzheng")
  end
  if player:getMark("@lan__qianlong_daoxin") >= 60 and not player:hasSkill("lan__jiushi") then
    room:handleAddLoseSkills(player, "lan__jiushi")
  end
  if player:getMark("@lan__qianlong_daoxin") >= 70 and not player:hasSkill("lan__fangzhu") then
    room:handleAddLoseSkills(player, "lan__fangzhu")
  end
  if player:getMark("@lan__qianlong_daoxin") >= 80 and not player:hasSkill("lan__huituo") then
    room:handleAddLoseSkills(player, "lan__huituo")
  end
  if player:getMark("@lan__qianlong_daoxin") >= 90 and not player:hasSkill("zhimin") then
    room:handleAddLoseSkills(player, "zhimin")
  end
  if player:getMark("@lan__qianlong_daoxin") >= 100 and not player:hasSkill("lan__juejin") then
    room:handleAddLoseSkills(player, "lan__juejin")
  end
end

qianlong:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  daoxin_handle_skills(player)
end)

qianlong:addLoseEffect(function (self, player, is_death)
  local room = player.room
  room:setPlayerMark(player, "@lan__qianlong_daoxin", 0)
  room:handleAddLoseSkills(player, "-lan__yongzu|-lan__lilu|-lan__qingzheng|-lan__jiushi|-lan__fangzhu|-lan__huituo|-zhimin|-lan__juejin")
end)
--改变道心值的函数
local function ChangeDaoxin(player, num)
  local room = player.room
  local daoxin = player:getMark("@lan__qianlong_daoxin")
  num = math.min(100 - daoxin, num)
  if num > 0 then
    room:setPlayerMark(player, "@lan__qianlong_daoxin", daoxin + num)
    daoxin_handle_skills(player)
  end
end

qianlong:addEffect(fk.GameStart, {
  can_trigger = function (self, event, target, player, data)
    return player:hasSkill(qianlong.name) and player:getMark("@lan__qianlong_daoxin") < 100
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = 20
    if player:hasSkill("lan__weitong") and table.find(room.alive_players, function(p)
      return p ~= player and p.kingdom == "wei"
    end)
    then
      num = 100
      player:broadcastSkillInvoke("lan__weitong", 1)
      room:notifySkillInvoked(player, "weitong", "support")
    end
    ChangeDaoxin(player, num)
  end,
})

qianlong:addEffect(fk.Damaged, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(qianlong.name) and player:getMark("@lan__qianlong_daoxin") < 100
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    ChangeDaoxin(player, 10 * data.damage)
  end,
})

qianlong:addEffect(fk.Damage, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(qianlong.name) and player:getMark("@lan__qianlong_daoxin") < 100
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    ChangeDaoxin(player, 15 * data.damage)
  end,
})
qianlong:addEffect(fk.AfterCardsMove, {
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(qianlong.name) and player:getMark("@lan__qianlong_daoxin") < 100 then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Card.PlayerHand then
          return true
        end
      end
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    ChangeDaoxin(player, 5)
  end,
})

local wei_lord_skills = {"lan__qingliu", "lan__yizheng", "lan__yijin", "lan__jianxiong",
"lan__xixiang", "lan__aige", "lan__zhenglue", "lan__dingxi", "hx__kangkai", "lan__chihui",
"lan__fuxi", "lan__xingshang", "dl__luoying", "lan__chengxiang", "ol_ex__renxin",
"lan__jiangchi", "mingjian", "lan__zhaotu", "jingju"}
-- 获得大魏君王的技能
local function get_wei_lord_skills(player)
  local randomIndex = math.random(#wei_lord_skills) -- 获取一个随机索引
  local removedSkill = table.remove(wei_lord_skills, randomIndex)
  player.room:handleAddLoseSkills(player, removedSkill)
end

qianlong:addEffect(fk.Damaged or fk.Damage, {
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(qianlong.name) and
    player:getMark("@lan__qianlong_daoxin") == 100 and #wei_lord_skills > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "lan__qianlong__weilord")
    if player:getMark("lan__qianlong__weilord") == 2 then
      get_wei_lord_skills(player)
      room:addPlayerMark(player, "lan__qianlong-achievements") -- 用于统计战功
      room:setPlayerMark(player, "lan__qianlong__weilord", 0)
    end
  end,
})

--战功：大魏君王
qianlong:addEffect(fk.GameFinished, {
  global = true,
  priority = 0.0001,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("lan__qianlong-achievements") >= 3 and ok
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local players = room.players
    local winners = data:split("+")
    for _, p in ipairs(players) do
      if table.contains(winners, p.role) and ok then
        D.updateAchievement(room, p, "lan__caomao", "lan__caomao_1", 1)
      end
    end
  end
})

return qianlong