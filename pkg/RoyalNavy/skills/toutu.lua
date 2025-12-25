local yyfy_toutu = fk.CreateSkill{
  name = "yyfy_toutu",
  anim_type = "control",
}

Fk:loadTranslationTable{
  ["yyfy_toutu"] = "偷图",
  [":yyfy_toutu"] = "出牌阶段限一次，你可以随机获得以下每种图纸0~1张，并获得对应效果（X为该类图纸的数量）："..
  "<br>\n①<font color='red'>主炮</font>：你使用牌可以多结算X次；"..
  "<br>\n②<font color='orange'>副炮</font>：你使用杀造成伤害后，可令受伤角色获得【燃殇】然后对其造成X点火焰伤害；"..
  "<br>\n③<font color='green'>战斗机</font>：你受到的伤害-X；"..
  "<br>\n④<font color='cyan'>轰炸机</font>：你使用牌可以额外指定至多X个目标；"..
  "<br>\n⑤<font color='blue'>鱼雷</font>：你不因此技能造成伤害时，可令此伤害+X；"..
  "<br>\n⑥<font color='purple'>彩船</font>：出牌阶段限一次，你可从X+2个武将中选择X个，获得其武将牌上全部技能。",

  
  ["#yyfy_toutu-get"] = "偷图：每种图纸随机偷取0~1张",
  ["@yyfy_toutu_zhupao"] = "主炮",
  ["@yyfy_toutu_fupao"] = "副炮",
  ["@yyfy_toutu_zhandouji"] = "战斗机",
  ["@yyfy_toutu_hongzhaji"] = "轰炸机",
  ["@yyfy_toutu_yulei"] = "鱼雷",
  ["@yyfy_toutu_caichuan"] = "彩船",
  
  ["$yyfy_toutu1"] = "猜猜看，今天为你们准备的主菜是鱼雷呢，还是炮弹呢~？",
  ["$yyfy_toutu2"] = "赢啦，亲爱的，我们赢啦！耶~！",
}

local MARK_TYPES = {
  "zhupao",
  "fupao", 
  "zhandouji",
  "hongzhaji",
  "yulei",
  "caichuan",
}

yyfy_toutu:addEffect("active", {
  mute = true,
  prompt = "#yyfy_toutu-get",
  card_num = 0,
  target_num = 0,
  max_phase_use_time = 1,
  on_use = function(self, room, effect)
    local player = effect.from
    local obtained = {}
    
    -- 随机获得每种图纸0~1张
    for _, markType in ipairs(MARK_TYPES) do
      if math.random() < 0.5 then
        local markName = "@yyfy_toutu_" .. markType
        room:addPlayerMark(player, markName, 1)
        table.insert(obtained, markType)
      end
    end
    player:broadcastSkillInvoke(self.name, 1)
    player:chat("猜猜看，今天为你们准备的主菜是鱼雷呢，还是炮弹呢~？")
    -- 发送获得的图纸信息
    if #obtained > 0 then
      local obtainedNames = {}
      for _, markType in ipairs(obtained) do
        table.insert(obtainedNames, Fk:translate(markType))
      end
    end
    
    -- 彩船
    if table.contains(obtained, "caichuan") and not player:hasSkill("yyfy_caichuan") then
      room:handleAddLoseSkills(player, "yyfy_caichuan", yyfy_toutu.name, true, true)
    end
  end,
})

-- 主炮
yyfy_toutu:addEffect(fk.CardUsing, {
  mute = true,
  anim_type = "control",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yyfy_toutu.name) and
           player:getMark("@yyfy_toutu_zhupao") > 0 and
           #data.tos > 0 and (data.card.type == Card.TypeBasic or data.card:isCommonTrick() )
  end,
  on_use = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, "@yyfy_toutu_zhupao")
    local X = player:getMark("@yyfy_toutu_zhupao")
    data.additionalEffect = (data.additionalEffect or 0) + X
  end,
})

-- 副炮
yyfy_toutu:addEffect(fk.Damage, {
  mute = true,
  on_cost = function(self, event, target, player, data)
    if not (data.from and data.from:hasSkill(yyfy_toutu.name) and
           data.card and data.card.trueName == "slash" and
           data.from:getMark("@yyfy_toutu_fupao") > 0 and
           data.to:isAlive()) then return false end
    local room = player.room
    return room:askToSkillInvoke(data.from, {
      skill_name = yyfy_toutu.name,
      prompt = "是否令其获得【燃殇】并造成火焰伤害？"
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local from = data.from
    local to = data.to
    player.room:notifySkillInvoked(player, "@yyfy_toutu_fupao")
    player:broadcastSkillInvoke(self.name, 2)
    player:chat("赢啦，亲爱的，我们赢啦！耶~！")
    -- 获得燃殇
    room:handleAddLoseSkills(to, "ranshang", yyfy_toutu.name, true)
    
    -- 火焰伤害
    if from == nil then return end
    local X = from:getMark("@yyfy_toutu_fupao")
    room:damage{
      from = from,
      to = to,
      damage = X,
      damageType = fk.FireDamage,
      skillName = yyfy_toutu.name,
    }
  end,
})

-- 轰炸机
yyfy_toutu:addEffect(fk.AfterCardTargetDeclared, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yyfy_toutu.name) and
           player:getMark("@yyfy_toutu_hongzhaji") > 0 and
           player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local extraTargets = data:getExtraTargets({bypass_distances = true})
    if #extraTargets == 0 then return false end

    local X = player:getMark("@yyfy_toutu_hongzhaji")
    local maxNum = math.min(#extraTargets, X)
    
    local tos = room:askToChoosePlayers(player, {
      min_num = 0,
      max_num = maxNum,
      targets = extraTargets,
      skill_name = yyfy_toutu.name,
      prompt = "轰炸机：你可以为此牌额外选择X个目标",
      cancelable = true,
    })
    
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, "@yyfy_toutu_hongzhaji")
    local tos = event:getCostData(self).tos
    if tos == nil then return end
    for _, p in ipairs(tos) do
      data:addTarget(p)
    end
  end,
})

-- 鱼雷
yyfy_toutu:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(yyfy_toutu.name) and
           data.skillName ~= yyfy_toutu.name and
           player:getMark("@yyfy_toutu_yulei") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = yyfy_toutu.name,
      prompt = "鱼雷：是否要令此伤害+X？"
    })
  end,
  on_use = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, "@yyfy_toutu_yulei")
    local X = player:getMark("@yyfy_toutu_yulei")
    data.damage = data.damage + X
  end,
})

-- 战斗机
yyfy_toutu:addEffect(fk.DamageInflicted, {
  mute =true,
  on_cost = function(self, event, target, player, data)
    return data.to == player and player:hasSkill(yyfy_toutu.name) and
           player:getMark("@yyfy_toutu_zhandouji") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:notifySkillInvoked(player, "@yyfy_toutu_zhandouji")
    player:broadcastSkillInvoke(self.name, 2)
    local X = player:getMark("@yyfy_toutu_zhandouji")
    data.damage = math.max(0, data.damage - X)
  end,
})

return yyfy_toutu