local yyfy_mou_qingshu = fk.CreateSkill {
  name = "yyfy_mou_qingshu",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable {
  ["yyfy_mou_qingshu"] = "青书",
  [":yyfy_mou_qingshu"] = "持恒技，获得此技能时，你获得所有可能存在的<a href='yyfy_tianshu_href'>“天书”</a>组合。",
}

-- 太逆天了，737个技能，不能上线
-- yyfy_mou_qingshu:addAcquireEffect(function(self, player, is_start, src)
--   local room = player.room
--   for trigger = 1, 30 do
--     local effectNumbers = {}
--     for j = 1, 30 do
--       table.insert(effectNumbers, j)
--     end
--     -- 排除部分绑定时机效果
--     if not table.contains({ 4, 7, 18, 21, 25, 29, 30 }, trigger) then
--       table.removeOne(effectNumbers, 5) --获得造成伤害的牌
--     end
--     if not table.contains({ 8, 23 }, trigger) then
--       table.removeOne(effectNumbers, 13) --令此牌对你无效
--     end
--     if not table.contains({ 12, 16 }, trigger) then
--       table.removeOne(effectNumbers, 15) --改判
--       table.removeOne(effectNumbers, 16) --获得判定牌
--     end
--     if not table.contains({ 29, 30 }, trigger) then
--       table.removeOne(effectNumbers, 26) --伤害+1
--       table.removeOne(effectNumbers, 30) --防止伤害
--     end
--     -- 构建所有剩余效果的选项
--     local effectChoices = {}
--     for _, num in ipairs(effectNumbers) do
--       table.insert(effectChoices, "yyfy_tianshu_effects" .. num)
--     end
--     for _, choice_effect in ipairs(effectChoices) do
--       local effect = tonumber(string.sub(choice_effect, 21))
--       -- 房间记录技能信息（不再记录次数，仅记录组合）
--       local banner = room:getBanner("yyfy_tianshu_skills") or {}
--       local name = "yyfy_tianshu"
--       for i = 1, 737, 1 do
--         if banner["yyfy_tianshu" .. tostring(i)] == nil then
--           name = "yyfy_tianshu" .. tostring(i)
--           break
--         end
--       end
--       banner[name] = {
--         trigger,
--         effect,
--         player.id,
--       }
--       room:setBanner("yyfy_tianshu_skills", banner)
--       room:handleAddLoseSkills(player, name)
--     end
--   end
-- end)

return yyfy_mou_qingshu