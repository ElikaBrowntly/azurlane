local lunhui = fk.CreateSkill{
  name = "yyfy_lunhui",
  tags = { Skill.Compulsory },
  dynamic_desc = function (self, player, lang)
    return "yyfy_lunhui_inner:"..(player.tag["yyfy_lunhui"] or 0)
  end
}

Fk:loadTranslationTable{
  ["yyfy_lunhui"] = "轮回",
  [":yyfy_lunhui"] = "锁定技，共鸣技，你死亡时，若你的体力上限大于轮次+<font color='blue'>0</font>，"..
  "且武将牌已全部出场，你复活并增加一点体力上限。",
  [":yyfy_lunhui_inner"] = "锁定技，共鸣技，你死亡时，若你的体力上限大于轮次+<font color='blue'>{1}</font>，"..
  "且武将牌已全部出场，你复活并增加一点体力上限。"
}

local all_generals = {"yyfy_shenglingpuni"}
local j = 1
while j <= 7 do
  table.insert(all_generals, "yyfy_shenglingpuni"..tostring(j))
  j = j + 1
end

lunhui:addEffect(fk.BeforeGameOverJudge, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(lunhui.name, false, true) then
      local round = player.tag["yyfy_lunhui"] or 0
      return (table.contains(all_generals, player.general) or table.contains(all_generals, player.deputyGeneral))
      and player.maxHp > player.room:getBanner("RoundCount") + round
      and #player.tag["yyfy_shengling"] == 0
     end
    end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    room:setTag("SkipGameRule", true)
    room:revivePlayer(player, true, lunhui.name)
    player:chat("轮回更替之时，万物萌生！")
    room:changeMaxHp(player, 1)
    end
  })

return lunhui