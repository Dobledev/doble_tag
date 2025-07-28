ESX = exports['es_extended']:getSharedObject()
local playersWithTag = {}

RegisterCommand('tag', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if xPlayer.getGroup() == 'admin' then
        if playersWithTag[source] then
            playersWithTag[source] = nil
            TriggerClientEvent('doble_tag:updateTagState', -1, source, false)
        else
            playersWithTag[source] = true
            TriggerClientEvent('doble_tag:updateTagState', -1, source, true)
        end
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { '^1Sistema', 'No tienes permiso para usar este comando.' }
        })
    end
end)

AddEventHandler('playerConnecting', function(name, setReason, deferrals)
    local src = source
    for playerId, _ in pairs(playersWithTag) do
        TriggerClientEvent('doble_tag:updateTagState', src, playerId, true)
    end
end)
