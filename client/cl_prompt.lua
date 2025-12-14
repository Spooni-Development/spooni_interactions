PromptManager = {}
local promptGroup = GetRandomIntInRange(0, 0xffffff)
local Interact = nil
local StandUp = nil

-- Initialize prompt system
function PromptManager.Initialize()
    -- Main interaction prompt
    local str = Translation[Config.Locale]['prompt_interact']
    Interact = PromptRegisterBegin()
    UiPromptSetControlAction(Interact, Config.Keys.interact)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    UiPromptSetText(Interact, str)
    UiPromptSetEnabled(Interact, 1)
    UiPromptSetVisible(Interact, 1)
    UiPromptSetStandardMode(Interact, 1)
    UiPromptSetGroup(Interact, promptGroup)
    UiPromptSetUrgentPulsingEnabled(Interact, true)
    UiPromptRegisterEnd(Interact)
    
    -- Stand up prompt (hidden by default)
    local standUpStr = Translation[Config.Locale]['prompt_stand_up']
    StandUp = PromptRegisterBegin()
    UiPromptSetControlAction(StandUp, Config.Keys.standUp)
    standUpStr = CreateVarString(10, 'LITERAL_STRING', standUpStr)
    UiPromptSetText(StandUp, standUpStr)
    UiPromptSetEnabled(StandUp, 1)
    UiPromptSetVisible(StandUp, 0)
    UiPromptSetHoldMode(StandUp, 500)
    UiPromptSetGroup(StandUp, promptGroup)
    UiPromptSetUrgentPulsingEnabled(StandUp, true)
    UiPromptRegisterEnd(StandUp)
end

-- Activate interaction prompt (when not interacting)
function PromptManager.Activate(title)
    UiPromptSetVisible(Interact, 1)
    UiPromptSetVisible(StandUp, 0)
    
    local label = CreateVarString(10, 'LITERAL_STRING', title or Translation[Config.Locale]['prompt_group'])
    UiPromptSetActiveGroupThisFrame(promptGroup, label)
end

-- Activate both prompts (when interacting)
function PromptManager.ActivateStandUp()
    UiPromptSetVisible(Interact, 1)
    UiPromptSetVisible(StandUp, 1)
    
    local label = CreateVarString(10, 'LITERAL_STRING', Translation[Config.Locale]['prompt_group'])
    UiPromptSetActiveGroupThisFrame(promptGroup, label)
end

-- Check if interact prompt was pressed
function PromptManager.IsPressed()
    return UiPromptHasStandardModeCompleted(Interact)
end

-- Check if stand up prompt was pressed
function PromptManager.IsStandUpPressed()
    return UiPromptHasHoldModeCompleted(StandUp)
end
