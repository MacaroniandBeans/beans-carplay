local currentVehicle = nil
local vehicleNetId = nil
local musicData = {}
local lastFadeVolume = 0.5

RegisterCommand('carplay', function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        lib.notify({ type = 'error', description = 'You must be in a vehicle.' })
        return
    end

    currentVehicle = GetVehiclePedIsIn(ped, false)
    vehicleNetId = NetworkGetNetworkIdFromEntity(currentVehicle)
    vehicleCoords = GetEntityCoords(currentVehicle)

    SendNUIMessage({ action = 'toggleUI', show = true })
    SetNuiFocus(true, true)
end, false)

RegisterNUICallback('getVolume', function(data, cb)
    if data and data.volume then
        lastFadeVolume = tonumber(data.volume)
    end
    cb({})
end)

RegisterNetEvent('carRadio:checkVehicleOccupants', function(data)
    local vehicle = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(vehicle) then return end

    for _, playerId in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(playerId)
        if IsPedInVehicle(ped, vehicle, false) then
            TriggerServerEvent('carRadio:sendToPlayer', GetPlayerServerId(playerId), data)
        end
    end
end)


RegisterNUICallback('sendMusicData', function(data, cb)
    musicData = {
        url = data.url,
        radius = data.radius,
        volume = data.volume,
        netId = vehicleNetId
    }
    TriggerServerEvent('carRadio:syncMusic', musicData)
    cb({})
end)


RegisterNUICallback('stopMusic', function(_, cb)
    TriggerServerEvent('carRadio:stopMusic', vehicleNetId)
    cb({})
end)

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNetEvent('carRadio:playMusic', function(data)
    musicData = data
    currentVehicle = NetworkGetEntityFromNetworkId(data.netId)

    SendNUIMessage({
        action = 'play',
        url = data.url,
        volume = data.volume or 0.5
    })

    local previousVolume = 0.0

    CreateThread(function()
        while musicData and musicData.url and DoesEntityExist(currentVehicle) do
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)
            local vehCoords = GetEntityCoords(currentVehicle)
    
            local dist = #(playerCoords - vehCoords)
            local radius = 15.0
            local fade = math.max(0.0, 1.0 - (dist / radius))
            SendNUIMessage({ action = 'getCurrentVolumeRequest' })
            local baseVolume = lastFadeVolume
            if type(baseVolume) ~= "number" then
                baseVolume = 0.5 
            end
    
            local targetVolume = baseVolume * fade
            local inVehicle = IsPedInVehicle(ped, currentVehicle, false)
            local doorOpen = false
            for i = 0, 3 do
                if GetVehicleDoorAngleRatio(currentVehicle, i) > 0.2 then
                    doorOpen = true
                    break
                end
            end
    
            if not inVehicle and not doorOpen then
                targetVolume = targetVolume * 0.3 
            end
            local smoothing = 0.2
            local smoothedVolume = (1 - smoothing) * previousVolume + smoothing * targetVolume
            previousVolume = smoothedVolume
            SendNUIMessage({ action = 'setVolume', volume = smoothedVolume })
            Wait(100)
        end
    
        SendNUIMessage({ action = 'stop' })
        musicData = {}
    end)
end)    



RegisterNetEvent('carRadio:stopMusicClient', function()
    musicData = {}
    SendNUIMessage({ action = 'stop' })
end)
