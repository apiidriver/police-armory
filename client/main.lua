local QBCore = exports['qb-core']:GetCoreObject()
local inArmory = false
local customItems = {}

function RequestCustomItems()
    TriggerServerEvent('qb-policearmory:server:getCustomItems')
end

Citizen.CreateThread(function()
    print("Police Armory: Starting ped creation")
    for k, armory in pairs(Config.Armories) do
        print("Police Armory: Creating ped #" .. k)
        local pedModel = GetHashKey(armory.ped)

        RequestModel(pedModel)
        while not HasModelLoaded(pedModel) do
            Citizen.Wait(1)
        end
        print("Police Armory: Model loaded")

        local armoryPed = CreatePed(4, pedModel, armory.pedlocation.x, armory.pedlocation.y, armory.pedlocation.z - 1.0, armory.pedheading, false, true)
        print("Police Armory: Ped created at " .. armory.pedlocation.x .. ", " .. armory.pedlocation.y .. ", " .. armory.pedlocation.z)
        
        if armory.pedSettings.SetEntityInvincible then
            SetEntityInvincible(armoryPed, true)
        end
        
        if armory.pedSettings.SetBlockingOfNonTemporaryEvents then
            SetBlockingOfNonTemporaryEvents(armoryPed, true)
        end
        
        if armory.pedSettings.FreezeEntityPosition then
            FreezeEntityPosition(armoryPed, true)
        end

        RequestAnimDict(armory.pedanim.dict)
        while not HasAnimDictLoaded(armory.pedanim.dict) do
            Citizen.Wait(1)
        end
        TaskPlayAnim(armoryPed, armory.pedanim.dict, armory.pedanim.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
        print("Police Armory: Animation set")

        -- Try a simpler target implementation first
        exports.ox_target:addBoxZone({
            coords = vector3(armory.pedlocation.x, armory.pedlocation.y, armory.pedlocation.z),
            size = vector3(2.0, 2.0, 3.0),
            rotation = armory.pedheading,
            debug = false,
            options = {
                {
                    name = 'open_armory_' .. k,
                    icon = 'fas fa-box-open',
                    label = 'Open Armory',
                    canInteract = function()
                        local Player = QBCore.Functions.GetPlayerData()
                        return Player.job and (Player.job.name == 'police' or Player.job.name == 'sheriff')
                    end,
                    onSelect = function()
                        print("Police Armory: Zone target selected")
                        OpenArmory(armory)
                    end
                }
            }
        })
        print("Police Armory: Target added to ped")
    end
    print("Police Armory: All peds created")
end)

function OpenArmory(armory)
    local playerData = QBCore.Functions.GetPlayerData()
    local job = playerData.job.name
    local grade = playerData.job.grade.level

    print("Opening armory for job: " .. job .. " with grade: " .. grade) -- Debug print

    if armory.ArmoryItems and armory.ArmoryItems[job] then
        local itemsByGrade = {}
        
        -- First, add the default items from config
        for i = 0, grade do
            itemsByGrade[i] = {}
            if armory.ArmoryItems[job][i] then
                for _, item in pairs(armory.ArmoryItems[job][i]) do
                    print("Adding default item: " .. item.name .. " to grade: " .. i) -- Debug print
                    table.insert(itemsByGrade[i], item)
                end
            end
        end
        
        -- Then, add any custom items from the database
        if customItems and customItems[job] then
            for i = 0, grade do
                if customItems[job][i] then
                    for _, item in pairs(customItems[job][i]) do
                        print("Adding custom item: " .. item.name .. " to grade: " .. i) -- Debug print
                        table.insert(itemsByGrade[i], item)
                    end
                end
            end
        end

        if next(itemsByGrade) then
            print("Sending items to UI") -- Debug print
            SendNUIMessage({
                action = 'open',
                itemsByGrade = itemsByGrade,
                maxGrade = grade
            })
            SetNuiFocus(true, true)
            inArmory = true
        else
            print("No items found for player's job and grade") -- Debug print
            QBCore.Functions.Notify("You do not have access to the armory.", "error")
        end
    else
        print("No armory items found for job: " .. job) -- Debug print
        QBCore.Functions.Notify("You do not have access to the armory.", "error")
    end
end

RegisterNUICallback('close', function(data, cb)
    print("Close NUI callback triggered") -- Debug print
    SetNuiFocus(false, false)
    inArmory = false
    cb('ok')
end)

RegisterNUICallback('buyItem', function(data, cb)
    print("Buy item callback triggered for item: " .. data.item) -- Debug print
    TriggerServerEvent('qb-policearmory:server:buyItem', data.item, data.price, data.amount)
    cb('ok')
end)

RegisterNUICallback('checkout', function(data, cb)
    local items = data.items
    local paymentType = data.paymentType
    
    TriggerServerEvent('qb-policearmory:server:checkout', items, paymentType)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    inArmory = false
    
    -- Make sure to send a message back to the UI to hide itself
    SendNUIMessage({
        action = 'close'
    })
    
    cb('ok')
end)

RegisterNetEvent('qb-policearmory:client:receiveCustomItems')
AddEventHandler('qb-policearmory:client:receiveCustomItems', function(items)
    customItems = items
    print("Received custom armory items from server")
end)

RegisterNetEvent('qb-policearmory:client:refreshCustomItems')
AddEventHandler('qb-policearmory:client:refreshCustomItems', function()
    RequestCustomItems()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    RequestCustomItems()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if inArmory and IsControlJustReleased(0, 177) then -- 177 is the ESC key
            SetNuiFocus(false, false)
            inArmory = false
            
            -- Make sure to send a message back to the UI to hide itself
            SendNUIMessage({
                action = 'close'
            })
        end
    end
end)