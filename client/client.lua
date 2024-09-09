local AvailableInteractions = {}
local CanStartInteraction = true
local CurrentInteraction = nil
local InMenu = false
local MaxRadius = 0.0
local promptGroup = GetRandomIntInRange(0, 0xffffff)
local MenuData = exports.vorp_menu:GetMenuData()
local StartingCoords = nil
local UIPrompt = {}

UIPrompt.activate = function(title)
    local label = CreateVarString(10, 'LITERAL_STRING', title)
    PromptSetActiveGroupThisFrame(promptGroup, label)
end

UIPrompt.initialize = function()
    local str = Translation[Config.Locale]['prompt_interact']
    Interact = PromptRegisterBegin()
    PromptSetControlAction(Interact, Config.Key)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(Interact, str)
    PromptSetEnabled(Interact, 1)
    PromptSetVisible(Interact, 1)
    PromptSetStandardMode(Interact, 1)
    PromptSetGroup(Interact, promptGroup)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, Interact, true)
    PromptRegisterEnd(Interact)
end

local function Debug(...)
    if Config.DevMode then
        print(...)
    end
end

local function EnumerateEntities(firstFunc, nextFunc, endFunc)
    return coroutine.wrap(function()
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
    end)
end

local function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

local function HasCompatibleModel(entity, models)
    local entityModel = GetEntityModel(entity)
    for _, model in ipairs(models) do
        if entityModel == GetHashKey(model) then
            return model
        end
    end
    return nil
end

local function CanStartInteractionAtObject(interaction, object, playerCoords, objectCoords)
    local distance = #(playerCoords - objectCoords)
    if distance > interaction.radius then
        return nil
    end
    return HasCompatibleModel(object, interaction.objects)
end

local function PlayAnimation(ped, anim)
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

local function StartInteractionAtCoords(interaction)
    local x, y, z, h = interaction.x, interaction.y, interaction.z, interaction.heading
    if not StartingCoords then
        StartingCoords = GetEntityCoords(PlayerPedId())
    end
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), true)
    Debug('ClearPedTasksImmediately: ^2ON^0 \n FreezeEntityPosition: ^2ON^0')
    if interaction.scenario then
        TaskStartScenarioAtPosition(PlayerPedId(), GetHashKey(interaction.scenario), x, y, z, h, -1, false, true)
    elseif interaction.animation then
        SetEntityCoordsNoOffset(PlayerPedId(), x, y, z)
        SetEntityHeading(PlayerPedId(), h)
        PlayAnimation(PlayerPedId(), interaction.animation)
    end
    if interaction.effect then
        Config.Effects[interaction.effect]()
    end
    CurrentInteraction = interaction
end

local function StartInteractionAtObject(interaction)
    local objectHeading = GetEntityHeading(interaction.object)
    local objectCoords = GetEntityCoords(interaction.object)
    local r = math.rad(objectHeading)
    local cosr = math.cos(r)
    local sinr = math.sin(r)
    local x = interaction.x * cosr - interaction.y * sinr + objectCoords.x
    local y = interaction.y * cosr + interaction.x * sinr + objectCoords.y
    local z = interaction.z + objectCoords.z
    local h = interaction.heading + objectHeading
    interaction.x, interaction.y, interaction.z, interaction.heading = x, y, z, h
    StartInteractionAtCoords(interaction)
end

local function IsCompatible(t, ped)
    return not t.isCompatible or t.isCompatible(ped)
end

local function SortInteractions(a, b)
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

local function AddInteractions(availableInteractions, interaction, playerCoords, targetCoords, modelName, object)
    local distance = #(playerCoords - targetCoords)
    if interaction.scenarios then
        for _, scenario in ipairs(interaction.scenarios) do
            if IsCompatible(scenario, PlayerPedId()) then
                table.insert(availableInteractions, {
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
                })
            end
        end
    end
    if interaction.animations then
        for _, animation in ipairs(interaction.animations) do
            if IsCompatible(animation, PlayerPedId()) then
                table.insert(availableInteractions, {
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
                    labelText = animation.label,
                    labelText2 = interaction.labelText,
                    targetCoords = targetCoords
                })
            end
        end
    end
end

local function GetAvailableInteractions()
    local playerCoords = GetEntityCoords(PlayerPedId())
    AvailableInteractions = {}
    for _, interaction in ipairs(Config.Interactions) do
        if IsCompatible(interaction, PlayerPedId()) then
            if interaction.objects then
                for object in EnumerateObjects() do
                    local objectCoords = GetEntityCoords(object)
                    local modelName = CanStartInteractionAtObject(interaction, object, playerCoords, objectCoords)
                    if modelName then
                        AddInteractions(AvailableInteractions, interaction, playerCoords, objectCoords, modelName, object)
                    end
                end
            else
                local targetCoords = vector3(interaction.x, interaction.y, interaction.z)
                if #(playerCoords - targetCoords) <= interaction.radius then
                    AddInteractions(AvailableInteractions, interaction, playerCoords, targetCoords)
                end
            end
        end
        Wait(0)
    end
    table.sort(AvailableInteractions, SortInteractions)
    return AvailableInteractions
end

local function menuStartInteraktion(data)
    if data.object then
        StartInteractionAtObject(data)
    else
        StartInteractionAtCoords(data)
    end
end

local function StopInteraction()
    CurrentInteraction = nil
    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    Debug('ClearPedTasksImmediately: ^1OFF^0 \n FreezeEntityPosition: ^1OFF^0')
    if StartingCoords then
        SetEntityCoordsNoOffset(PlayerPedId(), StartingCoords.x, StartingCoords.y, StartingCoords.z)
        StartingCoords = nil
    end
end

local function openInteractionMenu(availableInteractions)
    InMenu = true
    MenuData.CloseAll()

    local elements = {}

    table.insert(elements, { label = Translation[Config.Locale]["menu_cancel"], value = "cancel" })

    for k, v in pairs(availableInteractions) do
        local data = {}

        if v.labelText then
            local label
            if v.label == "left" then
                label = tostring(v.labelText .. Translation[Config.Locale]["menu_left"])
            elseif v.label == "right" then
                label = tostring(v.labelText .. Translation[Config.Locale]["menu_right"])
            else
                label = tostring(v.labelText)
            end
            data = { label = label, value = v.scenario, interaction = availableInteractions[k] }
        else
            data = { label = v.labelText2, value = v.scenario, interaction = availableInteractions[k] }
        end
        

        table.insert(elements, data)
    end

    MenuData.Open("default", GetCurrentResourceName(), "spooni_interactions",
        {
            title = Translation[Config.Locale]["menu_title"],
            subtext = Translation[Config.Locale]["menu_subtitle"],
            align = "top-left",
            elements = elements
        },
        function(data, menu)
            if data.current.value == "cancel" then
                StopInteraction()
                menu.close()
                InMenu = false
            else
                if data.current.interaction.scenario then
                    menuStartInteraktion(data.current.interaction)
                else
                    menuStartInteraktion(data.current.interaction)
                end
                menu.close()
                InMenu = false
            end
        end,
        function(data, menu)
            menu.close()
            -- DisplayRadar(true)
            InMenu = false
            ClearPedTasks(PlayerPedId())
        end
    )
end

local function StartInteraction()
    AvailableInteractions = GetAvailableInteractions()
    if #AvailableInteractions > 0 then
        InMenu = true
        openInteractionMenu(AvailableInteractions)
    else
        if InMenu then
            MenuData.CloseAll()
        end
        InMenu = false
        if CurrentInteraction then
            StopInteraction()
        end
    end
end

local function GetNearbyObjects(coords)
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

local function nearInteractionObject()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, interaction in ipairs(Config.Interactions) do
        if IsCompatible(interaction, PlayerPedId()) then
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

for _, interaction in ipairs(Config.Interactions) do
    MaxRadius = math.max(MaxRadius, interaction.radius)
end

CreateThread(function()
    while true do
        CanStartInteraction = not IsPedDeadOrDying(PlayerPedId()) and not IsPedInCombat(PlayerPedId())
        Wait(1000)
    end
end)

local nearObject = false
CreateThread(function()
    UIPrompt.initialize()
    while true do
        Citizen.Wait(0)
        local isNearInteractionObject = nearInteractionObject()
        if isNearInteractionObject == true and CanStartInteraction then
            nearObject = true
        else
            MenuData.CloseAll()
            nearObject = false
        end
        Citizen.Wait(500)
    end
end)

CreateThread(function()
    while true do
        Citizen.Wait(0)
        if nearObject == true and CanStartInteraction then
            UIPrompt.activate(Translation[Config.Locale]['prompt_group'])
        else
            Citizen.Wait(500)
        end

    end
end)

CreateThread(function()
    while true do
        Citizen.Wait(0)
        if UiPromptHasStandardModeCompleted(Interact) and CanStartInteraction then
            StartInteraction()
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    if InMenu then
        MenuData.close()
    end
    StopInteraction()
end)
