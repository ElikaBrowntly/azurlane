local yyfy_gangquan = fk.CreateSkill {
  name = "yyfy_gangquan",
}

Fk:loadTranslationTable {
  ["yyfy_gangquan"] = "罡拳",
  [":yyfy_gangquan"] = "你可以将一张装备牌当指定相邻角色为目标的火【杀】使用（无次数限制）；" ..
      "你可以将一张锦囊牌当【决斗】使用。",

  ["$yyfy_gangquan1"] = "罡风贯耳，为我战歌！",
  ["$yyfy_gangquan2"] = "用这拳头，打破一切！",
}

yyfy_gangquan:addEffect("viewas", {
  anim_type = "offensive",
  pattern = "slash,duel",
  prompt = function(self, player)
    return "罡拳：将装备牌当火【杀】，或将锦囊牌当【决斗】使用"
  end,
  handly_pile = true,
  filter_pattern = {
    max_num = 1,
    min_num = 1,
    pattern = ".|.|.|.|.|equip,trick",
  },
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local type = Fk:getCardById(cards[1]).type
    local name = type == 2 and "duel" or "fire__slash"
    local c = Fk:cloneCard(name)
    c.skillName = yyfy_gangquan.name
    c:addSubcard(cards[1])
    if name == "fire__slash" then
      ---@diagnostic disable-next-line: assign-type-mismatch
      c.skill = Fk.skills["yyfy_gangquan__slash_skill"]
    end
    return c
  end,
  before_use = function(self, player, use)
    if use.card.name == "fire__slash" then
      local c = Fk:cloneCard("fire__slash")
      c.skillName = yyfy_gangquan.name
      c:addSubcard(use.card.subcards[1])
      use.card = c
      local room = player.room
      use.tos = table.filter(room.alive_players, function(p)
        return p ~= player and (p:getNextAlive() == player or player:getNextAlive() == p) and
            not player:isProhibited(p, c)
      end)
    end
  end,
  enabled_at_play = Util.TrueFunc,
  enabled_at_response = Util.FalseFunc
})

return yyfy_gangquan