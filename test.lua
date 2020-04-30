 --добавляешь цикл в конец серверной функции
 
 for _,task in pairs(cfg.doubleMissions) do
    for perm,mission in pairs(task) do -- each repair perm def
      -- add missions to users
      local users = vRP.getUsersByPermission(perm)
      for _, user in pairs(users) do
        local user_id = user
        local player = vRP.getUserSource(user_id)
        if vRP.getSpawns(user_id) == 1 and not vRP.hasMission(player) then -- check spawned without mission
          if math.random(1,mission.chance) == 1 then -- chance check
            local mdata = {}
            mdata.name = mission.title
            mdata.steps = {}
            --building steps
            for i=1,mission.steps do
              local step = {
                text = mission.title.."<br />Награда: "..mission.moneyReward.." $",
                onenter = function(player)
                  if i == 1 then
                    vRP.giveInventoryItem(player,mission.neededItem ,mission.steps-1)
                    vRP.nextMissionStep(player)
                  end
                  if i > 1 and i <= mission.steps then
                    if vRP.tryGetInventoryItem(player, mission.neededItem, 1) then
                      vRPclient._playAnim(player,false,{task=mission.tasks[math.random(1,#mission.tasks)]},false)
                      vRPRMclient._FreezePosition(player,true)
                      SetTimeout(1000*mission.interval, function()
                        vRPclient._stopAnim(player,false)
                        vRPRMclient._FreezePosition(player,false)
                      end)
                    end
                    vRP.nextMissionStep(player)
                  end
                  if i == mission.steps then
                    SetTimeout(1000*mission.interval, function()
                      if mission.reward ~= nil then
                        vRP.giveInventoryItem(player,mission.reward[math.random(1,#mission.reward)], math.random(1,5))
                      end
                      vRP.giveMoneyWithTax(player, "percent_firm", mission.moneyReward)
                      vRPclient._notify(player, "Вы получили "..mission.moneyReward.."$")
                      vRP.nextMissionStep(player)
                    end)
                  end
                end,
                position = randPos(i, mission)
              }
              table.insert(mdata.steps, step)
            end
            vRP.startMission(player,mdata)
          end
        end
      end
    end
  end
  
--функцию перед SetTimeout(30000,task_mission)
function randPos(i, mission)
  if i == 1 then
    return  mission.firstPos[math.random(1, #mission.firstPos)]
  elseif i > 1 then
    return mission.secondPos[math.random(1, #mission.secondPos)]
  end
end

--и это в конфиг
cfg.doubleMissions = {}


cfg.doubleMissions.builder = {
  ["builder.build"] = {
    chance = 5,
    title = "Починка здания",
    interval = 10,
    steps = 5,
    neededItem = "bMaterials",
    tasks = {
      "WORLD_HUMAN_WELDING",

    },
    firstPos = {
      {1074.3629150391,-1948.6986083984,30.804862976074}, --завод
      {-576.15588378906,5372.744140625,70.243194580078}, --лесопилка
      {-601.16418457031,2098.0070800781,130.24917602539}, --шахта
      {2704.3315429688,2780.2219238281,37.877986907959}, --карьер
    },
    secondPos = {
      {-456.59390258789,-904.21691894531,29.392835617065},
      {-457.75106811523,-953.32293701172,29.392831802368},
      {-464.73785400391,-879.76416015625,29.392818450928},
      {-439.9934387207,-879.67193603516,29.392837524414},
      {-456.18753051758,-900.58587646484,47.98392868042}
    },
    moneyReward = 5000,
    reward = {
      "rubber",
      "paint",
      "steel"
    }
  }
}
