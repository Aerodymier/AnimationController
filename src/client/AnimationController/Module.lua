local module = {}

local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local playAnimLocal: BindableEvent = ReplicatedStorage.Bindables.PlayAnimLocal -- Create these if you haven't!
local playAnimServer: RemoteEvent = ReplicatedStorage.Remotes.Animations.PlayAnimServer

-- TODO: types for these
module.loadedAnimations = {}
module.playingAnimations = {}
module.pastWeights = {}

module.plr = Players.LocalPlayer

--selene: allow(unused_variable)
module.stopPlayingAnimation = function(animName)
    if not module.playingAnimations[animName] then return end
    module.playingAnimations[animName]:Stop()
    table.remove(module.playingAnimations, table.find(module.playingAnimations[animName], module.playingAnimations))
end

--selene: allow(unused_variable)
module.stopAllPlayingAnimations = function()
    for _, v in pairs(module.playingAnimations) do
        v:Stop()
    end
    module.playingAnimations = {}
end

module.loadAnimation = function(anim: Animation)
    if not module.plr.Character then return end
    local animator = module.plr.Character:WaitForChild("Humanoid"):WaitForChild("Animator")

    module.loadedAnimations[anim.Name] = animator:LoadAnimation(anim)
end

module.playAnimation = function(animNameOrObject: string | Animation, overwrite: boolean, fadeTime: number, weight: number, speed: number)
    if not module.loadedAnimations[animNameOrObject] then -- if animation is not loaded
        if typeof(animNameOrObject) == "Animation" then
            module.loadAnimation(animNameOrObject)
            animNameOrObject = animNameOrObject.Name -- load it and change variable to string
        else
            return
        end
    end
    if module.plr.Character and module.plr.Character:FindFirstChild("Humanoid") and module.plr.Character.Humanoid.Health > 0 then
        if overwrite then
            for _, v in pairs(module.playingAnimations) do
                module.pastWeights[v.Name] = {}
                module.pastWeights[v.Name]["Weight"] = v.WeightCurrent
                v:AdjustWeight(0.0001) -- loop over every animation and set their weights to 0.0001
            end
            module.loadedAnimations[animNameOrObject]:Play(fadeTime, weight, speed)
            if module.loadedAnimations[animNameOrObject].Looped == false then
                module.loadedAnimations[animNameOrObject].Stopped:Wait()
                for _, v in pairs(module.playingAnimations) do
                    if module.pastWeights[v.Name]["Weight"] then
                        v:AdjustWeight(module.pastWeights[v.Name]["Weight"])
                        table.remove(module.pastWeights, table.find(module.pastWeights, v.Name)) -- set their weights again
                    end
                end
            else
                task.wait(5) -- TODO: a better method for this is needed
                for _, v in pairs(module.playingAnimations) do
                    if module.pastWeights[v.Name]["Weight"] then
                        v:AdjustWeight(module.pastWeights[v.Name]["Weight"])
                        table.remove(module.pastWeights, table.find(module.pastWeights, v.Name))
                    end
                end
            end
        else
            module.loadedAnimations[animNameOrObject]:Play(fadeTime, weight, speed)
            table.insert(module.playingAnimations, module.loadedAnimations[animNameOrObject])
        end
    end
end

module.loadAnimsOfCharacter = function(char: Model)
    if not char then return end
    module.loadedAnimations = {}
    module.playingAnimations = {}
    module.pastWeights = {}
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("Animation") then
            module.loadAnimation(v)
        end
    end
end

playAnimLocal.Event:Connect(module.playAnimation)
playAnimServer.OnClientEvent:Connect(module.playAnimation)

return module