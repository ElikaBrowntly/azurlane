local chengxiang = fk.CreateSkill{
  name = "lan__chengxiang",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["lan__chengxiang"] = "称象",
  [":lan__chengxiang"] = "持恒技，当你受到1点伤害后，你可以亮出牌堆顶四张牌，获得其中任意张数量点数之和不大于13的牌，将其余的牌置入弃牌堆。"..
  "若获得的牌点数之和恰好为13，你复原武将牌，且本局游戏发动〖称象〗时多亮出一张牌。",

  ["#lan__chengxiang-choose"] = "称象：请选择任意张点数之和不大于13的牌",

  ["$lan__chengxiang1"] = "父亲，父亲，看冲儿的！",
  ["$lan__chengxiang2"] = "白雀身小若此，何可比象之斤重?",
  ["$lan__chengxiang3"] = "若吾称得象重，文直须应我之约。",
  ["$lan__chengxiang4"] = "谁知道称大象需要几步？",
  ["$lan__chengxiang5"] = "象虽大，然可并舟称之。",
  ["$lan__chengxiang6"] = "大象，大象，你过来啊。",
  ["$lan__chengxiang7"] = "那我问你，象重几何？",
}

chengxiang:addEffect(fk.Damaged, {
  anim_type = "masochism",
  trigger_times = function(self, event, target, player, data)
    return data.damage
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 每达成一次13点就+1
    local baseNum = 4
    local extraNum = player:getMark("lan__chengxiang_extra")
    local num = baseNum + extraNum
    
    local cards = room:getNCards(num)
    room:turnOverCardsFromDrawPile(player, cards, chengxiang.name)
    
    local get = room:askToArrangeCards(player, {
      skill_name = chengxiang.name,
      card_map = {cards},
      prompt = "#lan__chengxiang-choose",
      free_arrange = false,
      box_size = 0,
      max_limit = {num, num},
      min_limit = {0, 1},
      poxi_type = "chengxiang",
      default_choice = {{}, {cards[1]}},
    })[2]
    
    -- 计算获得的牌点数之和
    local n = 0
    for _, id in ipairs(get) do
      n = n + Fk:getCardById(id).number
    end
    
    -- 移动获得的牌到玩家手牌
    room:moveCardTo(get, Player.Hand, player, fk.ReasonJustMove, chengxiang.name, nil, true, player)
    room:cleanProcessingArea(cards, chengxiang.name)
    
    -- 如果点数之和恰好为13
    if n == 13 then
      -- 复原武将牌
      player:reset()
      
      -- 永久增加后续发动称象时的亮牌数量
      room:addPlayerMark(player, "lan__chengxiang_extra", 1)
    end
  end
})

return chengxiang