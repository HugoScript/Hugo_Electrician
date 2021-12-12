----------------    CONFIG  ----------------
Config = {}
Config.Item = {
    {name = "729253480", x = 143.89, y = -939.03, z = 29},
}
Config.Entreprise = {
    {vehicle = "burrito3", x = -118.16, y = -958.36, z = 26.79}
}
Config.Ped = {
    {pedName = "a_m_y_business_03", x = -118.16, y = -958.36, z = 26.29}
}
ladderIsPut = false
repairStreetLight = false
ladderIsPutOnVehcicle = true
ladderIsPoseInVehcile = true
playerGotCar = false
playerGotClothe = false
----------------    PED  ----------------
Citizen.CreateThread(function()
    local playerPed = PlayerPedId()
    for k, v in pairs (Config.Ped) do
        local pedNameHash = RequestModel(GetHashKey(v.pedName))
        while not HasModelLoaded(GetHashKey(v.pedName)) do
            Wait(1)
        end
        
        npc = CreatePed(4, pedNameHash, v.x, v.y, v.z, 20, false, false)

	    SetEntityHeading(npc, 20)
	    FreezeEntityPosition(npc, true)
	    SetEntityInvincible(npc, true)
	    SetBlockingOfNonTemporaryEvents(npc, true)

        while true do 
            local playerCoords = GetEntityCoords(playerPed)
            distancePedPlayer = GetDistanceBetweenCoords(playerCoords, v.x, v.y, v.z, false)
            Citizen.Wait(5)
        end
    end
end)

----------------DEFINITION OF MENU ----------------
local menuPool = MenuPool()
menuPool.OnOpenMenu = function(screenPosition, hitSomething, worldPosition, hitEntity, normalDirection)
    CreateMenu(screenPosition, worldPosition, hitEntity)
end

----------------    MENU GENERAL    ----------------
function CreateMenu(screenPosition, worldPosition, hitEntity)
    menuPool:Reset()
    local contextMenu = menuPool:AddMenu()
    
    if (hitEntity ~= nil and DoesEntityExist(hitEntity)) then
        ----------------MENU STREET LIGHT ----------------
        if (IsEntityAnObject(hitEntity)) then

            --------MENU PUT LADDER  --------
            for k, v in pairs (Config.Item) do
                if ladderIsPut == false and ladderIsPutOnVehcicle == false then
                    streetLight = GetEntityModel(hitEntity)
                    if tonumber(v.name) == tonumber(streetLight) then
                        local menuLadderPut = contextMenu:AddItem("Put Ladder On Street Light ")
                        menuLadderPut.OnClick = function()
                            ladderPutFunction(hitEntity, ladderOnHand)
                        end   
                    end
                end
            end
            
            --------MENU REMOVE LADDER --------
            if ladderIsPut == true then
                local menuLadderRemove = contextMenu:AddItem("Remove Ladder On Street Light ")
                menuLadderRemove.OnClick = function()
                    repairStreetLight = false
                    ladderRemoveFunction(hitEntity)
                end  

             --------MENU REPAIR STREET LIGHT --------
                if repairStreetLight == false then
                    local menuStreetLightRepair = contextMenu:AddItem("Repair Street Light")
                    menuStreetLightRepair.OnClick = function()
                        repairStreetLightFunction(hitEntity)
                    end 
                end
            end

        --------MENU LADDER VEHICLE --------
        elseif (IsEntityAVehicle(hitEntity)) then 

            --------MENU REMOVE LADDER VEHICLE --------
            if tonumber(vehicleSpawn) == tonumber(hitEntity) then
                if ladderIsPoseInVehcile == true then
                    local menuLadderPut = contextMenu:AddItem("Remove Ladder From Vehicle ")
                    menuLadderPut.OnClick = function()
                        removeLadderFromVehicle(ladderVehicle)
                    end  
                end
                
                if ladderIsPutOnVehcicle == false then
                    local menuLadderPut = contextMenu:AddItem("Put Ladder On Vehicle ")
                    menuLadderPut.OnClick = function()
                        putLadderOnVehicle(ladderOnHand, vehicleSpawn)
                    end  
                end
            end 

        elseif (IsEntityAPed(hitEntity)) then 
            if tonumber(distancePedPlayer) <= tonumber(7) then
                --------MENU PED SPAWN CAR --------
                if tonumber(npc) == tonumber(hitEntity) then
                    if playerGotCar == false then
                        local menuLadderPut = contextMenu:AddItem("Got Electrician Vehicle ")
                        menuLadderPut.OnClick = function()
                            spawnCarForPlayer()
                        end  
                    end

                    if playerGotCar == true then
                        local menuLadderPut = contextMenu:AddItem("Storing The Vehicle ")
                        menuLadderPut.OnClick = function()
                            storingCarForPlayer(ladderVehicle, vehicleSpawn)
                        end  
                    end

                    if playerGotClothe == false then
                        local menuLadderPut = contextMenu:AddItem("Put Clothe ")
                        menuLadderPut.OnClick = function()
                            putPlayerClothe()
                        end  
                    end

                    if playerGotClothe == true then
                        local menuLadderPut = contextMenu:AddItem("Remove Clothe ")
                        menuLadderPut.OnClick = function()
                            removePlayerClothe()
                        end  
                    end
                end 
            end

        end
    end
    contextMenu:SetPosition(screenPosition)
    contextMenu:Visible(true)
end

----------------FUNCTION ITEM ----------------
function ladderPutFunction(hitEntity, ladderOnHand)
    local playerId = PlayerPedId()
    local playerCoords = GetEntityCoords(playerId)
    local objectCoords = GetEntityCoords(hitEntity)

    ladder = GetHashKey("dt1_15_ladder_003")
    ladderIsPut = true
    ladderIsPutOnVehcicle = true

    RequestAnimDict("mini")
    RequestAnimDict("mini@repair")
    while (not HasAnimDictLoaded("mini@repair")) do Citizen.Wait(0) end
    TaskPlayAnim(playerId,"mini@repair","fixing_a_ped",1.0,-1.0, 5000, 0, 1, true, true, true)

    Citizen.Wait(6000)

    DeleteEntity(ladderOnHand)

    ladderProps = CreateObject(ladder, objectCoords.x, objectCoords.y, objectCoords.z - 0.8, true, true, true)
    SetEntityHeading(ladderProps, 20)
	FreezeEntityPosition(ladderProps, true)
	SetEntityInvincible(ladderProps, true)
	SetBlockingOfNonTemporaryEvents(ladderProps, true)
end

function ladderRemoveFunction()
    local playerId = PlayerPedId()
    local playerCoords = GetEntityCoords(playerId)
    local ladder = GetHashKey("dt1_15_ladder_003")
    ladderIsPut = false
    ladderIsPutOnVehcicle = false
    ladderIsPoseInVehcile = false

    RequestAnimDict("mini")
    RequestAnimDict("mini@repair")
    while (not HasAnimDictLoaded("mini@repair")) do Citizen.Wait(0) end
    TaskPlayAnim(playerId,"mini@repair","fixing_a_ped",1.0,-1.0, 5000, 0, 1, true, true, true)

    Citizen.Wait(6000)
    
    DeleteEntity(ladderProps)

    ladderOnHand = CreateObject(ladder, playerCoords, true, true, true)

    AttachEntityToEntity(ladderOnHand, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), -0.2, 0.3, 0.5, 0, 0, -270.0, true, true, false, false, 1, true)

end

function repairStreetLightFunction()
    repairStreetLight = true
    effect = true
end

function removeLadderFromVehicle(ladderVehicle)
    local playerId = PlayerPedId()
    local playerCoords = GetEntityCoords(playerId)
    local ladder = GetHashKey("dt1_15_ladder_003")
    ladderIsPutOnVehcicle = false
    ladderIsPoseInVehcile = false
        
    RequestAnimDict("mini")
    RequestAnimDict("mini@repair")
    while (not HasAnimDictLoaded("mini@repair")) do Citizen.Wait(0) end
    TaskPlayAnim(playerId,"mini@repair","fixing_a_ped",1.0,-1.0, 5000, 0, 1, true, true, true)

    Citizen.Wait(6000)

    DeleteEntity(ladderVehicle)
    ladderOnHand = CreateObject(ladder, playerCoords, true, true, true)

    AttachEntityToEntity(ladderOnHand, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), -0.2, 0.3, 0.5, 0, 0, -270.0, true, true, false, false, 1, true)

end

function putLadderOnVehicle(ladderOnHand, vehicleSpawn)
    DeleteEntity(ladderOnHand)
    local playerId = PlayerPedId()
    local vehicleCoords = GetEntityCoords(vehicleSpawn)
    ladderIsPutOnVehcicle = true
    ladderIsPoseInVehcile = true

    RequestAnimDict("mini")
    RequestAnimDict("mini@repair")
    while (not HasAnimDictLoaded("mini@repair")) do Citizen.Wait(0) end
    TaskPlayAnim(playerId,"mini@repair","fixing_a_ped",1.0,-1.0, 5000, 0, 1, true, true, true)

    Citizen.Wait(6000)

    ladderVehicleHash = GetHashKey("dt1_08_ladder_003")
    ladderVehicle = CreateObject(ladderVehicleHash, vehicleCoords - 0.8, true, false, false)

    AttachEntityToEntity(ladderVehicle, vehicleSpawn, GetEntityBoneIndexByName(vehicleSpawn, "chassic"), 0.25, -1.55, 1.29, -270.0, 0.0, 0.0, true, true, false, true, 0, true)
end

function spawnCarForPlayer()
    for k, v in pairs (Config.Entreprise) do
        local vehicle = v.vehicle
        vehiclehash = GetHashKey(vehicle)
        RequestModel(vehiclehash)
        
        local waiting = 0
        while not HasModelLoaded(vehiclehash) do
            waiting = waiting + 100
            Citizen.Wait(100)
            if waiting > 5000 then  
                break
            end
        end
        vehicleSpawn = CreateVehicle(vehiclehash, v.x, v.y, v.z, 0.8, 1, 0)
        ladderVehicleHash = GetHashKey("dt1_08_ladder_003")
        ladderVehicle = CreateObject(ladderVehicleHash, v.x, v.y ,v.z - 0.8, true, false, false)

        AttachEntityToEntity(ladderVehicle, vehicleSpawn, GetEntityBoneIndexByName(vehicleSpawn, "chassic"), 0.25, -1.55, 1.29, -270.0, 0.0, 0.0, true, true, false, true, 0, true)
        playerGotCar = true
    end 
end

function storingCarForPlayer(ladderVehicle, vehicleSpawn)
    DeleteEntity(ladderVehicle)
    DeleteEntity(vehicleSpawn)
    playerGotCar = false
end

function putPlayerClothe()
    playerGotClothe = true
    local playerId = PlayerPedId()
    local testePedHash = RequestModel(GetHashKey("mp_m_freemode_01"))
    while not HasModelLoaded(GetHashKey("mp_m_freemode_01")) do
        Wait(1)
    end
        
        npcTeSTE = CreatePed(4, testePedHash, -117.16, -956.36, 26.29, 20, false, false)

	    SetEntityHeading(npcTeSTE, 20)
	    FreezeEntityPosition(npcTeSTE, true)
	    SetEntityInvincible(npcTeSTE, true)
	    SetBlockingOfNonTemporaryEvents(npcTeSTE, true)
        SetPedComponentVariation(npcTeSTE, 0, 0, 1, 1)
        SetPedComponentVariation(npcTeSTE, 10, 0, 1, 1)
        SetPedComponentVariation(npcTeSTE, 9, 0, 1, 1)
        SetPedComponentVariation(npcTeSTE, 8, 15, 1, 1)
        SetPedComponentVariation(npcTeSTE, 3, 12, 1, 1)
        SetPedComponentVariation(npcTeSTE, 5, 0, 1, 1)
        SetPedComponentVariation(npcTeSTE, 4, 34, 1, 1)
        SetPedComponentVariation(npcTeSTE, 6, 27, 1, 1)
        SetPedComponentVariation(npcTeSTE, 11, 90, 1, 1)
end

function removePlayerClothe()
    playerGotClothe = false
end
----------------PARTICLE FX SYSTEM ----------------
Citizen.CreateThread(function()
    effect = false
    local particleDictionary = "core"
    local particleName = "ent_amb_elec_crackle"
    RequestNamedPtfxAsset(particleDictionary)
    while not HasNamedPtfxAssetLoaded(particleDictionary) do
        Citizen.Wait(0)
    end
    local particleEffects = {}
    countItemInConfig = 0

    for k, v in pairs (Config.Item) do
        while true do
            if effect == false then
                UseParticleFxAssetNextCall(particleDictionary)
                particle = StartParticleFxLoopedAtCoord(particleName, 144.14, -939.45, 27.86, 0.0, 0.0, 0.0, 3.0, false, false, false,false)
                table.insert(particleEffects, 1, particle)
                Citizen.Wait(1)
            else
                for _, particle in pairs (particleEffects) do
                    StopParticleFxLooped(particle, true)
                    Citizen.Wait(1)
                end
            end
        end
    end
end)