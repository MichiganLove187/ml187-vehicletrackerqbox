local utils = {}
local db = {}

function db.deleteOldTrackers()
    return MySQL.query.await('DELETE FROM `vehicle_trackers` WHERE startedAt < (NOW() - INTERVAL ? DAY)', {Config.TrackerLifespan})
end

function db.addTracker(serialNumber, vehiclePlate)
    return MySQL.prepare.await('INSERT INTO `vehicle_trackers` (`serialNumber`, `vehiclePlate`) VALUES (?, ?)', {serialNumber, vehiclePlate})
end

function db.deleteTracker(vehiclePlate)
    return MySQL.prepare.await('DELETE FROM `vehicle_trackers` WHERE `vehiclePlate` = ?', {vehiclePlate})
end

function db.getTracker(serialNumber)
    return MySQL.single.await('SELECT `serialNumber`, `vehiclePlate` FROM `vehicle_trackers` WHERE `serialNumber` = ? LIMIT 1', {serialNumber})
end

function db.isTracked(vehiclePlate)
    return MySQL.scalar.await('SELECT `serialNumber` FROM `vehicle_trackers` WHERE `vehiclePlate` = ? LIMIT 1', {vehiclePlate})
end

function db.getAllTrackers()
    return MySQL.query.await('SELECT `serialNumber`, `vehiclePlate` FROM `vehicle_trackers`')
end

function utils.getRandomSerialNumber()
    return lib.string.random('...........')
end

function utils.trim(plate)
    return (plate:gsub("^%s*(.-)%s*$", "%1"))
end

function utils.getVehicleNetworkIdByPlate(vehiclePlate)
    local vehicles = GetAllVehicles()
    for _, vehicle in ipairs(vehicles) do
        if utils.trim(GetVehicleNumberPlateText(vehicle)) == utils.trim(vehiclePlate) then
            return NetworkGetNetworkIdFromEntity(vehicle)
        end
    end
    return nil
end

function utils.isPlayerNearVehicle(playerCoords, vehiclePlate)
    local vehicle = lib.getClosestVehicle(playerCoords, Config.ScanDistance, true)
    if not vehicle or not DoesEntityExist(vehicle) or GetVehicleNumberPlateText(vehicle) ~= vehiclePlate then
        return false
    end
    return true
end

exports.qbx_core:CreateUseableItem(Config.Items.tracker, function(source, item)
    TriggerClientEvent('vehicle_tracker:client:placeTracker', source, item.info?.slot or item.slot, utils.getRandomSerialNumber())
end)

exports.qbx_core:CreateUseableItem(Config.Items.tablet, function(source, item)
    local trackers = db.getAllTrackers()
    TriggerClientEvent('vehicle_tracker:client:openTrackerTablet', source, trackers)
end)

exports.qbx_core:CreateUseableItem(Config.Items.scanner, function(source, item)
    TriggerClientEvent('vehicle_tracker:client:scanTracker', source, item.info?.slot or item.slot)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if cache.resource == resourceName then
        db.deleteOldTrackers()
    end
end)

lib.callback.register('vehicle_tracker:getTrackedVehicleBySerial', function(_, serialNumber)
    if type(serialNumber) ~= "string" or string.len(serialNumber) < 11 then return end
    
    local tracker = db.getTracker(serialNumber)
    if not tracker then return end
    
    local vehicleNetworkID = utils.getVehicleNetworkIdByPlate(tracker.vehiclePlate)
    if not vehicleNetworkID then return end
    
    local vehicleEntity = NetworkGetEntityFromNetworkId(vehicleNetworkID)
    if not DoesEntityExist(vehicleEntity) then return end
    
    local vehCoords = GetEntityCoords(vehicleEntity)
    return tracker.vehiclePlate, vector2(vehCoords.x, vehCoords.y)
end)

lib.callback.register('vehicle_tracker:isVehicleTracked', function(source, vehiclePlate)
    if type(vehiclePlate) ~= "string" or not utils.isPlayerNearVehicle(GetEntityCoords(GetPlayerPed(source)), vehiclePlate) then
        return false
    end
    return db.isTracked(utils.trim(vehiclePlate))
end)

lib.callback.register('vehicle_tracker:placeTracker', function(source, vehiclePlate, slot, serialNumber)
    if type(vehiclePlate) ~= "string" or type(serialNumber) ~= "string" or string.len(serialNumber) < 11 then return false end
    if not utils.isPlayerNearVehicle(GetEntityCoords(GetPlayerPed(source)), vehiclePlate) then return false end
    
    if not db.addTracker(serialNumber, utils.trim(vehiclePlate)) then return false end
    
    local Player = exports.qbx_core:GetPlayer(source)
    Player.Functions.RemoveItem(Config.Items.tracker, 1, slot)
    TriggerClientEvent('inventory:client:ItemBox', source, exports.ox_inventory:Items()[Config.Items.tracker], 'remove')
    
    return true
end)

lib.callback.register('vehicle_tracker:removeTracker', function(source, vehiclePlate, slot)
    if type(vehiclePlate) ~= "string" or not utils.isPlayerNearVehicle(GetEntityCoords(GetPlayerPed(source)), vehiclePlate) then
        return false
    end
    
    if not db.deleteTracker(utils.trim(vehiclePlate)) then return false end
    
    local Player = exports.qbx_core:GetPlayer(source)
    Player.Functions.RemoveItem(Config.Items.scanner, 1, slot)
    TriggerClientEvent('inventory:client:ItemBox', source, exports.ox_inventory:Items()[Config.Items.scanner], 'remove')
    
    return true
end)
