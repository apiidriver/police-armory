local QBCore = exports['qb-core']:GetCoreObject()

function FetchCustomArmoryItems(callback)
    local customItems = {}
    
    MySQL.Async.fetchAll('SELECT * FROM police_armory_items', {}, function(results)
        for _, item in ipairs(results) do
            if not customItems[item.job] then
                customItems[item.job] = {}
            end
            
            if not customItems[item.job][item.grade] then
                customItems[item.job][item.grade] = {}
            end
            
            table.insert(customItems[item.job][item.grade], {
                name = item.name,
                label = item.label,
                price = item.price,
                description = item.description
            })
        end
        
        callback(customItems)
    end)
end

-- Add an item to the armory (admin only)
QBCore.Commands.Add('addarmoryitem', 'Add item to police armory (Admin Only)', {
    {name = 'job', help = 'Job name (e.g. police)'},
    {name = 'grade', help = 'Job grade required'},
    {name = 'item', help = 'Item name/id'},
    {name = 'label', help = 'Display name'},
    {name = 'price', help = 'Item price'},
    {name = 'description', help = 'Item description'}
}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.job.grade.level >= Config.AdminRanks[1] then
        local job = args[1]
        local grade = tonumber(args[2])
        local item = args[3]
        local label = args[4]
        local price = tonumber(args[5])
        local description = args[6] or ''
        
        MySQL.Async.execute('INSERT INTO police_armory_items (job, grade, name, label, price, description) VALUES (?, ?, ?, ?, ?, ?)',
            {job, grade, item, label, price, description},
            function(rowsChanged)
                if rowsChanged > 0 then
                    TriggerClientEvent('QBCore:Notify', src, 'Item added to armory', 'success')
                    -- Notify all clients to refresh their custom items
                    TriggerClientEvent('qb-policearmory:client:refreshCustomItems', -1)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Failed to add item', 'error')
                end
            end
        )
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission', 'error')
    end
end)

-- Remove an item from the armory (admin only)
QBCore.Commands.Add('removearmoryitem', 'Remove item from police armory (Admin Only)', {
    {name = 'id', help = 'Item ID in database'}
}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.job.grade.level >= Config.AdminRanks[1] then
        local id = tonumber(args[1])
        
        MySQL.Async.execute('DELETE FROM police_armory_items WHERE id = ?', {id}, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('QBCore:Notify', src, 'Item removed from armory', 'success')
                -- Notify all clients to refresh their custom items
                TriggerClientEvent('qb-policearmory:client:refreshCustomItems', -1)
            else
                TriggerClientEvent('QBCore:Notify', src, 'Failed to remove item', 'error')
            end
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission', 'error')
    end
end)

-- Get all armory items (admin only)
QBCore.Commands.Add('listarmoryitems', 'List all armory items (Admin Only)', {}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.job.grade.level >= Config.AdminRanks[1] then
        MySQL.Async.fetchAll('SELECT * FROM police_armory_items', {}, function(results)
            if #results > 0 then
                for _, item in ipairs(results) do
                    TriggerClientEvent('chat:addMessage', src, {
                        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(41, 41, 41, 0.6); border-radius: 3px;"><b>ID: {0}</b> | Job: {1} | Grade: {2} | Item: {3} | Price: ${4}</div>',
                        args = {item.id, item.job, item.grade, item.name, item.price}
                    })
                end
            else
                TriggerClientEvent('QBCore:Notify', src, 'No custom items found in armory', 'error')
            end
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission', 'error')
    end
end)

RegisterServerEvent('qb-policearmory:server:getCustomItems')
AddEventHandler('qb-policearmory:server:getCustomItems', function()
    local src = source
    
    FetchCustomArmoryItems(function(customItems)
        TriggerClientEvent('qb-policearmory:client:receiveCustomItems', src, customItems)
    end)
end)

RegisterServerEvent('qb-policearmory:server:buyItem')
AddEventHandler('qb-policearmory:server:buyItem', function(item, price, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player has enough money
    local totalPrice = price * amount
    if Player.PlayerData.money.cash >= totalPrice then
        -- Remove money
        Player.Functions.RemoveMoney('cash', totalPrice)
        
        -- Add item to inventory
        Player.Functions.AddItem(item, amount)
        
        -- Send success notification
        TriggerClientEvent('QBCore:Notify', src, 'You purchased ' .. amount .. 'x ' .. item .. ' for $' .. totalPrice, 'success')
        
        -- Trigger inventory update
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
    else
        -- Send error notification
        TriggerClientEvent('QBCore:Notify', src, 'You do not have enough money.', 'error')
    end
end)

RegisterServerEvent('qb-policearmory:server:checkout')
AddEventHandler('qb-policearmory:server:checkout', function(items, paymentType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local totalPrice = 0
    local itemsToGive = {}
    
    -- Calculate total price and prepare items
    for _, item in ipairs(items) do
        local itemPrice = item.price * item.quantity
        totalPrice = totalPrice + itemPrice
        
        table.insert(itemsToGive, {
            name = item.name,
            amount = item.quantity
        })
    end
    
    -- Check if player has enough money
    local canPay = false
    
    if paymentType == 'cash' then
        canPay = Player.Functions.RemoveMoney('cash', totalPrice)
    elseif paymentType == 'bank' then
        canPay = Player.Functions.RemoveMoney('bank', totalPrice)
    end
    
    if canPay then
        -- Give items to player
        local allItemsGiven = true
        
        for _, item in ipairs(itemsToGive) do
            local canCarry = exports.ox_inventory:CanCarryItem(src, item.name, item.amount)
            
            if canCarry then
                Player.Functions.AddItem(item.name, item.amount)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], 'add')
            else
                allItemsGiven = false
                -- Refund for this specific item
                local refundAmount = 0
                for _, cartItem in ipairs(items) do
                    if cartItem.name == item.name then
                        refundAmount = cartItem.price * cartItem.quantity
                        break
                    end
                end
                
                if paymentType == 'cash' then
                    Player.Functions.AddMoney('cash', refundAmount)
                elseif paymentType == 'bank' then
                    Player.Functions.AddMoney('bank', refundAmount)
                end
                
                TriggerClientEvent('QBCore:Notify', src, 'Cannot carry ' .. QBCore.Shared.Items[item.name].label, 'error')
            end
        end
        
        if allItemsGiven then
            TriggerClientEvent('QBCore:Notify', src, 'Purchase complete!', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Some items could not be added to your inventory.', 'warning')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have enough money', 'error')
    end
end)

QBCore.Functions.CreateCallback('qb-policearmory:server:canCarryItem', function(source, cb, item, amount)
    local src = source
    amount = tonumber(amount) or 1
    local canCarry = exports.ox_inventory:CanCarryItem(src, item, amount)
    cb(canCarry)
end)