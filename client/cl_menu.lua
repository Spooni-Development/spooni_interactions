MenuManager = {}
local MenuData = exports.vorp_menu:GetMenuData()
local InMenu = false

-- Check if menu is currently open
function MenuManager.IsInMenu()
    return InMenu
end

-- Close menu
function MenuManager.Close()
    if InMenu then
        MenuData.CloseAll()
        InMenu = false
    end
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
    if category and category.label then
        return category.label
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
                            modelName = interaction.labelText2 or 'Location',
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

-- Group interactions by position
local function GroupInteractionsByPosition(interactions)
    local positions = {}
    
    for _, interaction in ipairs(interactions) do
        local positionKey = interaction.label or 'default'
        if not positions[positionKey] then
            positions[positionKey] = {
                label = positionKey,
                interactions = {}
            }
        end
        table.insert(positions[positionKey].interactions, interaction)
    end
    
    return positions
end

-- Open position selection menu (when multiple positions available)
local function OpenPositionSelectionMenu(positions, onSelectCallback, onBackCallback)
    InMenu = true
    MenuData.CloseAll()
    
    local elements = {}
    for positionKey, positionData in pairs(positions) do
        local label = Translation[Config.Locale]["menu_position_" .. positionKey] or 
                     (positionKey == 'left' and Translation[Config.Locale]["menu_position_left"] or
                      positionKey == 'right' and Translation[Config.Locale]["menu_position_right"] or
                      positionKey == 'middle' and Translation[Config.Locale]["menu_position_middle"] or
                      positionKey == 'up' and Translation[Config.Locale]["menu_position_up"] or
                      positionKey)
        table.insert(elements, {
            label = label,
            value = positionKey,
            desc = Translation[Config.Locale]["menu_select_position_subtitle"] or "Select this position",
            position = positionData
        })
    end
    
    table.sort(elements, function(a, b)
        return a.label < b.label
    end)
    
    MenuData.Open("default", GetCurrentResourceName(), "spooni_interactions_position",
        {
            title = Translation[Config.Locale]["menu_select_position"] or "Select Position",
            subtext = Translation[Config.Locale]["menu_select_position_subtitle"] or "Choose a position...",
            align = "top-left",
            elements = elements,
            maxVisibleItems = 6,
            hideRadar = false,
            enableCursor = Config.MenuEnableCursor == nil and true or Config.MenuEnableCursor
        },
        function(data, menu)
            if data.current.position then
                menu.close()
                InMenu = false
                onSelectCallback(data.current.position)
            end
        end,
        function(data, menu)
            menu.close()
            InMenu = false
            if onBackCallback then
                onBackCallback()
            else
                onSelectCallback(nil)
            end
        end
    )
end

-- Open category selection menu
local function OpenCategoryMenu(categories, onSelectCallback, onBackCallback)
    InMenu = true
    MenuData.CloseAll()
    
    local elements = {}
    local categoryOrder = {'sitting', 'drinking_smoking', 'instruments', 'other'}
    
    for _, categoryKey in ipairs(categoryOrder) do
        if categories[categoryKey] and #categories[categoryKey] > 0 then
            local label = GetCategoryLabel(categoryKey)
            local count = #categories[categoryKey]
            table.insert(elements, {
                label = label,
                value = categoryKey,
                desc = string.format("%s %d %s", label, count, count == 1 and "interaction" or "interactions"),
                categoryKey = categoryKey,
                category = categories[categoryKey]
            })
        end
    end
    
    MenuData.Open("default", GetCurrentResourceName(), "spooni_interactions_category",
        {
            title = Translation[Config.Locale]["menu_title"] or "Interactions",
            subtext = Translation[Config.Locale]["menu_select_category_subtitle"] or "Select a category...",
            align = "top-left",
            elements = elements,
            maxVisibleItems = 6,
            hideRadar = false,
            enableCursor = Config.MenuEnableCursor == nil and true or Config.MenuEnableCursor
        },
        function(data, menu)
            if data.current.category and data.current.categoryKey then
                menu.close()
                InMenu = false
                onSelectCallback(data.current.categoryKey, data.current.category)
            end
        end,
        function(data, menu)
            menu.close()
            InMenu = false
            if onBackCallback then
                onBackCallback()
            else
                onSelectCallback(nil, nil)
            end
        end
    )
end

-- Group interactions by type (scenario/animation, ignoring position)
local function GroupInteractionsByType(interactions)
    local groups = {}
    
    for _, interaction in ipairs(interactions) do
        local typeKey = interaction.scenario or (interaction.animation and interaction.animation.name) or "unknown"
        
        if not groups[typeKey] then
            groups[typeKey] = {
                interactions = {},
                baseLabel = interaction.labelText or interaction.labelText2 or "Unknown"
            }
        end
        table.insert(groups[typeKey].interactions, interaction)
    end
    
    return groups
end

-- Open interactions menu for a category
local function OpenInteractionsMenu(categoryInteractions, categoryLabel, onSelectCallback, onBackCallback)
    InMenu = true
    MenuData.CloseAll()
    
    -- Group interactions by type
    local interactionGroups = GroupInteractionsByType(categoryInteractions)
    
    local elements = {}
    for typeKey, groupData in pairs(interactionGroups) do
        local baseLabel = groupData.baseLabel
        
        -- Check if multiple positions available
        local hasMultiplePositions = false
        local positions = {}
        for _, interaction in ipairs(groupData.interactions) do
            if interaction.label and interaction.label ~= 'default' then
                hasMultiplePositions = true
                if not positions[interaction.label] then
                    positions[interaction.label] = {
                        label = interaction.label,
                        interactions = {}
                    }
                end
                table.insert(positions[interaction.label].interactions, interaction)
            end
        end
        
        if hasMultiplePositions and #groupData.interactions > 1 then
            -- Multiple positions: show base label
            table.insert(elements, {
                label = baseLabel,
                value = typeKey,
                desc = "Multiple positions available",
                hasPositions = true,
                positions = positions
            })
        else
            -- Single interaction: show directly
            local interaction = groupData.interactions[1]
            local desc = "Start this interaction"
            if interaction.scenario then
                desc = string.format("Start %s scenario", baseLabel)
            elseif interaction.animation then
                desc = string.format("Start %s animation", baseLabel)
            end
            table.insert(elements, {
                label = baseLabel,
                value = typeKey,
                desc = desc,
                interaction = interaction,
                hasPositions = false
            })
        end
    end
    
    table.sort(elements, function(a, b)
        return a.label < b.label
    end)
    
    MenuData.Open("default", GetCurrentResourceName(), "spooni_interactions_list",
        {
            title = categoryLabel,
            subtext = Translation[Config.Locale]["menu_subtitle"] or "Select an interaction...",
            align = "top-left",
            elements = elements,
            maxVisibleItems = 6,
            hideRadar = false,
            enableCursor = Config.MenuEnableCursor == nil and true or Config.MenuEnableCursor
        },
        function(data, menu)
            if data.current.hasPositions then
                -- Multiple positions: show position menu
                menu.close()
                InMenu = false
                OpenPositionSelectionMenu(data.current.positions, function(selectedPosition)
                    if selectedPosition and selectedPosition.interactions and #selectedPosition.interactions > 0 then
                        onSelectCallback(selectedPosition.interactions[1])
                    end
                end, function()
                    OpenInteractionsMenu(categoryInteractions, categoryLabel, onSelectCallback, onBackCallback)
                end)
            elseif data.current.interaction then
                -- Single interaction: use directly
                menu.close()
                InMenu = false
                onSelectCallback(data.current.interaction)
            end
        end,
        function(data, menu)
            menu.close()
            InMenu = false
            if onBackCallback then
                onBackCallback()
            else
                onSelectCallback(nil)
            end
        end
    )
end

-- Main entry point: Open categorized menu system
function MenuManager.Open(availableInteractions, onSelectCallback)
    -- Legacy compatibility: use provided interactions
    if availableInteractions and #availableInteractions > 0 then
        local categories = GroupInteractionsByCategory(availableInteractions)
        
        if GetTableLength(categories) == 1 then
            local categoryKey, categoryInteractions = next(categories)
            OpenInteractionsMenu(categoryInteractions, GetCategoryLabel(categoryKey), onSelectCallback)
        else
            local function ShowCategoryMenu()
                OpenCategoryMenu(categories, function(categoryKey, selectedCategory)
                    if categoryKey and selectedCategory then
                        OpenInteractionsMenu(selectedCategory, GetCategoryLabel(categoryKey), onSelectCallback, ShowCategoryMenu)
                    end
                end)
            end
            ShowCategoryMenu()
        end
        return
    end
    
    -- New system: Get available props
    local props = GetAvailableProps()
    
    if #props == 0 then
        return
    end
    
    -- Use closest prop
    local prop = props[1]
    local interactions = GetInteractionsForProp(prop)
    
    -- Check if position selection needed
    local positions = GroupInteractionsByPosition(interactions)
    local positionKeys = {}
    for k, v in pairs(positions) do
        table.insert(positionKeys, k)
    end
    
    if #positionKeys > 1 then
        -- Multiple positions: show position menu
        local function ShowPositionMenu()
            OpenPositionSelectionMenu(positions, function(selectedPosition)
                if selectedPosition then
                    local categories = GroupInteractionsByCategory(selectedPosition.interactions)
                    
                    if GetTableLength(categories) == 1 then
                        local categoryKey, categoryInteractions = next(categories)
                        OpenInteractionsMenu(categoryInteractions, GetCategoryLabel(categoryKey), onSelectCallback, ShowPositionMenu)
                    else
                        local function ShowCategoryMenuFromPosition()
                            OpenCategoryMenu(categories, function(categoryKey, selectedCategory)
                                if categoryKey and selectedCategory then
                                    OpenInteractionsMenu(selectedCategory, GetCategoryLabel(categoryKey), onSelectCallback, ShowCategoryMenuFromPosition)
                                end
                            end, ShowPositionMenu)
                        end
                        ShowCategoryMenuFromPosition()
                    end
                end
            end)
        end
        ShowPositionMenu()
    else
        -- No position selection: group by category
        local categories = GroupInteractionsByCategory(interactions)
        
        if GetTableLength(categories) == 1 then
            local categoryKey, categoryInteractions = next(categories)
            OpenInteractionsMenu(categoryInteractions, GetCategoryLabel(categoryKey), onSelectCallback)
        else
            local function ShowCategoryMenu()
                OpenCategoryMenu(categories, function(categoryKey, selectedCategory)
                    if categoryKey and selectedCategory then
                        OpenInteractionsMenu(selectedCategory, GetCategoryLabel(categoryKey), onSelectCallback, ShowCategoryMenu)
                    end
                end)
            end
            ShowCategoryMenu()
        end
    end
end

-- Get table length
function GetTableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- Legacy compatibility: Get available interactions (flat list)
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
