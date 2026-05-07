-- Defiant Armory 2.0: Standalone Server Logic

-- Fetch custom items from DB
function FetchCustomArmoryItems(callback)
    local customItems = {}
    exports.oxmysql:query('SELECT * FROM police_armory_items', {}, function(results)
        if not results then callback({}); return end
        for _, item in ipairs(results) do
            if not customItems[item.job] then customItems[item.job] = {} end
            local grade = tonumber(item.grade) or 0
            if not customItems[item.job][grade] then customItems[item.job][grade] = {} end
            table.insert(customItems[item.job][grade], {
                name = item.name,
                label = item.label,
                price = item.price,
                description = item.description
            })
        end
        callback(customItems)
    end)
end

-- Callbacks
lib.callback.register('defiantArmory:server:getCustomItems', function(source)
    local p = promise.new()
    FetchCustomArmoryItems(function(items) p:resolve(items) end)
    return Citizen.Await(p)
end)

-- Checkout Logic
RegisterNetEvent('defiantArmory:server:checkout', function(items, paymentType)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not player.PlayerData.job then return end
    
    if not items or type(items) ~= 'table' or #items == 0 then return end
    
    -- Duty Check
    if not player.PlayerData.job.onduty then
        TriggerClientEvent('ox_lib:notify', src, {title = Config.DepartmentName, description = "You must be on duty to access the armory.", type = "error"})
        return
    end

    local totalPrice = 0
    local validItems = {}

    for _, item in ipairs(items) do
        local amount = tonumber(item.amount) or 1
        local price = tonumber(item.price) or 0
        if amount > 0 then
            totalPrice = totalPrice + (price * amount)
            table.insert(validItems, item)
        end
    end

    -- Check Balance
    local balance = player.PlayerData.money[paymentType] or 0
    if balance < totalPrice then
        TriggerClientEvent('ox_lib:notify', src, {title = Config.DepartmentName, description = "You do not have enough " .. paymentType .. " ($" .. totalPrice .. ")", type = "error"})
        return
    end

    -- Transaction Process
    if player.Functions.RemoveMoney(paymentType, totalPrice, "Armory Checkout") then
        -- Give Items
        for _, item in ipairs(validItems) do
            local metadata = { is_department_issue = true }
            local lowerName = item.name:lower()
            if lowerName:find("weapon_") then
                metadata.serial = "POL-" .. math.random(11111, 99999)
                metadata.anim = {
                    "reaction@intimidation@cop@unarmed", "intro", 400,
                    "reaction@intimidation@cop@unarmed", "outro", 450
                }
            end
            exports.ox_inventory:AddItem(src, item.name, item.amount, metadata)
        end

        -- Society Deposit (Optional integration with Renewed-Banking)
        if GetResourceState('Renewed-Banking') == 'started' then
            exports['Renewed-Banking']:addAccountMoney('police', totalPrice)
        end

        -- Database Logging
        exports.oxmysql:insert('INSERT INTO police_transactions (department, type, amount, description, source) VALUES (?, ?, ?, ?, ?)', {
            player.PlayerData.job.name,
            'deposit',
            totalPrice,
            'Armory Checkout (' .. #validItems .. ' items)',
            player.PlayerData.citizenid
        })

        TriggerClientEvent('ox_lib:notify', src, {title = Config.DepartmentName, description = "Purchase successful for $" .. totalPrice, type = "success"})
    else
        TriggerClientEvent('ox_lib:notify', src, {title = Config.DepartmentName, description = "Transaction failed.", type = "error"})
    end
end)

-- Admin Commands
lib.addCommand('addarmoryitem', {
    help = 'Add an item to the police armory',
    params = {
        {name = 'job', type = 'string', help = 'Job name'},
        {name = 'grade', type = 'number', help = 'Min grade'},
        {name = 'item', type = 'string', help = 'Item ID'},
        {name = 'label', type = 'string', help = 'Label'},
        {name = 'price', type = 'number', help = 'Price'},
    },
    restricted = 'group.admin'
}, function(source, args)
    exports.oxmysql:execute('INSERT INTO police_armory_items (job, grade, name, label, price) VALUES (?, ?, ?, ?, ?)', {
        args.job, args.grade, args.item, args.label, args.price
    }, function(res)
        if res.affectedRows > 0 then
            TriggerClientEvent('defiantArmory:client:refreshCustomItems', -1)
            TriggerClientEvent('ox_lib:notify', source, {title = Config.DepartmentName, description = "Item added to armory", type = "success"})
        end
    end)
end)

-- Loadout Management
RegisterNetEvent('defiantArmory:server:manageLoadout', function(action)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not player.PlayerData.job then return end
    
    local PlayerData = player.PlayerData

    if action == 'deposit' then
        local items = exports.ox_inventory:GetInventoryItems(src)
        local deletedCount = 0
        
        for slot, item in pairs(items) do
            if item.metadata and item.metadata.is_department_issue then
                exports.ox_inventory:RemoveItem(src, item.name, item.count, item.metadata, slot)
                deletedCount = deletedCount + 1
            end
        end
        
        if deletedCount > 0 then
            TriggerClientEvent('ox_lib:notify', src, {title = Config.DepartmentName, description = "Shift complete. All " .. deletedCount .. " department items returned.", type = "success"})
        else
            TriggerClientEvent('ox_lib:notify', src, {title = Config.DepartmentName, description = "No department items found to return.", type = "error"})
        end
    elseif action == 'withdraw' then
        local jobName = PlayerData.job.name
        local grade = PlayerData.job.grade.level
        
        local loadout = Config.Items[jobName] and Config.Items[jobName][grade]
        if not loadout then
            TriggerClientEvent('ox_lib:notify', src, {title = Config.DepartmentName, description = "No standard loadout defined for your rank.", type = "error"})
            return
        end

        local officerName = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname
        local issuedCount = 0

        for _, item in ipairs(loadout) do
            local metadata = {
                is_department_issue = true,
                issued_to = officerName,
                officer_cid = PlayerData.citizenid,
                issued_at = os.date("%Y-%m-%d %H:%M:%S"),
                serial = "POL-" .. math.random(111111, 999999)
            }

            if item.name:lower():find("weapon_") then
                metadata.anim = {
                    "reaction@intimidation@cop@unarmed", "intro", 400,
                    "reaction@intimidation@cop@unarmed", "outro", 450
                }
            end

            if exports.ox_inventory:AddItem(src, item.name, item.amount or 1, metadata) then
                issuedCount = issuedCount + 1
            end
        end

        if issuedCount > 0 then
            TriggerClientEvent('ox_lib:notify', src, {title = Config.DepartmentName, description = "Standard shift loadout issued. Good luck out there.", type = "success"})
        end
    end
end)