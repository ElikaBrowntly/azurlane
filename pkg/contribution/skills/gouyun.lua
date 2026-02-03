local gouyun = fk.CreateSkill {
  name = "yyfy_gouyun",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_gouyun"] = "狗运",
  [":yyfy_gouyun"] = "锁定技，你的判定牌生效前，你须指定其花色和点数。",
  ["#yyfy_gouyun-prompt-suit"] = "狗运：请指定判定牌的花色",
  ["#yyfy_gouyun-prompt-number"] = "狗运：请指定判定牌的点数",
  ["#GouyunChange"] = "%from 发动了【%arg】，将判定牌改为 %arg2 %arg3",
}

local U = require "packages/utility/utility"

gouyun:addEffect(fk.AskForRetrial, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(gouyun.name) and data.who == player
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 花色选择
    local suit_choices = {"黑桃", "红桃", "梅花", "方块"}
    
    local suit_choice = room:askToChoice(player, {
      choices = suit_choices,
      skill_name = gouyun.name,
      prompt = "#yyfy_gouyun-prompt-suit",
    })
    
    -- 点数选择
    local number_choices = {}
    for i = 1, 13 do
      table.insert(number_choices, tostring(i))
    end
    
    local number_choice = room:askToChoice(player, {
      choices = number_choices,
      skill_name = gouyun.name,
      prompt = "#yyfy_gouyun-prompt-number",
    })
    
    -- 将选择的花色和点数转换为对应的值
    local suit_map = {
      ["黑桃"] = Card.Spade,
      ["红桃"] = Card.Heart, 
      ["梅花"] = Card.Club,
      ["方块"] = Card.Diamond,
    }
    
    local selected_suit = suit_map[suit_choice] or Card.NoSuit
    local selected_number = tonumber(number_choice) or 1
    
    -- 获取原判定牌的牌名
    local cardName = data.card.trueName
    -- 这里有一个小小的fixme，首先不能像ol活动场的地藏王技能【大愿】那样最终指定，因为需要给别人留改判机会；
    -- 其次，新月杀暂时没找到在中途直接操控判定点数和花色的办法，已有的改判都是“拿一张新的实体牌当判定牌”。
    -- 这里本来想印一张虚拟牌代替判定牌，用完即弃，但是新月杀的虚拟牌不具备点数，即使印牌前设置了点数，
    -- 实际使用时也没有点数，不能当判定牌。最后只好妥协，印一张实体牌当判定牌（灵感来自神荀彧印奇正相生），
    -- 为了不对牌堆产生影响，印牌放在虚空区，由于判定牌生效后会进入弃牌堆，我们设置进入弃牌堆时销毁，
    -- （参考ol蒲元）这样这张实体牌就是用完即弃，不会对牌堆产生影响。不过，还有一个小fixme就是，
    -- 那些用“一张手牌替换之”的改判将，如张角，如果在主视角之后改判，会暂时拿到这张实体牌，
    -- 算是一个小小的资敌，不过问题不大，在对面使用完进入弃牌堆后仍会销毁。期待出一个离开虚空区时销毁（bushi
    -- 印一张实体牌，放在虚空区
    local cardDic = {{cardName, selected_suit, selected_number}}
    -- 这里为什么要重置一次tag呢？因为prepareDeriveCards函数保存的tag如果已有，会直接读取原来的，
    -- 这会造成只要改判过一次，后续改判都没有用，都是第一次改判的结果，因为后续印卡都没有生效
    room:setTag("yyfy_gouyun_judge_card", nil)
    local printedCards = U.prepareDeriveCards(room, cardDic, "yyfy_gouyun_judge_card")
    -- 将印的牌移动到虚空区
    room:changeCardArea(printedCards, Card.Void)
    local printedCard = Fk:getCardById(printedCards[1])
    -- 设置销毁标记，进入弃牌堆时销毁
    room:setCardMark(printedCard, "__destr_discard", true)
    -- 使用实体牌进行改判
    room:changeJudge{
      card = printedCard,
      player = player,
      data = data,
      skillName = self.name,
    }
    -- 发送日志
    room:sendLog{
      type = "#GouyunChange",
      from = player.id,
      arg = gouyun.name,
      arg2 = suit_choice,
      arg3 = number_choice,
    }
  end,
})

return gouyun