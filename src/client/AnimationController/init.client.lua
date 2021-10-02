local AnimationController = require(script.Module)

local PlayerService = game:GetService("Players")
local plr = PlayerService.LocalPlayer

plr.CharacterAdded:Connect(function(char)
    char.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Animation") then
            AnimationController.loadAnimation(descendant)
        end
    end)
end)

AnimationController.plr.CharacterRemoving:Connect(function()
    AnimationController.loadedAnimations = {}
    AnimationController.playingAnimations = {}
    AnimationController.pastWeights = {}
end)

AnimationController.loadAnimsOfCharacter(AnimationController.plr.Character) -- just in case if character loads faster than the event bind on the first spawn