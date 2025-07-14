local playerBlips = {}
local blipTargets = {}
local blipsEnabled = false

local updateInterval = 500
local smoothFactor = 0.01

RegisterCommand("playerblip", function()
    ESX.TriggerServerCallback('playerblips:canUse', function(allowed)
        if not allowed then
            ESX.ShowNotification("~r~Du hast keine Berechtigung.")
            return
        end

        blipsEnabled = not blipsEnabled
        if blipsEnabled then
            ESX.ShowNotification("~g~Spieler-Blips aktiviert")
        else
            ESX.ShowNotification("~r~Spieler-Blips deaktiviert")
            removeAllBlips()
        end
    end)
end, false)

function removeAllBlips()
    for _, blip in pairs(playerBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    playerBlips = {}
    blipTargets = {}
end

CreateThread(function()
    while true do
        Wait(updateInterval)
        if blipsEnabled then
            updatePlayerBlipTargets()
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        if blipsEnabled then
            for playerId, blip in pairs(playerBlips) do
                if DoesBlipExist(blip) and blipTargets[playerId] then
                    local currentPos = GetBlipCoords(blip)
                    local target = blipTargets[playerId]

                    local newX = currentPos.x + (target.x - currentPos.x) * smoothFactor
                    local newY = currentPos.y + (target.y - currentPos.y) * smoothFactor
                    local newZ = currentPos.z + (target.z - currentPos.z) * smoothFactor

                    SetBlipCoords(blip, newX, newY, newZ)
                    SetBlipRotation(blip, math.ceil(target.heading or 0))
                end
            end
        end
    end
end)

function updatePlayerBlipTargets()
    ESX.TriggerServerCallback('playerblips:getPlayerCoords', function(players)
        local seenPlayers = {}

        for _, player in ipairs(players) do
            seenPlayers[player.playerId] = true

            if not playerBlips[player.playerId] or not DoesBlipExist(playerBlips[player.playerId]) then
                local blip = AddBlipForCoord(player.coords.x, player.coords.y, player.coords.z)
                SetBlipSprite(blip, 1)
                SetBlipColour(blip, 0)
                SetBlipScale(blip, 0.85)
                SetBlipAsShortRange(blip, true)
                ShowHeadingIndicatorOnBlip(blip, true)
                ShowNumberOnBlip(blip, player.playerId)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(player.name)
                EndTextCommandSetBlipName(blip)

                playerBlips[player.playerId] = blip
            end

            blipTargets[player.playerId] = {
                x = player.coords.x,
                y = player.coords.y,
                z = player.coords.z,
                heading = player.coords.w or 0
            }
        end

        for playerId, blip in pairs(playerBlips) do
            if not seenPlayers[playerId] then
                if DoesBlipExist(blip) then
                    RemoveBlip(blip)
                end
                playerBlips[playerId] = nil
                blipTargets[playerId] = nil
            end
        end
    end)
end