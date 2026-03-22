local zengzhi = fk.CreateSkill {
  name = "yyfy_zengzhi",
  tags = { Skill.Permanent }
}

Fk:loadTranslationTable {
  ["yyfy_zengzhi"] = "增殖",
  [":yyfy_zengzhi"] = "持恒技，其他角色使用牌或技能时，你摸1张牌、增加1点体力上限并回复1点体力。<font color='red'>（已进入禁卡表，无法发动）</font>",
  
  ["#yyfy_zengzhi_trigger"] = "%from 使用%arg，触发 %to 的「增殖」",
}

-- zengzhi:addLoseEffect(function(self, player, is_death)
--   player.room:handleAddLoseSkills(player, self.name, nil, false, true)
-- end)

-- zengzhi:addEffect(fk.CardUseFinished, {
--   anim_type = "drawcard",
--   can_trigger = function(self, event, target, player, data)
--     return target ~= player and player:hasSkill(zengzhi.name)
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local room = player.room
--     player:drawCards(1, zengzhi.name)
--     room:changeMaxHp(player, 1)
--     room:recover({
--       who = player,
--       num = 1,
--       skillName = zengzhi.name,
--     })
--   end,
-- })

-- zengzhi:addEffect(fk.SkillEffect, {
--   is_delay_effect = true,
--   anim_type = "drawcard",
--   can_trigger = function(self, event, target, player, data)
--     return target and target ~= player and data.skill.name ~= self.name and
--            player:hasSkill(zengzhi.name) and data.skill:isPlayerSkill(target)
--   end,
--   on_cost = Util.TrueFunc,
--   on_use = function(self, event, target, player, data)
--     local room = player.room  
--     player:drawCards(1, zengzhi.name)
--     room:changeMaxHp(player, 1)
--     room:recover({
--       who = player,
--       num = 1,
--       skillName = zengzhi.name,
--     })
--   end,
-- })

return zengzhi