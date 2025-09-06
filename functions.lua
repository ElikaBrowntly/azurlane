local functions = {}

-- 判断两个角色之间是否为敌对关系
function functions.isEnemy(from, to)
  if from.id == to.id then return false end -- 自己不是敌人
  
  if from.role == "lord" or from.role == "loyalist" then
    return (to.role ~= "lord" and to.role ~= "loyalist")
  elseif from.role == "rebel" then
    return (to.role == "lord" or to.role == "loyalist")
  elseif from.role == "renegade" then
    return true -- 内奸视所有其他角色为敌人
  end
  
  return false -- 默认不是敌人
end

return functions