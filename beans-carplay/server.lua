local QBCore = exports['qb-core']:GetCoreObject()
local musicByVehicle = {}

RegisterNetEvent('carRadio:syncMusic', function(data)
    musicByVehicle[data.netId] = data
    TriggerClientEvent('carRadio:checkVehicleOccupants', source, data)
end)

RegisterNetEvent('carRadio:sendToPlayer', function(target, data)
    TriggerClientEvent('carRadio:playMusic', target, data)
end)

RegisterNetEvent('carRadio:stopMusic', function(netId)
    musicByVehicle[netId] = nil
    TriggerClientEvent('carRadio:stopMusicClient', -1)
end)
