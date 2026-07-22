local moshangsang = fk.CreateSkill {
  name = "yyfy_moshangsang",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable {
  ["yyfy_moshangsang"] = "陌上桑",
  [":yyfy_moshangsang"] = "锁定技，其他女性角色回合开始时，需要从《<a href='yyfy_luofu-moshangsang'>" ..
      "<font color='red'>陌上桑</font></a>》随机三句中选出正确的一句，若选对则获得此武将牌一个其他技能，否则其本轮非锁定技失效。",

  ["yyfy_luofu-moshangsang"] = "<b>《陌上桑》</b><br>收录于汉乐府，所以是汉势力。其实罗敷是战国时期赵国人，绝对不是因为懒所以没做赵势力（" ..
      "<br><br><font color='blue'><i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" ..
      "《陌上桑》者，出秦氏女子。秦氏，邯郸人，有女名罗敷，为邑人千乘王仁妻。王仁后为赵王家令，罗敷出采桑于陌上，" ..
      "赵王登台见而悦之，因置酒欲夺焉。罗敷巧弹筝，乃作《陌上桑》之歌以自明，赵王乃止。" ..
      "<div style = 'text-align:right;'>———晋·崔豹《古今注》</div></i></font>",

  ["$yyfy_moshangsang1"] = "碧玉闺秀，只可远观。",
  ["$yyfy_moshangsang2"] = "我的容貌，让你心动了吗？"
}

Fk:addMiniGame {
  name = "MoshangsangTest",
  qml_path = "packages/hidden-clouds/qml/MoshangsangBox",
  default_choice = function(player, data)
    return "false"   -- 挂机/超时默认视为挑战失败
  end,
  update_func = function(player, data)
    for _, p in ipairs(player.room.players) do
      p:doNotify("UpdateMiniGame", data)
    end
  end,
}

moshangsang:addEffect(fk.TurnStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player and player:hasSkill(self) and target.gender == General.Female
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local req = room:askToMiniGame({ target }, {
      skill_name = moshangsang.name,
      game_type = "MoshangsangTest",
      data_table = { [target.id] = {} },
      timeout = 6
    })
    room:delay(4000)
    if req:getResult(target) == "false" then
      room:addPlayerMark(target, MarkEnum.UncompulsoryInvalidity .. "-round")
      return
    end
    local skills = { "yyfy_guose", "jilve__tianxiang", "yyfy_biyue", "yyfy_xiuhua", "jilve__chenyu", "jilve__luoyan" }
    skills = table.filter(skills, function(s)
      return Fk.skills[s] and not target:hasSkill(s, true)
    end)
    if #skills == 0 then return end
    local result = room:askToCustomDialog(target, {
      skill_name = moshangsang.name,
      component = {
        url = "packages/utility/qml/ChooseSkillBox.qml",
        model = {
          url = "packages/utility/qml/models/ChooseSkillModel.qml",
          prop = {
            skills = skills,
            min = 1,
            max = 1,
            prompt = "陌上桑：请选择1个技能获得"
          }
        }
      }
    })
    if result == "" then return end
    if type(result) == "table" then
      result = result[1]
    end
    room:handleAddLoseSkills(target, result)
  end,
})

return moshangsang