local ok, U = pcall(require, "packages.glory_days.utility")

local extension = Package:new("contribution2")
extension.extensionName = "hidden-clouds"
extension:loadSkillSkelsByPath("./packages/hidden-clouds/pkg/contribution2/skills")

local mou__yongyimoyi = General:new(extension, "mou__yyfy_yongyimoyi", "god", 4, 4)
mou__yongyimoyi:addSkills { "yyfy_guopai", "beifen" }
Fk:loadTranslationTable
{
  ["mou"] = "谋？",
  ["contribution2"] = "投稿 2",
  ["mou__yyfy_yongyimoyi"] = "谋用一摸一",
  ["#mou__yyfy_yongyimoyi"] = "四血过牌悲愤",
  ["designer:mou__yyfy_yongyimoyi"] = "名字加载中……",
  ["~mou__yyfy_yongyimoyi"] = "空晓事而未见老，枉少作而愧对君……",
}

local shi__yongyimoyi = General:new(extension, "shi__yyfy_yongyimoyi", "god", 4, 4)
shi__yongyimoyi:addSkills { "yyfy_mingzhe", "beifen" }
Fk:loadTranslationTable
{
  ["shi"] = "",
  ["shi__yyfy_yongyimoyi"] = "失一摸一",
  ["#shi__yyfy_yongyimoyi"] = "诸葛瑾（",
  ["designer:shi__yyfy_yongyimoyi"] = "名字加载中……",
  ["~shi__yyfy_yongyimoyi"] = "臣一心向吴，忠心青天可鉴。",
}

local Robbins = General:new(extension, "yyfy__Robbins", "west", 3)
Robbins:addSkills { "yyfy_plan", "yyfy_organize", "yyfy_lead", "yyfy_motivate", "control", "yyfy_coordinate" }
Fk:loadTranslationTable
{
  ["yyfy__"] = "",
  ["yyfy__Robbins"] = "罗宾斯",
  ["#yyfy__Robbins"] = "管理学大师",
  ["designer:yyfy__Robbins"] = "夜隐浮云",
  ["~yyfy__Robbins"] = " ",
}

return extension