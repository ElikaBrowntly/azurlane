local fusu = fk.CreateSkill{
  name = "yyfy_fusu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["yyfy_fusu"] = "复苏",
  [":yyfy_fusu"] = "锁定技，当你发动技能时，若“圣灵谱尼”阵亡，你令其复活并回复所有体力，然后你失去此技能。"
}

local all_generals = {"yyfy_shenglingpuni"}
local j = 1
while j <= 7 do
  table.insert(all_generals, "yyfy_shenglingpuni"..tostring(j))
  j = j + 1
end

fusu:addEffect(fk.SkillEffect, {
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    local room = player.room
    local targets = {}
    if not (player and player:hasSkill(self) and data.who == player) then return false end
    for _, p in ipairs(room:getAllPlayers()) do
      if p.dead and (table.contains(all_generals, p.general) or table.contains(all_generals, p.deputyGeneral)) then
        table.insert(targets, p)
      end
    end
    if #targets ~= 0 then
      event:setCostData(self, {tos = targets})
      return true
    end
  end,
  on_trigger = function (self, event, target, player, data)
    local targets = event:getCostData(self).tos
    local to
    local room = player.room
    if targets and #targets == 1 then
      to = targets
    elseif targets then
      to = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        skill_name = fusu.name,
        prompt = "复苏：请选择一位“圣灵谱尼”，令其复活"
      })
    end
    if type(to) == "table" and #to == 1 then
      room:revivePlayer(to[1], true, fusu.name)
      room:recover({
        who = to[1],
        num = to[1].maxHp - to[1].hp,
        recoverBy = player,
        skillName = fusu.name
      })
      room:handleAddLoseSkills(player, "-yyfy_fusu", fusu.name)
    end
  end
})

return fusu