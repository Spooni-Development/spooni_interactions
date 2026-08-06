MenuManager = {}

local MENU_ROOT = 'spooni_interactions:categories'
local createdMenus = {}
local selectionHandled = true

local function RegisterMenu(id, data)
    createdMenus[#createdMenus + 1] = id
    return jo.menu.create(id, data)
end

local function ClearMenus()
    for i = 1, #createdMenus do
        jo.menu.delete(createdMenus[i])
    end
    createdMenus = {}
end

-- Push every built menu to the NUI layer
local function SendMenus()
    for i = 1, #createdMenus do
        jo.menu.send(createdMenus[i])
    end
end

-- Check if menu is currently open
function MenuManager.IsInMenu()
    return jo.menu.isOpen()
end

-- Close menu
function MenuManager.Close()
    if jo.menu.isOpen() then
        jo.menu.show(false)
    end
    ClearMenus()
end

-- Check if interaction is compatible with ped
local function IsCompatible(t, ped)
    return not t.isCompatible or t.isCompatible(ped)
end

-- Get category key for scenario/animation name
local function GetCategoryForScenario(scenarioName)
    if not scenarioName then return 'other' end

    for categoryKey, categoryData in pairs(Config.Categories) do
        if categoryKey ~= 'other' then
            for _, scenario in ipairs(categoryData.scenarios) do
                if scenario == scenarioName then
                    return categoryKey
                end
            end
        end
    end
    return 'other'
end

-- Get category label from config
local function GetCategoryLabel(categoryKey)
    local category = Config.Categories[categoryKey]
    if category then
        if category.labelKey then
            return L(category.labelKey)
        end
        if category.label then
            return category.label
        end
    end
    return categoryKey
end

-- Get available props grouped by entity
local function GetAvailableProps()
    local ped = PlayerPedId()
    local playerCoords = GetEntityCoords(ped)
    local props = {}
    local propMap = {}

    -- Get nearby objects using itemset
    local itemset = CreateItemset(true)
    local maxRadius = 0.0
    for _, interaction in ipairs(Config.Interactions) do
        maxRadius = math.max(maxRadius, interaction.radius)
    end
    local size = Citizen.InvokeNative(0x59B57C4B06531E1E, playerCoords, maxRadius, itemset, 3, Citizen.ResultAsInteger())
    local nearbyObjects = {}
    if size > 0 then
        for i = 0, size - 1 do
            table.insert(nearbyObjects, GetIndexedItemInItemset(i, itemset))
        end
    end
    if IsItemsetValid(itemset) then
        DestroyItemset(itemset)
    end

    -- Check if entity model matches interaction models
    local function HasCompatibleModel(entity, models)
        if not models then return nil end
        local entityModel = GetEntityModel(entity)
        for _, model in ipairs(models) do
            if entityModel == GetHashKey(model) then
                return model
            end
        end
        return nil
    end

    -- Process interactions and group by entity
    for _, interaction in ipairs(Config.Interactions) do
        if IsCompatible(interaction, ped) then
            if interaction.objects then
                -- Object-based interaction
                for _, object in ipairs(nearbyObjects) do
                    if DoesEntityExist(object) then
                        local objectCoords = GetEntityCoords(object)
                        local modelName = HasCompatibleModel(object, interaction.objects)
                        if modelName then
                            local distance = #(playerCoords - objectCoords)
                            if distance <= interaction.radius then
                                -- Group by entity
                                if not propMap[object] then
                                    propMap[object] = {
                                        entity = object,
                                        modelName = modelName,
                                        interactions = {},
                                        distance = distance,
                                        coords = objectCoords
                                    }
                                end

                                table.insert(propMap[object].interactions, {
                                    interaction = interaction,
                                    distance = distance
                                })
                            end
                        end
                    end
                end
            else
                -- Coordinate-based interaction
                local targetCoords = vector3(interaction.x, interaction.y, interaction.z)
                if #(playerCoords - targetCoords) <= interaction.radius then
                    local coordKey = string.format("%.2f,%.2f,%.2f", targetCoords.x, targetCoords.y, targetCoords.z)
                    if not propMap[coordKey] then
                        propMap[coordKey] = {
                            entity = nil,
                            modelName = interaction.labelText2 or L('menu_location'),
                            interactions = {},
                            distance = #(playerCoords - targetCoords),
                            coords = targetCoords
                        }
                    end
                    table.insert(propMap[coordKey].interactions, {
                        interaction = interaction,
                        distance = #(playerCoords - targetCoords)
                    })
                end
            end
        end
    end

    -- Convert to array and sort by distance
    for _, propData in pairs(propMap) do
        table.insert(props, propData)
    end

    table.sort(props, function(a, b)
        return a.distance < b.distance
    end)

    return props
end

-- Get all interactions for a specific prop
local function GetInteractionsForProp(propData)
    local ped = PlayerPedId()
    local interactions = {}

    for _, interactionData in ipairs(propData.interactions) do
        local interaction = interactionData.interaction
        local targetCoords = propData.coords

        -- Process scenarios
        if interaction.scenarios then
            for _, scenario in ipairs(interaction.scenarios) do
                if IsCompatible(scenario, ped) then
                    table.insert(interactions, {
                        x = interaction.x,
                        y = interaction.y,
                        z = interaction.z,
                        heading = interaction.heading,
                        scenario = scenario.name,
                        object = propData.entity,
                        modelName = propData.modelName,
                        distance = interactionData.distance,
                        label = interaction.label,
                        effect = interaction.effect,
                        labelText = scenario.label,
                        labelText2 = interaction.labelText,
                        targetCoords = targetCoords,
                        category = GetCategoryForScenario(scenario.name)
                    })
                end
            end
        end

        -- Process animations
        if interaction.animations then
            for _, animation in ipairs(interaction.animations) do
                if IsCompatible(animation, ped) then
                    table.insert(interactions, {
                        x = interaction.x,
                        y = interaction.y,
                        z = interaction.z,
                        heading = interaction.heading,
                        animation = animation,
                        object = propData.entity,
                        modelName = propData.modelName,
                        distance = interactionData.distance,
                        label = interaction.label,
                        effect = interaction.effect,
                        labelText = animation.label,
                        labelText2 = interaction.labelText,
                        targetCoords = targetCoords,
                        category = 'other'
                    })
                end
            end
        end
    end

    return interactions
end

-- Group interactions by category
local function GroupInteractionsByCategory(interactions)
    local categories = {}

    for _, interaction in ipairs(interactions) do
        local categoryKey = interaction.category or 'other'
        if not categories[categoryKey] then
            categories[categoryKey] = {}
        end
        table.insert(categories[categoryKey], interaction)
    end

    return categories
end

-- Group interactions by type (scenario/animation, ignoring position)
local function GroupInteractionsByType(interactions)
    local groups = {}
    local order = {}

    for _, interaction in ipairs(interactions) do
        local typeKey = interaction.scenario or (interaction.animation and interaction.animation.name) or "unknown"

        if not groups[typeKey] then
            groups[typeKey] = {
                key = typeKey,
                interactions = {},
                baseLabel = interaction.labelText or interaction.labelText2 or L('menu_unknown')
            }
            order[#order + 1] = groups[typeKey]
        end
        table.insert(groups[typeKey].interactions, interaction)
    end

    table.sort(order, function(a, b)
        return a.baseLabel < b.baseLabel
    end)

    return order
end

-- Split a group into its selectable positions
local function GetPositionsForGroup(groupData)
    local positions = {}
    local order = {}

    for _, interaction in ipairs(groupData.interactions) do
        local positionKey = interaction.label
        if positionKey and positionKey ~= 'default' then
            if not positions[positionKey] then
                positions[positionKey] = { key = positionKey, interactions = {} }
                order[#order + 1] = positions[positionKey]
            end
            table.insert(positions[positionKey].interactions, interaction)
        end
    end

    table.sort(order, function(a, b)
        return L('menu_position_' .. a.key) < L('menu_position_' .. b.key)
    end)

    return order
end

-- Main entry point: Open categorized menu system
function MenuManager.Open(availableInteractions, onSelectCallback)
    if not availableInteractions or #availableInteractions == 0 then
        return
    end

    ClearMenus()
    selectionHandled = false

    local function Select(interaction)
        if selectionHandled then return end
        selectionHandled = true
        jo.menu.show(false)
        onSelectCallback(interaction)
    end

    local function Cancel()
        if selectionHandled then return end
        selectionHandled = true
        jo.menu.show(false)
        onSelectCallback(nil)
    end

    local categories = GroupInteractionsByCategory(availableInteractions)
    local categoryOrder = Config.CategoryOrder or { 'sitting', 'drinking_smoking', 'instruments', 'other' }

    local activeCategories = {}
    for _, categoryKey in ipairs(categoryOrder) do
        if categories[categoryKey] and #categories[categoryKey] > 0 then
            activeCategories[#activeCategories + 1] = categoryKey
        end
    end

    if #activeCategories == 0 then
        return
    end

    local isSingleCategory = #activeCategories == 1

    -- Build one list menu per category
    for _, categoryKey in ipairs(activeCategories) do
        local categoryLabel = GetCategoryLabel(categoryKey)
        local categoryMenuId = 'spooni_interactions:cat:' .. categoryKey
        local categoryMenu = RegisterMenu(categoryMenuId, {
            title = categoryLabel,
            subtitle = L('menu_subtitle'),
            numberOnScreen = Config.MenuItemsOnScreen or 8,
            displayBackButton = true,
            onBack = isSingleCategory and Cancel or nil
        })

        local groups = GroupInteractionsByType(categories[categoryKey])

        for groupIndex, groupData in ipairs(groups) do
            local positions = GetPositionsForGroup(groupData)

            if #positions > 1 then
                local positionMenuId = string.format('spooni_interactions:pos:%s:%d', categoryKey, groupIndex)
                local positionMenu = RegisterMenu(positionMenuId, {
                    title = groupData.baseLabel,
                    subtitle = L('menu_select_position_subtitle'),
                    numberOnScreen = Config.MenuItemsOnScreen or 8,
                    displayBackButton = true
                })

                for _, positionData in ipairs(positions) do
                    local target = positionData.interactions[1]
                    positionMenu:addItem({
                        title = L('menu_position_' .. positionData.key),
                        description = L('menu_start_interaction'),
                        onClick = function()
                            Select(target)
                        end
                    })
                end

                categoryMenu:addItem({
                    title = groupData.baseLabel,
                    description = L('menu_multiple_positions'),
                    child = positionMenuId
                })
            else
                local target = groupData.interactions[1]
                local description = L('menu_start_interaction')
                if target.scenario then
                    description = L('menu_start_scenario', groupData.baseLabel)
                elseif target.animation then
                    description = L('menu_start_animation', groupData.baseLabel)
                end

                categoryMenu:addItem({
                    title = groupData.baseLabel,
                    description = description,
                    onClick = function()
                        Select(target)
                    end
                })
            end
        end
    end

    local rootMenuId = 'spooni_interactions:cat:' .. activeCategories[1]

    -- Category picker is only needed when more than one category is available
    if not isSingleCategory then
        rootMenuId = MENU_ROOT
        local rootMenu = RegisterMenu(MENU_ROOT, {
            title = L('menu_title'),
            subtitle = L('menu_select_category_subtitle'),
            numberOnScreen = Config.MenuItemsOnScreen or 8,
            displayBackButton = true,
            onBack = Cancel
        })

        for _, categoryKey in ipairs(activeCategories) do
            local categoryLabel = GetCategoryLabel(categoryKey)
            local count = #categories[categoryKey]
            rootMenu:addItem({
                title = categoryLabel,
                description = string.format('%s %d %s', categoryLabel, count,
                    count == 1 and L('menu_interaction_singular') or L('menu_interaction_plural')),
                child = 'spooni_interactions:cat:' .. categoryKey
            })
        end
    end

    SendMenus()
    jo.menu.setCurrentMenu(rootMenuId, false)
    jo.menu.show(true, true, false, true, Config.MenuEnableCursor ~= true)
end

-- Get available interactions (flat list)
function MenuManager.GetAvailableInteractions()
    local props = GetAvailableProps()
    local allInteractions = {}

    for _, prop in ipairs(props) do
        local interactions = GetInteractionsForProp(prop)
        for _, interaction in ipairs(interactions) do
            table.insert(allInteractions, interaction)
        end
    end

    return allInteractions
end
