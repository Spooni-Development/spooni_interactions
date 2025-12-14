DetectionManager = {}
local MaxRadius = 0.0
local cachedNearbyObjects = {}
local cacheValid = false
local lastPlayerCoords = vector3(0, 0, 0)
local CACHE_INVALIDATION_DISTANCE = 2.0

-- Calculate maximum detection radius from all interactions
function DetectionManager.Initialize()
    if not Config or not Config.Interactions then
        print('Error: Config.Interactions is not defined')
        return
    end
    
    for _, interaction in ipairs(Config.Interactions) do
        if interaction and interaction.radius then
            MaxRadius = math.max(MaxRadius, interaction.radius)
        end
    end
end

-- Get nearby objects using itemset (performance optimized)
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

-- Check if entity model matches any in the provided list
local function HasCompatibleModel(entity, models)
    if not models then return false end
    local entityModel = GetEntityModel(entity)
    for _, model in ipairs(models) do
        if entityModel == GetHashKey(model) then
            return model
        end
    end
    return nil
end

-- Check if interaction is compatible with ped
local function IsCompatible(t, ped)
    return not t.isCompatible or t.isCompatible(ped)
end

-- Check if player is near any interaction object
function DetectionManager.IsNearInteractionObject(playerCoords)
    local ped = PlayerPedId()
    
    -- Invalidate cache if player moved significantly
    local distanceMoved = #(playerCoords - lastPlayerCoords)
    if distanceMoved > CACHE_INVALIDATION_DISTANCE then
        cacheValid = false
        lastPlayerCoords = playerCoords
    end
    
    -- Use cached objects if available
    local nearbyObjects = cacheValid and cachedNearbyObjects or GetNearbyObjects(playerCoords)
    if not cacheValid then
        cachedNearbyObjects = nearbyObjects
        cacheValid = true
    end
    
    -- Check all interactions
    for _, interaction in ipairs(Config.Interactions) do
        if IsCompatible(interaction, ped) then
            if interaction.objects then
                -- Object-based interaction
                for _, object in ipairs(nearbyObjects) do
                    if DoesEntityExist(object) then
                        local objectCoords = GetEntityCoords(object)
                        local distance = #(playerCoords - objectCoords)
                        
                        if distance <= interaction.radius then
                            local modelName = HasCompatibleModel(object, interaction.objects)
                            if modelName then
                                return true
                            end
                        end
                    end
                end
            else
                -- Coordinate-based interaction
                local targetCoords = vector3(interaction.x, interaction.y, interaction.z)
                if #(playerCoords - targetCoords) <= interaction.radius then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Invalidate detection cache
function DetectionManager.InvalidateCache()
    cacheValid = false
    cachedNearbyObjects = {}
end

-- Check if area is banned from interactions
function DetectionManager.IsAreaBanned(coords)
    for _, area in ipairs(Config.BannedAreas) do
        local dist = #(coords - area.coords)
        if dist < area.radius then
            return true
        end
    end
    return false
end
