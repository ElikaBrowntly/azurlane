local yyfy_toutu = fk.CreateSkill{
  name = "yyfy_toutu",
  anim_type = "control",
}

Fk:loadTranslationTable{
  ["yyfy_toutu"] = "偷图",
  [":yyfy_toutu"] = "出牌阶段限一次，你可以偷一张图纸，并获得对应效果（X为该类图纸的数量）："..
  "<br>\n①<font color='red'>彩炮</font>：你使用杀造成伤害后，可令受伤角色获得【燃殇】然后对其造成X点火焰伤害；"..
  "<br>\n②<font color='blue'>天雷</font>：你使用牌可以额外指定至多X个目标；"..
  "<br>\n③<font color='green'>la-9</font>：你不因此技能造成伤害时，可令此伤害+X；"..
  "<br>\n④<font color='purple'>彩船</font>：出牌阶段限一次，你可从X+1个萌势力武将中选择一个，获得其武将牌上全部技能。",

  
  ["#yyfy_toutu-choose"] = "偷图：请选择要获得的标记",
  ["caipao"] = "彩炮",
  ["tianlei"] = "天雷",
  ["caichuan"] = "彩船",
  ["@yyfy_toutu_caipao"] = "彩炮",
  ["@yyfy_toutu_tianlei"] = "天雷",
  ["@yyfy_toutu_la-9"] = "[la-9]",
  ["@yyfy_toutu_caichuan"] = "彩船",
  
  ["$yyfy_toutu1"] = "猜猜看，今天为你们准备的主菜是鱼雷呢，还是炮弹呢~？",
  ["$yyfy_toutu2"] = "赢啦，亲爱的，我们赢啦！耶~！",
}

local MARK_TYPES = {
  "caipao",
  "tianlei",
  "la-9",
  "caichuan",
}

yyfy_toutu:addEffect("active", {
  prompt = "#yyfy_toutu-choose",
  card_num = 0,
  target_num = 0,
  max_phase_use_time = 1,
  interaction = function(self, player)
    return UI.ComboBox {
      choices = MARK_TYPES,
      all_choices = MARK_TYPES,
    }
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local choice = self.interaction.data
    print(choice)
    if(choice=="caipao") then room:addPlayerMark(player,"@yyfy_toutu_caipao",1) end
    if(choice=="tianlei") then room:addPlayerMark(player,"@yyfy_toutu_tianlei",1) end
    if(choice=="la-9") then room:addPlayerMark(player,"@yyfy_toutu_la-9",1) end
    if(choice=="caichuan") then room:addPlayerMark(player,"@yyfy_toutu_caichuan",1) end
    print(player:getMark("@yyfy_toutu_caichuan") )
    -- 彩船
    if player:getMark("@yyfy_toutu_caichuan") > 0 and not player:hasSkill("yyfy_caichuan") then
      room:handleAddLoseSkills(player, "yyfy_caichuan", yyfy_toutu.name, true, true)
    end
  end,
})

-- 彩炮
yyfy_toutu:addEffect(fk.Damage, {
  on_cost = function(self, event, target, player, data)
    if not (data.from and data.from:hasSkill(yyfy_toutu.name) and
           data.card and data.card.trueName == "slash" and
           data.from:getMark("@yyfy_toutu_caipao") > 0 and
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
    
    -- 获得燃殇
    room:handleAddLoseSkills(to, "ranshang", yyfy_toutu.name, true)
    
    -- 火焰伤害
    if from == nil then return end
    local X = from:getMark("@yyfy_toutu_caipao")
    room:damage{
      from = from,
      to = to,
      damage = X,
      damageType = fk.FireDamage,
      skillName = yyfy_toutu.name,
    }
  end,
})

-- 天雷
yyfy_toutu:addEffect(fk.AfterCardTargetDeclared, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yyfy_toutu.name) and
           player:getMark("@yyfy_toutu_tianlei") > 0 and
           player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local extraTargets = data:getExtraTargets({bypass_distances = true})
    if #extraTargets == 0 then return false end

    local X = player:getMark("@yyfy_toutu_tianlei")
    local maxNum = math.min(#extraTargets, X)
    
    local tos = room:askToChoosePlayers(player, {
      min_num = 0,
      max_num = maxNum,
      targets = extraTargets,
      skill_name = yyfy_toutu.name,
      prompt = "天雷：你可以为此牌额外选择X个目标",
      cancelable = true,
    })
    
    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local tos = event:getCostData(self).tos
    if tos == nil then return end
    for _, p in ipairs(tos) do
      data:addTarget(p)
    end
  end,
})

-- la-9
yyfy_toutu:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(yyfy_toutu.name) and
           data.skillName ~= yyfy_toutu.name and
           player:getMark("@yyfy_toutu_la-9") > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = yyfy_toutu.name,
      prompt = "la-9：是否要令此伤害+X？"
    })
  end,
  on_use = function(self, event, target, player, data)
    local X = player:getMark("@yyfy_toutu_la-9")
    data.damage = data.damage + X
  end,
})

return yyfy_toutu