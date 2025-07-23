local skill = fk.CreateSkill{
  name = "fate_bishi",
  anim_type = "control",
}

Fk:loadTranslationTable{
  ["fate_bishi"] = "避矢",
  [":fate_bishi"] = "当【杀】或普通锦囊牌对唯一目标生效前，你可以进行一次判定："..
    "若与该牌类型相同，你令目标角色视为使用一张抵消此牌的牌（不可被响应）；否则，你获得此判定牌。",
  
  ["#fate_bishi-response"] = "%from 受到「%arg」效果影响，视为使用了一张响应 %arg2 的牌",
  ["#fate_bishi-obtain"] = "%from 获得「%arg」的判定牌",
  ["#fate_bishi-ask"] = "避矢：是否发动技能进行判定？",
  
  ["$fate_bishi1"] = "看得见的话就躲得开！",
  ["$fate_bishi2"] = "放马过来吧？",
}

skill:addEffect(fk.AskForCardUse, {
  can_trigger = function(self, event, target, player, data)
    local cardType = data.pattern
    if cardType ~= "jink" and cardType ~= "nullification" then
      return false
    end
    return player:hasSkill("fate_bishi") and player:isAlive()
  end,
  
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
        skill_name = "fate_bishi",
        prompt = "#fate_bishi-ask",
    })
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    
    local responseCard = Fk:cloneCard(data.pattern)

    local judge = {
      who = player,
      reason = self.name,
      pattern = nil,
    }
    room:judge(judge)
    
    local judgeCard = judge.card

    if judgeCard.type == responseCard.type then

      responseCard.skillName = self.name
      data.result = {
        from = target,
        tos = {},
        card = responseCard,
      }

      return true

    else
      room:obtainCard(player.id, judgeCard.id, false, fk.ReasonJustMove)
      return false
    end
  end,
})

skill:addEffect(fk.PreCardEffect, {
  can_trigger = function (self, event, target, player, data)
    return data.card:isCommonTrick() and player:hasSkill(skill.name) 
    and target:isAlive() and #data.tos == 1 and data.card.trueName ~= "nullification"
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
        skill_name = "fate_bishi",
        prompt = "#fate_bishi-ask",
    })
  end,
  on_use = function (self, event, target, player, data)
    local card = Fk:cloneCard("nullification")

    local judge = {
      who = player,
      reason = self.name,
      pattern = nil,
    }
    player.room:judge(judge)
    local judgeCard = judge.card
    
    if judgeCard.type == card.type then

    local use = {
      from = data.to,
      tos = data.to,
      skill_name = skill.name,
      card = card,
      cancelable = false,
      toCard = data.card
    }
    player.room:useCard(use)
    data.nullified = true

    else
      player.room:obtainCard(player.id, judgeCard.id, false, fk.ReasonJustMove)
      return false
    end
  end
})

return skill