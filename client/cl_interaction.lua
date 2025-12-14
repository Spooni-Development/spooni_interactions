InteractionManager = {}
local CurrentInteraction = nil
local StartingCoords = nil

-- Debug helper
local function Debug(...)
    if Config.DevMode then print(...) end
end

-- Play animation on ped
local function PlayAnimation(ped, anim)
    if not DoesAnimDictExist(anim.dict) then
        Debug('Animation dict does not exist: ' .. anim.dict)
        return false
    end
    
    RequestAnimDict(anim.dict)
    local timeout = 0
    while not HasAnimDictLoaded(anim.dict) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    
    if HasAnimDictLoaded(anim.dict) then
        TaskPlayAnim(ped, anim.dict, anim.name, 0.0, 0.0, -1, 1, 1.0, false, false, false, "", false)
        RemoveAnimDict(anim.dict)
        return true
    else
        Debug('Failed to load animation dict: ' .. anim.dict)
        RemoveAnimDict(anim.dict)
        return false
    end
end

-- Start interaction at coordinates
local function StartInteractionAtCoords(interaction)
    if not interaction then
        Debug('Error: interaction is nil in StartInteractionAtCoords')
        return
    end
    
    local ped = PlayerPedId()
    local x, y, z, h = interaction.x, interaction.y, interaction.z, interaction.heading
    
    -- Save starting position for restoration
    if not StartingCoords then
        StartingCoords = GetEntityCoords(ped)
    end
    
    -- Instantly move to target like before (no walking), then start
    SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)
    if h then SetEntityHeading(ped, h) end
    
    -- Execute scenario or animation
    if interaction.scenario then
        TaskStartScenarioAtPosition(ped, GetHashKey(interaction.scenario), x, y, z, h, -1, false, true)
    elseif interaction.animation then
        SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)
        SetEntityHeading(ped, h)
        PlayAnimation(ped, interaction.animation)
    end
    
    -- Apply effect if defined
    if interaction.effect and Config.Effects[interaction.effect] then
        Config.Effects[interaction.effect]()
    end
    
    CurrentInteraction = interaction
end

-- Start interaction at object (calculate world position from relative offset)
function InteractionManager.StartInteractionAtObject(interaction)
    if not interaction or not interaction.object then
        Debug('Error: interaction or interaction.object is nil in StartInteractionAtObject')
        return
    end
    
    local objectHeading = GetEntityHeading(interaction.object)
    local objectCoords = GetEntityCoords(interaction.object)
    local r = math.rad(objectHeading)
    local cosr = math.cos(r)
    local sinr = math.sin(r)
    
    -- Calculate world coordinates from relative offset
    local x = interaction.x * cosr - interaction.y * sinr + objectCoords.x
    local y = interaction.y * cosr + interaction.x * sinr + objectCoords.y
    local z = interaction.z + objectCoords.z
    local h = interaction.heading + objectHeading
    
    -- Create modified interaction with world coordinates
    local modifiedInteraction = {
        x = x,
        y = y,
        z = z,
        heading = h,
        scenario = interaction.scenario,
        animation = interaction.animation,
        effect = interaction.effect
    }
    
    StartInteractionAtCoords(modifiedInteraction)
end

-- Start interaction at coordinates
function InteractionManager.StartInteractionAtCoords(interaction)
    if not interaction then
        Debug('Error: interaction is nil in InteractionManager.StartInteractionAtCoords')
        return
    end
    
    StartInteractionAtCoords(interaction)
end

-- Stop current interaction and restore player state
function InteractionManager.StopInteraction()
    local ped = PlayerPedId()
    
    CurrentInteraction = nil
    
    -- Clear tasks based on teleport setting
    if Config.TeleportBackOnStop and StartingCoords then
        -- Immediate clear and teleport back
        ClearPedTasksImmediately(ped)
        ClearPedSecondaryTask(ped)
        SetEntityCoordsNoOffset(ped, StartingCoords.x, StartingCoords.y, StartingCoords.z, false, false, false)
    else
        -- Clear with stand-up animation, stay at interaction spot
        ClearPedTasks(ped)
        ClearPedSecondaryTask(ped)
    end
    
    StartingCoords = nil
end
-- Check if currently interacting
function InteractionManager.IsInteracting()
    return CurrentInteraction ~= nil
end

-- Get current interaction
function InteractionManager.GetCurrentInteraction()
    return CurrentInteraction
end
