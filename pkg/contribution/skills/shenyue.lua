local shenyue = fk.CreateSkill {
  name = "yyfy_shenyue",
}

Fk:loadTranslationTable{
  ["yyfy_shenyue"] = "神乐",
  [":yyfy_shenyue"] = "为了神乐舞做准备，你每回合可以更换一次服饰，并变更背景音乐（未实装）。",
}

shenyue:addEffect("active", {
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
      "../image/generals/yyfy_LaffeyII.jpg",
      "../image/generals/yyfy_LaffeyII.jpg",
      "../image/generals/yyfy_LaffeyII.jpg"
    }
    local musicNames = { "歌曲1", "歌曲2", "歌曲3" }

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
      -- 在这里编写更换服饰和背景音乐的具体逻辑
      -- 例如：
      -- if dressIdx then 更换服饰 end
      -- if bgmIdx then 更换BGM end
    end
  end
})

return shenyue