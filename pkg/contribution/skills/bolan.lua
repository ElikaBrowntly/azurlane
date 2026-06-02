local bolan = fk.CreateSkill{
  name = "yyfy_bolan",
  attached_skill_name = "yyfy_bolan&",
  dynamic_desc = function (self, player, lang)
    return player:getMark("@@yyfy_yifa-turn") > 0 and
    "每名角色的出牌阶段限一次，其可以令你从随机三个<a href='yyfy_bolan-skill2'><font color='#8300FF'>"..
    "受到伤害后</font></a>的技能中选择一个获得直到本阶段结束。若不为你，其失去1点体力。" or
    "每名角色的出牌阶段限一次，其可以令你从随机三个<a href='yyfy_bolan-skills'><font color='#8300FF'>"..
    "出牌阶段限一次</font></a>的技能中选择一个获得直到本阶段结束。若不为你，其失去1点体力。"
  end
}

Fk:loadTranslationTable{
  ["yyfy_bolan"] = "博览",
  [":yyfy_bolan"] = "每名角色的出牌阶段限一次，其可以令你从随机三个<a href='yyfy_bolan-skill1'><font color='#8300FF'>"..
  "出牌阶段限一次</font></a>的技能中选择一个获得直到本阶段结束。若不为你，其失去1点体力。",
  ["yyfy_bolan-skill1"] = "“博览”技能池为多服扩充版，且不会出现房间禁卡",
  ["yyfy_bolan-skill2"] = "同魔曹操：<br><a href=':zhichi'>智迟 </a><a href=':ex__ganglie'>刚烈 </a><a href=':ex__fankui'>反馈 </a><br>"..
  " <a href=':ex__yiji'>遗计 </a><a href=':ol_ex__jieming'>节命 </a><a href=':fangzhu'>放逐 </a><br>"..
  "<a href=':shibei'>矢北 </a><a href=':ty_ex__chengxiang'>称象 </a><a href=':zhiyu'>智愚 </a><br>"..
  "<a href=':ty__jilei'>鸡肋 </a><a href=':ty__benyu'>贲育 </a><a href=':chouce'>筹策 </a><br>"..
  "<a href=':wuhun'>武魂 </a><br>",
  ["#yyfy_bolan-choice"] = "博览：选择令 %dest 此阶段获得技能",

  ["$yyfy_bolan1"] = "博览群书，融会贯通。",
  ["$yyfy_bolan2"] = "博览于文，约之以礼。",
}

BolanSkills = {
  --ol official skills
  "quhu", "qiangxi", "qice", "daoshu", "ol_ex__tiaoxin", "qiangwu", "tianyi", "ex__zhiheng", "ex__jieyin", "ex__guose",
  "lijian", "qingnang", "lihun", "mingce", "mizhao", "sanchen", "gongxin", "ex__chuli",
  --standard
  "ex__kurou", "ex__yijue", "fanjian", "ex__fanjian", "dimeng", "jijie", "poxi", "jueyan", "zhiheng","feijun", "tiaoxin",
  --sp
  "quji", "dahe", "tanhu", "fenxun","xueji", "re__anxu",
  --yjcm
  "nos__xuanhuo", "xinzhan", "nos__jujian", "ganlu", "xianzhen", "anxu", "gongqi", "huaiyi", "zhige", "anguo", "mingjian", "mieji",
  "duliang","junxing",
  --ol
  "ziyuan", "lianzhu", "shanxi", "lianji", "jianji", "liehou", "xianbi", "shidu", "yanxi", "xuanbei", "yushen", "bolong", "fuxun",
  "qiuxin", "ol_ex__dimeng", "juguan", "ol__xuehen", "ol__fenxun", "weikui", "caozhaoh", "ol_ex__changbiao","qingyix","qin__qihuo",
  "lilun","chongxin","xiaosi", "ol__mouzhu",
  --mobile
  "wuyuan", "zhujian", "duansuo", "poxiang", "hannan", "shihe", "wisdom__qiai", "shameng", "zundi", "mobile__shangyi", "yangjie",
  "m_ex__anxu", "beizhu", "mobile__zhouxuan", "mobile__yizheng", "guli", "m_ex__xianzhen", "m_ex__ganlu", "m_ex__mieji",
  "qiaosi", "pingcai","guanxu","guangu","shandao", "mou__zhiheng", "m_ex__junxing","mobile__yinju","dingzhou","guanzong","huiyao",
  --mougong
  "mou__qixi", "mou__lijian",
  --overseas
  "os__jimeng", "os__beini", "os__yuejian", "os__waishi", "os__weipo", "os__shangyi", "os__jinglue", "os__zhanyi", "os__daoji",
  "os_ex__gongqi", "os__gongxin", "os__zhuidu", "os__danlie","os__mutao",
  --tenyear
  "guolun", "kuiji", "ty__jianji", "caizhuang", "xinyou", "tanbei", "lueming", "ty__songshu", "ty__mouzhu", "libang", "nuchen",
  "weiwu", "ty__qingcheng", "ty__jianshu", "qiangzhiz", "ty__fenglue", "boyan", "ty_ex__mingce", "ty_ex__anxu",
  "ty_ex__mingjian", "ty_ex__quji", "jianzheng", "ty_ex__jixu", "ty__kuangfu", "yingshui", "weimeng", "tunan", "ty_ex__ganlu",
  "ty_ex__gongqi","huahuo","qiongying","jichun","xiaowu","mansi","kuizhen","zigu","ty_ex__wurong","jiuxianc","ty__lianji",
  "ty__xiongsuan","channi","ty__lianzhu","ty__beini","minsi","zhuren","cuijian", "changqu","ty__jiaohao","qingtan","yanjiao",
  "liangyan",
  --jsrg
  "js__yizheng", "shelun", "lunshi", "chushi", "pingtao","js__lianzhu","js__jinfa", "duxing", "yangming",
  --offline
  "miaojian", "xuepin", "ofl__shameng", "lifengs", "duyi", "mixin",
  --mini,
  "mini_yanshi", "mini_jifeng", "mini__jieyin", "mini__qiangwu", "mini_zhujiu",
}

BolanSkills2 = {
  "zhichi", "ex__ganglie", "ex__fankui", "yiji", "ol_ex__jieming", "fangzhu", "shibei",
  "ty_ex__chengxiang", "zhiyu", "ty__jilei", "ty__benyu", "chouce", "wuhun"
}

---@param room Room
local getBolanSkills = function(room)
  local mark = room:getBanner("yyfy_BolanSkills")
  if mark then
    return mark
  else
    local all_skills = {}
    for _, g in ipairs(room.general_pile) do
      for _, s in ipairs(Fk.generals[g]:getSkillNameList()) do
        table.insert(all_skills, s)
      end
    end
    local skills = table.filter(BolanSkills, function(s) return table.contains(all_skills, s) end)
    room:setBanner("yyfy_BolanSkills", skills)
    return skills
  end
end

---@param room Room
local getBolanSkills2 = function(room)
  local mark = room:getBanner("yyfy_BolanSkills2")
  if mark then
    return mark
  else
    local all_skills = {}
    for _, g in ipairs(room.general_pile) do
      for _, s in ipairs(Fk.generals[g]:getSkillNameList()) do
        table.insert(all_skills, s)
      end
    end
    local skills = table.filter(BolanSkills2, function(s) return table.contains(all_skills, s) end)
    room:setBanner("yyfy_BolanSkills2", skills)
    return skills
  end
end

bolan:addEffect("active", {
  can_use = function(self, player)
    return player and player:hasSkill(bolan.name) and player.phase == Player.Play
    and player:usedSkillTimes(bolan.name, Player.HistoryPhase) == 0
  end,
  target_num = 0,
  card_num = 0,
  card_filter = Util.FalseFunc,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from
    local all_skills = player:getMark("@@yyfy_yifa-turn") == 0 and getBolanSkills(room) or getBolanSkills2(room)
    local skills = table.filter(all_skills, function (skill_name)
      return not player:hasSkill(skill_name, true)
    end)
    if #skills > 0 then
      local choice = room:askToChoice(player, {
        choices = room:tableRandomPick(skills, 3),
        skill_name = bolan.name,
        prompt = "#yyfy_bolan-choice::"..player.id,
        detailed = true,
      })
      room:handleAddLoseSkills(player, choice)
      room.logic:getCurrentEvent():findParent(GameEvent.Phase):addCleaner(function()
        room:handleAddLoseSkills(player, "-"..choice)
      end)
    end
  end,
})

return bolan