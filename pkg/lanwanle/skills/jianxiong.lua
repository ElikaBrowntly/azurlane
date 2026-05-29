local jianxiong = fk.CreateSkill {
  name = "lan__jianxiong",
}

Fk:loadTranslationTable{
  ["lan__jianxiong"] = "奸雄",
  [":lan__jianxiong"] = "当你受到伤害后，你可以摸一张牌，并获得造成伤害的牌。当你发动此技能后，摸牌数+1。",

  ["$lan__jianxiong1"] = "夫英雄者，胸怀大志，腹有良谋！",
  ["$lan__jianxiong2"] = "日月之行，若出其中。",
  ["$lan__jianxiong3"] = "星汉灿烂，若出其里。",
  ["$lan__jianxiong4"] = "宁教我负天下人休教天下人负我！",
}

jianxiong:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:usedSkillTimes(jianxiong.name, Player.HistoryGame)
    player:drawCards(n, jianxiong.name)
    if not player.dead and data.card and room:getCardArea(data.card) == Card.Processing then
      room:obtainCard(player, data.card, true, fk.ReasonJustMove, player, jianxiong.name)
    end
  end,
})

return jianxiong
