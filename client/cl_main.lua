-- State variables
local CanStartInteraction = true
local nearObject = false
local Initialized = false

-- Initialize all systems
CreateThread(function()
    Wait(1000)
    PromptManager.Initialize()
    DetectionManager.Initialize()
    Initialized = true
    print('Initialized successfully')
end)

-- Check if player can interact (not dead, not in combat)
CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        CanStartInteraction = not IsPedDeadOrDying(ped) and not IsPedInCombat(ped)
    end
end)

-- Detect nearby interaction objects
CreateThread(function()
    -- Wait for initialization to complete
    while not Initialized do
        Wait(100)
    end
    
    local baseInterval = Config.DetectionInterval or 500
    local activeInterval = 0 -- No wait when near objects for instant response
    local currentInterval = baseInterval
    
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local isNearInteractionObject = DetectionManager.IsNearInteractionObject(playerCoords)
        
        if isNearInteractionObject and CanStartInteraction then
            nearObject = true
            currentInterval = activeInterval -- Switch to instant updates
        else
            nearObject = false
            currentInterval = baseInterval -- Switch back to normal interval
            -- Close menu and stop interaction if player moved away
            if MenuManager.IsInMenu() then
                MenuManager.Close()
            end
            if InteractionManager.IsInteracting() then
                InteractionManager.StopInteraction()
            end
        end
        
        Wait(currentInterval)
    end
end)

-- Display prompts based on player state
CreateThread(function()
    while true do
        Wait(0)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        local isInteracting = InteractionManager.IsInteracting()
        
        if isInteracting then
            -- Show both prompts when interacting
            if not DetectionManager.IsAreaBanned(playerCoords) and CanStartInteraction then
                PromptManager.ActivateStandUp()
            else
                Wait(500)
            end
        elseif not DetectionManager.IsAreaBanned(playerCoords) and nearObject and CanStartInteraction then
            -- Show interaction prompt when near object
            PromptManager.Activate(Translation[Config.Locale]['prompt_group'])
        else
            Wait(500)
        end
    end
end)

-- Handle prompt presses and open menu
CreateThread(function()
    while true do
        Wait(0)
        
        local isInteracting = InteractionManager.IsInteracting()
        
        -- Stand up prompt pressed
        if isInteracting and PromptManager.IsStandUpPressed() and CanStartInteraction then
            InteractionManager.StopInteraction()
            if MenuManager.IsInMenu() then
                MenuManager.Close()
            end
            Wait(500)
        -- Interaction prompt pressed - open menu
        elseif PromptManager.IsPressed() and CanStartInteraction then
            local availableInteractions = MenuManager.GetAvailableInteractions()
            
            if #availableInteractions > 0 then
                MenuManager.Open(availableInteractions, function(selectedInteraction)
                    if selectedInteraction then
                        -- Start selected interaction directly
                        if selectedInteraction.object then
                            InteractionManager.StartInteractionAtObject(selectedInteraction)
                        else
                            InteractionManager.StartInteractionAtCoords(selectedInteraction)
                        end
                        MenuManager.Close()
                    else
                        -- Cancel - stop current interaction
                        if InteractionManager.IsInteracting() then
                            InteractionManager.StopInteraction()
                        end
                    end
                end)
            else
                -- No interactions available
                if InteractionManager.IsInteracting() then
                    InteractionManager.StopInteraction()
                end
            end
            
            Wait(500)
        end
    end
end)

-- Clean up on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    if MenuManager.IsInMenu() then
        MenuManager.Close()
    end
    
    if InteractionManager.IsInteracting() then
        InteractionManager.StopInteraction()
    end
end)
