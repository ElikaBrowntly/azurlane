local shenyue = fk.CreateSkill {
  name = "yyfy_shenyue",
}

Fk:loadTranslationTable{
  ["yyfy_shenyue"] = "神乐",
  [":yyfy_shenyue"] = "为了神乐舞做准备，你每回合可以更换一次服饰，并变更背景音乐。",

  ["$yyfy_shenyue1"] = "《花鸟风月》",
  ["$yyfy_shenyue2"] = "《以恋结缘》",
  ["$yyfy_shenyue3"] = "《甘美风来》"
}

local generals = {"yyfy_TomotakeYoshino", "yyfy_TomotakeYoshino1", "yyfy_TomotakeYoshino2",
"yyfy_TomotakeYoshino3", "yyfy_TomotakeYoshino4", "yyfy_TomotakeYoshino5"}

shenyue:addEffect("active", {
  mute = true,
  anim_type = "drawcard",
  can_use = function (self, player)
    return player and player:hasSkill(self) and player.phase == Player.Play and player:usedSkillTimes(self.name) == 0
  end,
  card_num = 0,
  target_num = 0,
  prompt = "神乐：你可以更换服饰和BGM",
  on_use = function (self, room, skillUseEvent)
    local player = skillUseEvent.from
    local dressImages = {
      "../image/generals/yyfy_TomotakeYoshino1.jpg",
      "../image/generals/yyfy_TomotakeYoshino2.jpg",
      "../image/generals/yyfy_TomotakeYoshino3.jpg",
      "../image/generals/yyfy_TomotakeYoshino4.jpg",
      "../image/generals/yyfy_TomotakeYoshino5.jpg"
    }
    local musicCovers = {
      "../image/generals/yyfy_TomotakeYoshino1.jpg",
      "../image/generals/yyfy_shenyue1.jpg",
      "../image/generals/yyfy_shenyue2.jpg"
    }
    local musicNames = { "《花鸟风月》", "《以恋结缘》", "《甘美风来》" }

    local result = room:askToCustomDialog(player, {
      skill_name = shenyue.name,
      qml_path = "packages/hidden-clouds/qml/shenyue.qml",
      extra_data = {
        dressImages = dressImages,
        musicCovers = musicCovers,
        musicNames = musicNames
      }
    })

    if type(result) == "table" then
      local dressIdx = result.dress  -- 数字索引（0~2）或 nil
      local bgmIdx = result.bgm      -- 数字索引或 nil
      if dressIdx then
        if table.contains(generals, player.general) then
          room:setPlayerProperty(player, "general", "yyfy_TomotakeYoshino"..tostring(dressIdx + 1))
        elseif table.contains(generals, player.deputyGeneral) then
          room:setPlayerProperty(player, "deputyGeneral", "yyfy_TomotakeYoshino"..tostring(dressIdx + 1))
        end
      end
      if bgmIdx then
        player:broadcastSkillInvoke(shenyue.name, bgmIdx + 1)
      end
    end
  end
})

return shenyue