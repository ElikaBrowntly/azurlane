local hedao = fk.CreateSkill{
  name = "yyfy_hedao",
  tags = { Skill.Wake },
}

Fk:loadTranslationTable{
  ["yyfy_hedao"] = "合道",
  [":yyfy_hedao"] = "觉醒技，你的濒死结算后，若被救回，则将体力回复至上限；否则你复活。然后你将武将牌"..
  "替换为<a href='yyfy_hedao_moulaoxian'>谋南华老仙</a>。",

  ["yyfy_hedao_moulaoxian"] = "<b>谋南华老仙 神 4/4</b><br><b>青书 </b>持恒技，获得此技能时，"..
  "你获得所有可能存在的“天书”<br><br><font color='red'>700+技能对服务器影响太大，故此效果不会执行。</font>",
  ["$yyfy_hedao1"] = "不参黄泉，难悟大道。",
  ["$yyfy_hedao2"] = "道者，亦置之死地而后生。"
}

hedao:addEffect(fk.AfterDying, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(hedao.name)
    and player.tag[hedao.name] ~= 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:recover({
      who = player,
      num = player.maxHp - player.hp,
      recoverBy = player,
      skillName = hedao.name
    })
    player.tag[hedao.name] = 1
  end,
})

hedao:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(hedao.name, false, true)
    and player.tag[hedao.name] ~= 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    local room = player.room
    player.tag[hedao.name] = 1
    room:setTag("SkipGameRule", true)
    room:revivePlayer(player)
    -- 不给换将
    -- local isDeputy = false
    -- if player.deputyGeneral == "yyfy_ex_nanhualaoxian" then
    --   isDeputy = true
    -- end
    -- room:changeHero(player, "yyfy_mou_nanhualaoxian", true, isDeputy)
  end,
})

return hedao