local CanStartInteraction = true
local nearObject = false
local Initialized = false

CreateThread(function()
    Wait(1000)
    PromptManager.Initialize()
    DetectionManager.Initialize()
    Initialized = true
end)

CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        CanStartInteraction = not IsPedDeadOrDying(ped) and not IsPedInCombat(ped)
    end
end)

CreateThread(function()
    while not Initialized do
        Wait(100)
    end

    local idleInterval = Config.DetectionInterval or 500
    local nearInterval = Config.DetectionIntervalNear or 250

    while true do
        if CanStartInteraction then
            nearObject = DetectionManager.IsNearInteractionObject(GetEntityCoords(PlayerPedId()))
        else
            nearObject = false
        end

        if not nearObject then
            if MenuManager.IsInMenu() then
                MenuManager.Close()
            end
            if InteractionManager.IsInteracting() then
                InteractionManager.StopInteraction()
            end
        end

        Wait(nearObject and nearInterval or idleInterval)
    end
end)

CreateThread(function()
    while not Initialized do
        Wait(100)
    end

    while true do
        local isInteracting = InteractionManager.IsInteracting()

        if not isInteracting and not nearObject then
            Wait(250)
            goto continue
        end

        if MenuManager.IsInMenu() then
            Wait(100)
            goto continue
        end

        if DetectionManager.IsAreaBanned(GetEntityCoords(PlayerPedId())) or not CanStartInteraction then
            Wait(250)
            goto continue
        end

        if isInteracting then
            PromptManager.ActivateStandUp()

            if PromptManager.IsStandUpPressed() then
                InteractionManager.StopInteraction()
                Wait(500)
                goto continue
            end
        else
            PromptManager.Activate(L('prompt_group'))
        end

        if PromptManager.IsPressed() then
            local availableInteractions = MenuManager.GetAvailableInteractions()

            if #availableInteractions > 0 then
                MenuManager.Open(availableInteractions, function(selectedInteraction)
                    if selectedInteraction then
                        if selectedInteraction.object then
                            InteractionManager.StartInteractionAtObject(selectedInteraction)
                        else
                            InteractionManager.StartInteractionAtCoords(selectedInteraction)
                        end
                    elseif InteractionManager.IsInteracting() then
                        InteractionManager.StopInteraction()
                    end
                end)
            elseif InteractionManager.IsInteracting() then
                InteractionManager.StopInteraction()
            end

            Wait(300)
            goto continue
        end

        Wait(0)

        ::continue::
    end
end)

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
