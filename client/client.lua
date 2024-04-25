local StartingCoords
local CurrentInteraction
local CanStartInteraction = true
local inmenu = false
local availableInteractions
local MaxRadius = 0.0
local InteractPrompt = Uiprompt:new(Config.Key, Translation[Config.Locale]["INTERACT"], nil, false)

TriggerEvent(Config.Menu..":getData",function(call)
        MenuData = call
end)

AddEventHandler(Config.Menu..":closemenu",function()
    if inmenu then
        inmenu = false
        bankinfo = nil
        ClearPedTasks(PlayerPedId())
    end
end)

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

function EnumerateEntities(firstFunc, nextFunc, endFunc)
    return coroutine.wrap(
        function()
            local iter, id = firstFunc()

            if not id or id == 0 then
                endFunc(iter)
                return
            end

            local enum = { handle = iter, destructor = endFunc }
            setmetatable(enum, entityEnumerator)

            local next = true
            repeat
                coroutine.yield(id)
                next, id = nextFunc(iter)
            until not next

            enum.destructor, enum.handle = nil, nil
            endFunc(iter)
        end
    )
end

function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function HasCompatibleModel(entity, models)
    local entityModel = GetEntityModel(entity)

    for _, model in ipairs(models) do
        if entityModel == GetHashKey(model) then
            return model
        end
    end

    return nil
end

function CanStartInteractionAtObject(interaction, object, playerCoords, objectCoords)
    if #(playerCoords - objectCoords) > interaction.radius then
        return nil
    end

    return HasCompatibleModel(object, interaction.objects)
end

function PlayAnimation(ped, anim)
    if not DoesAnimDictExist(anim.dict) then
        return
    end

    RequestAnimDict(anim.dict)

    while not HasAnimDictLoaded(anim.dict) do
        Wait(0)
    end

    TaskPlayAnim(ped, anim.dict, anim.name, 0.0, 0.0, -1, 1, 1.0, false, false, false, "", false)

    RemoveAnimDict(anim.dict)
end

function StartInteractionAtCoords(interaction)
    local x = interaction.x
    local y = interaction.y
    local z = interaction.z
    local h = interaction.heading

    local ped = PlayerPedId()

    if not StartingCoords then
        StartingCoords = GetEntityCoords(ped)
    end

    ClearPedTasksImmediately(ped)

    FreezeEntityPosition(ped, true)

    if interaction.scenario then
        TaskStartScenarioAtPosition(ped, GetHashKey(interaction.scenario), x, y, z, h, -1, false, true)
    elseif interaction.animation then
        SetEntityCoordsNoOffset(ped, x, y, z)
        SetEntityHeading(ped, h)
        PlayAnimation(ped, interaction.animation)
    end

    if interaction.effect then
        Config.Effects[interaction.effect]()
    end

    CurrentInteraction = interaction
end

function StartInteractionAtObject(interaction)
    local objectHeading = GetEntityHeading(interaction.object)
    local objectCoords = GetEntityCoords(interaction.object)

    local r = math.rad(objectHeading)
    local cosr = math.cos(r)
    local sinr = math.sin(r)

    local x = interaction.x * cosr - interaction.y * sinr + objectCoords.x
    local y = interaction.y * cosr + interaction.x * sinr + objectCoords.y
    local z = interaction.z + objectCoords.z
    local h = interaction.heading + objectHeading

    interaction.x = x
    interaction.y = y
    interaction.z = z
    interaction.heading = h

    StartInteractionAtCoords(interaction)
end

function IsCompatible(t, ped)
    return not t.isCompatible or t.isCompatible(ped)
end

function SortInteractions(a, b)
    if a.distance == b.distance then
        if a.object == b.object then
            local aLabel = a.scenario or a.animation.label
            local bLabel = b.scenario or b.animation.label
            return aLabel < bLabel
        else
            return a.object < b.object
        end
    else
        return a.distance < b.distance
    end
end

function AddInteractions(availableInteractions, interaction, playerCoords, targetCoords, modelName, object)
    local distance = #(playerCoords - targetCoords)
    local playerPed = PlayerPedId()
    if interaction.scenarios then
        for _, scenario in ipairs(interaction.scenarios) do
            if IsCompatible(scenario, playerPed) then
                table.insert(
                    availableInteractions,
                    {
                        x = interaction.x,
                        y = interaction.y,
                        z = interaction.z,
                        heading = interaction.heading,
                        scenario = scenario.name,
                        object = object,
                        modelName = modelName,
                        distance = distance,
                        label = interaction.label,
                        effect = interaction.effect,
                        labelText = scenario.label,
                        labelText2 = interaction.labelText,
                        targetCoords = targetCoords
                    }
                )
            end
        end
    end

    if interaction.animations then
        for _, animation in ipairs(interaction.animations) do
            if IsCompatible(animation, playerPed) then
                table.insert(
                    availableInteractions,
                    {
                        x = interaction.x,
                        y = interaction.y,
                        z = interaction.z,
                        heading = interaction.heading,
                        animation = animation,
                        object = object,
                        modelName = modelName,
                        distance = distance,
                        label = interaction.label,
                        effect = interaction.effect,
                        labelText = interaction.labelText,
                        targetCoords = targetCoords
                    }
                )
            end
        end
    end
end

function GetAvailableInteractions()
    local playerCoords = GetEntityCoords(PlayerPedId())
    availableInteractions = {}
    local playerPed = PlayerPedId()
    for _, interaction in ipairs(Config.Interactions) do
        if IsCompatible(interaction, playerPed) then
            if interaction.objects then
                for object in EnumerateObjects() do
                    local objectCoords = GetEntityCoords(object)

                    local modelName = CanStartInteractionAtObject(interaction, object, playerCoords, objectCoords)

                    if modelName then
                        AddInteractions(
                            availableInteractions,
                            interaction,
                            playerCoords,
                            objectCoords,
                            modelName,
                            object
                        )
                    end
                end
            else
                local targetCoords = vector3(interaction.x, interaction.y, interaction.z)

                if #(playerCoords - targetCoords) <= interaction.radius then
                    AddInteractions(availableInteractions, interaction, playerCoords, targetCoords)
                end
            end
        end

        Wait(0)
    end

    table.sort(availableInteractions, SortInteractions)

    return availableInteractions
end

function StartInteraction()
    availableInteractions = GetAvailableInteractions()

    if #availableInteractions > 0 then
        inmenu = true
        openInteractionMenu(availableInteractions)
    else
        if menu then
            menu.close()
        end
        inmenu = false

        if CurrentInteraction then
            StopInteraction()
        end
    end
end

function StopInteraction()
    CurrentInteraction = nil

    local ped = PlayerPedId()

    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)

    Wait(100)

    if StartingCoords then
        SetEntityCoordsNoOffset(ped, StartingCoords.x, StartingCoords.y, StartingCoords.z)
        StartingCoords = nil
    end
end

function SetInteractionMarker(target)
    InteractionMarker = target
end

function menuStartInteraktion(data)
    if data.object then
        StartInteractionAtObject(data)
    else
        StartInteractionAtCoords(data)
    end
end

CreateThread(
    function()
        while true do
            local ped = PlayerPedId()
            CanStartInteraction = not IsPedDeadOrDying(ped) and not IsPedInCombat(ped)
            Wait(1000)
        end
    end
)

function whenKeyJustPressed(key)
    if Citizen.InvokeNative(0x580417101DDB492F, 0, key) then
        return true
    else
        return false
    end
end

function GetNearbyObjects(coords)
    local itemset = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, coords, MaxRadius, itemset, 3, Citizen.ResultAsInteger())

    local objects = {}

    if size > 0 then
        for i = 0, size - 1 do
            table.insert(objects, GetIndexedItemInItemset(i, itemset))
        end
    end

    if IsItemsetValid(itemset) then
        DestroyItemset(itemset)
    end

    return objects
end

function nearInteractionObject()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, interaction in ipairs(Config.Interactions) do
        if IsCompatible(interaction, playerPed) then
            if interaction.objects then
                for _, object in ipairs(GetNearbyObjects(playerCoords)) do
                    local objectCoords = GetEntityCoords(object)

                    local modelName = CanStartInteractionAtObject(interaction, object, playerCoords, objectCoords)

                    if modelName then
                        return true
                    end
                end
            else
                local targetCoords = vector3(interaction.x, interaction.y, interaction.z)

                if #(playerCoords - targetCoords) <= interaction.radius then
                    return true
                end
            end
        end
    end

    return false
end

local nearObject = false
CreateThread(function()
    while true do
        interact = nearInteractionObject()
        if interact == true and CanStartInteraction then
            nearObject = true
        else
            nearObject = false
            if InteractPrompt:isEnabled() then
                InteractPrompt:setEnabledAndVisible(false)
                if inmenu == true then
                    inmenu = false
                    MenuData.CloseAll()
                end
            end
        end
        Citizen.Wait(300)
    end
end)

CreateThread(function()
    while true do
        if nearObject == true and CanStartInteraction then
            if not InteractPrompt:isEnabled() then
                InteractPrompt:setEnabledAndVisible(true)
            end
            Citizen.Wait(0)
        else
            Citizen.Wait(300)
        end
    end
end)

local menuControlCheckPoint = 0
CreateThread(function()
    for _, interaction in ipairs(Config.Interactions) do
        MaxRadius = math.max(MaxRadius, interaction.radius)
    end

    while true do
        local playerPed = PlayerPedId()

        if whenKeyJustPressed(Config.Key) and CanStartInteraction then
            StartInteraction()
        end

        if inmenu == true then
            if whenKeyJustPressed(0x6319DB71) then
                if menuControlCheckPoint == 0 then
                    menuControlCheckPoint = tablelength(availableInteractions)
                else
                    menuControlCheckPoint = menuControlCheckPoint - 1
                    if menuControlCheckPoint ~= 0 then
                    end
                end
            end
            if whenKeyJustPressed(0x05CA7C52) then
                if menuControlCheckPoint == tablelength(availableInteractions) then
                    menuControlCheckPoint = 0
                else
                    menuControlCheckPoint = menuControlCheckPoint + 1
                end
            end
        else
            if menuControlCheckPoint ~= 0 then
                menuControlCheckPoint = 0
            end
        end

        Wait(0)
    end
end)

CreateThread(function()
    while true do
        if inmenu == true and menuControlCheckPoint ~= 0 then
            Citizen.InvokeNative(
                0x2A32FAA57B937173,
                0x94FDAE17,
                availableInteractions[menuControlCheckPoint].targetCoords.x,
                availableInteractions[menuControlCheckPoint].targetCoords.y,
                availableInteractions[menuControlCheckPoint].targetCoords.z,
                0,
                0,
                0,
                0,
                0,
                0,
                1.0,
                1.0,
                0.1,
                Config.Marker.R,
                Config.Marker.G,
                Config.Marker.B,
                Config.Marker.A,
                0,
                true,
                2,
                0,
                0,
                0,
                0
            )
            Citizen.Wait(0)
        else
            Citizen.Wait(300)
        end
    end
end)

function openInteractionMenu(availableInteractions)
    inmenu = true
    MenuData.CloseAll()

    local elements = {}

    table.insert(elements, { label = Translation[Config.Locale]["MENU_CANCEL"], value = "cancel" })

    for k, v in pairs(availableInteractions) do
        local data = {}

        if v.labelText then
            if v.label == "right" then
                local label = tostring(v.labelText .. Translation[Config.Locale]["MENU_RIGHT"])
                data = { label = label, value = v.scenario, interaction = availableInteractions[k] }
            else
                local label = tostring(v.labelText)
                data = { label = label, value = v.scenario, interaction = availableInteractions[k] }
            end
        else
            data = { label = v.labelText2, value = v.scenario, interaction = availableInteractions[k] }
        end

        table.insert(elements, data)
    end

    MenuData.Open("default",
        GetCurrentResourceName(),
        Config.Menu.."",
        {
            title = Translation[Config.Locale]["MENU_TITLE"],
            subtext = Translation[Config.Locale]["MENU_SUBTITLE"],
            align = "top-left",
            elements = elements
        },
        function(data, menu)
            if data.current.value == "cancel" then
                StopInteraction()
                menu.close()
                inmenu = false
            else
                if data.current.interaction.scenario then
                    menuStartInteraktion(data.current.interaction)
                else
                    menuStartInteraktion(data.current.interaction)
                end
                menu.close()
                inmenu = false
            end
        end,
        function(data, menu)
            menu.close()
            -- DisplayRadar(true)
            inmenu = false
            ClearPedTasks(PlayerPedId())
        end
    )
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end
