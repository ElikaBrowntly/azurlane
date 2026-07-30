local skill = fk.CreateSkill{
  name = "yyfy_dianqigonglvMax",
  tags = { Skill.Compulsory }
}

Fk:loadTranslationTable {
  ["yyfy_dianqigonglvMax"] = "电气功率Max",
  [":yyfy_dianqigonglvMax"] = "每当你失去2张花色不同的牌后，你对一名角色造成1点伤害并弃置其1张牌，然后你摸1张牌，受到1点无来源伤害并获得1点护甲。",

  ["@yyfy_dianqigonglv"] = "电气功率",
  ["#yyfy_dianqigonglvMax-damage"] = "电气功率Max:请对一名角色造成1点伤害并弃置其1张牌",
  ["#yyfy_dianqigonglvMax-discard"] = "电气功率Max:请弃置%dest的1张牌",
  ["$yyfy_dianqigonglvMax1"] = "埃尔德里奇军团…冲锋…！",
  ["$yyfy_dianqigonglvMax2"] = "埃尔德里奇，是电气偶像……"
}

skill:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if not (player and player:hasSkill(self) and type(data) == "table") then return false end
    local past = player:getTableMark("@yyfy_dianqigonglv")
    for _, move in ipairs(data) do
      if move.from == player then
        for _, info in ipairs(move.moveInfo) do
          if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip)
          and not table.contains(past, Fk:getCardById(info.cardId):getSuitString(true))then
            table.insert(past, Fk:getCardById(info.cardId):getSuitString(true))
          end
        end
      end
    end
    player.room:setPlayerMark(player, "@yyfy_dianqigonglv", past)
    return #past >= 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@yyfy_dianqigonglv", 0)
    local to = room:askToChoosePlayers(player, {
      targets = room:getAlivePlayers(false),
      min_num = 1,
      max_num = 1,
      skill_name = skill.name,
      prompt = "#yyfy_dianqigonglvMax-damage",
      cancelable = false
    })
    if not to or #to ~= 1 then return end
    room:damage({
      from = player,
      to = to[1],
      damage = 1,
      skillName = skill.name
    })
    if to[1]:isAlive() then
      room:askToChooseCard(player, {
      target = to[1],
      flag = "he",
      skill_name = skill.name,
      prompt = "#yyfy_dianqigonglvMax-discard::"..to[1].id
    })
    end
    player:drawCards(1, skill.name)
    room:damage({
      to = player,
      damage = 1,
      skillName = skill.name
    })
    room:changeShield(player, 1)
  end,
})

return skill