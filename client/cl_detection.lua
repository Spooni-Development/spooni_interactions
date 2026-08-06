DetectionManager = {}
InteractionIndex = { byModel = {}, coordBased = {}, maxRadius = 0.0 }

local cachedNearbyObjects = {}
local cacheValid = false
local lastPlayerCoords = vector3(0, 0, 0)
local CACHE_INVALIDATION_DISTANCE = 2.0

function DetectionManager.Initialize()
    if not Config or not Config.Interactions then
        print('Error: Config.Interactions is not defined')
        return
    end

    local byModel = {}
    local coordBased = {}
    local maxRadius = 0.0

    for _, interaction in ipairs(Config.Interactions) do
        if interaction and interaction.radius then
            maxRadius = math.max(maxRadius, interaction.radius)

            if interaction.objects then
                for _, model in ipairs(interaction.objects) do
                    local hash = GetHashKey(model)
                    local bucket = byModel[hash]
                    if not bucket then
                        bucket = { modelName = model, entries = {} }
                        byModel[hash] = bucket
                    end
                    bucket.entries[#bucket.entries + 1] = interaction
                end
            else
                coordBased[#coordBased + 1] = {
                    interaction = interaction,
                    coords = vector3(interaction.x, interaction.y, interaction.z),
                    radius = interaction.radius
                }
            end
        end
    end

    InteractionIndex.byModel = byModel
    InteractionIndex.coordBased = coordBased
    InteractionIndex.maxRadius = maxRadius
end

function DetectionManager.GetNearbyObjects(coords)
    local itemset = CreateItemset(true)
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, coords, InteractionIndex.maxRadius, itemset, 3,
        Citizen.ResultAsInteger())
    local objects = {}

    if size > 0 then
        for i = 0, size - 1 do
            objects[#objects + 1] = GetIndexedItemInItemset(i, itemset)
        end
    end

    if IsItemsetValid(itemset) then
        DestroyItemset(itemset)
    end

    return objects
end

local function IsCompatible(t, ped)
    return not t.isCompatible or t.isCompatible(ped)
end

function DetectionManager.IsNearInteractionObject(playerCoords)
    local ped = PlayerPedId()

    for i = 1, #InteractionIndex.coordBased do
        local entry = InteractionIndex.coordBased[i]
        if #(playerCoords - entry.coords) <= entry.radius and IsCompatible(entry.interaction, ped) then
            return true
        end
    end

    if #(playerCoords - lastPlayerCoords) > CACHE_INVALIDATION_DISTANCE then
        cacheValid = false
        lastPlayerCoords = playerCoords
    end

    if not cacheValid then
        cachedNearbyObjects = DetectionManager.GetNearbyObjects(playerCoords)
        cacheValid = true
    end

    local byModel = InteractionIndex.byModel

    for i = 1, #cachedNearbyObjects do
        local object = cachedNearbyObjects[i]
        if DoesEntityExist(object) then
            local bucket = byModel[GetEntityModel(object)]
            if bucket then
                local distance = #(playerCoords - GetEntityCoords(object))
                local entries = bucket.entries
                for j = 1, #entries do
                    local interaction = entries[j]
                    if distance <= interaction.radius and IsCompatible(interaction, ped) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function DetectionManager.InvalidateCache()
    cacheValid = false
    cachedNearbyObjects = {}
end

function DetectionManager.IsAreaBanned(coords)
    for _, area in ipairs(Config.BannedAreas) do
        if #(coords - area.coords) < area.radius then
            return true
        end
    end
    return false
end
