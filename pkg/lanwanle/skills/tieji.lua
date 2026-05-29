local tieji = fk.CreateSkill {
  name = "lan__tieji",
}

Fk:loadTranslationTable{
  ["lan__tieji"] = "铁骑",
  [":lan__tieji"] = "你使用【杀】指定其他角色为目标后，你可令其本回合内技能失效、无法响应此【杀】，并与你进行“谋弈”："..
  "<br/>①直取敌营：你获得其一张牌；"..
  "<br/>②扰阵疲敌：你摸两张牌。"..
  "<br/>“谋弈”成功后，本回合出【杀】次数+1，然后你可以弃置一张手牌，获得一张【杀】。",

  ["@@lan__tieji-turn"] = "铁骑",
  ["@lan__tieji_slash-turn"] = "出杀+",
  ["lan__tieji-zhiqu"] = "直取敌营",
  ["lan__tieji-raozheng"] = "扰阵疲敌",
  ["lan__tieji-chuzheng"] = "出阵迎敌",
  ["lan__tieji-huwei"] = "拱卫中军",
  [":lan__tieji-zhiqu"] = "谋奕成功后，获得对方一张牌",
  [":lan__tieji-raozheng"] = "谋奕成功后，你摸两张牌",
  [":lan__tieji-chuzheng"] = "用于防御“直取敌营”(防止其获得你牌)",
  [":lan__tieji-huwei"] = "用于防“御扰阵疲敌”(防止其摸两张牌)",
  ["#lan__tieji-ask"] = "铁骑：你可以弃置一张手牌，然后获得一张【杀】",

  ["$lan__tieji1"] = "烈风罡影照白鞍，飒露行役战天山。",
  ["$lan__tieji2"] = "铁骑飞将逐仇虏，笑问何处玉门关。",
  ["$lan__tieji3"] = "随我号令，全军突击！",
  ["$lan__tieji4"] = "铁骑冲锋，碾碎他们！",
}

local U = require "packages.utility.utility"
local ok, DL = pcall(require, "packages.delight.dlfs")
tieji:addEffect(fk.TargetSpecified, {
  mute = true,
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tieji.name) and data.to ~= player and data.card.trueName == "slash"
  end,
  on_use = function(self, event, target, player, data)
    if ok then
      DL.doSkinAnim(player, tieji.name, { "dlmou__machao_1", "dlmou__machao_1__daiji" })
    end
    local room = player.room
    local to = data.to
    data.disresponsive = true
    room:addPlayerMark(to, "@@lan__tieji-turn")
    local choices = U.doStrategy(room, player, to,
    { "lan__tieji-zhiqu", "lan__tieji-raozheng" },
    { "lan__tieji-chuzheng", "lan__tieji-huwei" },
    tieji.name, 1)
    local success = false
    if choices[1] == "lan__tieji-zhiqu" and choices[2] ~= "lan__tieji-chuzheng" then
      success = true
      if not to:isNude() then
        local card = room:askToChooseCard(player, { target = to, flag = "he", skill_name = tieji.name })
        room:obtainCard(player, card, false, fk.ReasonPrey, player, tieji.name)
      end
    elseif choices[1] == "lan__tieji-raozheng" and choices[2] ~= "lan__tieji-huwei" then
      success = true
      player:drawCards(2, tieji.name)
    end
    if success then
      room:addPlayerMark(player, "@lan__tieji_slash-turn")
      room:addPlayerMark(player, MarkEnum.SlashResidue .. "-turn")
      if #room:askToDiscard(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        prompt = "#lan__tieji-ask",
        skill_name = tieji.name,
        cancelable = true,
      }) > 0 then
        local cards = ok and DL.getCardsFromPileByRule(room, "slash", 1) or room:getCardsFromPileByRule("slash", 1)
        if #cards > 0 then
          room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonJustMove, tieji.name)
        end
      end
    end
  end,
})

tieji:addEffect("invalidity", {
  invalidity_func = function(self, from, skill)
    return from:getMark("@@lan__tieji-turn") > 0 and skill:isPlayerSkill(from)
  end,
})

return tieji