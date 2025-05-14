local trackedVehicles = {}


local function uiNotify(description, nType)
    lib.notify({
        description = description, 
        type = nType, 
        position = Config.NotifyPosition, 
        iconAnimation = 'bounce', 
        duration = Config.NotifyDuration
    })
end

local function uiProgressBar(duration, label, anim, prop)
    return lib.progressBar({
        duration = duration,
        label = label,
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = anim,
        prop = prop
    })
end

local function playSound(soundConfig)
    local soundId = GetSoundId()
    PlaySoundFrontend(soundId, soundConfig.name, soundConfig.dict, false)
    SetTimeout(3000, function()
        StopSound(soundId)
        ReleaseSoundId(soundId)
    end)
end

local function createTrackerBlip(coords, plate, serialNumber)
    local blip = AddBlipForCoord(coords.x, coords.y, 0.0)
    
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAlpha(blip, Config.Blip.alpha)
    SetBlipDisplay(blip, Config.Blip.display)
    SetBlipScale(blip, Config.Blip.scale)
    PulseBlip(blip)
    SetBlipAsShortRange(blip, Config.Blip.shortRange)
    
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Tracker ' .. plate)
    EndTextCommandSetBlipName(blip)
    
    SetNewWaypoint(coords.x, coords.y)
    trackedVehicles[serialNumber] = blip
    
    return blip
end

RegisterNetEvent('vehicle_tracker:client:openTrackerTablet', function(trackers)
    if #trackers == 0 then
        return uiNotify('No active trackers found.', 'error')
    end
    if uiProgressBar(
        Config.ProgressDuration.connect, 
        ('Connecting...'),
        Config.Animations.tablet,
        Config.Props.tablet
    ) then
        local options = {}
        
        for _, tracker in ipairs(trackers) do
            table.insert(options, {
                title = ('Track Vehicle: ' .. tracker.vehiclePlate),
                event = 'vehicle_tracker:client:locateTracker',
                icon = 'location-dot',
                args = tracker.serialNumber
            })
        end
        
        lib.registerContext({
            id = 'vt_menu',
            title = ('Vehicle GPS Tracker'),
            options = options
        })
        
        lib.showContext('vt_menu')
    else
        uiNotify(('Cancelled'), 'error')
    end
end)

RegisterNetEvent('vehicle_tracker:client:manageTracker', function(serialNumber)
    lib.registerContext({
        id = 'vt_menu',
        title = ('Vehicle GPS Tracker'),
        options = {
            {
                title = ('Check GPS Location'),
                event = 'vehicle_tracker:client:locateTracker',
                icon = 'eye',
                args = serialNumber
            }
        }
    })
    
    if uiProgressBar(
        Config.ProgressDuration.connect, 
        ('Connecting...'),
        Config.Animations.tablet,
        Config.Props.tablet
    ) then 
        lib.showContext('vt_menu')
    else 
        uiNotify(('Cancelled'), 'error')
    end
end)

RegisterNetEvent('vehicle_tracker:client:scanTracker', function(slot)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), Config.ScanDistance, true)
    
    if vehicle == nil or not DoesEntityExist(vehicle) then 
        uiNotify(('No vehicle nearby!'), 'error')
        return 
    end
    
    if uiProgressBar(
        Config.ProgressDuration.scan, 
        ('Scanning...'),
        Config.Animations.mechanic,
        Config.Props.scanner
    ) then
        lib.callback('vehicle_tracker:isVehicleTracked', false, function(veh)
            if veh == nil then 
                uiNotify(('No GPS Tracker found on this vehicle.'), 'info')
                return 
            end
            
            playSound(Config.Sounds.alert)
            
            local alert = lib.alertDialog({
                header = ('GPS Tracker Found!'),
                content = ('You have found a GPS Tracker! Do you want to remove it?'),
                centered = true,
                cancel = true
            })
            
            if alert == 'confirm' then
                TriggerEvent('vehicle_tracker:client:removeTracker', slot)
            end
        end, GetVehicleNumberPlateText(vehicle))
    else
        uiNotify(('Cancelled'), 'error')
    end
end)

RegisterNetEvent('vehicle_tracker:client:placeTracker', function(slot, serialNumber)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), Config.PlaceDistance, true)
    
    if vehicle == nil or not DoesEntityExist(vehicle) then 
        uiNotify(('No vehicle nearby!'), 'error')
        return 
    end
    
    if uiProgressBar(
        Config.ProgressDuration.place, 
        ('Placing GPS Tracker...'),
        Config.Animations.mechanic,
        Config.Props.tracker
    ) then
        lib.callback('vehicle_tracker:placeTracker', false, function(success)
            if not success then return end
            
            playSound(Config.Sounds.success)
            uiNotify(('The GPS tracker was successfully placed on the vehicle!'), 'success')
        end, GetVehicleNumberPlateText(vehicle), slot, serialNumber)
    else
        uiNotify(('Cancelled'), 'error')
    end
end)

RegisterNetEvent('vehicle_tracker:client:removeTracker', function(slot)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), Config.ScanDistance, true)
    
    if vehicle == nil or not DoesEntityExist(vehicle) then 
        uiNotify(('No vehicle nearby!'), 'error')
        return 
    end
    
    local vehPlate = GetVehicleNumberPlateText(vehicle)
    
    lib.callback('vehicle_tracker:isVehicleTracked', false, function(veh)
        if veh == nil then 
            return uiNotify(('No GPS Tracker found on this vehicle.'), 'info')
        end
        
        if uiProgressBar(
            Config.ProgressDuration.remove, 
            ('Removing GPS Tracker...'),
            Config.Animations.mechanic,
            {}
        ) then
            lib.callback('vehicle_tracker:removeTracker', false, function(success)
                if not success then return end
                
                if trackedVehicles[veh.serialNumber] then
                    RemoveBlip(trackedVehicles[veh.serialNumber])
                    trackedVehicles[veh.serialNumber] = nil
                end
                
                playSound(Config.Sounds.success)
                uiNotify(('The GPS tracker was removed from the vehicle.'), 'success')
            end, vehPlate, slot)
        else
            uiNotify(('Cancelled'), 'error')
        end
    end, vehPlate)
end)

RegisterNetEvent('vehicle_tracker:client:locateTracker', function(serialNumber)
    if serialNumber == nil then 
        uiNotify(('This GPS Tracker is not placed on a vehicle.'), 'error')
        return 
    end
    
    lib.callback('vehicle_tracker:getTrackedVehicleBySerial', false, function(veh, vehCoords)
        if veh == nil then 
            uiNotify(('Unable to connect to the tracker!'), 'error')
            return 
        end
        
        if trackedVehicles[serialNumber] then
            RemoveBlip(trackedVehicles[serialNumber])
        end
        
        createTrackerBlip(vehCoords, veh, serialNumber)
        
        playSound(Config.Sounds.locate)
        uiNotify(('Connection successful! Location is set on your Map.'), 'success')
    end, serialNumber)
end)

CreateThread(function()
    while true do
        Wait(3000)
        for serialNumber, blip in pairs(trackedVehicles) do
            local blipAlpha = GetBlipAlpha(blip)
            if blipAlpha > 0 then
                SetBlipAlpha(blip, blipAlpha - 10)
            else
                trackedVehicles[serialNumber] = nil
                RemoveBlip(blip)
            end
        end
    end
end)

