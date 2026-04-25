local liangyuan = fk.CreateSkill{
  name = "lan__liangyuan&",
}

Fk:loadTranslationTable{
  ["lan__liangyuan&"] = "良缘",
  [":lan__liangyuan&"] = "出牌阶段或濒死结算中，你可以令曹宪曹华选择是否要让你将一张<font color='blue'>"
  .."「灵杉」</font>当<font color='blue'>【酒】</font>使用。",

  ["#lan__liangyuan&-invoke"] = "良缘：是否同意%dest将一张「灵杉」当【酒】使用？",

  ["$lan__liangyuan&1"] = "苍山有灵，杉树相依。",
  ["$lan__liangyuan&2"] = "前盟已断，杉树长别。",
  ["$lan__liangyuan&3"] = "心似双丝网，中有千千结。",
  ["$lan__liangyuan&4"] = "我本草木间人，和光同尘，唯此情常在"
}

liangyuan:addEffect("viewas", {
  anim_type = "support",
  pattern = "analeptic",
  prompt = "良缘：将一张「灵杉」当【酒】使用",
  card_num = 1,
  expand_pile = function ()
    local subcards = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      table.insertTable(subcards, p:getPile("lan__huamu_lingshan"))
    end
    return subcards
  end,
  card_filter = function (self, player, to_select, selected, selected_targets)
    local subcards = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      table.insertTable(subcards, p:getPile("lan__huamu_lingshan"))
    end
    return #selected == 0 and table.contains(subcards, to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("analeptic")
    card.skillName = liangyuan.name
    card:addSubcards(cards)
    return card
  end,
  before_use = function (self, player, use)
    if player:hasSkill("lan__liangyuan") then
      return
    end
    -- 没有原版良缘，说明不是二曹本人，需要征得二曹同意
    local room = player.room
    local owner
    for _, p in ipairs(room:getAlivePlayers()) do
      if p:hasSkill("lan__liangyuan") then
        owner = p
        break
      end
    end
    if not room:askToSkillInvoke(owner, {
      skill_name = "lan__liangyuan",
      prompt = "#lan__liangyuan&-invoke::"..player.id
    }) then
      return "Cancel"
    end
  end,
  enabled_at_play = function (self, player)
    local subcards = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      table.insertTable(subcards, p:getPile("lan__huamu_lingshan"))
    end
    return #subcards > 0 and #player:getViewAsCardNames(liangyuan.name, {"analeptic"}, subcards) > 0
  end,
  enabled_at_response = function (self, player, response)
    if response then return false end
    local subcards = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      table.insertTable(subcards, p:getPile("lan__huamu_lingshan"))
    end
    return #subcards > 0 and #player:getViewAsCardNames(liangyuan.name, {"analeptic"}, subcards) > 0
  end,
})

return liangyuan