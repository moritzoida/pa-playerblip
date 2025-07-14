ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('playerblips:getPlayerCoords', function(source, cb)
    local sourceId = source
    local xPlayers = ESX.GetExtendedPlayers()
    local result = {}

    for _, xPlayer in pairs(xPlayers) do
        if xPlayer.source ~= sourceId then
            local ped = GetPlayerPed(xPlayer.source)
            if DoesEntityExist(ped) then
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)
                table.insert(result, {
                    coords = vector4(coords.x, coords.y, coords.z, heading),
                    playerId = xPlayer.source,
                    name = GetPlayerName(xPlayer.source)
                })
            end
        end
    end

    cb(result)
end)

ESX.RegisterServerCallback('playerblips:canUse', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.getGroup() == 'admin' then
        cb(true)
    else
        cb(false)
    end
end)
