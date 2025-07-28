local Config = {
    Text = "STAFF",
    TextColor = { r = 128, g = 0, b = 255, a = 200 },
    DrawDistance = 15.0,
    WaitTimeActive = 0,
    WaitTimeInactive = 500
}

local playersWithTag = {}

RegisterNetEvent('doble_tag:updateTagState')
AddEventHandler('doble_tag:updateTagState', function(playerId, state)
    if state then
        playersWithTag[playerId] = true
    else
        playersWithTag[playerId] = nil
    end
end)

local function Draw3DText(x, y, z, text, color)
    local onScreen, screenX, screenY = World3dToScreen2d(x, y, z + 1.2) -- un poco más arriba para que no se vea pegado
    if onScreen then
        local camCoords = GetGameplayCamCoords()
        local dist = #(vector3(x, y, z) - camCoords)
        if dist <= Config.DrawDistance then
            local scale = (1 / dist) * 1.0 -- escala base más grande que antes
            scale = scale * 0.8 -- ajustar para que no sea demasiado gigante

            SetTextScale(2.5 * scale, 2.5 * scale)   -- escala mayor (antes era 0.35)
            SetTextFont(4)                           -- fuente legible y clara
            SetTextProportional(true)
            SetTextColour(color.r, color.g, color.b, color.a)
            SetTextDropshadow(2, 0, 0, 0, 255)      -- sombra más visible
            SetTextEdge(4, 0, 0, 0, 255)             -- borde más grueso
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(text)
            DrawText(screenX, screenY)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local waitTime = Config.WaitTimeInactive
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        local foundTag = false

        for playerId, _ in pairs(playersWithTag) do
            local serverPlayer = GetPlayerFromServerId(playerId)
            if serverPlayer ~= -1 and serverPlayer ~= PlayerId() then
                local ped = GetPlayerPed(serverPlayer)
                if DoesEntityExist(ped) and not IsPedDeadOrDying(ped) then
                    local pedCoords = GetEntityCoords(ped)
                    local dist = #(playerCoords - pedCoords)
                    if dist <= Config.DrawDistance then
                        foundTag = true
                        Draw3DText(pedCoords.x, pedCoords.y, pedCoords.z, Config.Text, Config.TextColor)
                    end
                end
            elseif serverPlayer == PlayerId() then
                local pedCoords = playerCoords
                foundTag = true
                Draw3DText(pedCoords.x, pedCoords.y, pedCoords.z, Config.Text, Config.TextColor)
            end
        end

        if foundTag then
            waitTime = Config.WaitTimeActive
        end

        Citizen.Wait(waitTime)
    end
end)
