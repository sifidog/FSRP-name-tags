local currId, mode, hidden, text3d, talking = 0, Config['Modes'][Config['Mode']], false, true, {}

CreateThread(function()
    while true do
        Wait(0)

        if not hidden then
            if NetworkIsPlayerTalking(PlayerId()) then
                DrawTxt('~w~[~r~Voice~w~]\n~b~[~y~Proximity~b~] - ~g~' .. mode[2] .. ' ~w~(Shift + H)\n~b~[~y~Channel~b~] - ~w~' .. currId, vector4(255, 255, 255, 255), vector2(0.0, 0.45), 0.4)
            else
                DrawTxt('~w~[~r~Voice~w~]\n~b~[~y~Proximity~b~] - ~w~' .. mode[1] .. ' (Shift + H)\n~b~[~y~Channel~b~] - ~w~' .. currId, vector4(255, 255, 255, 255), vector2(0.0, 0.45), 0.4)
            end
        end

        NetworkClearVoiceChannel()
        NetworkSetTalkerProximity(mode[3])

        if IsControlPressed(0, 21) then
            if IsControlJustReleased(0, 74) then
                if Config['Modes'][Config['Mode'] + 1] then
                    Config['Mode'] = Config['Mode'] + 1
                else
                    Config['Mode'] = 1
                end
                mode = Config['Modes'][Config['Mode']]
            end
        end

        if text3d then
            for k, v in pairs(GetActivePlayers()) do
                if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(v))) <= 30.0 then
                    if HasEntityClearLosToEntity(PlayerPedId(), GetPlayerPed(v), 17) then
                        if NetworkIsPlayerTalking(v) then
                            DrawText3D(GetPedBoneCoords(GetPlayerPed(v), 12844, vec3(0.4, 0.0, 0.0)), ('~w~[~g~Talking~w~] ~w~%s ~b~[~w~%s~b~]'):format(GetPlayerName(v), GetPlayerServerId(v)))
                        else
                            DrawText3D(GetPedBoneCoords(GetPlayerPed(v), 12844, vec3(0.4, 0.0, 0.0)), ('~w~[~r~Not talking~w~] ~w~%s ~b~[~w~%s~b~]'):format(GetPlayerName(v), GetPlayerServerId(v)))
                        end
                    end
                end
            end
        end

    end
end)

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(0) end
    while true do
        currId = GetId(GetEntityCoords(PlayerPedId()))
        NetworkSetVoiceChannel(currId)

        Debug(NetworkGetTalkerProximity())

        Wait(1000)
    end
end)

Debug = function(...)
    if Config['Debug'] then
        print(...)
    end
end

GetId = function(coords)
    local res = math.floor((coords.x + 8192) / 2048)
    if res <= 30 and res >= 1 then
        return res
    else
        return 1
    end
end

DrawTxt = function(text, rgba, pos, scale)
    SetTextFont(6)
    SetTextScale(scale, scale)
    SetTextWrap(0.0, 1.0)
    SetTextDropshadow(0.1, 0, 0, 0, 255)
    SetTextScale(0.5, scale)
    SetTextColour(math.floor(rgba.x), math.floor(rgba.y), math.floor(rgba.z), math.floor(rgba.w))
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(pos.x, pos.y)
end

local StringRemove = {
    '~r~',
    '~w~',
    '~y~',
    '~b~',
    '~g~'
}

DrawText3D = function(coords, text)
    SetDrawOrigin(coords)

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    for k, v in pairs(StringRemove) do
        text = text:gsub(v, '')
    end
    DrawRect(0.0, 0.0 + 0.0125, 0.015 + string.len(text) / 370, 0.03, 45, 45, 45, 150)

    ClearDrawOrigin()
end

RegisterCommand(Config['Command'], function()
    hidden = not hidden
end)

RegisterCommand(Config['HideNames'], function()
    text3d = not text3d
end)