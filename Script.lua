local RunService =game:GetService("RunService")
local Userinput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Charatcer = Player.Character or Player.CharacterAdded:Wait()
local LastPressedMovementKey = ""
local MovementKeyIsPressed = false
local AnimationID = {
	WalkForward = "rbxassetid://15731313893",
	WalkBackWard = "rbxassetid://15731312134",
	Sprint = "rbxassetid://15731315812",
}
local W, S, A, D = Enum.KeyCode.W,Enum.KeyCode.S,Enum.KeyCode.A,Enum.KeyCode.D

Player.CharacterAdded:Connect(function(char)
	Charatcer = char
	local Humanoid = Charatcer:WaitForChild("Humanoid")
	Humanoid.JumpHeight = 0
end)

local MovementAnimationtrack:AnimationTrack = nil
local CurrentPlayingAnimation = "Idle"

--this function overrides any existing animation with the new one
--by stopping the previouse animation track and loading in a new one.
function NewMovementAnimationTrack(NewAnimation)
	-- this if statement checks if the animation track exist or not if so then stop the animation
	if MovementAnimationtrack then
		MovementAnimationtrack:Stop()
	end
	-- checking if the character is properly loaded and is not dead
	local Humanoid = Charatcer:FindFirstChild("Humanoid")
	if not Humanoid then warn("Unable to find humanoid") return end
	if Humanoid.Health <= 0 then warn("Player is dead") return end
	
	local Animator = Humanoid:FindFirstChild("Animator")
	if not Animator then warn("Unable to find Animator") return end
	
	-- Load in a new animation
	MovementAnimationtrack = Animator:LoadAnimation(NewAnimation)
	MovementAnimationtrack.Looped = true
	MovementAnimationtrack.Priority = Enum.AnimationPriority.Action
end
--[[this function update the movement animation, it will fire every time w,s,a or d is pressed or release,
once fired this function will check which direction keys (w,s,a,d) is being pressed and change the animation and speed accordingly,
]]
function MovementAnimationUpdate()
	-- check if the character is properly loaded and not dead
	local Humanoid = Charatcer:FindFirstChild("Humanoid")
	if not Humanoid then warn("Unable to find humanoid") return end
	if Humanoid.Health <= 0 then warn("Player is dead") return end
	--this if statement checks to see if any movement key is currently being pressed if not then all movement animation will be stopped
	if not MovementKeyIsPressed and CurrentPlayingAnimation ~= "Idle" then
		-- idle
		TweenService:Create(Charatcer.LowerTorso.Root, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C1 = CFrame.fromOrientation(0, 0, math.rad(0))}):Play()
		CurrentPlayingAnimation = "Idle"
		if MovementAnimationtrack then
			MovementAnimationtrack:Stop()
			MovementAnimationtrack = nil
		end
		return 
	end
	
	-- this if statement checks if only the W key is being pressed and if it is being pressed with the S key or not
	if Userinput:IsKeyDown(W) and not Userinput:IsKeyDown(S) then
		-- Moves Forward
		local AnimationInstance = Instance.new("Animation", script)
		-- this if statement will check if the leftshift is being pressed or not, if it is then the Running animation will be played instead of the walking animation and the player speed will increase
		-- if the leftshift is not being pressed then the walking animation will be played and the player speed will decrease
		-- if the current playing animation is the same as the new one then the new animation will not be loaded
		if Userinput:IsKeyDown(Enum.KeyCode.LeftShift) then
			if CurrentPlayingAnimation ~= "Running"then
				print("Running")
				AnimationInstance.AnimationId = AnimationID.Sprint
				Humanoid.WalkSpeed = 30
				NewMovementAnimationTrack(AnimationInstance)
				CurrentPlayingAnimation = "Running"
				MovementAnimationtrack:Play()
			end
			
		else
			if CurrentPlayingAnimation ~= "WalkingF"then
				AnimationInstance.AnimationId = AnimationID.WalkForward
				Humanoid.WalkSpeed = 8
				NewMovementAnimationTrack(AnimationInstance)
				CurrentPlayingAnimation = "WalkingF"
				MovementAnimationtrack:Play()
			end
			
		end
	end
	
	--this if statement is similar to the one above, it checks if only the S key is being pressed
	-- if the current playing animation is the same as the new one then the new animation will not be loaded
	if Userinput:IsKeyDown(S) and not Userinput:IsKeyDown(W) and CurrentPlayingAnimation ~= "WalkingB" then
		-- Move Backward 
		local AnimationInstance = Instance.new("Animation", script)
		AnimationInstance.AnimationId = AnimationID.WalkBackWard
		Humanoid.WalkSpeed = 8
		NewMovementAnimationTrack(AnimationInstance)
		CurrentPlayingAnimation = "WalkingB"
		MovementAnimationtrack:Play()
	end
	
	-- if both W and S key is being pressed at the same time then all movement animation will be stopped
	if Userinput:IsKeyDown(W) and Userinput:IsKeyDown(S) then
		if MovementAnimationtrack then
			MovementAnimationtrack:Stop()
			MovementAnimationtrack = nil
			CurrentPlayingAnimation = "Idle"
		end
	end
	
	-- similar to the onces above, this one checks if only the D key is being pressed
	-- if so then the character RootMotor will be tweened to 5 degrees in the Z axis
	-- if the S key isn't pressed that means the player is either moving Forward Right or Right
	-- if the current playing animation is not "WalkingF" then the WalkingForward animation will be played
	-- but if the S key is pressed then that means the player is moving Backward Right so the WalkingBackWard animation will be played instead of the WalkingForward Animation
	-- but if S,W,D are pressed at the same time then that means the player is moving right and the Forward Walking Animation will play
	if Userinput:IsKeyDown(D) and not Userinput:IsKeyDown(A) then
		-- Move Right
		TweenService:Create(Charatcer.LowerTorso.Root, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C1 = CFrame.fromOrientation(0, 0, math.rad(5))}):Play()
		if not Userinput:IsKeyDown(W) then
			Humanoid.WalkSpeed = 8
			if CurrentPlayingAnimation ~= "WalkingF" and not Userinput:IsKeyDown(S) then
				local AnimationInstance = Instance.new("Animation", script)
				AnimationInstance.AnimationId = AnimationID.WalkForward
				NewMovementAnimationTrack(AnimationInstance)
				CurrentPlayingAnimation = "WalkingF"
				MovementAnimationtrack:Play()
			elseif Userinput:IsKeyDown(S) and CurrentPlayingAnimation ~= "WalkingB" then

				local AnimationInstance = Instance.new("Animation", script)
				AnimationInstance.AnimationId = AnimationID.WalkBackWard
				NewMovementAnimationTrack(AnimationInstance)
				CurrentPlayingAnimation = "WalkingB"
				MovementAnimationtrack:Play()
			end
		elseif CurrentPlayingAnimation ~= "WalkingF" and Userinput:IsKeyDown(S) and Userinput:IsKeyDown(W) then
				local AnimationInstance = Instance.new("Animation", script)
				AnimationInstance.AnimationId = AnimationID.WalkForward
				NewMovementAnimationTrack(AnimationInstance)
				CurrentPlayingAnimation = "WalkingF"
				MovementAnimationtrack:Play()
		end
		
	end
	-- this one is very similar to the ones above, the only difference is, the RootMotor Tweened -5 degrees on the Z axis instead of 5 Degrees
	if Userinput:IsKeyDown(A) and not Userinput:IsKeyDown(D) then
		-- Move Left
		TweenService:Create(Charatcer.LowerTorso.Root, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C1 = CFrame.fromOrientation(0, 0, math.rad(-5))}):Play()
		if not Userinput:IsKeyDown(W) then
			Humanoid.WalkSpeed = 8
			if CurrentPlayingAnimation ~= "WalkingF" and not Userinput:IsKeyDown(S) then
				local AnimationInstance = Instance.new("Animation", script)
				AnimationInstance.AnimationId = AnimationID.WalkForward
				NewMovementAnimationTrack(AnimationInstance)
				CurrentPlayingAnimation = "WalkingF"
				MovementAnimationtrack:Play()
			elseif Userinput:IsKeyDown(S) and CurrentPlayingAnimation ~= "WalkingB" then

				local AnimationInstance = Instance.new("Animation", script)
				AnimationInstance.AnimationId = AnimationID.WalkBackWard
				NewMovementAnimationTrack(AnimationInstance)
				CurrentPlayingAnimation = "WalkingB"
				MovementAnimationtrack:Play()
			end
		elseif CurrentPlayingAnimation ~= "WalkingF" and Userinput:IsKeyDown(S) and Userinput:IsKeyDown(W) then
			local AnimationInstance = Instance.new("Animation", script)
			AnimationInstance.AnimationId = AnimationID.WalkForward
			NewMovementAnimationTrack(AnimationInstance)
			CurrentPlayingAnimation = "WalkingF"
			MovementAnimationtrack:Play()
		end
	end
	
	-- if both A and D are pressed at the same time then the Root motor will tweened to 0 degrees on the z axis
	if not Userinput:IsKeyDown(A) and not Userinput:IsKeyDown(D) then
		TweenService:Create(Charatcer.LowerTorso.Root, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {C1 = CFrame.fromOrientation(0, 0, math.rad(0))}):Play()
	end
	
end

local OnDashCooldown = false
function Dash()
	OnDashCooldown = true
	local HumanoidRootPart = Charatcer:FindFirstChild("HumanoidRootPart")
	local Humanoid = Charatcer:FindFirstChild("Humanoid")
	if not HumanoidRootPart and not Humanoid and Humanoid.Health <= 0 then return end
	-- this will loop through the character and make any part or mesh part massless within the character
	for i, v in pairs(Charatcer:GetChildren()) do
		if v.ClassName == "Part" or v.ClassName == "MeshPart" then
			v.Massless = true
		end 
	end
	local LV = Instance.new("LinearVelocity", HumanoidRootPart)
	LV.Attachment0 = HumanoidRootPart.RootAttachment
	LV.MaxForce = 10000
	local Direction = ""
	-- the dash direction are determind by the key that are pressed
	if Userinput:IsKeyDown(W) then
		Direction = "F"
	elseif Userinput:IsKeyDown(S) then
		Direction = "B"
	elseif Userinput:IsKeyDown(A) then
		Direction = "L"
	elseif Userinput:IsKeyDown(D) then
		Direction = "R"
	end
	
	local Velocity = 100
	local Con
	-- this heart beat event will decelerate the dash velocity by decreasing the velocity every heartbeat
	-- by using delta time the velocity will decrease 500 per second
	-- once the velocity is below 5 then the LinearVelocity will be destroyed and The event connection disconnect
	-- after 1 second the OnDashCooldown will change to false allowing the player to use dash again
	Con = RunService.Heartbeat:Connect(function(dt)

		if Direction == "F" then
			LV.VectorVelocity = HumanoidRootPart.CFrame.LookVector * Velocity
		elseif Direction == "B" then
			LV.VectorVelocity = -HumanoidRootPart.CFrame.LookVector * Velocity
		elseif Direction == "L" then
			LV.VectorVelocity = -HumanoidRootPart.CFrame.RightVector * Velocity
		elseif Direction == "R" then
			LV.VectorVelocity = HumanoidRootPart.CFrame.RightVector * Velocity
		end
		Velocity -= 500 * dt
		print(LV.VectorVelocity.Magnitude)
		if Velocity < 5 then
			LV:Destroy()
			Con:Disconnect()
			wait(1)
			OnDashCooldown = false
		end
	end)
end


Userinput.InputBegan:Connect(function(input, IsTyping)
	if IsTyping then return end
	local KeyCode = input.KeyCode
	-- if the key input is either W,S,A,D then it will fire the MovementAnimationUpdate function
	if KeyCode == W or KeyCode == S or KeyCode == A or KeyCode == D or KeyCode == Enum.KeyCode.LeftShift then
		print("MovmentUpdate")
		MovementKeyIsPressed = true
		MovementAnimationUpdate()
	end
	if KeyCode == Enum.KeyCode.Q and not OnDashCooldown then
		Dash()
	end
end)

Userinput.InputEnded:Connect(function(input, IsTyping)
	if IsTyping then return end
	local KeyCode = input.KeyCode
	-- if either W,S,A,D key been release then the MovementAnimationUpdate will fire
	if KeyCode == W or KeyCode == S or KeyCode == A or KeyCode == D or KeyCode == Enum.KeyCode.LeftShift then
		print("MovmentUpdate")
		MovementAnimationUpdate()
	end
end)

-- this heartbeat event will check if one of W,S,A,D is being pressed if not then it will Change the "MovementKeyIsPressed" Variable to false and update the movement animation
RunService.Heartbeat:Connect(function()
	
	if not Userinput:IsKeyDown(W) and not Userinput:IsKeyDown(S) and not Userinput:IsKeyDown(A) and not Userinput:IsKeyDown(D) then
		MovementKeyIsPressed = false
		MovementAnimationUpdate()
	end
end)
