local inArmory = false
local customItems = {}

-- Simplified Bridge logic for Standalone
local function GetPlayerData()
    return exports.qbx_core:GetPlayerData()
end

local function IsPolice()
    local data = GetPlayerData()
    if not data or not data.job then return false end
    -- Check against config jobs
    for _, job in ipairs(Config.Locations[1].jobs) do -- Simplified for first location
        if data.job.name == job then return true end
    end
    return false
end

local function IsOnDuty()
    local data = GetPlayerData()
    if not data or not data.job then return false end
    return data.job.onduty or false
end

local function ShowNotification(msg, type)
    lib.notify({
        title = Config.DepartmentName,
        description = msg,
        type = type or 'info'
    })
end

function RequestCustomItems()
    lib.callback('defiantArmory:server:getCustomItems', false, function(items)
        customItems = items or {}
    end)
end

local function CreateArmoryPeds()
    if not Config.Locations then return end

    for k, armory in pairs(Config.Locations) do
        local point = lib.points.new({
            coords = armory.pedlocation,
            distance = 50,
        })

        local armoryPed = nil

        function point:onEnter()
            local pedModel = GetHashKey(armory.ped)
            lib.requestModel(pedModel)
            armoryPed = CreatePed(4, pedModel, armory.pedlocation.x, armory.pedlocation.y, armory.pedlocation.z - 1.0, armory.pedheading, false, true)
            
            if armoryPed and DoesEntityExist(armoryPed) then
                if armory.pedSettings.SetEntityInvincible then SetEntityInvincible(armoryPed, true) end
                if armory.pedSettings.SetBlockingOfNonTemporaryEvents then SetBlockingOfNonTemporaryEvents(armoryPed, true) end
                if armory.pedSettings.FreezeEntityPosition then FreezeEntityPosition(armoryPed, true) end

                lib.requestAnimDict(armory.pedanim.dict)
                TaskPlayAnim(armoryPed, armory.pedanim.dict, armory.pedanim.anim, 8.0, -8.0, -1, 1, 0, false, false, false)
            end
            SetModelAsNoLongerNeeded(pedModel)

            exports.ox_target:addLocalEntity(armoryPed, {
                {
                    name = 'open_armory_' .. k,
                    icon = 'fas fa-box-open',
                    label = 'Access Armory',
                    distance = 2.0,
                    canInteract = function()
                        return IsPolice() and IsOnDuty()
                    end,
                    onSelect = function()
                        OpenArmory()
                    end
                },
                {
                    name = 'deposit_loadout_' .. k,
                    icon = 'fas fa-hand-holding-heart',
                    label = 'Return & Retire Gear',
                    distance = 2.0,
                    canInteract = function()
                        return IsPolice()
                    end,
                    onSelect = function()
                        TriggerServerEvent('defiantArmory:server:manageLoadout', 'deposit')
                    end
                },
                {
                    name = 'withdraw_loadout_' .. k,
                    icon = 'fas fa-shield-alt',
                    label = 'Equip Full Shift Loadout',
                    distance = 2.0,
                    canInteract = function()
                        return IsPolice() and IsOnDuty()
                    end,
                    onSelect = function()
                        TriggerServerEvent('defiantArmory:server:manageLoadout', 'withdraw')
                    end
                }
            })
        end

        function point:onExit()
            if armoryPed and DoesEntityExist(armoryPed) then
                DeleteEntity(armoryPed)
                armoryPed = nil
            end
        end
    end
end

function CloseArmory()
    if not inArmory then return end
    SetNuiFocus(false, false)
    inArmory = false
    SendNUIMessage({ action = 'close' })
end

function OpenArmory()
    local PlayerData = GetPlayerData()
    if not PlayerData or not PlayerData.job then return end
    
    local job = PlayerData.job.name
    local grade = PlayerData.job.grade.level

    if Config.Items and Config.Items[job] then
        local itemsByGrade = {}

        -- Add items from config
        for i = 0, grade do
            itemsByGrade[i] = {}
            if Config.Items[job][i] then
                for _, item in pairs(Config.Items[job][i]) do
                    table.insert(itemsByGrade[i], item)
                end
            end
        end

        -- Add custom database items
        if customItems and customItems[job] then
            for i = 0, grade do
                if customItems[job][i] then
                    for _, item in pairs(customItems[job][i]) do
                        table.insert(itemsByGrade[i], item)
                    end
                end
            end
        end

        if next(itemsByGrade) then
            SendNUIMessage({
                action = 'open',
                itemsByGrade = itemsByGrade,
                maxGrade = grade
            })
            SetNuiFocus(true, true)
            inArmory = true
        else
            ShowNotification("No items available for your rank.", "error")
        end
    else
        ShowNotification("You do not have access to this armory.", "error")
    end
end

RegisterNUICallback('close', function(_, cb)
    CloseArmory()
    cb('ok')
end)

RegisterNUICallback('checkout', function(data, cb)
    TriggerServerEvent('defiantArmory:server:checkout', data.items, data.paymentType)
    cb('ok')
end)

-- State Bag Listener for Login
AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(GetPlayerServerId(PlayerId())), function(_, _, value)
    if value then RequestCustomItems() end
end)

RegisterNetEvent('defiantArmory:client:refreshCustomItems', function()
    RequestCustomItems()
end)

-- Initialization
CreateThread(function()
    Wait(1000)
    CreateArmoryPeds()
    RequestCustomItems()
end)

-- Exports
exports('OpenArmory', OpenArmory)
exports('CloseArmory', CloseArmory)