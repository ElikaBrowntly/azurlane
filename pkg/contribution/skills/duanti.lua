local yyfy_duanti = fk.CreateSkill {
  name = "yyfy_duanti",
  tags = { Skill.Switch, Skill.Compulsory },
  anim_type = "support",
}

local D = require "packages.DR-system.record.DRRP"

Fk:loadTranslationTable{
  ["yyfy_duanti"] = "锻体",
  [":yyfy_duanti"] = "转换技，锁定技，你每使用或打出一张牌结算结束后，阳：你增加一点体力上限；"..
  "阴：你回复一点体力。当你以此法增加5点体力上限后，你获得〖五灵〗。",
  
  ["$yyfy_duanti1"] = "人同于兽，奇经八脉、吐息参合，不宜异同。",
  ["$yyfy_duanti2"] = "兽长于野，餐风露，循作息，无病以扰。",
}

local function handleDuantiEffect(self, event, target, player, data)
  local room = player.room
  
  if player:getSwitchSkillState(yyfy_duanti.name) == fk.SwitchYang then
    -- 阳状态
    room:recover{
      who = player,
      num = 1,
      skillName = self.name,
    }
    
    
  else
    -- 阴状态
    room:changeMaxHp(player, 1)

    local yangCount = player:getMark("yyfy_duanti_yang") + 1
    room:setPlayerMark(player, "yyfy_duanti_yang", yangCount)

    if yangCount >= 5 and not player:hasSkill("wuling") then
      room:handleAddLoseSkills(player, "wuling")
      -- 计入战功进度
      D.updateAchievement(room, player, "yyfy_mou_wupu", "yyfy_mou_wupu_1", 3)
    end

  end
end

-- 使用结算后
yyfy_duanti:addEffect(fk.CardUseFinished, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = handleDuantiEffect,
})

-- 打出结算后
yyfy_duanti:addEffect(fk.CardRespondFinished, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = handleDuantiEffect,
})

return yyfy_duanti