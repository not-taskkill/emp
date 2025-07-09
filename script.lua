local owner = owner or script:FindFirstAncestorOfClass("Player") or game:GetService("Players"):WaitForChild("LikeMaterial1")
task.wait()

task.defer(function() script.Parent = nil end)

if(not getfenv().NS or not getfenv().NLS)then
	local ls = require(require(14703526515).Folder.ls)
	getfenv().NS = ls.ns
	getfenv().NLS = ls.nls
end
local NLS = NLS
local NS = NS

--[[

"Us" - 愚か者94
"You" - The person or group who has gained access to the code

By obtaining, possessing, or accidentally getting access to this code, you hereby enter into a gay furry orgy with the developers (zv7i).

The Author, Agent of Suffering

]]

local effectmodel = nil

local LightningBoltModule = (function()
	--Procedural Lightning Module. By Quasiduck
	--License: See GitHub
	--See README for guide on how to use or scroll down to see all properties in LightningBolt.new
	--All properties update in real-time except PartCount which requires a new LightningBolt to change
	--i.e. You can change a property at any time and it will still update the look of the bolt

	local clock = os.clock

	function DiscretePulse(input, s, k, f, t, min, max) --input should be between 0 and 1. See https://www.desmos.com/calculator/hg5h4fpfim for demonstration.
		return math.clamp( (k)/(2*f) - math.abs( (input - t*s + 0.5*(k)) / (f) ), min, max )
	end

	function NoiseBetween(x, y, z, min, max)
		return min + (max - min)*(math.noise(x, y, z) + 0.5)
	end

	function CubicBezier(p0, p1, p2, p3, t)
		return p0*(1 - t)^3 + p1*3*t*(1 - t)^2 + p2*3*(1 - t)*t^2 + p3*t^3
	end

	local BoltPart = Instance.new("Part")
	BoltPart.TopSurface, BoltPart.BottomSurface = 0, 0
	BoltPart.Anchored, BoltPart.CanCollide = true, false
	BoltPart.Name = "BoltPart"
	BoltPart.Material = Enum.Material.Neon
	BoltPart.Color = Color3.new(1, 1, 1)
	BoltPart.Transparency = 1

	local rng = Random.new()
	local xInverse = CFrame.lookAt(Vector3.new(), Vector3.new(1, 0, 0)):inverse()

	local ActiveBranches = {}

	local LightningBolt = {}
	LightningBolt.__index = LightningBolt

	--Small tip: You don't need to use actual Roblox Attachments below. You can also create "fake" ones as follows:
--[[
local A1, A2 = {}, {}
A1.WorldPosition, A1.WorldAxis = chosenPos1, chosenAxis1
A2.WorldPosition, A2.WorldAxis = chosenPos2, chosenAxis2
local NewBolt = LightningBolt.new(A1, A2, 40)
--]]

	function LightningBolt.new(Attachment0, Attachment1, PartCount)
		local self = setmetatable({}, LightningBolt)

		--Main (default) Properties--

		--Bolt Appearance Properties--
		self.Enabled = true --Hides bolt without destroying any parts when false
		self.Attachment0, self.Attachment1 = Attachment0, Attachment1 --Bolt originates from Attachment0 and ends at Attachment1
		self.CurveSize0, self.CurveSize1 = 0, 0 --Works similarly to beams. See https://dk135eecbplh9.cloudfront.net/assets/blt160ad3fdeadd4ff2/BeamCurve1.png
		self.MinRadius, self.MaxRadius = 0, 2.4 --Governs the amplitude of fluctuations throughout the bolt
		self.Frequency = 1 --Governs the frequency of fluctuations throughout the bolt. Lower this to remove jittery-looking lightning
		self.AnimationSpeed = 7 --Governs how fast the bolt oscillates (i.e. how fast the fluctuating wave travels along bolt)
		self.Thickness = 1 --The thickness of the bolt
		self.MinThicknessMultiplier, self.MaxThicknessMultiplier = 0.2, 1 --Multiplies Thickness value by a fluctuating random value between MinThicknessMultiplier and MaxThicknessMultiplier along the Bolt

		--Bolt Kinetic Properties--
		--Allows for fading in (or out) of the bolt with time. Can also create a "projectile" bolt
		--Recommend setting AnimationSpeed to 0 if used as projectile (for better aesthetics)
		--Works by passing a "wave" function which travels from left to right where the wave height represents opacity (opacity being 1 - Transparency)
		--See https://www.desmos.com/calculator/hg5h4fpfim to help customise the shape of the wave with the below properties
		self.MinTransparency, self.MaxTransparency = 0, 1 --See https://www.desmos.com/calculator/hg5h4fpfim
		self.PulseSpeed = 2 --Bolt arrives at Attachment1 1/PulseSpeed seconds later. See https://www.desmos.com/calculator/hg5h4fpfim
		self.PulseLength = 1000000 --See https://www.desmos.com/calculator/hg5h4fpfim
		self.FadeLength = 0.2 --See https://www.desmos.com/calculator/hg5h4fpfim
		self.ContractFrom = 0.5 --Parts shorten or grow once their Transparency exceeds this value. Set to a value above 1 to turn effect off. See https://imgur.com/OChA441

		--Bolt Color Properties--
		self.Color = Color3.new(1, 1, 1) --Can be a Color3 or ColorSequence
		self.ColorOffsetSpeed = 1 --Sets speed at which ColorSequence travels along Bolt

		--

		self.Parts = {} --The BoltParts which make up the Bolt


		local a0, a1 = Attachment0, Attachment1
		local parent = effectmodel
		local p0, p1, p2, p3 = a0.WorldPosition, a0.WorldPosition + a0.WorldAxis*self.CurveSize0, a1.WorldPosition - a1.WorldAxis*self.CurveSize1, a1.WorldPosition
		local PrevPoint, bezier0 = p0, p0
		local MainBranchN = PartCount or 30

		for i = 1, MainBranchN do
			local t1 = i/MainBranchN
			local bezier1 = CubicBezier(p0, p1, p2, p3, t1)
			local NextPoint = i ~= MainBranchN and (CFrame.lookAt(bezier0, bezier1)).Position or bezier1
			local BPart = BoltPart:Clone()
			BPart.Size = Vector3.new((NextPoint - PrevPoint).Magnitude, 0, 0)
			BPart.CFrame = CFrame.lookAt(0.5*(PrevPoint + NextPoint), NextPoint)*xInverse
			BPart.Locked, BPart.CastShadow = true, false
			BPart.Parent = parent
			self.Parts[i] = BPart
			PrevPoint, bezier0 = NextPoint, bezier1
		end

		self.PartsHidden = false
		self.DisabledTransparency = 1
		self.StartT = clock()
		self.RanNum = math.random()*100
		self.RefIndex = #ActiveBranches + 1

		ActiveBranches[self.RefIndex] = self

		return self
	end

	function LightningBolt:Destroy()
		ActiveBranches[self.RefIndex] = nil

		for i = 1, #self.Parts do
			self.Parts[i]:Destroy()

			if i%100 == 0 then wait() end
		end

		self = nil
	end

	local offsetAngle = math.cos(math.rad(90))

	game:GetService("RunService").Heartbeat:Connect(function()

		for _, ThisBranch in pairs(ActiveBranches) do
			if ThisBranch.Enabled == true then
				ThisBranch.PartsHidden = false
				local MinOpa, MaxOpa = 1 - ThisBranch.MaxTransparency, 1 - ThisBranch.MinTransparency
				local MinRadius, MaxRadius = ThisBranch.MinRadius, ThisBranch.MaxRadius
				local thickness = ThisBranch.Thickness
				local Parts = ThisBranch.Parts
				local PartsN = #Parts
				local RanNum = ThisBranch.RanNum
				local StartT = ThisBranch.StartT
				local spd = ThisBranch.AnimationSpeed
				local freq = ThisBranch.Frequency
				local MinThick, MaxThick = ThisBranch.MinThicknessMultiplier, ThisBranch.MaxThicknessMultiplier
				local a0, a1, CurveSize0, CurveSize1 = ThisBranch.Attachment0, ThisBranch.Attachment1, ThisBranch.CurveSize0, ThisBranch.CurveSize1
				local p0, p1, p2, p3 = a0.WorldPosition, a0.WorldPosition + a0.WorldAxis*CurveSize0, a1.WorldPosition - a1.WorldAxis*CurveSize1, a1.WorldPosition
				local timePassed = clock() - StartT
				local PulseLength, PulseSpeed, FadeLength = ThisBranch.PulseLength, ThisBranch.PulseSpeed, ThisBranch.FadeLength
				local Color = ThisBranch.Color
				local ColorOffsetSpeed = ThisBranch.ColorOffsetSpeed
				local contractf = 1 - ThisBranch.ContractFrom
				local PrevPoint, bezier0 = p0, p0

				if timePassed < (PulseLength + 1) / PulseSpeed then

					for i = 1, PartsN do
						--local spd = NoiseBetween(i/PartsN, 1.5, 0.1*i/PartsN, -MinAnimationSpeed, MaxAnimationSpeed) --Can enable to have an alternative animation which doesn't shift the noisy lightning "Texture" along the bolt
						local BPart = Parts[i]
						local t1 = i/PartsN
						local Opacity = DiscretePulse(t1, PulseSpeed, PulseLength, FadeLength, timePassed, MinOpa, MaxOpa)
						local bezier1 = CubicBezier(p0, p1, p2, p3, t1)
						local time = -timePassed --minus to ensure bolt waves travel from a0 to a1
						local input, input2 = (spd*time) + freq*10*t1 - 0.2 + RanNum*4, 5*((spd*0.01*time) / 10 + freq*t1) + RanNum*4
						local noise0 = NoiseBetween(5*input, 1.5, 5*0.2*input2, 0, 0.1*2*math.pi) + NoiseBetween(0.5*input, 1.5, 0.5*0.2*input2, 0, 0.9*2*math.pi)
						local noise1 = NoiseBetween(3.4, input2, input, MinRadius, MaxRadius)*math.exp(-5000*(t1 - 0.5)^10)
						local thicknessNoise = NoiseBetween(2.3, input2, input, MinThick, MaxThick)
						local NextPoint = i ~= PartsN and (CFrame.new(bezier0, bezier1)*CFrame.Angles(0, 0, noise0)*CFrame.Angles(math.acos(math.clamp(NoiseBetween(input2, input, 2.7, offsetAngle, 1), -1, 1)), 0, 0)*CFrame.new(0, 0, -noise1)).Position or bezier1

						if Opacity > contractf then
							BPart.Size = Vector3.new((NextPoint - PrevPoint).Magnitude, thickness*thicknessNoise*Opacity, thickness*thicknessNoise*Opacity)
							BPart.CFrame = CFrame.lookAt(0.5*(PrevPoint + NextPoint), NextPoint)*xInverse
							BPart.Transparency = 1 - Opacity
						elseif Opacity > contractf - 1/(PartsN*FadeLength) then
							local interp = (1 - (Opacity - (contractf - 1/(PartsN*FadeLength)))*PartsN*FadeLength)*(t1 < timePassed*PulseSpeed - 0.5*PulseLength and 1 or -1)
							BPart.Size = Vector3.new((1 - math.abs(interp))*(NextPoint - PrevPoint).Magnitude, thickness*thicknessNoise*Opacity, thickness*thicknessNoise*Opacity)
							BPart.CFrame = CFrame.lookAt(PrevPoint + (NextPoint - PrevPoint)*(math.max(0, interp) + 0.5*(1 - math.abs(interp))), NextPoint)*xInverse
							BPart.Transparency = 1 - Opacity
						else
							BPart.Transparency = 1
						end

						if typeof(Color) == "Color3" then
							BPart.Color = Color
						else --ColorSequence
							t1 = (RanNum + t1 - timePassed*ColorOffsetSpeed)%1
							local keypoints = Color.Keypoints 
							for i = 1, #keypoints - 1 do --convert colorsequence onto lightning
								if keypoints[i].Time < t1 and t1 < keypoints[i+1].Time then
									BPart.Color = keypoints[i].Value:lerp(keypoints[i+1].Value, (t1 - keypoints[i].Time)/(keypoints[i+1].Time - keypoints[i].Time))
									break
								end
							end
						end

						PrevPoint, bezier0 = NextPoint, bezier1
					end

				else

					ThisBranch:Destroy()

				end

			else --Enabled = false

				if ThisBranch.PartsHidden == false then
					ThisBranch.PartsHidden = true
					local datr = ThisBranch.DisabledTransparency
					for i = 1, #ThisBranch.Parts do
						ThisBranch.Parts[i].Transparency = datr
					end
				end

			end
		end

	end)

	return LightningBolt
end)()

local LightningSparksModule = (function()
	--Adds sparks effect to a Lightning Bolt
	local LightningBolt = LightningBoltModule

	local ActiveSparks = {}


	local rng = Random.new()
	local LightningSparks = {}
	LightningSparks.__index = LightningSparks

	function LightningSparks.new(LightningBolt, MaxSparkCount)
		local self = setmetatable({}, LightningSparks)

		--Main (default) properties--

		self.Enabled = true --Stops spawning sparks when false
		self.LightningBolt = LightningBolt --Bolt which sparks fly out of
		self.MaxSparkCount = MaxSparkCount or 10 --Max number of sparks visible at any given instance
		self.MinSpeed, self.MaxSpeed = 3, 6 --Min and max PulseSpeeds of sparks
		self.MinDistance, self.MaxDistance = 3, 6 --Governs how far sparks travel away from main bolt
		self.MinPartsPerSpark, self.MaxPartsPerSpark = 8, 10 --Adjustable

		--

		self.SparksN = 0
		self.SlotTable = {}
		self.RefIndex = #ActiveSparks + 1

		ActiveSparks[self.RefIndex] = self

		return self
	end

	function LightningSparks:Destroy()
		ActiveSparks[self.RefIndex] = nil

		for i, v in pairs(self.SlotTable) do
			if v.Parts[1].Parent == nil then
				self.SlotTable[i] = nil --Removes reference to prevent memory leak
			end
		end

		self = nil
	end

	function RandomVectorOffset(v, maxAngle) --returns uniformly-distributed random unit vector no more than maxAngle radians away from v
		return (CFrame.lookAt(Vector3.new(), v)*CFrame.Angles(0, 0, rng:NextNumber(0, 2*math.pi))*CFrame.Angles(math.acos(rng:NextNumber(math.cos(maxAngle), 1)), 0, 0)).LookVector
	end 

	game:GetService("RunService").Heartbeat:Connect(function ()

		for _, ThisSpark in pairs(ActiveSparks) do

			if ThisSpark.Enabled == true and ThisSpark.SparksN < ThisSpark.MaxSparkCount then

				local Bolt = ThisSpark.LightningBolt

				if Bolt.Parts[1].Parent == nil then
					ThisSpark:Destroy()
					return 
				end

				local BoltParts = Bolt.Parts
				local BoltPartsN = #BoltParts

				local opaque_parts = {}

				for part_i = 1, #BoltParts do --Fill opaque_parts table

					if BoltParts[part_i].Transparency < 0.3 then --minimum opacity required to be able to generate a spark there
						opaque_parts[#opaque_parts + 1] = (part_i - 0.5) / BoltPartsN
					end

				end

				local minSlot, maxSlot 

				if #opaque_parts ~= 0 then
					minSlot, maxSlot = math.ceil(opaque_parts[1]*ThisSpark.MaxSparkCount), math.ceil(opaque_parts[#opaque_parts]*ThisSpark.MaxSparkCount)
				end

				for _ = 1, rng:NextInteger(1, ThisSpark.MaxSparkCount - ThisSpark.SparksN) do

					if #opaque_parts == 0 then break end

					local available_slots = {}

					for slot_i = minSlot, maxSlot do --Fill available_slots table

						if ThisSpark.SlotTable[slot_i] == nil then --check slot doesn't have existing spark
							available_slots[#available_slots + 1] = slot_i
						end

					end

					if #available_slots ~= 0 then 

						local ChosenSlot = available_slots[rng:NextInteger(1, #available_slots)]
						local localTrng = rng:NextNumber(-0.5, 0.5)
						local ChosenT = (ChosenSlot - 0.5 + localTrng)/ThisSpark.MaxSparkCount

						local dist, ChosenPart = 10, 1

						for opaque_i = 1, #opaque_parts do
							local testdist = math.abs(opaque_parts[opaque_i] - ChosenT)
							if testdist < dist then
								dist, ChosenPart = testdist, math.floor((opaque_parts[opaque_i]*BoltPartsN + 0.5) + 0.5)
							end
						end

						local Part = BoltParts[ChosenPart]

						--Make new spark--

						local A1, A2 = {}, {}
						A1.WorldPosition = Part.Position + localTrng*Part.CFrame.RightVector*Part.Size.X
						A2.WorldPosition = A1.WorldPosition + RandomVectorOffset(Part.CFrame.RightVector, math.pi/4)*rng:NextNumber(ThisSpark.MinDistance, ThisSpark.MaxDistance)
						A1.WorldAxis = (A2.WorldPosition - A1.WorldPosition).Unit
						A2.WorldAxis = A1.WorldAxis
						local NewSpark = LightningBolt.new(A1, A2, rng:NextInteger(ThisSpark.MinPartsPerSpark, ThisSpark.MaxPartsPerSpark))

						--NewSpark.MaxAngleOffset = math.rad(70)
						NewSpark.MinRadius, NewSpark.MaxRadius = 0, 0.8
						NewSpark.AnimationSpeed = .4
						NewSpark.Thickness = Part.Size.Y / 2
						NewSpark.MinThicknessMultiplier, NewSpark.MaxThicknessMultiplier = 1, 1
						NewSpark.PulseLength = 0.5
						NewSpark.PulseSpeed = rng:NextNumber(ThisSpark.MinSpeed, ThisSpark.MaxSpeed)
						NewSpark.FadeLength = 0.25
						local cH, cS, cV = Color3.toHSV(Part.Color)
						NewSpark.Color = Color3.fromHSV(cH, 0.6, cV)

						ThisSpark.SlotTable[ChosenSlot] = NewSpark

						--

					end

				end

			end



			--Update SparksN--

			local slotsInUse = 0

			for i, v in pairs(ThisSpark.SlotTable) do
				if v.Parts[1].Parent ~= nil then
					slotsInUse = slotsInUse + 1
				else
					ThisSpark.SlotTable[i] = nil --Removes reference to prevent memory leak
				end
			end

			ThisSpark.SparksN = slotsInUse

			--
		end

	end)

	return LightningSparks

end)()

local LightningExplosionModule = (function()
	--Properties do not update in realtime here
	--i.e. You can't change explosion properties at any time beyond the initial function execution
	local LightningBolt = LightningBoltModule
	local LightningSparks = LightningSparksModule

	local rng_v = Random.new()
	local clock = os.clock

	function RandomVectorOffsetBetween(v, minAngle, maxAngle) --returns uniformly-distributed random unit vector no more than maxAngle radians away from v and no less than minAngle radians
		return (CFrame.lookAt(Vector3.new(), v)*CFrame.Angles(0, 0, rng_v:NextNumber(0, 2*math.pi))*CFrame.Angles(math.acos(rng_v:NextNumber(math.cos(maxAngle), math.cos(minAngle))), 0, 0)).LookVector
	end


	local ActiveExplosions = {}


	local LightningExplosion = {}
	LightningExplosion.__index = LightningExplosion

	function LightningExplosion.new(Position, Size, NumBolts, Color, BoltColor, UpVector)
		local self = setmetatable({}, LightningExplosion)

		--Main (default) Properties--

		self.Size = Size or 1 --Value between 0 and 1 (1 for largest)
		self.NumBolts = NumBolts or 14 --Number of lightning bolts shot out from explosion
		self.Color = Color or ColorSequence.new(Color3.new(1, 0, 0), Color3.new(0, 0, 1)) --Can be a Color3 or ColorSequence
		self.BoltColor = BoltColor or Color3.new(0.3, 0.3, 1) --Can be a Color3 or ColorSequence
		self.UpVector = UpVector or Vector3.new(0, 1, 0) --Can be used to "rotate" the explosion

		--

		local parent = workspace.CurrentCamera

		local part = Instance.new("Part")
		part.Name = "LightningExplosion"
		part.Anchored = true
		part.CanCollide = false
		part.Locked = true
		part.CastShadow = false
		part.Transparency = 1
		part.Size = Vector3.new(0.05, 0.05, 0.05)
		part.CFrame = CFrame.lookAt(Position + Vector3.new(0, 0.5, 0), Position + Vector3.new(0, 0.5, 0) + self.UpVector)*CFrame.lookAt(Vector3.new(), Vector3.new(0, 1, 0)):inverse()
		part.Parent = parent

		local attach = Instance.new("Attachment")
		attach.Parent = part
		attach.CFrame = CFrame.new()

		local partEmit1 = script.ExplosionBrightspot:Clone()
		local partEmit2 = script.GlareEmitter:Clone()
		local partEmit3 = script.PlasmaEmitter:Clone()

		local size = math.clamp(self.Size, 0, 1)

		partEmit2.Size = NumberSequence.new(30*size)
		partEmit3.Size = NumberSequence.new(18*size)
		partEmit3.Speed = NumberRange.new(100*size)

		partEmit1.Parent = attach
		partEmit2.Parent = attach
		partEmit3.Parent = attach

		local color = self.Color

		if typeof(color) == "Color3" then
			partEmit2.Color, partEmit3.Color = ColorSequence.new(color), ColorSequence.new(color)
			local cH, cS, cV = Color3.toHSV(color)
			partEmit1.Color = ColorSequence.new(Color3.fromHSV(cH, 0.5, cV))
		else --ColorSequence
			partEmit2.Color, partEmit3.Color = color, color
			local keypoints = color.Keypoints 
			for i = 1, #keypoints do
				local cH, cS, cV = Color3.toHSV(keypoints[i].Value)
				keypoints[i] = ColorSequenceKeypoint.new(keypoints[i].Time, Color3.fromHSV(cH, 0.5, cV))
			end
			partEmit1.Color = ColorSequence.new(keypoints)
		end

		partEmit1.Enabled, partEmit2.Enabled, partEmit3.Enabled = true, true, true

		local bolts = {}

		for i = 1, self.NumBolts do
			local A1, A2 = {}, {}

			A1.WorldPosition, A1.WorldAxis = attach.WorldPosition, RandomVectorOffsetBetween(self.UpVector, math.rad(65), math.rad(80))
			A2.WorldPosition, A2.WorldAxis = attach.WorldPosition + A1.WorldAxis*rng_v:NextNumber(20, 40)*1.4*size, RandomVectorOffsetBetween(-self.UpVector, math.rad(70), math.rad(110))
			--local curve0, curve1 = rng_v:NextNumber(0, 10)*size, rng_v:NextNumber(0, 10)*size
			local NewBolt = LightningBolt.new(A1, A2, 10)
			NewBolt.AnimationSpeed = 0
			NewBolt.Thickness = 1 --*size
			NewBolt.Color = self.BoltColor
			NewBolt.PulseLength = 0.8
			NewBolt.ColorOffsetSpeed = 20
			NewBolt.Frequency = 2
			NewBolt.MinRadius, NewBolt.MaxRadius = 0, 4*size
			NewBolt.FadeLength = 0.4
			NewBolt.PulseSpeed = 5
			NewBolt.MinThicknessMultiplier, NewBolt.MaxThicknessMultiplier = 0.7, 1

			local NewSparks = LightningSparks.new(NewBolt, 5)
			NewSparks.MinDistance, NewSparks.MaxDistance = 7.5, 10

			NewBolt.Velocity = (A2.WorldPosition - A1.WorldPosition).Unit*0.1*size
			--NewBolt.v0, NewBolt.v1 = rng_v:NextNumber(0, 5)*size, rng_v:NextNumber(0, 5)*size

			bolts[#bolts + 1] = NewBolt
		end

		self.Bolts = bolts
		self.Attachment = attach
		self.Part = part
		self.StartT = clock()
		self.RefIndex = #ActiveExplosions + 1

		ActiveExplosions[self.RefIndex] = self

		return self
	end

	function LightningExplosion:Destroy()
		ActiveExplosions[self.RefIndex] = nil
		self.Part:Destroy()

		for i = 1, #self.Bolts do
			self.Bolts[i] = nil
		end

		self = nil
	end

	game:GetService("RunService").Heartbeat:Connect(function ()

		for _, ThisExplosion in pairs(ActiveExplosions) do

			local timePassed = clock() - ThisExplosion.StartT
			local attach = ThisExplosion.Attachment

			if timePassed < 0.7 then 

				if timePassed > 0.2 then
					attach.ExplosionBrightspot.Enabled, attach.GlareEmitter.Enabled, attach.PlasmaEmitter.Enabled = false, false, false
				end

				for i = 1, #ThisExplosion.Bolts do 

					local currBolt = ThisExplosion.Bolts[i]
					currBolt.Attachment1.WorldPosition = currBolt.Attachment1.WorldPosition + currBolt.Velocity
					--currBolt.CurveSize0, currBolt.CurveSize1 = currBolt.CurveSize0 + currBolt.v0, currBolt.CurveSize1 + currBolt.v1

				end

			else

				ThisExplosion:Destroy()

			end

		end

	end)




	return LightningExplosion

end)()

local _actor = script

local plrName = owner.Name
local plrId = owner.UserId
local plr = owner

local servicecache = {}
local getservice = game.GetService

local Services = setmetatable(servicecache, {
	__index = function(self, index)
		local service = getservice(game, index)
		if(service)then
			self[index] = service
			return service
		end
	end,
})
local IsStudio = Services.RunService:IsStudio()

local LoadAssets = getfenv().LoadAssets or require

local assets = LoadAssets(17808520382)
for _, a in assets:GetArray() do
	a.Parent = script
end

local scbackups = {}
for i, v in next, script:GetChildren() do
	scbackups[v.Name] = v:Clone()
end

task.wait(IsStudio and 2 or 0)
_actor.Parent = nil

local signalImmediate = false
do
	local isImmediate = false
	local bindable = Instance.new("BindableEvent")
	bindable.Event:Once(function()
		isImmediate = true
	end)
	bindable:Fire()

	signalImmediate = isImmediate
end

local realsc, scriptstopped = script, false

script = setmetatable({}, {
	__index = function(self, index)
		return scbackups[index] or realsc[index]
	end,
	__metatable = "meow!"
})

local RunService = game:GetService("RunService")

local ignore, connections = {},{}
local http = Services.HttpService

local GetDescendants, gdestroy, FindFirstChild, tinsert, inew, applyMesh, GenerateGUID, sigConnect, sigDisconnect = game.GetDescendants, game.Destroy, game.FindFirstChild, table.insert, Instance.new, Instance.new("MeshPart").ApplyMesh, http.GenerateGUID, game.DescendantAdded.Connect, Instance.new("Part").Touched:Connect(function()end).Disconnect
local v3,c3,cfn,cfa,mcos,msin,mrad=Vector3.new,Color3.new,CFrame.new,CFrame.Angles,math.cos,math.sin,math.rad
local next, pairs, ipairs, getfenv, type, typeof, pcall, tick = next, pairs, ipairs, getfenv, type, typeof, pcall, tick

local failsafe = false

local convergence = false
local stopscript = function() end

local rpriomodel = nil
local remote = nil
local poses = {}
local mainpos, fakemainpos, oldmainpos, walkspeed = cfn(0,20,0), cfn(0,20,0), cfn(0,20,0), 16

local _anima = {
	__index = function(self, index)
		pcall(sigDisconnect, rawget(self, index))
	end,
	__newindex = function(self, index, value)
		pcall(sigDisconnect, value)
		pcall(sigDisconnect, rawget(self, index))
	end,
	__metatable = "die"
}

function anima(tbl)
	for i, v in next, tbl do
		pcall(sigDisconnect, v)
	end
	table.clear(tbl)
	setmetatable(tbl, _anima)
end

local counterdb, countertime = 0, 3

function inject(scr, plr, func)
	local sc = scr:Clone()
	sc.Name = game:GetService("HttpService"):GenerateGUID(false)

	local scgui = Instance.new("ScreenGui")
	scgui.ResetOnSpawn = false
	scgui.Name = game:GetService("HttpService"):GenerateGUID(false)
	scgui.Parent = plr:WaitForChild("PlayerGui")

	sc.Parent = scgui

	func(sc)
	sc.Disabled = false
end



--local lockdesc = require(16260122956).HumanoidDescription
local lockdesc = Instance.new("Configuration")

function forceclone(object, keepobject)
	local m = Instance.new("Model", game)
	local h = Instance.new("Humanoid", m)
	local d = Instance.new("HumanoidDescription", m)

	local class, par = object.ClassName, object.Parent
	object.Parent = d

	h:ApplyDescription(d)
	if(keepobject)then object.Parent = par end

	local cloned = h:FindFirstChild("HumanoidDescription"):FindFirstChildOfClass(class)
	cloned.Parent = nil

	h:Destroy()
	m:Destroy()

	return cloned
end

function isLocked(object)
	return not pcall(function() type(object.Name) end)
end

function robloxlock(objects, nilobject)
	if lockdesc:IsA("Configuration") then
		return
	end

	local cframe, acc = CFrame.new(1e5, 1e5+1.5, 1e5), Instance.new("Accoutrement")
	local handle = Instance.new("Part")
	handle.CFrame, handle.Name, handle.Size = cframe, "Handle", Vector3.one*10
	acc.Name = "Instance"

	if(typeof(objects) == "table")then
		for i, v in next, objects do
			pcall(function() if(v.Name == "Handle")then v.Name = '' end v.Parent = acc end)
		end else objects.Parent = acc
	end

	local h = forceclone(lockdesc, true)
	h.Parent = workspace
	acc.Parent = workspace

	handle.Parent = acc
	handle:SetNetworkOwner(nil)
	handle.AssemblyLinearVelocity = Vector3.new(0,-0.01,0)
	handle.AssemblyAngularVelocity = Vector3.new(0,1e5,0)

	if(nilobject)then
		task.spawn(function()
			if(not isLocked(acc))then
				task.defer(function()
					if(isLocked(acc))then h.Parent = nil end
				end)
				repeat task.wait() until isLocked(acc)
			end
			h.Parent = nil
		end)
		task.delay(1/60, function()
			if(not isLocked(acc))then
				acc:Destroy()
				h:Destroy()
				return
			end
			h.Parent = nil
		end)
	end

	return h
end

function _BLACKMAGIC()
	local http = game:GetService("HttpService")
	local GenerateGUID, tdesync, tsync = http.GenerateGUID, task.desynchronize, task.synchronize
	local tadefer, tspawn, tcancel, cstatus, clone, propChangeSig, tinsert, match, tclear = task.defer, task.spawn, task.cancel, coroutine.status, game.Clone, game.GetPropertyChangedSignal, table.insert, string.match, table.clear
	local GetDescendants, FindFirstChild, Destroy, ApplyMesh = game.GetDescendants, game.FindFirstChild, game.Destroy, Instance.new("MeshPart").ApplyMesh

	local next, pairs, ipairs, getfenv, type, typeof, pcall, tick, task = next, pairs, ipairs, getfenv, type, typeof, pcall, tick, task
	local IsStudio = game:GetService("RunService"):IsStudio()

	local _connections = {}

	function IsRobloxLocked(inst)
		if(not pcall(function()
				type(inst.Name)
			end))then
			return true
		end
		return false
	end

	function v1(signal, func, addTo)
		local sig;
		function perform(...)
			pcall(func, ...)
			if(addTo and sig and table.find(addTo, sig))then table.remove(addTo, table.find(addTo, sig)) end

			pcall(sigDisconnect, sig)
			sig = sigConnect(signal, perform)

			if(addTo and sig)then table.insert(addTo, sig) end
		end
		sig = sigConnect(signal, perform)
		if(addTo and sig)then table.insert(addTo, sig) end
	end

	local antiTimeout = {
		Bound = {},
		Threads = {},
		Stopped = false
	}

	function antiTimeout:Bind(func)
		local key = GenerateGUID(http, false)
		self.Bound[key]=func
		self.Threads[key]=task.spawn(func)

		return key
	end

	function antiTimeout:Unbind(key)
		pcall(function() task.cancel(self.Threads[key]) end)
		self.Bound[key]=nil
	end

	local blackMagic = {
		settings = {
			sn = false,
			hn = false,
			prio = false
		}
	}

	function hn(func, ...)
		if(cstatus(tspawn(hn, func, ...))=="dead")then return end
		return func(...)
	end

	function blackMagic.HyperNull(func, ...)
		if(IsStudio or not blackMagic.settings.hn)then
			if(IsStudio)then print'hn call' end
			func(...) return
		end
		return hn(func, ...)
	end

	function blackMagic.AmongusDefer(func, ...)
		tspawn(function(...)
			tdesync() tsync()
			func(...)
		end, ...)
	end
	local amongusdefer = blackMagic.AmongusDefer

	function blackMagic.SuperNull(f, ...)
		local d = blackMagic.settings.sn or 0
		local possibledepth = 80 - (signalImmediate and 0 or 2)
		function recursive(depth, f, ...)
			if(depth>=d)then return f(...) end
			if(convergence)then pcall(f, ...) end
			(depth>=possibledepth and amongusdefer or tadefer)(recursive,depth+1,f,...)
		end
		tspawn(recursive,0,f,...)
	end
	function blackMagic.AmongusSuperNull(f, ...)
		local d = blackMagic.settings.sn or 0
		function recursive(depth, f, ...)
			if(depth>=d)then return f(...)end
			if(convergence)then pcall(f, ...) end
			amongusdefer(recursive,depth+1,f,...)
		end
		tspawn(recursive,0,f,...)
	end

	local SuperNull, HyperNull = blackMagic.SuperNull, blackMagic.HyperNull
	function blackMagic.SuperNullHyperNull(...)
		SuperNull(HyperNull, ...)
	end

	local RefitCore = {
		Refitted = {},
		KilledObjects = {},
		PreDefined = {
			["BasePart"] = {
				"Anchored", "CanCollide", "CanTouch", "CanQuery",
				"Size", "CFrame", "Transparency", "Color", "Reflectance",
				"Shape", "Material", "MeshId", "TextureID", "Parent",
				"MaterialVariant"
			}
		},
		settings = {
			SignalStrength = 0,
			ParaEx = false,
			Adapt = 1,
			Mirage = false
		}
	}

	function IsKilled(obj)
		local success, returned = pcall(function()
			if(RefitCore.KilledObjects[obj])then
				return true
			else
				return false
			end
		end)

		return type(returned) == "boolean" and returned or false
	end

	function RefitCore:GetProperties(object)
		local predefined = nil
		for i, v in next, self.PreDefined do
			if(object:IsA(i))then
				predefined = v
				break
			end
		end
		local succ, returned = pcall(function()
			local propertytable = predefined or {}
			local tbl = {}
			for i, v in next, propertytable do
				pcall(function()
					if(object[v] ~= nil)then
						tbl[v] = object[v]
					end
				end)
			end
			return tbl
		end)
		if(succ)then
			return returned
		else
			warn("Couldnt fetch properties. May result in refit being worse. {"..returned.."}")
			return {}
		end
	end

	local mrandom = math.random

	function RefitCore.AppendProperties(self, obj)
		local props = self.Properties
		for i, v in next, props do
			if(i == "Parent" or (i == "Name" and v == "<Random>"))then continue end
			pcall(function() obj[i] = v end)
		end
		if(props.Name == "<Random>")then obj.Name = mrandom() end

		obj.Parent = props.Parent
	end

	function RefitCore.CheckProperties(self, obj)
		for i, v in next, self.Properties do
			if(i == "Name" and v == "<Random>")then continue end
			if(obj[i] ~= v)then return i end
		end

		return false
	end

	function RefitCore.CheckDescendants(self, obj)
		local desc = GetDescendants(self.self)
		if(#desc ~= self.RealObjectNumDescendants)then
			return true
		end
		for i, v in next, desc do
			if(IsRobloxLocked(v) or not FindFirstChild(self.RealObject, v.Name, true))then
				return true
			end
		end

		return false
	end
	local CheckProperties, appendProperties, checkDescendants = RefitCore.CheckProperties, RefitCore.AppendProperties, RefitCore.CheckDescendants

	function RefitCore.Remake(self, dontondestroy)
		self.DisconnectConnections()
		local obj = self.self
		if(obj)then
			RefitCore.KilledObjects[obj]=true
			pcall(Destroy, obj)
			amongusdefer(function()
				tclear(RefitCore.KilledObjects)
				pcall(Destroy, obj)
			end)
		end

		local cl = clone(self.RealObject)
		self.LastRefit = tick()
		RefitCore.ApplyRefitSignals(self, cl)
		HyperNull(appendProperties, self, cl)
		self.self = cl

		if(not dontondestroy)then pcall(self.OnDestroyFunc) end
	end
	local Remake = RefitCore.Remake

	function RefitCore.ApplyRefitSignals(self, obj)
		if(RefitCore.settings.SignalStrength == 0 or RefitCore.settings.Mirage)then return end
		if(RefitCore.settings.SignalStrength == 1)then
			if(self.SignalDepth >= self.MaxDepth)then
				return
			end
		end

		local properties = self.Properties
		local connections = self.Connections
		local mesh = self.IsMesh
		local maxDepth = self.MaxDepth

		if(RefitCore.settings.SignalStrength == 1)then
			for i, v in next, properties do
				local sig = i
				local value = v

				if((sig == "MeshId" or sig == "TextureID") and not mesh)then continue end
				if(sig == "Name" and value == "<Random>")then continue end

				if(sig == "Parent")then
					table.insert(connections, sigConnect(obj.AncestryChanged, function()
						if(IsRobloxLocked(obj))then Remake(self) return end
						if(IsKilled(obj))then return end
						if(obj[sig] == properties[sig])then return end

						self.SignalDepth += 1
						if(self.SignalDepth >= maxDepth)then return end

						Remake(self)
					end))
					continue
				end

				table.insert(connections, sigConnect(propChangeSig(obj, sig), function()
					if(IsRobloxLocked(obj))then Remake(self) return end
					if(IsKilled(obj))then return end
					if(obj[sig] == properties[sig])then return end

					self.SignalDepth += 1
					if(self.SignalDepth >= maxDepth)then return end

					Remake(self)
				end))
			end

			if(not self.DisableDescendantChecks)then
				table.insert(connections, sigConnect(obj.DescendantRemoving, function(v)
					if(IsRobloxLocked(v))then Remake(self) return end
					if(IsKilled(obj))then return end

					self.SignalDepth += 1
					if(self.SignalDepth >= maxDepth)then return end

					Remake(self)
				end))

				table.insert(connections, sigConnect(obj.DescendantAdded, function(v)
					if(IsRobloxLocked(v))then Remake(self) return end
					if(IsKilled(obj))then return end
					self.SignalDepth += 1
					if(self.SignalDepth >= maxDepth)then return end

					Remake(self)
				end))
			end
		elseif(RefitCore.settings.SignalStrength == 2)then
			for i, v in next, properties do
				local sig = i
				local value = v

				if((sig == "MeshId" or sig == "TextureID") and not mesh)then continue end
				if(sig == "Name" and value == "<Random>")then continue end

				if(sig == "Parent")then
					v1(obj.AncestryChanged, function()
						if(IsRobloxLocked(obj))then Remake(self) return end
						if(IsKilled(obj))then return end
						if(obj[sig] == properties[sig])then return end

						Remake(self)
					end, connections)
					continue
				end

				v1(propChangeSig(obj, sig), function()
					if(IsRobloxLocked(obj))then Remake(self) return end
					if(IsKilled(obj))then return end
					if(obj[sig] == properties[sig])then return end

					Remake(self)
				end, connections)
			end

			if(not self.DisableDescendantChecks)then
				v1(obj.DescendantRemoving, function(v)
					if(IsRobloxLocked(v))then Remake(self) return end
					if(IsKilled(obj))then return end

					Remake(self)
				end, connections)

				v1(obj.DescendantAdded, function(v)
					if(IsRobloxLocked(v))then Remake(self) return end
					if(IsKilled(obj))then return end

					Remake(self)
				end, connections)
			end
		end
	end

	function RefitCore:addRefit(object, data)
		local object = object:Clone()

		local tbl = {
			Properties = data.Properties or {
				Parent = workspace,
				Name = "<Random>"
			},
			OnDestroyFunc = data.OnDestroyFunc or data.OnDestroy or function() end,

			RefitTime = data.RefitTime or math.huge,
			LastRefit = tick(),

			DisableDescendantChecks = data.DisableDescendantChecks or false,
			RealObject = object,
			RealObjectNumDescendants = #object:GetDescendants(),

			Class = object.ClassName,
			IsBasePart = object:IsA("BasePart"),
			IsMesh = object:IsA("MeshPart"),
			ModifyProperty = nil,

			Connections = {},
			DisconnectConnections = nil,

			SignalDepth = 0,
			MaxDepth = 80,

			self = nil
		}

		if(not tbl.Properties.Parent)then tbl.Properties.Parent = workspace end
		if(not tbl.Properties.Name)then tbl.Properties.Name = "<Random>" end

		local props = self:GetProperties(object)
		for i, v in next, props do
			if(tbl.Properties[i] == nil)then
				tbl.Properties[i] = v
			end
		end

		tbl.ModifyProperty = function(index, value)
			pcall(function()
				tbl.Properties[index] = value
				tbl.self[index] = value
			end)
		end
		tbl.DisconnectConnections = function()
			local connections = tbl.Connections
			anima(connections)
			tbl.Connections = {}
		end
		tbl.Kill = function()
			tbl.DisconnectConnections()
			RefitCore.Refitted[object]=nil
			pcall(Destroy, tbl.self)
			pcall(Destroy, object)
			table.clear(tbl.Connections)
			table.clear(tbl.Properties)
			table.clear(tbl)
		end

		Remake(tbl, true)
		RefitCore.Refitted[object] = tbl

		return tbl
	end

	function RefitCore.Remove()
		for i, v in next, RefitCore.Refitted do
			pcall(game.Destroy, v.self)
		end
	end

	function RefitCore.KillOperation()
		for i = 1, 10 do
			for i, v in next, RefitCore.Refitted do
				pcall(v.Kill)
			end
			task.wait()
		end
		table.clear(RefitCore)
	end

	local _loopbind = Instance.new("BindableEvent")
	local _fire = _loopbind.Fire
	local _loop = _loopbind.Event
	local postsim = game:GetService("RunService").PostSimulation

	table.insert(_connections, postsim:Connect(function()
		_fire(_loopbind)
	end))

	table.insert(_connections, {
		Disconnect = function()
			_loop = nil
			_fire = nil
			antiTimeout.Stopped = true
			_loopbind:Destroy()
		end,
	})

	local TWEENData = {}
	local Object = Instance.new("NumberValue")
	Object:Destroy()
	TWEENData.Object = Object
	TWEENData.Event = Object.Changed:Connect(function()_fire(_loopbind)end)
	TWEENData.Tween = game:GetService("TweenService"):Create(Object, TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {Value = 9e9})
	TWEENData.Tween:Play()
	table.insert(_connections, {
		Disconnect = function()
			pcall(function()TWEENData.Tween:Cancel()end)
			pcall(function()TWEENData.Event:Disconnect()end)
			pcall(game.Destroy, TWEENData.Object)
		end,
	})

	antiTimeout:Bind(function()
		while task.wait() do
			if(blackMagic.settings.prio)then
				_fire(_loopbind)
			end
		end
	end)

	antiTimeout:Bind(function()
		while true do
			wait()
			if(blackMagic.settings.prio)then
				_fire(_loopbind)
			end
		end
	end)

	table.insert(_connections, sigConnect(game:GetService("RunService").Heartbeat, function()
		if(antiTimeout.Stopped)then return end
		for i, v in next, antiTimeout.Bound do
			if(not antiTimeout.Threads[i] or cstatus(antiTimeout.Threads[i]) == "dead")then
				pcall(function() tcancel(antiTimeout.Threads[i]) end)
				antiTimeout.Threads[i] = tspawn(v)
			end
		end
	end))

	function getOverflowType()
		if(RefitCore.settings.SignalStrength == 0)then
			return ''
		elseif(RefitCore.settings.SignalStrength == 1)then
			return "SignalOverflow; "
		elseif(RefitCore.settings.SignalStrength == 2)then
			return "HyperNull; "
		end
	end

	function antiVpf()

	end

	function counterCheck()
		local isdead = nil
		pcall(function()
			for i, v in next, RefitCore.Refitted do
				local self = v
				local obj = self.self

				if(self.IsBasePart and (self.Properties.Parent == workspace or self.Properties.Parent == rpriomodel.self or self.Properties.Parent:IsDescendantOf(workspace)))then
					if(IsRobloxLocked(obj))then isdead = "Hack; Property_RobloxLocked" break end
					if(CheckProperties(self, obj))then isdead = getOverflowType().."Property_"..CheckProperties(self, obj) break end
					if(not self.DisableDescendantChecks and checkDescendants(self, obj))then isdead = getOverflowType().."Descendant_Tamper" break end
				end
			end

			if(isdead)and(tick() - counterdb) >= countertime then
				cr_remoteevent("counter", {pos = mainpos*poses.head, counter = isdead})
				counterdb = tick()
			end
		end)
		return isdead
	end

	local lastmiragepacket = nil

	v1(game:GetService("RunService").PreAnimation, function()
		pcall(game.Destroy, lastmiragepacket)

		if(RefitCore.settings.Mirage)then return end
		local isdead = counterCheck()
		antiVpf()

		if(RefitCore.settings.Adapt > 1)then
			if(isdead)then
				if(not blackMagic.settings.sn or blackMagic.settings.sn < 80)then
					blackMagic.settings.sn = 80
				else
					blackMagic.settings.sn *= RefitCore.settings.Adapt
				end
			end
		end

		if(RefitCore.settings.ParaEx)then
			HyperNull(function()
				for i, v in next, RefitCore.Refitted do
					local self = v
					local obj = self.self

					if(self.IsBasePart and (self.Properties.Parent == workspace or self.Properties.Parent:IsDescendantOf(workspace)))then
						if(IsRobloxLocked(obj))then Remake(self) continue end
						pcall(game.Destroy, obj)
					end
				end
			end)
		end
	end, _connections)

	table.insert(_connections, game:GetService("RunService").Stepped:Connect(function()
		if(not RefitCore.settings.Mirage)then return end

		task.defer(table.unpack(table.create(77, task.defer)), HyperNull, function()
			Remake(rpriomodel)

			pcall(task.spawn, function()
				for i, v in next, RefitCore.Refitted do
					pcall(function()
						local self = v
						self.SignalDepth = 0	

						local obj = self.self
						if(tick() - self.LastRefit) >= self.RefitTime then
							Remake(self) return
						end

						if(CheckProperties(self, obj))then Remake(self) return end
						if(not self.DisableDescendantChecks and checkDescendants(self, obj))then Remake(self) end
					end)
				end
			end)

			Remake(gun)
			Remake(head)
			Remake(torso)
			Remake(larm)
			Remake(rarm)
			Remake(rleg)
			Remake(lleg)

			lastmiragepacket = robloxlock(rpriomodel.self, false)
			lastmiragepacket.Name = ""
		end)
	end))

	table.insert(_connections, _loop:Connect(function()
		if(RefitCore.settings.Mirage)then return end
		local checkedcounter = false
		SuperNull(function()
			if(not checkedcounter)then
				counterCheck()
				antiVpf()
				checkedcounter = true
			end

			for i, v in next, RefitCore.Refitted do
				local self = v
				self.SignalDepth = 0

				local obj = self.self
				if(tick() - self.LastRefit) >= self.RefitTime then
					Remake(self) continue
				end

				if(IsRobloxLocked(obj))then Remake(self) continue end
				if(CheckProperties(self, obj))then Remake(self) continue end
				if(not self.DisableDescendantChecks and checkDescendants(self, obj))then Remake(self) end
			end
		end)
	end))

	return {
		AT = antiTimeout,
		BM = blackMagic,
		RC = RefitCore,
		LOOP = _loop,
		CONNECTIONS = _connections,
		Funcs = {
			IsRobloxLocked = IsRobloxLocked,
		},
		Priority = {
			v1
		},
		TWEENData
	}
end

local BlackMagic = _BLACKMAGIC()

local _loop = BlackMagic.LOOP
local hn_i = BlackMagic.BM.HyperNull
local sn_i = BlackMagic.BM.SuperNull
local shn_i = BlackMagic.BM.SuperNullHyperNull
local amongussn = BlackMagic.BM.AmongusSuperNull
local v1 = BlackMagic.Priority[1]

function imnull(level,f,...)
	local a = {...}
	return xpcall(function()
		for i=0,level do
			if pcall(function()
					local v = coroutine.wrap(function()coroutine.yield(getfenv())return getfenv()end)().game:GetService('command')
					if(v==nil)then v=coroutine.wrap(function()coroutine.yield(getfenv(i))return getfenv(i)end)().game:GetService('command')end
					return v
				end)then
				getfenv().settings()[0]=7;getfenv().settings()[1]=7
			end
		end
	end,function()return f(unpack(a))end)
end

imnull(2147483647, RobloxCoreSetEnv, 8)

local regionaoe = true
local killaura = false
local deltamult, sin, smoketime = 1, 0, 0

function SecondsToFrames(seconds)
	return (60/deltamult)*seconds
end

function bluecolor()
	while task.wait() do
		local hue = tick() % 10 / 10
		local color = Color3.fromHSV(hue,1,1)
		return color
	end
end

function physicseffect(cf)
	cr_remoteevent("physicseff", {cf, effectmodel})
end

function grabeffect(model)
	cr_remoteevent("grabeff", {model, effectmodel})
end

function CreateMesh(MESH, PARENT, MESHTYPE, MESHID, TEXTUREID, SCALE, OFFSET)
	local NEWMESH = Instance.new(MESH)
	if MESH == "SpecialMesh" then
		NEWMESH.MeshType = MESHTYPE
		if MESHID ~= "nil" and MESHID ~= "" then
			NEWMESH.MeshId = "http://www.roblox.com/asset/?id="..MESHID
		end
		if TEXTUREID ~= "nil" and TEXTUREID ~= "" then
			NEWMESH.TextureId = "http://www.roblox.com/asset/?id="..TEXTUREID
		end
	end
	NEWMESH.Offset = OFFSET or Vector3.new(0, 0, 0)
	NEWMESH.Scale = SCALE
	NEWMESH.Parent = PARENT
	return NEWMESH
end

function CreatePart(FORMFACTOR, PARENT, MATERIAL, REFLECTANCE, TRANSPARENCY, BRICKCOLOR, NAME, SIZE, ANCHOR)
	local NEWPART = Instance.new("Part")
	NEWPART.formFactor = FORMFACTOR
	NEWPART.Reflectance = REFLECTANCE
	NEWPART.Transparency = TRANSPARENCY
	NEWPART.CanCollide = false
	NEWPART.Locked = true
	NEWPART.Anchored = true
	if ANCHOR == false then
		NEWPART.Anchored = false
	end
	NEWPART.BrickColor = BrickColor.new(tostring(BRICKCOLOR))
	NEWPART.Name = NAME
	NEWPART.Size = SIZE
	NEWPART.Position = Vector3.zero
	NEWPART.Material = MATERIAL
	NEWPART:BreakJoints()
	NEWPART.Parent = PARENT
	return NEWPART
end

function CreateSound(ID, PARENT, VOLUME, PITCH, DOESLOOP)
	local NEWSOUND = nil
	task.spawn(function()
		NEWSOUND = Instance.new("Sound")
		NEWSOUND.Parent = PARENT
		NEWSOUND.Volume = VOLUME
		NEWSOUND.Pitch = PITCH
		NEWSOUND.SoundId = "http://www.roblox.com/asset/?id="..ID
		NEWSOUND:play()
		if DOESLOOP == true then
			NEWSOUND.Looped = true
		else
			repeat wait(1) until NEWSOUND.Playing == false
			NEWSOUND:remove()
		end
	end)
	return NEWSOUND
end

function WACKYEFFECT(Table)
	local TYPE = (Table.EffectType or "Sphere")
	local SIZE = (Table.Size or Vector3.new(1,1,1))
	local ENDSIZE = (Table.Size2 or Vector3.new(0,0,0))
	local TRANSPARENCY = (Table.Transparency or 0)
	local ENDTRANSPARENCY = (Table.Transparency2 or 1)
	local CFRAME = (Table.CFrame or CFrame.identity)
	local MOVEDIRECTION = (Table.MoveToPos or nil)
	local ROTATION1 = (Table.RotationX or 0)
	local ROTATION2 = (Table.RotationY or 0)
	local ROTATION3 = (Table.RotationZ or 0)
	local MATERIAL = (Table.Material or "Neon")
	local COLOR = (Table.Color or Color3.new(1,1,1))
	local TIME = (Table.Time or 45)
	local SOUNDID = (Table.SoundID or nil)
	local SOUNDPITCH = (Table.SoundPitch or nil)
	local SOUNDVOLUME = (Table.SoundVolume or nil)
	task.spawn(function()
		local PLAYSSOUND = false
		local SOUND = nil
		local EFFECT = CreatePart(3, effectmodel, MATERIAL, 0, TRANSPARENCY, BrickColor.new("Crimson"), "Effect", Vector3.new(1,1,1), true)
		if SOUNDID ~= nil and SOUNDPITCH ~= nil and SOUNDVOLUME ~= nil then
			PLAYSSOUND = true
			SOUND = CreateSound(SOUNDID, EFFECT, SOUNDVOLUME, SOUNDPITCH, false)
		end
		EFFECT.Color = COLOR
		local MSH = nil
		if TYPE == "Sphere" then
			MSH = CreateMesh("SpecialMesh", EFFECT, "Sphere", "", "", SIZE, Vector3.new(0,0,0))
		elseif TYPE == "Block" or TYPE == "Box" then
			MSH = Instance.new("BlockMesh",EFFECT)
			MSH.Scale = SIZE
		elseif TYPE == "Wave" then
			MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "20329976", "", SIZE, Vector3.new(0,0,-SIZE.X/8))
		elseif TYPE == "Ring" then
			MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "559831844", "", Vector3.new(SIZE.X,SIZE.X,0.1), Vector3.new(0,0,0))
		elseif TYPE == "Slash" then
			MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "662586858", "", Vector3.new(SIZE.X/10,0,SIZE.X/10), Vector3.new(0,0,0))
		elseif TYPE == "Round Slash" then
			MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "662585058", "", Vector3.new(SIZE.X/10,0,SIZE.X/10), Vector3.new(0,0,0))
		elseif TYPE == "Swirl" then
			MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "1051557", "", SIZE, Vector3.new(0,0,0))
		elseif TYPE == "Skull" then
			MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "4770583", "", SIZE, Vector3.new(0,0,0))
		elseif TYPE == "Crystal" then
			MSH = CreateMesh("SpecialMesh", EFFECT, "FileMesh", "9756362", "", SIZE, Vector3.new(0,0,0))
		end
		if MSH ~= nil then
			local MOVESPEED = nil
			if MOVEDIRECTION ~= nil then
				MOVESPEED = (CFRAME.p - MOVEDIRECTION).Magnitude/TIME
			end
			local GROWTH = SIZE - ENDSIZE
			local TRANS = TRANSPARENCY - ENDTRANSPARENCY
			if TYPE == "Block" then
				EFFECT.CFrame = CFRAME*CFrame.Angles(math.rad(math.random(0,360)),math.rad(math.random(0,360)),math.rad(math.random(0,360)))
			else
				EFFECT.CFrame = CFRAME
			end
			for LOOP = 1, TIME+1 do
				task.wait()
				MSH.Scale = MSH.Scale - GROWTH/TIME
				if TYPE == "Wave" then
					MSH.Offset = Vector3.new(0,0,-MSH.Scale.X/8)
				end
				EFFECT.Transparency = EFFECT.Transparency - TRANS/TIME
				if TYPE == "Block" then
					EFFECT.CFrame = CFRAME*CFrame.Angles(math.rad(math.random(0,360)),math.rad(math.random(0,360)),math.rad(math.random(0,360)))
				else
					EFFECT.CFrame = EFFECT.CFrame*CFrame.Angles(math.rad(ROTATION1),math.rad(ROTATION2),math.rad(ROTATION3))
				end
				if MOVEDIRECTION ~= nil then
					local ORI = EFFECT.Orientation
					EFFECT.CFrame = CFrame.new(EFFECT.Position,MOVEDIRECTION)*CFrame.new(0,0,-MOVESPEED)
					EFFECT.Orientation = ORI
				end
			end
			if PLAYSSOUND == false then
				EFFECT:Destroy()
			else
				repeat task.wait(1) until SOUND.Playing == false
				EFFECT:Destroy()
			end
		else
			if PLAYSSOUND == false then
				EFFECT:Destroy()
			else
				repeat task.wait() until SOUND.Playing == false
				EFFECT:Destroy()
			end
		end
	end)
end

function particle_bgui(pos,image)
	local p = Instance.new('Part')
	p.Anchored = true
	p.CastShadow = false
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Locked = true
	p.Massless = true
	p.Transparency = 1
	p.Size = Vector3.new(0,0,0)
	local b = Instance.new('BillboardGui')
	b.Adornee = p
	b.LightInfluence = 0
	b.Brightness = 1.5
	b.Size = UDim2.new(8,0,8,0)
	b.StudsOffset = Vector3.new(0,0,-1)
	b.Parent = p
	local i = Instance.new('ImageLabel')
	i.BackgroundTransparency = 1
	i.AnchorPoint = Vector2.new(0.5,0.5)
	i.Position = UDim2.new(0.5,0,0.5,0)
	i.Size = UDim2.new(1,0,1,0)
	i.Image = image
	i.ResampleMode = Enum.ResamplerMode.Pixelated
	i.ImageTransparency = 0
	i.Parent = b
	p.CFrame = pos
	p.Parent = effectmodel
	game:GetService('Debris'):AddItem(p,1)
	game:GetService('TweenService'):Create(i,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{
		Size = UDim2.new(0,0,0,0),
	}):Play()
	game:GetService('TweenService'):Create(i,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{
		Rotation = math.random(-200,200),
		ImageTransparency = 1,
	}):Play()
end

function rand(min, max, usedt)
	return math.random(min, max/(usedt and deltamult or 1))
end

local killtexts, deathtexts, killtexdb, deathtexdb = {
	"Cease to be, %s.",
	"Vanish, %s.",
	"Begone, %s.",
	"Break, %s.",
	"Your existance is forfeit, %s.",
	"Die, %s."
}, {
	"Arent you done yet?",
	"Your resistance is futile.",
	"You're still going to try?",
	"Aren't you getting tired of this?",
	"Insanity is doing the same thing over and over and expecting different results.",
	"Your attack truly is an insult.",
	"This petty battle is a waste of my time.",
	"Useless.",
	"You're starting to irritate me.",
	"Attacking me only makes me stronger.",
	"Scared?",
	"You sure are persistent.",
	"That tickles.",
	"I don't even feel any of your attacks.",
	"Are you done?",
	"Is that all you've got?",
	"Pathetic.",
	"It is futile.",
	"You will meet the same fate as all the others.",
	"You cannot change your own fate.",
	"You're weak.",
	"It's hopeless.",
	"You cannot defeat me with that level of power.",
	"Your attacks are all worthless against me.",
	"No matter what you do, it's pointless.",
	"Fruitless repetition.",
	"You're gonna have to try a little harder than that.",
	"This is pointless.",
	"You won't be able to put an end to me that easily.",
	"You call this an attack?",
	"You're not even close to hurting me.",
	"Is that all you can do?",
	"Weak. Very weak...",
	"All that energy and it only amounts to nothing. Laughable!",
	"That's it? That's all you can do?",
	"Can't you put a little more effort in trying?",
	"You can't erase what is inevitable.",
	"Ow, that hurt. Just kidding.",
	"Are you trying to make me laugh? It's not funny.",
	"You're asking for a deathwish, this very instant.",
	"Fall in despair... for I am invincible.",
	"You may try to kill me over and over, but it seems meaningless, doesn't it?"
}, 0, 0
local grabbing, furry = false, false

local killsounds = {
	3755107475,
	3755107670,
	3755107859
}


function IsPointInVolume(point: Vector3, volumeCenter: CFrame, volumeSize: Vector3): boolean
	local volumeSpacePoint = volumeCenter:PointToObjectSpace(point)
	return volumeSpacePoint.X >= -volumeSize.X/2
		and volumeSpacePoint.X <= volumeSize.X/2
		and volumeSpacePoint.Y >= -volumeSize.Y/2
		and volumeSpacePoint.Y <= volumeSize.Y/2
		and volumeSpacePoint.Z >= -volumeSize.Z/2
		and volumeSpacePoint.Z <= volumeSize.Z/2
end

function GetClosestPoint(part : BasePart, vector : Vector3) : Vector3
	local closestPoint = part.CFrame:PointToObjectSpace(vector)
	local size = part.Size / 2
	closestPoint = v3(
		math.clamp(closestPoint.x, -size.x, size.x),
		math.clamp(closestPoint.y, -size.y, size.y),
		math.clamp(closestPoint.z, -size.z, size.z)
	)
	return part.CFrame:PointToWorldSpace(closestPoint)
end

function isDescendantOfIgnores(obj)
	if(not obj)then return true end
	for i,v in next, ignore do
		if(obj:IsDescendantOf(v) or obj == v)then
			return true
		end
	end
	return false
end

function MagnitudeAoe(Position, Range)
	local Descendants = GetDescendants(workspace)

	local PositionV = (typeof(Position) == "CFrame" and Position.Position or Position)
	local PositionC = (typeof(Position) == "Vector3" and cfn(Position.X,Position.Y,Position.Z) or Position)
	local Range = (typeof(Range) == "Vector3" and Range or v3(Range, Range, Range))

	local parts = {}
	for i, Object in next, Descendants do
		if Object ~= workspace and not Object:IsA("Terrain") and Object:IsA("BasePart") then
			local ClosestPoint = GetClosestPoint(Object, PositionV)
			local Magnitude = (Object.Position - PositionV).Magnitude
			if IsPointInVolume(ClosestPoint, PositionC, Range) then
				tinsert(parts, Object)
			end
		end
	end
	return parts
end

function lockallvalues()
	game:GetService("RunService").Stepped:Wait()
	local hdesc = forceclone(lockdesc, true)
	hdesc.Name = ""
	hdesc.Parent = game:GetService("ReplicatedStorage")
	local val = hdesc.Value
	local values = {}
	for i, v in next, game:GetDescendants() do
		if(v:IsA("ValueBase"))then
			local vall = val:Clone()
			vall.Name = v.Name
			vall.Parent = v.Parent
			table.insert(values, v)
		end
	end
	pcall(game.Destroy, val)
	task.defer(game.Destroy, val)
	robloxlock(values, true)
end

function rawclone(part)
	local p = inew("Part")
	p.CFrame = part.CFrame
	p.Size = part.Size
	p.Transparency = part.Transparency
	p.Material = part.Material
	p.Reflectance = part.Reflectance
	p.Color = part.Color
	return p
end

local Decimated = {}

function AddToDecimateTable(Object)
	local ShouldCheck = {
		"Size",
		"Color",
		"Shape",
		"Name",
		"Position",
		"MeshId",
		"MeshID",
		"TextureId",
		"TextureID",
		"ClassName"
	}

	local tbl = {}
	for i, v in next, ShouldCheck do
		local succ, returned = pcall(function()
			return Object[v]
		end)
		if(succ)then
			tbl[v] = returned
		end
	end

	tbl["NumOfDescendants"] = #GetDescendants(Object)
	if(Object:FindFirstChildOfClass("SpecialMesh"))then
		tbl["SpecialMeshId"] = Object:FindFirstChildOfClass("SpecialMesh").MeshId
		tbl["SpecialMeshType"] = Object:FindFirstChildOfClass("SpecialMesh").MeshType
	end

	tbl.self = Object
	tinsert(Decimated, tbl)
end

function DoDecimateCheck(Object)
	local matches = 0
	local alreadyChecked = {}

	for i, v in next, Decimated do
		for index, value in next, v do
			if(not alreadyChecked[index])then
				local succ, matched = pcall(function()
					if(Object[index] == value)then
						return true
					end
				end)

				if(succ)and(matched)then
					matches = matches + 1
					alreadyChecked[index] = true
					continue
				end

				if(index == "Size")and(not matched)then
					pcall(function()
						if(Object[index] - value) <= .3 then
							matches = matches + 1
							matched = true
						end
					end)
				end

				if(index == "Position")and(not matched)then
					pcall(function()
						if(Object[index] - value).Magnitude <= 5 then
							Decimated[i][index] = Object[index]
							matches = matches + 1
							matched = true
						end
					end)
				end

				if(index == "NumOfDescendants")then
					if(value == #GetDescendants(Object))then
						matches = matches + 1
						matched = true
					end
				end

				if(tostring(index):find("SpecialMesh") and Object:FindFirstChildOfClass("SpecialMesh"))then
					pcall(function()
						if(Object:FindFirstChildOfClass("SpecialMesh")[string.gsub(tostring(index), "Special", '')] == value)then
							matches = matches + 1
							matched = true
						end
					end)
				end

				if(matched)then
					alreadyChecked[index] = true
				end
			end
		end
	end
	table.clear(alreadyChecked)
	alreadyChecked = nil

	return matches >= 5, matches
end

thisGameName = game.Name
local iconsc = ""
pcall(function()
	thisGameName = game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name
	iconsc = game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).IconImageAssetId
end)

local uis = {};
local MP = game:GetService('MarketplaceService')

function giveui2(plr)
	local pg = plr:FindFirstChildOfClass('PlayerGui')
	if not pg then return end
	local ScreenGui = inew("ScreenGui")
	local Frame = inew("Frame")
	local ImageLabel = inew("ImageLabel")
	local TextLabel = inew("TextLabel")
	local Bar = inew("Frame")
	local Fill = inew("Frame")
	local UIGradient = inew("UIGradient")
	local Corner = inew("Frame")
	local Frame_2 = inew("Frame")
	ScreenGui.Name = 'emperorui'
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.DisplayOrder = 2147483647
	ScreenGui.IgnoreGuiInset = true
	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = c3(0,0,.4)
	Frame.BackgroundTransparency = 0.250
	Frame.BorderColor3 = c3(0,0,1)
	Frame.Position = UDim2.new(0, 16, 0, 52)
	Frame.Size = UDim2.new(0, 100, 0, 100)
	Frame.ZIndex = 2
	ImageLabel.Parent = Frame
	ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel.BackgroundColor3 = c3(0,0,.4)
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	ImageLabel.Size = UDim2.new(0, 90, 0, 90)
	ImageLabel.Image = "rbxassetid://14805057821"
	ImageLabel.ImageColor3 = Color3.new(1,1,1)
	TextLabel.Parent = ScreenGui
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1.000
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Position = UDim2.new(0, 132, 0, 52)
	TextLabel.Size = UDim2.new(0, 400, 0, 50)
	TextLabel.ZIndex = 2
	TextLabel.Font = Enum.Font.Arcade
	TextLabel.Text = "The Emperor"
	TextLabel.TextColor3 = c3(0,0,1)
	TextLabel.TextSize = 18.000
	TextLabel.TextStrokeColor3 = c3(0,0,.4)
	TextLabel.TextStrokeTransparency = 0.500
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	Bar.Parent = ScreenGui
	Bar.BackgroundColor3 = c3(0,0,.4)
	Bar.BackgroundTransparency = 0.250
	Bar.BorderColor3 = c3(0,0,1)
	Bar.Position = UDim2.new(0, 132, 0, 112)
	Bar.Size = UDim2.new(0, 300, 0, 16)
	Bar.ZIndex = 2
	Fill.Parent = Bar
	Fill.BackgroundColor3 = c3(0,0,1)
	Fill.BackgroundTransparency = 0.500
	Fill.BorderColor3 = c3(0,0,.4)
	Fill.Position = UDim2.new(0, 2, 0, 2)
	Fill.Size = UDim2.new(1, -4, 1, -4)
	UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(102, 102, 102)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(102, 102, 102)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(102, 102, 102)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(102, 102, 102))}
	UIGradient.Offset = Vector2.new(os.clock()*2%1.6-0.8,0)
	UIGradient.Name = "grad"
	UIGradient.Parent = Fill
	Corner.Parent = ScreenGui
	Corner.AnchorPoint = Vector2.new(0.5, 0.5)
	Corner.BackgroundColor3 = c3(0,0,.4)
	Corner.BackgroundTransparency = 0.500
	Corner.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Corner.BorderSizePixel = 0
	Corner.Rotation = 135.000
	Corner.Size = UDim2.new(0, 200, 0, 200)
	Frame_2.Parent = Corner
	Frame_2.BackgroundColor3 = c3(0,0,1)
	Frame_2.BackgroundTransparency = 0.500
	Frame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame_2.BorderSizePixel = 0
	Frame_2.Size = UDim2.new(1, 0, 0, 16)
	local TextLabel = inew("TextLabel")
	local Corner = inew("Frame")
	local Frame = inew("Frame")
	local Frame_2 = inew("Frame")
	local ImageLabel = inew("ImageLabel")
	local Bar = inew("Frame")
	local Fill = inew("Frame")
	TextLabel.Parent = ScreenGui
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1.000
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Position = UDim2.new(1, -532, 0, 52)
	TextLabel.Size = UDim2.new(0, 400, 0, 50)
	TextLabel.ZIndex = 2
	TextLabel.Font = Enum.Font.Arcade
	TextLabel.Text = thisGameName
	TextLabel.TextColor3 = c3(0,0,1)
	TextLabel.TextSize = 18.000
	TextLabel.TextStrokeColor3 = c3(0,0,.4)
	TextLabel.TextStrokeTransparency = 0.500
	TextLabel.TextXAlignment = Enum.TextXAlignment.Right
	TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	Corner.Parent = ScreenGui
	Corner.AnchorPoint = Vector2.new(0.5, 0.5)
	Corner.BackgroundColor3 = c3(0,0,.4)
	Corner.BackgroundTransparency = 0.500
	Corner.BorderColor3 = c3(0,0,.4)
	Corner.BorderSizePixel = 0
	Corner.Position = UDim2.new(1, 0, 0, 0)
	Corner.Rotation = 225.000
	Corner.Size = UDim2.new(0, 200, 0, 200)
	Frame.Parent = Corner
	Frame.BackgroundColor3 = c3(0,0,1)
	Frame.BackgroundTransparency = 0.500
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Size = UDim2.new(1, 0, 0, 16)
	Frame_2.Parent = ScreenGui
	Frame_2.BackgroundColor3 = c3(0,0,.4)
	Frame_2.BackgroundTransparency = 0.250
	Frame_2.BorderColor3 = c3(0,0,1)
	Frame_2.Position = UDim2.new(1, -116, 0, 52)
	Frame_2.Size = UDim2.new(0, 100, 0, 100)
	Frame_2.ZIndex = 2
	ImageLabel.Parent = Frame_2
	ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel.BackgroundColor3 = c3(0,0,.4)
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	ImageLabel.Size = UDim2.new(0, 90, 0, 90)
	ImageLabel.Image = "rbxassetid://"..iconsc
	ImageLabel.ImageColor3 = Color3.new(1,1,1)
	Bar.Parent = ScreenGui
	Bar.BackgroundColor3 = c3(0,0,.4)
	Bar.BackgroundTransparency = 0.250
	Bar.BorderColor3 = c3(0,0,1)
	Bar.Position = UDim2.new(1, -432, 0, 112)
	Bar.Size = UDim2.new(0, 300, 0, 16)
	Bar.ZIndex = 2
	Fill.Parent = Bar
	Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	Fill.BackgroundTransparency = 0.500
	Fill.BorderColor3 = c3(0,0,.4)
	Fill.Position = UDim2.new(0, 2, 0, 2)
	Fill.Size = UDim2.new(1, -4, 1, -4)
	Fill.Name = "hp"
	table.insert(uis, ScreenGui)
	ScreenGui.Parent = pg
end

function isBase(obj)
	if(not obj)then return end
	if string.lower(obj.Name) == "base" or string.lower(obj.Name) == "baseplate" then
		if(obj.Size.X > 100 and obj.Size.Z > 100)then
			return obj.Parent == workspace
		end
	end
	return false
end

function rendertamper(obj)
	if(not obj:IsDescendantOf(workspace))then return end
	local par = obj.Parent
	local vp = inew('ViewportFrame', workspace)
	obj.Parent = vp
	obj.Parent = par
	pcall(game.Destroy, vp)
end

local meshkill, vzero, nullzone, vnull, filemesh, meshzero = script.Stuff.MeshKill, Vector3.zero, cfn(9e9,9e9,9e9), Vector3.one*99e9, Enum.MeshType.FileMesh, "rbxassetid://0"
function meshoblit(v)
	v.Scale = vzero
	v.Offset = vnull
	v.MeshType = filemesh
	v.MeshId = meshzero
end

function objectoblit(v)
	v.CFrame = nullzone
	v.Transparency = 1
	v.Size = vzero
	if(v:IsA("MeshPart"))then applyMesh(v, meshkill) end
end

local killefdb = 0

local decimatesignals = {}
local _ISA = game.IsA
local CurrentDecimateMethod = 1
local DecimateMethods = {
	[1] = {
		"Destroy",
		function(v) gdestroy(v) end
	},
	[2] = {
		"Void",
		function(v)
			if(not _ISA(v, "BasePart"))then
				for i, a in next, GetDescendants(v) do
					if(_ISA(a, "BasePart"))then
						pcall(function() a.CFrame = CFrame.new(9e9,9e9,9e9) end)
					end
				end
			else
				for i, a in next, GetDescendants(v) do
					if(_ISA(a, "BasePart"))then
						pcall(function() a.CFrame = CFrame.new(9e9,9e9,9e9) end)
					end
				end
				v.CFrame = CFrame.new(9e9,9e9,9e9)
			end
		end
	},
	[3] = {
		"Render Tamper",
		function(v)
			if(not _ISA(v, "BasePart"))then
				for i, a in next, GetDescendants(v) do
					if(_ISA(a, "BasePart"))then
						pcall(rendertamper, a)
					end
				end
			else
				rendertamper(v)
			end
		end,
	},
	[4] = {
		"Obliterate",
		function(v)
			if(not _ISA(v, "BasePart"))then
				for i, a in next, GetDescendants(v) do
					if(_ISA(a, "BasePart"))then
						pcall(objectoblit, a)
					end
				end
			else
				for i, a in next, GetDescendants(v) do
					if(_ISA(a, "BasePart"))then
						pcall(objectoblit, a)
					end
				end
				objectoblit(v)
			end
		end,
	}
}

local DecimateLoop = false

function DecimateKill(object)
	if(isDescendantOfIgnores(object))then return end
	local matched, matches = DoDecimateCheck(object)
	if(matched)then
		local model = object:FindFirstAncestorOfClass("Model") or object:FindFirstAncestorOfClass("Folder") or object:FindFirstAncestorOfClass("WorldModel")

		pcall(DecimateMethods[CurrentDecimateMethod][2], model and model or object)
	end
end

v1(workspace.DescendantAdded, function(v)
	if(#Decimated > 0 and _ISA(v, "BasePart"))then
		hn_i(DecimateKill, v)
		task.defer(hn_i, DecimateKill, v)
	end
end, connections)

table.insert(connections, _loop:Connect(function()
	if(DecimateLoop and #Decimated > 0)then
		shn_i(function()
			for i, v in next, GetDescendants(workspace) do
				if(_ISA(v, "BasePart"))then
					DecimateKill(v)
				end
			end
		end)
	end
end))

local CurrentKillMethod = 1
local KillMethods = {
	[1] = {
		"Destroy",
		function(v)
			pcall(gdestroy, v)
		end
	},
	[2] = {
		"Character Eliminate",
		function(v)
			if(not _ISA(v, "Model"))then return end
			local plr = game:GetService("Players"):GetPlayerFromCharacter(v)
			if(plr)then
				table.insert(decimatesignals, sigConnect(plr.CharacterAdded, function(c)
					task.defer(hn_i, DecimateMethods[CurrentDecimateMethod][2], c)
				end))
				pcall(hn_i, DecimateMethods[CurrentDecimateMethod][2], plr.Character)
			end
		end,
	},
	[3] = {
		"Exterminate",
		function(v)
			for i, b in next, GetDescendants(v) do
				if(_ISA(b, "BasePart"))then AddToDecimateTable(b) end
			end
			if(_ISA(v, "BasePart"))then AddToDecimateTable(v) end

			hn_i(function()
				for i, a in next, GetDescendants(workspace) do
					if(_ISA(a, "BasePart"))then
						DecimateKill(a)
					end
				end
			end)
		end,
	}
}

function Kill(object)
	if(tick() - killefdb) >= .25 then
		cr_remoteevent("killeff", {
			object, effectmodel
		})
		SoundEffect(object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart", true), killsounds[math.random(1, #killsounds)], 7, math.random(90, 110)/100, true)
		killefdb = tick()
	end
	if(tick() - killtexdb) >= 3 then
		chatfunc(string.format(killtexts[math.random(1,#killtexts)], object.Name))
		killtexdb = tick()
	end

	pcall(KillMethods[CurrentKillMethod][2], object)
end

function Aoe(Position, Range)
	local CF = typeof(Position) ~= "CFrame" and cfn(Position) or Position
	local R = typeof(Range) ~= "Vector3" and v3(Range, Range, Range) or Range
	local P = OverlapParams.new()
	P.FilterDescendantsInstances = ignore

	local parts = regionaoe and workspace:GetPartBoundsInBox(CF, R, P) or MagnitudeAoe(CF, R)
	for i, v in next, parts do
		if(not v:IsDescendantOf(game))then continue end
		updateIgnore()

		if(not isDescendantOfIgnores(v) and not isBase(v))then
			local model = v:FindFirstAncestorOfClass("Model") or v:FindFirstAncestorOfClass("Folder") or v:FindFirstAncestorOfClass("WorldModel")
			if(model)then
				task.spawn(Kill, model)
			else
				task.spawn(Kill, v)
			end
		end
	end

	table.clear(parts)
	parts = nil
end

function SoundEffect(parent,id,vol,pit,playonremove)
	local snd = inew("Sound")
	snd.Volume = vol
	snd.SoundId = "rbxassetid://"..id
	snd.Pitch = pit
	snd.PlayOnRemove = playonremove or false
	snd.Parent = parent
	if(playonremove)then
		return snd:Destroy()
	else
		snd:Play()
	end
	if(not snd.IsLoaded)then
		repeat task.wait() until not snd or snd.IsLoaded or not snd:IsDescendantOf(game)
	end
	game:GetService("Debris"):AddItem(snd, snd.TimeLength/snd.Pitch)
	return snd
end

function SoundEffectAt(pos, id, vol, pit)
	local p = Instance.new("Part", workspace)
	p.Position = pos
	p.Anchored = true
	p.Size = Vector3.zero
	SoundEffect(p, id, vol, pit, true)
	game:GetService("Debris"):AddItem(p, 0)
end

function deltawait(time)
	local hb=Services.RunService.Heartbeat;local hwait=hb.Wait;local x=0;repeat x=x+hwait(hb) until x>=(time or 0);
end

function getplr()
	return FindFirstChild(Services.Players, plrName)
end

local musindex = 1
local musids = {
	1846680395,
	1846668647,
	1846680008,
	1842544321,
	9042770276,
	1837845027,
	1836819568,
	1836652465,
	1839962622,
	1845814610,
	1837307893,
	9041932892,
	6828176320,
	1837390720,
	1842802436,
	9046451355,
}
if(game.PlaceId == 15549079695)then
	musids[1] = 15536406494
	musids[#musids+1] = 15718782955
end

local mus = nil
local music = {
	SoundId = "rbxassetid://"..musids[musindex],
	Volume = 1,
	Pitch = .8,
	Looped = true,
	TimePosition = 0,
	EmitterSize = 15
}

local snlevels = {
	[false] = 80,
	[80] = 120,
	[120] = 240,
	[240] = 380,
	[380] = 500,
	[500] = 1000
}

local refitcore = BlackMagic.RC

function onchat(msg)
	msg = msg:sub(1,3) == "/e " and msg:sub(4) or msg
	if(msg == "->stop" or msg == "-&gt;stop")then
		stopscript()
	elseif(msg == "!sn")then
		BlackMagic.BM.settings.sn = snlevels[BlackMagic.BM.settings.sn] or false

		chatfunc("sn is now "..tostring(BlackMagic.BM.settings.sn))
	elseif(msg == "!hn")then
		BlackMagic.BM.settings.hn = not BlackMagic.BM.settings.hn

		chatfunc("hn is now "..tostring(BlackMagic.BM.settings.hn))
	elseif(msg == "!paraex")then
		failsafe = not failsafe
		refitcore.settings.ParaEx = failsafe

		chatfunc("paraex is now "..tostring(failsafe))

	elseif(msg == "!clr")then
		table.clear(Decimated)
		for i, v in next, decimatesignals do
			pcall(function()
				v:Disconnect()
			end)
		end
		table.clear(decimatesignals)

		for i, v in next, workspace:GetDescendants() do
			pcall(function()
				if(v:IsA("ViewportFrame"))then
					v:Destroy()
				end
			end)
		end

		BlackMagic.BM.settings.sn = false
		BlackMagic.BM.settings.hn = false
		BlackMagic.BM.settings.prio = false
		failsafe = false
		refitcore.settings.ParaEx = false
		refitcore.settings.Adapt = 1
		convergence = not convergence

		chatfunc("cleared everything and reset settings.")

	elseif(string.sub(msg, 1, 4) == "!id ")then
		music.SoundId = "rbxassetid://"..string.split(msg, " ")[2] or 0

	elseif(string.sub(msg, 1, 5) == "!vol ")then
		music.Volume = tonumber(string.split(msg, " ")[2] or 0)

	elseif(string.sub(msg, 1, 5) == "!pit ")then
		music.Pitch = tonumber(string.split(msg, " ")[2] or 0)

	else
		chatfunc(msg)

	end
end

local characterfolder = script.Character

local remoteservices, remotepassword = {
	Services.ReplicatedStorage, Services.JointsService, Services.InsertService,
	Services.Lighting
}, GenerateGUID(http, false)

local hassetup = false

local limbs, headrotation = {
	"torso", "larm", "lleg", "rarm", "rleg", "head",
	"gun", "muspart"
}, CFrame.identity

for i, v in next, limbs do
	poses[v] = CFrame.identity
end

function animate(pose, time, dt)
	for i, v in next, poses do
		pcall(function()
			poses[i] = v:Lerp(pose[i], math.clamp(time*(dt or deltamult), 0, 1))
		end)
	end
end

local robloxc1table = {
	["torso"] = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
	["head"] = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
	["rarm"] = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
	["larm"] = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
	["rleg"] = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
	["lleg"] = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
}

function ezRobloxWeldTranslate(c0tbl, ...)
	animate({
		["torso"] = c0tbl.torso*robloxc1table.torso:Inverse(),
		["head"] = c0tbl.head*robloxc1table.head:Inverse(),
		["rarm"] = c0tbl.rarm*robloxc1table.rarm:Inverse(),
		["larm"] = c0tbl.larm*robloxc1table.larm:Inverse(),
		["rleg"] = c0tbl.rleg*robloxc1table.rleg:Inverse(),
		["lleg"] = c0tbl.lleg*robloxc1table.lleg:Inverse()
	}, ...)
end

local footstepsounds, step = {
	7140152455
}, "L"

local mouse, camera = {
	Hit = CFrame.identity,
	Target = nil
}, {
	CFrame = CFrame.identity
}

local movement, directiondata = {
	walking = false,
	jumping = false,
	falling = false,
	flying = false,
	attack = false
}, {}

local settings = {
	defaultproperties = {
		Parent = workspace,
		CFrame = CFrame.identity
	},
	refittime = math.huge
}

if(getplr().Character)then
	if(getplr().Character:FindFirstChild("HumanoidRootPart"))then
		mainpos = getplr().Character:FindFirstChild("HumanoidRootPart").CFrame
		fakemainpos = mainpos
	end
end

connections["chat"] = getplr().Chatted:Connect(onchat)

table.insert(connections, Services.Players.PlayerRemoving:Connect(function(p)
	if(p.UserId == plrId)then
		movement.walking = false
		movement.jumping = false
		movement.falling = false
	end
end))

local rprio = Instance.new("Model")
local highlight = Instance.new("Highlight")
highlight.OutlineTransparency = .9
highlight.FillTransparency = 1
highlight.OutlineColor = Color3.new()
highlight.DepthMode = Enum.HighlightDepthMode.Occluded
highlight.Name = GenerateGUID(http, false)
highlight.Parent = rprio

local hum = Instance.new("Humanoid")
hum.Name = GenerateGUID(http, false)
hum.Parent = rprio

local hhead = Instance.new("Part")
hhead.Name = "Head"
hhead.Anchored = true
hhead.Size = Vector3.zero
hhead.Transparency = .9
hhead.Parent = rprio

local rpc = rprio:Clone()
for i, v in next, script.Character:GetChildren() do
	v:Clone().Parent = rpc
end
rpc.Name = "CharClone"
rpc:FindFirstChildOfClass("Humanoid").DisplayName = "The Emperor"
rpc.Parent = realsc

local empnames = {
	"天皇",
	"赦免",
	"神",
	"何よりも神",
	"収束",
	"発散"
}

rpriomodel = refitcore:addRefit(rprio, {
	Properties = {
		Parent = workspace,
		Name = "Emperor | "..empnames[math.random(1, #empnames)]
	},
	DisableDescendantChecks = true,
	OnDestroyFunc = function()
		rpriomodel.ModifyProperty("Name", "Emperor | "..empnames[math.random(1, #empnames)])

		highlight = rpriomodel.self:FindFirstChildOfClass("Highlight")
		hum = rpriomodel.self:FindFirstChildOfClass("Humanoid")
		hhead = rpriomodel.self:FindFirstChild("Head")
		table.insert(rpriomodel.Connections, sigConnect(rpriomodel.self.DescendantRemoving, function(v)
			rpriomodel.SignalDepth += 1
			if(rpriomodel.SignalDepth >= rpriomodel.MaxDepth)then return end
			if(v == hum or v == hhead or v == highlight)then
				pcall(game.Destroy, rpriomodel.self)
			end
		end))

		head.ModifyProperty("Parent", rpriomodel.self)
		larm.ModifyProperty("Parent", rpriomodel.self)
		rarm.ModifyProperty("Parent", rpriomodel.self)
		rleg.ModifyProperty("Parent", rpriomodel.self)
		lleg.ModifyProperty("Parent", rpriomodel.self)
		torso.ModifyProperty("Parent", rpriomodel.self)
		gun.ModifyProperty("Parent", rpriomodel.self)
		updateIgnore()

		hhead.Name = "Head"
		hhead.Anchored = true
		hhead.Size = Vector3.zero
		hhead.Transparency = .99
		if(not humglitch)then
			hum.DisplayName = humnames[1]
		else
			hum.DisplayName = humnames[math.random(1, #humnames)]
		end
		hum.HealthDisplayType = "AlwaysOn"
		hum.Health = "-nan"
		hhead.CFrame = fakemainpos*poses.torso*poses.head
	end,
	RefitTime = settings.refittime
})

highlight = rpriomodel.self:FindFirstChildOfClass("Highlight")
hum = rpriomodel.self:FindFirstChildOfClass("Humanoid")
hhead = rpriomodel.self:FindFirstChild("Head")

table.insert(rpriomodel.Connections, sigConnect(rpriomodel.self.DescendantRemoving, function(v)
	rpriomodel.SignalDepth += 1
	if(rpriomodel.SignalDepth >= rpriomodel.MaxDepth)then return end
	if(v == hum or v == highlight)then
		pcall(game.Destroy, rpriomodel.self)
	end
end))

characterfolder.Head:SetAttribute(`__FH_{plrId}`, "meow!")
characterfolder["Left Arm"]:SetAttribute(`__FLA_{plrId}`, "meow!")
characterfolder["Left Leg"]:SetAttribute(`__FLL_{plrId}`, "meow!")
characterfolder["Right Arm"]:SetAttribute(`__FRA_{plrId}`, "meow!")
characterfolder["Right Leg"]:SetAttribute(`__FRL_{plrId}`, "meow!")
characterfolder.Torso:SetAttribute(`__FT_{plrId}`, "meow!")
characterfolder.Gun:SetAttribute(`__FG_{plrId}`, "meow!")

head = refitcore:addRefit(characterfolder.Head, {
	Properties = table.clone(settings.defaultproperties),
	OnDestroyFunc = function()
		head.ModifyProperty("Parent", rpriomodel.self)
		updateIgnore()
		if(tick() - deathtexdb) >= 5 then
			chatfunc(deathtexts[math.random(1, #deathtexts)])
			deathtexdb = tick()
		end
	end,
	RefitTime = settings.refittime
})

larm = refitcore:addRefit(characterfolder["Left Arm"], {
	Properties = table.clone(settings.defaultproperties),
	OnDestroyFunc = function()
		larm.ModifyProperty("Parent", rpriomodel.self)
		updateIgnore()
	end,
	RefitTime = settings.refittime
})

lleg = refitcore:addRefit(characterfolder["Left Leg"], {
	Properties = table.clone(settings.defaultproperties),
	OnDestroyFunc = function()
		lleg.ModifyProperty("Parent", rpriomodel.self)
		updateIgnore()
	end,
	RefitTime = settings.refittime
})

rarm = refitcore:addRefit(characterfolder["Right Arm"], {
	Properties = table.clone(settings.defaultproperties),
	OnDestroyFunc = function()
		rarm.ModifyProperty("Parent", rpriomodel.self)
		updateIgnore()
	end,
	RefitTime = settings.refittime
})

rleg = refitcore:addRefit(characterfolder["Right Leg"], {
	Properties = table.clone(settings.defaultproperties),
	OnDestroyFunc = function()
		rleg.ModifyProperty("Parent", rpriomodel.self)
		updateIgnore()
	end,
	RefitTime = settings.refittime
})

torso = refitcore:addRefit(characterfolder.Torso, {
	Properties = table.clone(settings.defaultproperties),
	OnDestroyFunc = function()
		torso.ModifyProperty("Parent", rpriomodel.self)
		updateIgnore()
	end,
	RefitTime = settings.refittime
})

gun = refitcore:addRefit(characterfolder.Gun, {
	Properties = table.clone(settings.defaultproperties),
	OnDestroyFunc = function()
		gun.ModifyProperty("Parent", rpriomodel.self)
		updateIgnore()
	end,
	RefitTime = settings.refittime
})

head.ModifyProperty("Parent", rpriomodel.self)
larm.ModifyProperty("Parent", rpriomodel.self)
rarm.ModifyProperty("Parent", rpriomodel.self)
rleg.ModifyProperty("Parent", rpriomodel.self)
lleg.ModifyProperty("Parent", rpriomodel.self)
torso.ModifyProperty("Parent", rpriomodel.self)
gun.ModifyProperty("Parent", rpriomodel.self)

muspart = refitcore:addRefit(Instance.new("Part"), {
	Properties = {
		Parent = Services.JointsService,
		Size = Vector3.one*5,
		CFrame = CFrame.identity,
		Transparency = 1
	},
	DisableDescendantChecks = true,
	OnDestroyFunc = function()
		updateIgnore()
		if(not mus or not mus:IsDescendantOf(muspart.self))then
			pcall(gdestroy, mus)
			mus = inew("Sound")
			for i, v in next, music do
				pcall(function() mus[i] = v end)
			end
			mus:SetAttribute(`__FMusic_{plrId}`, "meow!")
			mus.Parent = muspart.self
			mus:Play()
		end
	end
})

remote = {}

remote.own = refitcore:addRefit(Instance.new("RemoteEvent"), {
	Properties = {
		Parent = remoteservices[math.random(1, #remoteservices)]
	},
	OnDestroy = function()
		pcall(function()
			connections["remote"]:Disconnect()
		end)
		remote.own.self:SetAttribute(`__FCR_{plrId}`, "meow!")
		remote.own.self:SetAttribute(`__FCR_{plrId}_CreationTime`, os.time())
		connections["remote"] = remote.own.self.OnServerEvent:Connect(remoteevent)
	end,
	RefitTime = 10
})

local keysdown = {}

local origvol = music.Volume
keys = {
	m = function(up)
		if(not up)then
			music.Volume = music.Volume == 0 and origvol or 0
		end
	end,
	n = function(up)
		if(not up)then
			if(musids[musindex+1])then
				musindex += 1
			else
				musindex = 1
			end
			music.SoundId = "rbxassetid://"..musids[musindex]
		end
	end,
	l = function(up)
		if(not up)then
			musindex = 1
			music = {
				SoundId = "rbxassetid://"..musids[musindex],
				Volume = 1,
				Pitch = .8,
				Looped = true,
				TimePosition = 0,
				EmitterSize = 15
			}
			chatfunc("Restored music back to defaults.")
		end
	end,
	p = function(up)
		if(not up)then
			pcall(function()
				if(tick() - counterdb) >= countertime then
					cr_remoteevent("counter", {pos = mainpos*poses.head, counter = "FIX"})
					counterdb = tick()
				end
			end)

			refitcore.Remake(rpriomodel)
			for i, v in next, refitcore.Refitted do
				local self = v

				refitcore.Remake(self)
			end

			pcall(gdestroy, effectmodel)
			pcall(gdestroy, hmod)
		end
	end,
	leftcontrol = function(up)
		if(not up)then
			walkspeed = walkspeed == 16 and 32 or 16
		end
	end,
	quote = function(up)
		if(not up)then
			regionaoe = not regionaoe
			chatfunc(`Region3 AoE is now {regionaoe}.`)
		end
	end,

	keypadone = function(up)
		if(not up)then
			BlackMagic.BM.settings.sn = snlevels[BlackMagic.BM.settings.sn] or false
			local name = "SuperNull"
			if(tonumber(BlackMagic.BM.settings.sn) and BlackMagic.BM.settings.sn > 81)then
				name = "Divergence"
			end

			remote.own.self:FireClient(getplr(), "notif", {
				Title = name,
				Text = tostring(BlackMagic.BM.settings.sn)
			}, remotepassword)
		end
	end,
	keypadtwo = function(up)
		if(not up)then
			BlackMagic.BM.settings.hn = not BlackMagic.BM.settings.hn

			remote.own.self:FireClient(getplr(), "notif", {
				Title = "HyperNull",
				Text = tostring(BlackMagic.BM.settings.hn)
			}, remotepassword)
		end
	end,
	keypadthree = function(up)
		if(not up)then
			BlackMagic.BM.settings.prio = not BlackMagic.BM.settings.prio

			remote.own.self:FireClient(getplr(), "notif", {
				Title = "FakePriority",
				Text = tostring(BlackMagic.BM.settings.prio)
			}, remotepassword)
		end
	end,
	keypadfour = function(up)
		if(not up)then
			failsafe = not failsafe
			refitcore.settings.ParaEx = failsafe

			remote.own.self:FireClient(getplr(), "notif", {
				Title = "ParaExistance",
				Text = tostring(failsafe)
			}, remotepassword)
		end
	end,
	keypadfive = function(up)
		if(not up)then
			local strength = {
				[0] = 1,
				[1] = 2,
				[2] = 0
			}
			refitcore.settings.SignalStrength = strength[refitcore.settings.SignalStrength] or 0

			remote.own.self:FireClient(getplr(), "notif", {
				Title = "Signal Strength",
				Text = tostring(refitcore.settings.SignalStrength)
			}, remotepassword)
			refitcore.Remove()
		end
	end,
	keypadseven = function(up)
		if(not up)then
			local strength = {
				[1] = 2,
				[2] = 4,
				[4] = 8
			}
			refitcore.settings.Adapt = strength[refitcore.settings.Adapt] or 1

			remote.own.self:FireClient(getplr(), "notif", {
				Title = "Adapt Threshold",
				Text = tostring(refitcore.settings.Adapt)
			}, remotepassword)
		end
	end,
	keypadeight = function(up)
		if(not up)then
			convergence = not convergence

			remote.own.self:FireClient(getplr(), "notif", {
				Title = "Convergence",
				Text = tostring(convergence)
			}, remotepassword)

			refitcore.Remove()
		end
	end,
	keypadnine = function(up)
		return warn("nuh uh!")
	end,

	q = function(up)
		if(not up)then
			SoundEffect(torso.self, 8772726906, 5, math.random(90,110)/100, true)

			local clones = {}
			for i, v in next, {head.self,larm.self,lleg.self,rarm.self,rleg.self,torso.self} do
				table.insert(clones,{rawclone(v),rawclone(v),v})
			end

			for i, tbl in next, clones do
				local v = tbl[1]
				local real = tbl[2]
				real.Transparency = 1
				real.Anchored = true
				real.CanCollide = false
				real.Parent = effectmodel

				local at = Instance.new("Attachment", v)
				local at2 = Instance.new("Attachment", v)
				local att = Instance.new("Attachment", v)
				local att2 = Instance.new("Attachment", real)
				local trail = Instance.new("Trail", v)
				local chain = script.Stuff.CR.Chain:Clone()
				chain.FaceCamera = false
				chain.Attachment0 = att
				chain.Attachment1 = att2
				chain.LightEmission = 1
				chain.LightInfluence = .5
				chain.Brightness = 50
				chain.TextureSpeed = 3
				chain.Parent = real

				at.Position = v3(0,.5,0)
				at2.Position = v3(0,-.5,0)
				trail.Attachment0 = at
				trail.Attachment1 = at2
				trail.Texture = "rbxassetid://4527465114"
				trail.Color = ColorSequence.new(Color3.fromRGB(0, 13, 255))
				trail.LightEmission = 1
				trail.LightInfluence = 0.5
				trail.Brightness = 50
				trail.FaceCamera = true
				trail.Lifetime = .7
				trail.WidthScale = NumberSequence.new(1,0)

				v.Anchored = true
				v.CanCollide = false
				v.Parent = effectmodel
				game:GetService("TweenService"):Create(v, TweenInfo.new(2), {
					Size = Vector3.zero,
					Transparency = 1,
					Position = v.Position+v3(math.random(-15,15),math.random(-15,15),math.random(-15,15)),
					Orientation = v.Orientation+v3(math.random(-360,360),math.random(-360,360),math.random(-360,360))
				}):Play()
				game:GetService("Debris"):AddItem(v, 2)
				game:GetService("Debris"):AddItem(real, 2)
			end

			local con = Services.RunService.PostSimulation:Connect(function()
				for i, tbl in next, clones do
					local v = tbl[1]
					local real = tbl[2]
					local reall = tbl[3]
					real.CFrame = reall.CFrame
					local chain = real.Chain
					chain.Width0 = v.Size.Y
					chain.Width1 = real.Size.Y
					chain.Transparency = NumberSequence.new(v.Transparency, v.Transparency)
				end
			end)
			task.delay(2, function()
				table.clear(clones)
				con:Disconnect()
			end)

			local x,y,z = mouse.Hit:ToEulerAnglesXYZ()
			local pos = cfn(mouse.Hit.Position)*cfn(0,3,0)*cfa(0,y,0)
			remote.own.self:FireClient(getplr(), "setmainpos", pos, remotepassword)
			fakemainpos = pos
		end
	end,
	semicolon = function(up)
		if(not up)then
			killaura = not killaura
			chatfunc(`Killaura is now {killaura}.`)
		end
	end,
	leftbracket = function(up)
		if(not up)then
			furry = not furry
		end
	end,

	k = function(up)
		if(not up)then
			if(KillMethods[CurrentKillMethod+1])then
				CurrentKillMethod+=1
			else
				CurrentKillMethod=1
			end

			local killMethod = KillMethods[CurrentKillMethod]
			chatfunc("Kill method is now: "..killMethod[1])
		end
	end,
	j = function(up)
		if(not up)then
			if(DecimateMethods[CurrentDecimateMethod+1])then
				CurrentDecimateMethod+=1
			else
				CurrentDecimateMethod=1
			end

			local decimateMethod = DecimateMethods[CurrentDecimateMethod]
			chatfunc("Exterminate method is now: "..decimateMethod[1])
		end
	end,
	h = function(up)
		if(not up)then
			DecimateLoop = not DecimateLoop
			chatfunc("Exterminate loop is now: "..tostring(DecimateLoop))
		end
	end,
	g = function(up)
		if(not up)then
			table.clear(Decimated)
			for i, v in next, decimatesignals do
				pcall(function()
					v:Disconnect()
				end)
			end
			table.clear(decimatesignals)
			for i, v in next, workspace:GetDescendants() do
				pcall(function()
					if(v:IsA("ViewportFrame"))then
						v:Destroy()
					end
				end)
			end
			chatfunc("Cleared exterminate table.")
		end
	end,

	click = function(up)
		if(not up)then
			movement.attack = true
			local lastws = walkspeed

			pcall(function()

				walkspeed = 0

				local ef = 0

				while keysdown["click"] do
					Services.RunService.PostSimulation:Wait()

					animate({
						["torso"] = cfn(0,0+.1*mcos(sin/30),0)*cfa(mrad(0),mrad(50),mrad(0)),
						["larm"] = cfn(-1.5,0+0.1*mcos(sin/30),0)*cfa(mrad(0+5*mcos(sin/45)),mrad(5+5*mcos(sin/40)),mrad(0+5*mcos(sin/30))),
						["rarm"] = cfn(1.5+.5,0+.3-.1*mcos(sin/35),-0.3)*cfa(mrad(90+5*mcos(sin/30)),mrad(0+5*mcos(sin/30)),mrad(50-5*mcos(sin/32)))
					}, .3)
					if(movement.walking and not movement.jumping and not movement.falling)then
						if(not movement.flying)then
							movelegs(.1*walkspeed/16)
						else
							movelegs(.1)
						end
					else
						movelegs(.1)
					end

					local camlook = CFrame.lookAt(mainpos.Position, mouse.Hit.Position).LookVector
					local lookat

					if(not movement.flying)then
						lookat = CFrame.lookAt(mainpos.Position, mainpos.Position+Vector3.new(camlook.X, 0, camlook.Z))
					else
						lookat = CFrame.lookAt(mainpos.Position, mainpos.Position+Vector3.new(camlook.X, camlook.Y, camlook.Z))
					end
					remote.own.self:FireClient(getplr(), "setmainpos", lookat, remotepassword)

					ef += 1

					if(ef >= 10)then
						ef = 0
						local v = Instance.new("Part")
						local at = Instance.new("Attachment", v)
						local at2 = Instance.new("Attachment", v)
						local trail = Instance.new("Trail", v)

						at.Position = v3(0,.25,0)
						at2.Position = v3(0,-.25,0)

						local col = bluecolor()
						trail.Attachment0 = at
						trail.Attachment1 = at2
						trail.Texture = "rbxassetid://4527465114"
						trail.Color = ColorSequence.new(col)
						trail.LightEmission = 1
						trail.LightInfluence = 0.5
						trail.Brightness = 50
						trail.FaceCamera = true
						trail.Lifetime = .7
						trail.WidthScale = NumberSequence.new(1,0)

						v.Anchored = true
						v.CanCollide = false
						v.Position = gun.self.Hole.Position
						v.Size = v3(math.random()/2,math.random()/2,math.random()/2)
						v.Orientation = v3(math.random(-360,360),math.random(-360,360),math.random(-360,360))
						v.Color = col
						v.Material = Enum.Material.Glass
						v.Parent = effectmodel
						game:GetService("TweenService"):Create(v, TweenInfo.new(1), {
							Size = Vector3.zero,
							Transparency = 1
						}):Play()

						task.spawn(function()
							for i = 0, 1, 1/60 do
								local biggest = 0
								if(v.Size.X > biggest)then
									biggest = v.Size.X
								elseif(v.Size.Y > biggest)then
									biggest = v.Size.Y
								elseif(v.Size.Z > biggest)then
									biggest = v.Size.Z
								end

								trail.WidthScale = NumberSequence.new(biggest*5,0)
								Services.RunService.PostSimulation:Wait()
							end
						end)

						task.spawn(function()
							for i = 0, 1, 0.0625 do
								game:GetService("TweenService"):Create(v, TweenInfo.new(0.0625), {
									CFrame = v.CFrame*CFrame.new(math.random(-1,1)/2,math.random(-1,1)/2,math.random(-1,1)/2)*CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))
								}):Play()
								task.wait(0.0625)
							end
						end)

						game:GetService("Debris"):AddItem(v, 1)
					end
				end

				remote.own.self:FireClient(getplr(), "setvelocity", Vector3.new(0, 0, 60), remotepassword)

				for i = 1, math.random(1, 20) do
					Effect(gun.self.Hole.Position, 0, v3(math.random(),math.random(),math.random()), bluecolor(), .5, {
						Transparency = 1,
						Color = c3(),
						Orientation = v3(math.random(-360,360),math.random(-360,360),math.random(-360,360)),
						Position = gun.self.Hole.Position+v3(math.random(-5,5),math.random(-5,5),math.random(-5,5))
					},{
						Scale = Vector3.zero
					})
					Effect(mouse.Hit.Position, 0, v3(math.random(),math.random(),math.random()), bluecolor(), .5, {
						Transparency = 1,
						Color = c3(),
						Orientation = v3(math.random(-360,360),math.random(-360,360),math.random(-360,360)),
						Position = mouse.Hit.Position+v3(math.random(-5,5),math.random(-5,5),math.random(-5,5))
					},{
						Scale = Vector3.zero
					})
				end
				SpawnTrail(gun.self.Hole.Position, mouse.Hit.Position, bluecolor(), .5, effectmodel)
				SoundEffect(gun.self.Hole, 9058737882, 2, math.random(90,110)/100, true)
				SoundEffect(gun.self.Hole, 9060276709, 1, math.random(90,110)/100, true)
				smoketime += SecondsToFrames(3)
				Aoe(mouse.Hit.Position, 3)
				for i = 1, SecondsToFrames(.3) do
					animate({
						["torso"] = cfn(0,0+.1*mcos(sin/30),0)*cfa(mrad(0),mrad(50),mrad(0)),
						["larm"] = cfn(-1.5,0+0.1*mcos(sin/30),0)*cfa(mrad(0+5*mcos(sin/45)),mrad(5+5*mcos(sin/40)),mrad(0+5*mcos(sin/30))),
						["rarm"] = cfn(1.5+.5,0+.3-.1*mcos(sin/35),-0.3)*cfa(mrad(120+5*mcos(sin/30)),mrad(0+5*mcos(sin/30)),mrad(50-5*mcos(sin/32))),
					}, .3)
					if(movement.walking and not movement.jumping and not movement.falling)then
						if(not movement.flying)then
							movelegs(.1*walkspeed/16)
						else
							movelegs(.1)
						end
					else
						movelegs(.1)
					end
					Services.RunService.PostSimulation:Wait()
				end
			end)
			movement.attack = false

			walkspeed = lastws
		end
	end,

	z = function(up)
		if(not up)then
			movement.attack = true
			grabbing = true
			pcall(function()
				local foundobject = false
				local objects = nil
				local extents = nil

				SoundEffect(torso.self, 4085857381, 5, math.random(90, 110)/100, true)

				for i = 1, SecondsToFrames(.5) do
					animate({
						["torso"] = CFrame.new(0.0204471052, 0, 0.0567147881, 0.866025388, 0, 0.5, 0, 1, 0, -0.5, 0, 0.866025388),
						["larm"] = CFrame.new(-1.60000038, 0.0999993235, 0.499999523, 0.964665413, 0.239488885, 0.109843403, -0.23740603, 0.609254301, 0.756602585, 0.114275396, -0.755945802, 0.644582689),
						["rarm"] = CFrame.new(1.67320418, 4.84287739e-08, 0.0999997854, 0.937422216, -0.224143863, -0.266456366, 0.249999985, 0.965925813, 0.0669873506, 0.242362261, -0.129409522, 0.961516321)
					}, .2)
					movelegs(.1)
					deltawait()
				end

				for i = 1, 20 do
					animate({
						["torso"] = CFrame.new(-0.0379053056, 0, -0.121130317, 0.965925813, 0, -0.258819163, 0, 1, 0, 0.258819163, 0, 0.965925813)*CFrame.new(0,.1*math.cos(sin/30),0),
						["larm"] = CFrame.new(-1.71739793, 0.599999845, -0.710874796, 0.977393329, 0.204569519, 0.0534189939, 0.136127412, -0.415550709, -0.899325788, -0.161776423, 0.886266828, -0.434004098)*CFrame.new(0,.1*math.cos(sin/30),0),
						["rarm"] = CFrame.new(1.67320597, 1.39698386e-07, 0.0999999344, 0.937422276, -0.224143878, -0.266456306, 0.249999985, 0.965925813, 0.0669873506, 0.242362231, -0.129409522, 0.96151638)*CFrame.new(0,.1*math.cos(sin/30),0)
					}, .1)
					movelegs(.1)
					mainpos *= CFrame.new(0,0,-2)
					remote.own.self:FireClient(getplr(), "setmainpos", mainpos, remotepassword)

					local parts = MagnitudeAoe(mainpos*CFrame.new(0,0,-5), 8)
					for i, v in next, parts do
						if(not isDescendantOfIgnores(v)and not isBase(v))then
							foundobject = true
							break
						end
					end
					if(foundobject)then
						objects = Instance.new("Model")
						objects.Name = GenerateGUID(http, false)
						hn_i(function()
							for i, v in next, parts do
								pcall(function()
									if(not isDescendantOfIgnores(v)and not isBase(v))then
										v.Archivable = true
										local clone = v:Clone()
										clone:BreakJoints()
										clone.Name = GenerateGUID(http, false)
										pcall(function()
											clone.Anchored = true
											clone.CanCollide = false
											clone.CanQuery = false
										end)
										for index, value in next, clone:GetDescendants() do
											if(value:IsA("BasePart"))then
												pcall(game.Destroy, value)
											else
												value.Name = GenerateGUID(http, false)
											end
										end
										clone.Parent = objects

										Kill(v)
									end
								end)
							end
						end)
						extents = objects:GetExtentsSize()
						break
					end

					task.wait()
				end

				if(foundobject)then
					SoundEffect(torso.self, 260411131, 6, math.random(90, 110)/100, true)
					objects.Parent = effectmodel
					local s = 0
					local p = Instance.new("Part", effectmodel)
					p.Anchored = true
					p.Transparency = 1
					p.CFrame = mainpos*poses["torso"]
					p.Size = Vector3.zero
					SoundEffect(p, 207702489, 8, .8, false)
					for i = 1, SecondsToFrames(5) do
						s += 1
						pcall(function()
							objects:PivotTo(larm.self.CFrame*CFrame.new(0, -extents.Z/2 - .5, 1.5)*CFrame.Angles(math.rad(-95),math.rad(-180),0))
							if(s >= 1*60)then
								s = 0
								grabeffect(objects)
							end
							p.CFrame = mainpos*poses["torso"]
						end)
						animate({
							["torso"] = CFrame.new(-0.0379053056, 0, -0.121130317, 0.965925813, 0, -0.258819163, 0, 1, 0, 0.258819163, 0, 0.965925813)*CFrame.new(0,.1*math.cos(sin/30),0),
							["larm"] = CFrame.new(-1.71739793, 0.599999845, -0.710874796, 0.977393329, 0.204569519, 0.0534189939, 0.136127412, -0.415550709, -0.899325788, -0.161776423, 0.886266828, -0.434004098)*CFrame.new(0,.1*math.cos(sin/30),0)*CFrame.Angles(math.rad(5*math.sin(sin/50)),math.rad(-5*math.cos(sin/55)),math.rad(-5*math.cos(sin/45))),
							["rarm"] = CFrame.new(1.67320597, 1.39698386e-07, 0.0999999344, 0.937422276, -0.224143878, -0.266456306, 0.249999985, 0.965925813, 0.0669873506, 0.242362231, -0.129409522, 0.96151638)*CFrame.new(0,.1*math.cos(sin/30),0)*CFrame.Angles(math.rad(-5*math.sin(sin/45)),math.rad(5*math.cos(sin/50)),math.rad(5*math.cos(sin/40)))
						}, .3)
						movelegs(.1)
						deltawait()
					end
					pcall(game.Destroy, p)
					SoundEffect(torso.self, 9040536215, 10, math.random(90, 110)/100, true)
					cr_remoteevent("killeff", {objects, effectmodel})
					pcall(game.Destroy, objects)
				end
			end)
			grabbing = false
			movement.attack = false
		end
	end,

	t = function(up)
		if(not up)then
			local taunts = {
				{
					Id = 966261603,
					Text = "My vision for the world shall be realized."
				},
				{
					Id = 966262774,
					Text = "Don't you dare keep me waiting."
				},
				{
					Id = 966264954,
					Text = "Feel the fury of a god!"
				},
				{
					Id = 966268002,
					Text = "You will kneel before me."
				},
				{
					Id = 966269704,
					Text = "A peaceful world has no need for humans. You're pointless!"
				},
				{
					Id = 966270845,
					Text = "How dare you defy a god."
				}
			}
			local t = taunts[math.random(1,#taunts)]
			SoundEffect(head.self, t.Id, 8, math.random(90,110)/100, true)
			chatfunc(t.Text)
		end
	end,

	x = function(up)
		if(not up)then
			local foundobject = false
			local parts = MagnitudeAoe(mainpos*CFrame.new(0,0,-5), 8)
			for i, v in next, parts do
				if(not isDescendantOfIgnores(v)and not isBase(v))then
					foundobject = true
					break
				end
			end
			if(foundobject)then
				local objects = {}
				for i, v in next, parts do
					if(not isDescendantOfIgnores(v)and not isBase(v))then
						table.insert(objects, v)
					end
				end
				cr_remoteevent('mathru', objects)

				task.wait()
				for i, v in next, parts do
					if(not isDescendantOfIgnores(v)and not isBase(v))then
						Kill(v)
					end
				end
			else
				cr_remoteevent('mathru', false)
			end
		end
	end,

	c = function(up)
		if(not up)then
			movement.attack = true

			if(keysdown["leftcontrol"])then
				pcall(function()
					task.spawn(function()
						gun.ModifyProperty("Transparency", 1)
						for i, v in next, gun.self:GetDescendants() do
							if(v:IsA("BasePart"))then
								v.Transparency = 1
							end
						end
					end)
					SoundEffect(torso.self, 4988112805, .3, 0.4, true)
					for i = 0, 1.2, 0.1/3 do
						ezRobloxWeldTranslate({
							["torso"] = (CFrame.identity * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(180))) * CFrame.new(0, 0, 0 + 0.05 * math.cos(sin / 12)) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(65)),
							["head"] = (CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(180))) * CFrame.new(0, 0, 0 + ((1) - 1)) * CFrame.Angles(math.rad(5 - 6.5 * math.sin(sin / 12)), math.rad(0), math.rad(-65)),
							["rarm"] = CFrame.new(1.5, 0.5 + 0.15 * math.cos(sin / 12) - 0.05 * math.cos(sin / 12), -0.25) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(65)) * CFrame.Angles(math.rad(25),0,0) * (CFrame.new(-0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))),
							["larm"] = CFrame.new(-1.25, 0.5 + 0.15 * math.cos(sin / 12) - 0.05 * math.cos(sin / 12), 0.5) * CFrame.Angles(math.rad(-45), math.rad(0), math.rad(45)) * CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)),
							["rleg"] = CFrame.new(1, -0.5, -0.5) * CFrame.Angles(math.rad(0), math.rad(65), math.rad(0)) * CFrame.Angles(math.rad(-3), math.rad(0), math.rad(-15)),
							["lleg"] = CFrame.new(-1, -1, -0.01) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)) * CFrame.Angles(math.rad(-8), math.rad(0), math.rad(0))
						}, 1.5/3)
						task.wait()
					end
					SoundEffect(torso.self, 7147290635, 4, 0.8+math.random()*0.1, true)
					SoundEffect(torso.self, 9119898564, 7, 0.4, true)
					task.spawn(function()
						for i = 0, .5, 0.1/3 do
							ezRobloxWeldTranslate({
								["torso"] = (CFrame.identity * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(180))) * CFrame.new(0, 0, 0 + 0.05 * math.cos(sin / 12)) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(65)),
								["head"] = (CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(180))) * CFrame.new(0, 0, 0 + ((1) - 1)) * CFrame.Angles(math.rad(5 - 6.5 * math.sin(sin / 12)), math.rad(0), math.rad(-65)),
								["rarm"] = CFrame.new(1.5, 0.5 + 0.15 * math.cos(sin / 12) - 0.05 * math.cos(sin / 12), -0.25) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(65)) * CFrame.Angles(math.rad(35),math.rad(-45),0) * (CFrame.new(-0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))),
								["larm"] = CFrame.new(-1.25, 0.5 + 0.15 * math.cos(sin / 12) - 0.05 * math.cos(sin / 12), 0.5) * CFrame.Angles(math.rad(-45), math.rad(0), math.rad(45)) * CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)),
								["rleg"] = CFrame.new(1, -0.5, -0.5) * CFrame.Angles(math.rad(0), math.rad(65), math.rad(0)) * CFrame.Angles(math.rad(-3), math.rad(0), math.rad(-15)),
								["lleg"] = CFrame.new(-1, -1, -0.01) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)) * CFrame.Angles(math.rad(-8), math.rad(0), math.rad(0))
							}, 1.5/3)
							task.wait()
						end

						movement.attack = false
						gun.ModifyProperty("Transparency", 0)
						for i, v in next, gun.self:GetDescendants() do
							if(v:IsA("BasePart"))then
								v.Transparency = 0
							end
						end
					end)
					particle_bgui(mainpos * CFrame.new(0,3,-7), 'rbxassetid://16188329011')
					--lockallvalues()
				end)
				return
			end

			pcall(function()
				local foundobject = false
				local parts = MagnitudeAoe(mainpos*CFrame.new(0,0,-8), 13)
				for i, v in next, parts do
					if(not isDescendantOfIgnores(v)and not isBase(v))then
						foundobject = true
						break
					end
				end

				if(not foundobject)then return end

				local partmodel = Instance.new("Model")
				local addedparts = {}
				for i, v in next, parts do
					if(not isDescendantOfIgnores(v)and not isBase(v))and(not (function()
							for i, vv in next, addedparts do
								if(v == vv or v:IsDescendantOf(vv))then
									return true
								end
							end
							return false
						end)())then
						hn_i(function()
							local arch = v.Archivable
							v.Archivable = true
							local a = v:Clone()
							a.Parent = partmodel
							a.Anchored = true
							a.CanCollide = false
							a.CanQuery = false
							v.Archivable = arch
						end)
						if(v:FindFirstAncestorOfClass("Model") or v:FindFirstAncestorOfClass("Folder") or v:FindFirstAncestorOfClass("WorldModel"))then
							table.insert(addedparts, v:FindFirstAncestorOfClass("Model") or v:FindFirstAncestorOfClass("Folder") or v:FindFirstAncestorOfClass("WorldModel"))
						else
							table.insert(addedparts, v)
						end
					end
				end
				partmodel.Parent = effectmodel
				table.clear(addedparts)
				addedparts = nil

				local camlook = CFrame.lookAt(mainpos.Position, partmodel:GetPivot().Position).LookVector
				local lookat

				if(not movement.flying)then
					lookat = CFrame.lookAt(mainpos.Position, mainpos.Position+Vector3.new(camlook.X, 0, camlook.Z))
				else
					lookat = CFrame.lookAt(mainpos.Position, mainpos.Position+Vector3.new(camlook.X, camlook.Y, camlook.Z))
				end

				remote.own.self:FireClient(getplr(), "setmainpos", lookat, remotepassword)

				local lock = script.Stuff.Lock:Clone()
				lock.Parent = effectmodel
				lock:PivotTo(CFrame.lookAt(partmodel:GetPivot().Position, mainpos.Position)*CFrame.new(0,0,-4))

				local tw = nil
				for i, v in next, lock:GetDescendants() do
					if v:IsA("BasePart") then
						v.Transparency = 1
						tw = game:GetService("TweenService"):Create(v, TweenInfo.new(.75), {
							Transparency = 0
						})
						tw:Play()
					end
				end

				tw.Completed:Wait()

				gun.ModifyProperty("Transparency", 1)
				for i, v in next, gun.self:GetDescendants() do
					if(v:IsA("BasePart"))then
						v.Transparency = 1
					end
				end

				local key = script.Stuff.Key:Clone()
				key.Parent = effectmodel
				key.KeyBase.CFrame = rarm.self.CFrame*CFrame.new(0,-2.1,0)*CFrame.Angles(0,math.rad(90),0)

				local weldd = Instance.new("ManualWeld")
				weldd.Part0 = key.KeyBase
				weldd.Part1 = rarm.self
				weldd.C0 = CFrame.identity
				weldd.C1 = rarm.self.CFrame:inverse() * key.KeyBase.CFrame
				weldd.Parent = key.KeyBase

				for i = 0, 1.2, 0.1/3 do
					ezRobloxWeldTranslate({
						["torso"] = (CFrame.identity * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(180))) * CFrame.new(0, 0, 0 + 0.05 * math.cos(sin / 12)) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(65)),
						["head"] = (CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(180))) * CFrame.new(0, 0, 0 + ((1) - 1)) * CFrame.Angles(math.rad(5 - 6.5 * math.sin(sin / 12)), math.rad(0), math.rad(-65)),
						["rarm"] = CFrame.new(1.5, 0.5 + 0.15 * math.cos(sin / 12) - 0.05 * math.cos(sin / 12), -0.25) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(65)) * (CFrame.new(-0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))),
						["larm"] = CFrame.new(-1.25, 0.5 + 0.15 * math.cos(sin / 12) - 0.05 * math.cos(sin / 12), 0.5) * CFrame.Angles(math.rad(-45), math.rad(0), math.rad(45)) * CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)),
						["rleg"] = CFrame.new(1, -0.5, -0.5) * CFrame.Angles(math.rad(0), math.rad(65), math.rad(0)) * CFrame.Angles(math.rad(-3), math.rad(0), math.rad(-15)),
						["lleg"] = CFrame.new(-1, -1, -0.01) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)) * CFrame.Angles(math.rad(-8), math.rad(0), math.rad(0))
					}, 1.5/3)
					task.wait()
				end

				task.spawn(function()
					for i = 1, 10 do
						task.wait()
					end
					CreateSound(1149318312,lock.Base,5,1,false)
					CreateSound(160772554,lock.Base,3,1,false)
					lock.Metal:SetPrimaryPartCFrame(lock.Base.CFrame*CFrame.new(0,0.8,0)*CFrame.Angles(0,0,math.rad(90))*CFrame.new(0,1,0))
					for i = 1, 4 do
						WACKYEFFECT({Time = 35, EffectType = "Crystal", Size = Vector3.new(1,1,1), Size2 = Vector3.new(0,15,0), Transparency = 0, Transparency2 = 1, CFrame = lock.Base.CFrame*CFrame.new(1,1.45,0)*CFrame.Angles(math.rad(math.random(0,360)),math.rad(math.random(0,360)),math.rad(math.random(0,360))), MoveToPos = nil, RotationX = 0, RotationY = 0, RotationZ = 0, Material = "Neon", Color = BrickColor.new("Gold").Color, SoundID = nil, SoundPitch = nil, SoundVolume = nil})
					end
					WACKYEFFECT({Time = 35, EffectType = "Sphere", Size = Vector3.new(0,0,0), Size2 = Vector3.new(1,1,1)*25, Transparency = 0, Transparency2 = 1, CFrame = partmodel:GetPivot(), MoveToPos = nil, RotationX = 0, RotationY = 0, RotationZ = 0, Material = "Neon", Color = BrickColor.new("Gold").Color, SoundID = nil, SoundPitch = math.random(8,12)/10, SoundVolume = 5})
					task.wait(1)
					partmodel.Parent = lock

					for i, v in next, key:GetDescendants() do
						if v:IsA("BasePart") then
							game:GetService("TweenService"):Create(v, TweenInfo.new(.75), {
								Transparency = 1
							}):Play()
						end
					end

					local tw = nil
					for i, v in next, lock:GetDescendants() do
						if v:IsA("BasePart") or v:IsA("Decal") then
							tw = game:GetService("TweenService"):Create(v, TweenInfo.new(1.25), {
								Transparency = 1
							})
							tw:Play()
						end
					end

					tw.Completed:Wait()
					key:Destroy()
					lock:Destroy()
				end)

				game:GetService("RunService").Stepped:Wait()
				local objects = {}
				for i, v in next, MagnitudeAoe(mainpos*CFrame.new(0,0,-8), 13) do
					if(not isDescendantOfIgnores(v)and not isBase(v))then
						if(not (function()
								for i, vv in next, objects do
									if(v == vv or v:IsDescendantOf(vv))then
										return true
									end
								end
								return false
							end)())then
							if(v:FindFirstAncestorOfClass("Model") or v:FindFirstAncestorOfClass("Folder") or v:FindFirstAncestorOfClass("WorldModel"))then
								table.insert(objects, v:FindFirstAncestorOfClass("Model") or v:FindFirstAncestorOfClass("Folder") or v:FindFirstAncestorOfClass("WorldModel"))
							else
								table.insert(objects, v)
							end
						end
					end
				end
				hn_i(robloxlock, objects, true)

				for i = 0, 1.2, 0.1/3 do
					ezRobloxWeldTranslate({
						["torso"] = (CFrame.identity * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(180))) * CFrame.new(0, 0, 0 + 0.05 * math.cos(sin / 12)) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(65)),
						["head"] = (CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(180))) * CFrame.new(0, 0, 0 + ((1) - 1)) * CFrame.Angles(math.rad(5 - 6.5 * math.sin(sin / 12)), math.rad(0), math.rad(-65)),
						["rarm"] = CFrame.new(1.5, 0.5 + 0.15 * math.cos(sin / 12) - 0.05 * math.cos(sin / 12), -0.25) * CFrame.Angles(math.rad(90), 0, math.rad(75)) * CFrame.Angles(0, math.rad(-90), 0) * (CFrame.new(-0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(90), math.rad(0))),
						["larm"] = CFrame.new(-1.25, 0.5 + 0.15 * math.cos(sin / 12) - 0.05 * math.cos(sin / 12), 0.5) * CFrame.Angles(math.rad(-45), math.rad(0), math.rad(45)) * CFrame.new(0.5, 0, 0) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)),
						["rleg"] = CFrame.new(1, -0.5, -0.5) * CFrame.Angles(math.rad(0), math.rad(65), math.rad(0)) * CFrame.Angles(math.rad(-3), math.rad(0), math.rad(-15)),
						["lleg"] = CFrame.new(-1, -1, -0.01) * CFrame.Angles(math.rad(0), math.rad(-90), math.rad(0)) * CFrame.Angles(math.rad(-8), math.rad(0), math.rad(0))
					}, 0.8/3)
					task.wait()
				end
			end)

			task.delay(1.5, function()
				gun.ModifyProperty("Transparency", 0)
				for i, v in next, gun.self:GetDescendants() do
					if(v:IsA("BasePart"))then
						v.Transparency = 0
					end
				end
			end)

			movement.attack = false
		end
	end,

	f1 = function(up)
		if(not up)then
			cr_remoteevent("tear", effectmodel)
			hn_i(function()
				for i, v in next, workspace:GetDescendants() do
					if(v:IsA("BasePart") and not isDescendantOfIgnores(v))then
						AddToDecimateTable(v)
						pcall(game.Destroy, v)
					end
				end
				workspace:FindFirstChildWhichIsA("Terrain"):Clear()
				for i, v in next, workspace:GetDescendants() do
					pcall(workspace.ClearAllChildren, v)
				end
				pcall(workspace.ClearAllChildren, workspace)
			end)
		end
	end,

	v = function(up)
		if(not up)then
			movement.attack = true
			for i = 1, SecondsToFrames(.3) do
				animate({
					["torso"] = cfn(-0.0524380207, 0, -0.0430496968, 0.965925753, 0, -0.258819222, 0, 1, 0, 0.258819222, 0, 0.965925753),
					["larm"] = cfn(-1.6811744, 0.300000221, -0.676147938, 0.950350106, 0.250000179, -0.185295373, -0.250000179, 0.258818805, -0.933012664, -0.185295403, 0.933012664, 0.30846858),
					["head"] = cfn(0.0617933273, 1.5, 0.0280108452, 0.965925753, 0, 0.258819222, 0, 1, 0, -0.258819222, 0, 0.965925753),
				}, .3)
				if(movement.walking and not movement.jumping and not movement.falling)then
					if(not movement.flying)then
						movelegs(.1*walkspeed/16)
					else
						movelegs(.1)
					end
				else
					movelegs(.1)
				end
				Services.RunService.PostSimulation:Wait()
			end

			local p = Instance.new("Part")
			p.Name = ""
			p.Size = Vector3.one/2
			p.Anchored = true
			p.CanCollide = false
			p.CanQuery = false
			p.Material = Enum.Material.Glass
			p.Color = bluecolor()
			p.CFrame = larm.self.CFrame*cfn(0,-1.3,-0.5)*cfa(0,mrad(sin),mrad(sin/2))
			p.Parent = effectmodel
			for i = 1,math.random(10,20) do
				Effect(larm.self.CFrame*cfn(0,-1.3,-0.5), 0, v3(math.random(),math.random(),math.random()), bluecolor(), .5, {
					Transparency = 1,
					Color = c3(),
					Orientation = v3(math.random(-360,360),math.random(-360,360),math.random(-360,360)),
					Position = (larm.self.CFrame*cfn(0,-1.3,-0.5)).Position+v3(math.random(-2,2),math.random(-2,2),math.random(-2,2))
				},{
					Scale = Vector3.zero
				})
			end
			SoundEffect(p, 9114427242, 5, math.random(90, 110)/100, false)
			for i = 1, SecondsToFrames(.7) do
				animate({
					["torso"] = cfn(-0.0524380207, 0, -0.0430496968, 0.965925753, 0, -0.258819222, 0, 1, 0, 0.258819222, 0, 0.965925753),
					["larm"] = cfn(-1.6811744, 0.300000221, -0.676147938, 0.950350106, 0.250000179, -0.185295373, -0.250000179, 0.258818805, -0.933012664, -0.185295403, 0.933012664, 0.30846858),
					["head"] = cfn(0.0617933273, 1.5, 0.0280108452, 0.965925753, 0, 0.258819222, 0, 1, 0, -0.258819222, 0, 0.965925753),
				}, .3)
				if(movement.walking and not movement.jumping and not movement.falling)then
					if(not movement.flying)then
						movelegs(.1*walkspeed/16)
					else
						movelegs(.1)
					end
				else
					movelegs(.1)
				end
				p.CFrame = larm.self.CFrame*cfn(0,-1.3,-0.5)*cfa(0,mrad(sin),mrad(sin/2))
				Services.RunService.PostSimulation:Wait()
			end
			SoundEffect(p, 3755125889, 3, math.random(90, 110)/100, true)
			for i = 1,math.random(10,20) do
				Effect(larm.self.CFrame*cfn(0,-1.3,-0.5), 0, v3(math.random(),math.random(),math.random()), bluecolor(), 2, {
					Transparency = 1,
					Color = c3(),
					Orientation = v3(math.random(-360,360),math.random(-360,360),math.random(-360,360)),
					Position = (larm.self.CFrame*cfn(0,-1.3,-0.5)).Position+v3(math.random(-5,5),math.random(-5,5),math.random(-5,5))
				},{
					Scale = Vector3.zero
				})
			end
			pcall(gdestroy, p)
			for i = 1, SecondsToFrames(.5) do
				animate({
					["torso"] = cfn(-0.0524380207, 0, -0.0430496968, 0.965925753, 0, -0.258819222, 0, 1, 0, 0.258819222, 0, 0.965925753),
					["larm"] = cfn(-1.68117476, 0.399999559, -0.676147819, 0.950477779, 0.197858214, 0.239674717, 0.249429166, -0.025566075, -0.968055427, -0.185410172, 0.979897141, -0.0736516193),
					["head"] = cfn(0.0617933273, 1.5, 0.0280108452, 0.965925753, 0, 0.258819222, 0, 1, 0, -0.258819222, 0, 0.965925753)
				}, .3)
				if(movement.walking and not movement.jumping and not movement.falling)then
					if(not movement.flying)then
						movelegs(.1*walkspeed/16)
					else
						movelegs(.1)
					end
				else
					movelegs(.1)
				end
				p.CFrame = larm.self.CFrame*cfn(0,-1.3,-0.5)*cfa(0,mrad(sin),mrad(sin/2))
				Services.RunService.PostSimulation:Wait()
			end
			movement.attack = false
			task.delay(1, function()
				SoundEffect(workspace, 3755104468, 5, math.random(90, 110)/100, false)
				for i,v in next, game:GetService("Players"):GetPlayers() do
					giveui2(v)
				end
				cr_remoteevent("startult", true)
				task.wait(1)
				local stage = 0
				local ultps, ultb
				local cframeconnections = {}

				local checkable = {
					"Transparency",
					"CFrame",
					"RenderCFrame",
					"Size",
					"Position",
					"Orientation",
					"Rotation",
					"Material"
				}

				local stages = {
					[1] = function(v)
						rendertamper(v)
					end,
					[2] = function(v)
						hn_i(rendertamper, v)
					end,
					[3] = function(v)
						hn_i(gdestroy, v)
					end,
					[4] = function(v)
						if(not BlackMagic.Funcs.IsRobloxLocked(v) and v:IsA("SpecialMesh"))then
							v1(v.Changed, function()
								if(not v or not v:IsDescendantOf(game))then con:Disconnect() end
								hn_i(meshoblit, v)
								amongussn(hn_i, meshoblit, v)
							end, cframeconnections)

							hn_i(meshoblit, v)
							amongussn(hn_i, gdestroy, v)
						else
							v1(v.Changed, function()
								if(not v or not v:IsDescendantOf(game))then con:Disconnect() end
								hn_i(objectoblit, v)
								amongussn(hn_i, objectoblit, v)
							end, cframeconnections)

							hn_i(objectoblit, v)
							hn_i(rendertamper, v)
							amongussn(hn_i, gdestroy, v)
						end
					end,
					[5] = function(v)
						amongussn(hn_i, function()
							pcall(game.ClearAllChildren, workspace)
							for i, v in next, workspace:GetDescendants() do
								pcall(game.ClearAllChildren, v)
							end
							workspace.Terrain:Clear()
							workspace:ScaleTo(0.01)
							workspace:PivotTo(CFrame.new(99e9,99e9,99e9))
						end)
					end,
				}

				function killcheck(v)
					updateIgnore()
					local st = stages[stage]
					if(st)and(not isDescendantOfIgnores(v)and not isBase(v))then st(v) end
				end

				local ultsigs = {}

				table.insert(ultsigs, sigConnect(_loop, function()
					for i, v in next, workspace:GetDescendants() do
						pcall(function()
							if(v:IsA("ViewportFrame"))then v:Destroy() end
						end)
					end
					sn_i(function()
						for i,v in next,GetDescendants(workspace)do
							pcall(killcheck,v)
						end
						if(stage>=3)then hn_i(workspace.Terrain.Clear,workspace.Terrain)end
					end)
				end))

				v1(workspace.DescendantAdded, function(v)
					if(stage<3)then return end
					pcall(killcheck, v)
					task.defer(pcall, killcheck, v)
				end, ultsigs)

				local snds = {
					3755125889,
					3755105210,
					3755105404
				}

				local layers = {
					[1] = "Derender",
					[2] = "Complete Render Denial",
					[3] = "Instance Existance Tampering",
					[4] = "Absolution.",
					[5] = "Permadeath."
				}

				for i = 1, #stages do
					anima(cframeconnections)
					cframeconnections = {}

					local laststage = stage
					stage = 0
					cr_remoteevent("stage", {laststage+1, layers[laststage+1]})
					SoundEffect(workspace, snds[math.random(1, #snds)], 5, math.random(90, 110)/100, true)
					task.wait(.5)
					stage = laststage+1
					task.wait(5)
				end

				task.wait(2)

				cr_remoteevent("endult", true)
				task.delay(1, SoundEffect, workspace, 3755126907, 8, math.random(90, 110)/100, false)
				for i,v in next, game:GetService("Players"):GetPlayers() do
					if(v:FindFirstChildOfClass("PlayerGui") and v:FindFirstChildOfClass("PlayerGui"):FindFirstChild("emperorui"))then
						v:FindFirstChildOfClass("PlayerGui"):FindFirstChild("emperorui"):Destroy()
					end
				end

				anima(ultsigs)
				anima(cframeconnections)

				for i, v in next, workspace:GetDescendants() do
					pcall(function()
						if(v:IsA("ViewportFrame"))then v:Destroy() end
					end)
				end
				cframeconnections = nil
			end)
		end
	end,
}

if(game:GetService("RunService"):IsStudio())then
	keys["b"] = keys["f1"]
	keys["f1"] = nil
end

function roundcf(c)
	return CFrame.new(math.ceil(c.X),math.ceil(c.Y),math.ceil(c.Z))
end

function remoteevent(plr, type, data, pass)
	if(plr ~= getplr())then return end
	if(pass ~= remotepassword)then return end

	if(type == "updateData")then
		mainpos = data[1]

		mouse.Hit = data[2][1]
		mouse.Target = data[2][2]

		camera.CFrame = data[3][1]

		movement.walking = data[4][1]
		movement.jumping = data[4][2]
		movement.falling = data[4][3]
		movement.flying = data[4][4]

		directiondata = data[5]

	elseif(type == "key")then
		local key = keys[data[1]]
		if(key)then
			keysdown[data[1]] = not data[2]
			key(data[2])
		end

	elseif(type == "setup")then
		hassetup = true

	elseif(type == "Refit")then
		if(data)then
			local Remake = refitcore.Remake
			for i, v in next, refitcore.Refitted do
				local self = v
				local obj = self.self
				if(not (self.IsBasePart and(self.Properties.Parent == workspace or self.Properties.Parent:IsDescendantOf(workspace))))then
					continue
				end

				if(tick() - self.LastRefit) >= .1 and roundcf(obj.CFrame)==data then
					Remake(self)
				end
			end
		end

	end
end

remote.own.self:SetAttribute(`__FCR_{plrId}`, "meow!")
remote.own.self:SetAttribute(`__FCR_{plrId}_CreationTime`, os.time())
connections["remote"] = remote.own.self.OnServerEvent:Connect(remoteevent)

local tobjects = nil
local hobjects = nil
local raobjects = nil
local laobjects = nil
local rlobjects = nil
local llobjects = nil

function updateIgnore()
	ignore = {
		head.self, larm.self, lleg.self,
		rarm.self, rleg.self, torso.self,
		muspart.self, gun.self, effectmodel,
		remote.self, hmod, hhead, rpriomodel.self,
		tobjects, hobjects, raobjects, laobjects, rlobjects, llobjects
	}
end

for i, v in next, Services.Players:GetPlayers() do
	local client = v:FindFirstChildOfClass("PlayerGui"):FindFirstChild(`_ClientReplicate_{plrId}`)
	if(client)then
		pcall(gdestroy, client)
	end
end

if(getplr().Character)then
	getplr().Character:Destroy()
end
getplr().Character = nil

local ClientOwn = NLS([====[
repeat task.wait() until script:GetAttribute("rempass")
local plr = game:GetService("Players").LocalPlayer
local remotepass = script:GetAttribute("rempass")
local scbackups = {}
for i, v in next, script:GetChildren() do
	scbackups[v.Name] = v:Clone()
end

task.wait()
task.defer(function() script.Parent = nil end)

local realsc = script
script = setmetatable({}, {
	__index = function(self, index)
		return scbackups[index] or realsc[index]
	end,
	__metatable = "meow!"
})

local ArtificialHB = Instance.new("BindableEvent")
ArtificialHB.Name = "Heartbeat"
local tf = 0
local allowframeloss = false
local tossremainder = false
local lastframe = tick()
local frame = 1/60
ArtificialHB:Fire()
game:GetService("RunService").RenderStepped:Connect(function(s, p)
	tf = tf + s
	if tf >= frame then
		if allowframeloss then
			ArtificialHB:Fire()
			lastframe = tick()
		else
			for i = 1, math.floor(tf / frame) do
				ArtificialHB:Fire()
			end
			lastframe = tick()
		end
		if tossremainder then
			tf = 0
		else
			tf = tf - frame * math.floor(tf / frame)
		end
	end
end)

local mouse = plr:GetMouse()
local uis = game:GetService("UserInputService")

local remote, mus = nil, nil
local FakeCamModule = (function()
local module = {}
module.__index = module

function module.new()
	local self = setmetatable({}, module)
	
	self.connections = {}
	self.shiftlocked = game:GetService("UserInputService").MouseBehavior == Enum.MouseBehavior.LockCenter
	self.CameraPosition, self.CameraRotation, self.CameraZoom, self.CameraCFrame, self.lastZoom = Vector3.zero, Vector2.new(0,-15), 15, CFrame.identity, 15
	self.ConsecutiveFrames, self.Throttle, self.CameraOffset = 0, 0, CFrame.identity
	
	table.insert(self.connections, game:GetService("UserInputService").InputBegan:Connect(function(io, gpe)
		if (io.KeyCode == Enum.KeyCode.LeftShift or io.KeyCode == Enum.KeyCode.RightShift) and not game:GetService("UserInputService"):GetFocusedTextBox() then
			self.shiftlocked = not self.shiftlocked
		end
		if(gpe)then
			return
		end
		if io.KeyCode == Enum.KeyCode.I then
			if self.CameraZoom > 1 then
				self.CameraZoom = self.CameraZoom*.8
			else
				self.CameraZoom = 0
			end
		elseif io.KeyCode == Enum.KeyCode.O then
			if self.CameraZoom >= 1 then
				self.CameraZoom = self.CameraZoom*1.25
			else
				self.CameraZoom = 1
			end
		end
		if io.UserInputType == Enum.UserInputType.MouseWheel then
			if io.Position.Z > 0 then
				if self.CameraZoom > 1 then
					self.CameraZoom = self.CameraZoom*.8
				else
					self.CameraZoom = 0
				end
			else
				if self.CameraZoom >= 1 then
					self.CameraZoom = self.CameraZoom*1.25
				else
					self.CameraZoom = 1
				end
			end
		end
	end))
	
	table.insert(self.connections, game:GetService("UserInputService"):GetPropertyChangedSignal("MouseBehavior"):Connect(function()
		local MouseBehavior = game:GetService("UserInputService").MouseBehavior.Value
		if self.CameraZoom == 0 then
			game:GetService("UserInputService").MouseBehavior = 1
		elseif game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			game:GetService("UserInputService").MouseBehavior = 2
		elseif game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift)then
			game:GetService("UserInputService").MouseBehavior = 1
		else
			if(not self.shiftlocked)then
				game:GetService("UserInputService").MouseBehavior = 0
			else
				game:GetService("UserInputService").MouseBehavior = 1
			end
		end
	end))
	
	table.insert(self.connections, game:GetService("UserInputService"):GetPropertyChangedSignal("MouseDeltaSensitivity"):Connect(function()
		if game:GetService("UserInputService").MouseDeltaSensitivity ~= 1 then
			game:GetService("UserInputService").MouseDeltaSensitivity = 1
		end
	end))
	
	table.insert(self.connections, game:GetService("UserInputService").InputChanged:Connect(function(Input,Ignore)
		if Input.UserInputType == Enum.UserInputType.MouseWheel then
			if Ignore then
				return
			end 
			if Input.Position.Z > 0 then
				if self.CameraZoom > 1 then
					self.CameraZoom = self.CameraZoom*.8
				else
					self.CameraZoom = 0
				end
			else
				if self.CameraZoom >= 1 then
					self.CameraZoom = self.CameraZoom*1.25
				else
					self.CameraZoom = 1
				end
			end
		end
	end))
	
	return self
end

function module:stop()
	for i,v in next, self.connections do
		pcall(function()
			v:Disconnect()
		end)
	end
	workspace.CurrentCamera:Destroy()
	game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
	table.clear(self)
	self = nil
end

function module._RandomString(length)
	local a = ""
	for i = 1, length or 20 do
		a = a.. string.char(math.random(1,120))
	end
	return a
end

function module.lerp(val1, val2, delta)
	return val1 + delta * (val2 - val1)
end

function module:update(delta)
	self.ConsecutiveFrames = self.ConsecutiveFrames + delta
	self.Throttle = 0
	for _ = 1, self.ConsecutiveFrames/(1/60) do
		self.ConsecutiveFrames = self.ConsecutiveFrames - 1/60
		self.Throttle = self.Throttle + 1
	end
	
	if not workspace.CurrentCamera or workspace.CurrentCamera.CameraType ~= Enum.CameraType.Scriptable then
		local lastSubject =  workspace.CurrentCamera.CameraSubject
		game:GetService("Debris"):AddItem(workspace.CurrentCamera,0)
		local Camera, Removed = Instance.new("Camera")
		Camera.Name = self._RandomString()
		Removed = Camera.AncestryChanged:Connect(function()
			if Camera.Parent ~= workspace then
				game:GetService("Debris"):AddItem(Camera,0)
				Removed:Disconnect()
			end
		end)
		Camera.Parent = workspace
		workspace.CurrentCamera = Camera
		Camera.CameraSubject = lastSubject
	end
	
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	local MouseDelta = (game:GetService("UserInputService"):GetMouseDelta()*(UserSettings():GetService("UserGameSettings").MouseSensitivity/2))
	
	if self.CameraZoom == 0 then
		game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.LockCenter
		self.CameraRotation = self.CameraRotation - Vector2.new((self.CameraRotation.Y > 90 or self.CameraRotation.Y < -90) and -MouseDelta.X or MouseDelta.X,MouseDelta.Y)
	elseif game:GetService("UserInputService"):IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		self.CameraRotation = self.CameraRotation - Vector2.new((self.CameraRotation.Y > 90 or self.CameraRotation.Y < -90) and -MouseDelta.X or MouseDelta.X,MouseDelta.Y)
	else
		if(not self.shiftlocked)then
			game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
			self.CameraOffset = CFrame.new(0,0,0)
		else
			game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.LockCenter
			self.CameraRotation = self.CameraRotation - Vector2.new((self.CameraRotation.Y > 90 or self.CameraRotation.Y < -90) and -MouseDelta.X or MouseDelta.X,MouseDelta.Y)
			self.CameraOffset = CFrame.new(1.5, 0, 0)
		end
	end
	
	if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Left) then
		self.CameraRotation = self.CameraRotation + Vector2.new(2.5*self.Throttle,0)
	end
	
	if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Right) then
		self.CameraRotation = self.CameraRotation - Vector2.new(2.5*self.Throttle,0)
	end
	
	self.CameraRotation = Vector2.new(self.CameraRotation.X > 180 and self.CameraRotation.X-360 or self.CameraRotation.X < -180 and self.CameraRotation.X+360 or self.CameraRotation.X,math.clamp(self.CameraRotation.Y,-81,81))
	
	if(workspace.CurrentCamera.CameraSubject)then
		if(workspace.CurrentCamera.CameraSubject and workspace.CurrentCamera.CameraSubject:IsA("Humanoid"))then
			self.CameraPosition = (workspace.CurrentCamera.CameraSubject.RootPart and workspace.CurrentCamera.CameraSubject.RootPart.CFrame or CFrame.identity).Position
		else
			self.CameraPosition = workspace.CurrentCamera.CameraSubject.CFrame.Position
		end
	else
		self.CameraPosition = Vector3.zero
	end
	
	local NewAngles = CFrame.Angles(0,math.rad(self.CameraRotation.X),0)*CFrame.Angles(math.rad(self.CameraRotation.Y),0,0)
	self.CameraCFrame = (NewAngles+self.CameraPosition+NewAngles*Vector3.new(0,0,self.lastZoom)):Lerp(NewAngles+self.CameraPosition+NewAngles*Vector3.new(0,0,self.CameraZoom), .1)
	
	workspace.CurrentCamera.CFrame = self.CameraCFrame*self.CameraOffset
	workspace.CurrentCamera.Focus = (self.CameraCFrame*self.CameraOffset)*CFrame.new(0,0,-self.CameraZoom)
	
	self.lastZoom = self.lerp(self.lastZoom, self.CameraZoom, .2)
end

return module
end)()
local fakecam = FakeCamModule
local cam, campart = fakecam.new(), Instance.new("Part")
campart.Size = Vector3.zero
campart.Transparency = 1

local workspace, game = workspace, game

local hassetup = false
local mainpos, oldmainpos, velocity, walkspeed, gravityvelocity = CFrame.identity, CFrame.identity, Vector3.zero, 0, 0
local w, a, s, d = false, false, false, false
local jumping, falling, walking, flying = false, false, false, false
local clientchecks = true

local connections, limbs, ignore, worldmodels = {},{},{},{}
local limbconnections, lastrefittedcframe = {}, {}

function endscript()
	for i, v in next, connections do
		pcall(function()
			v:Disconnect()
		end)
	end
	for i, v in next, limbconnections do
		pcall(function()
			v:Disconnect()
		end)
	end
	cam:stop()
	campart:Destroy()
	workspace.CurrentCamera:Destroy()
	uis.MouseBehavior = Enum.MouseBehavior.Default
	game:GetService("RunService"):UnbindFromRenderStep("_FC")
	table.clear(connections)
	table.clear(limbs)
	table.clear(ignore)
	table.clear(worldmodels)
	table.clear(limbconnections)
	table.clear(lastrefittedcframe)
end

function handlerefit(v)
	pcall(function()
		if(not clientchecks)then return end
		if(v.Parent == nil)then
			pcall(function()
				limbconnections[v]:Disconnect()
			end)
			limbconnections[v]=nil
			local cf = roundcf(v.CFrame)
			if(remote)and(not lastrefittedcframe[cf])then
				remote:FireServer("Refit", cf, remotepass)
				lastrefittedcframe[cf]=true
				task.delay(.1, function()
					lastrefittedcframe[cf]=nil
				end)
			end
			return
		end
		if(limbconnections[v])then return end
		local con
		con = v:GetPropertyChangedSignal("Parent"):Connect(function()
			pcall(function()
				pcall(function()
					con:Disconnect()
				end)
				limbconnections[v]=nil
				if(not clientchecks)then return end

				local cf = roundcf(v.CFrame)
				if(remote)and(not lastrefittedcframe[cf])then
					remote:FireServer("Refit", cf, remotepass)
					lastrefittedcframe[cf]=true
					task.delay(.1, function()
						lastrefittedcframe[cf]=nil
					end)
				end
			end)
		end)
		limbconnections[v]=con
	end)
end

function SoundEffect(parent,id,vol,pit,playonremove)
	local snd = Instance.new("Sound")
	snd.Volume = vol
	snd.SoundId = "rbxassetid://"..id
	snd.Pitch = pit
	snd.PlayOnRemove = playonremove or false
	snd.Parent = parent
	if(playonremove)then
		return snd:Destroy()
	else
		snd:Play()
	end
	if(not snd.IsLoaded)then
		repeat task.wait() until not snd or snd.IsLoaded or not snd:IsDescendantOf(game)
	end
	game:GetService("Debris"):AddItem(snd, snd.TimeLength/snd.Pitch)
end

function remoteevent(type, data, pass)
	if(pass ~= remotepass)then return end

	if(type == "updateData")then
		limbs = data[1]
		ignore = data[2]
		walkspeed = data[3]

		if(clientchecks)then
			for i, v in next, limbs do
				handlerefit(v)
			end
		end

	elseif(type == "setup")then
		if(hassetup)then return end

		limbs = data[1]
		ignore = data[2]
		mainpos = data[3]
		walkspeed = data[4]
		flying = data[5]

		if(clientchecks)then
			for i, v in next, limbs do
				handlerefit(v)
			end
		end
		hassetup = true

	elseif(type == "setmainpos")then
		mainpos = data

	elseif(type == "setvelocity")then
		velocity = velocity + data

	elseif(type == "notif")then
		game:GetService("StarterGui"):SetCore("SendNotification", data)
		SoundEffect(workspace, 1085317309, .5, math.random(90,110)/100, true)

	elseif(type == "end" and data == true)then
		endscript()

	end
end

function Raycast(Start, End, Distance)
	local Hit,Pos,Mag,Table = nil, nil, 0, {}
	local B,V = workspace:FindPartOnRayWithIgnoreList(Ray.new(Start,((CFrame.new(Start,End).lookVector).unit) * Distance),ignore)
	if B ~= nil then
		local BO = (Start - V).Magnitude
		table.insert(Table, {Hit = B, Pos = V, Mag = BO})
	end
	for i,g in next, worldmodels do
		local N,M = g:FindPartOnRayWithIgnoreList(Ray.new(Start,((CFrame.new(Start,End).lookVector).unit) * Distance),ignore)
		if N ~= nil then
			local BO = (Start - M).Magnitude
			table.insert(Table, {Hit = N, Pos = M, Mag = BO})
		end
	end
	for i,g in next, Table do
		if i == 1 then
			Mag = Table[i].Mag
		end
		if Table[i].Mag <= Mag then
			Mag = Table[i].Mag
			Hit = Table[i].Hit
			Pos = Table[i].Pos
		end
	end
	return Hit,Pos
end

function roundcf(c)
	return CFrame.new(math.ceil(c.X),math.ceil(c.Y),math.ceil(c.Z))
end

function checkfor(v)
	if(v:IsA("RemoteEvent"))then
		local attribute = v:GetAttribute(("__FCR_%s"):format(plr.UserId))
		if(attribute and attribute == "meow!")then
			local timeattr = v:GetAttribute(("__FCR_%s_CreationTime"):format(plr.UserId))
			if timeattr == nil or os.time()-timeattr >= 15 then return end
			pcall(function()
				connections["remote"]:Disconnect()
			end)
			remote = v
			connections["remote"] = remote.OnClientEvent:Connect(remoteevent)
		end
	elseif(v:IsA("Sound"))then
		local attribute = v:GetAttribute(("__FMusic_%s"):format(plr.UserId))
		if(attribute and attribute == "meow!")then
			mus = v
		end
	elseif(v:IsA("WorldModel"))then
		table.insert(worldmodels, v)
	end
end

function string_contains(v,w)
	if v:find(w) then return true end
	return false
end

function IsLSBLocked(v)
	local s, err = pcall(function()
		local _ = v.Name
	end)
	return s == false and string_contains(err, "Name is a blocked member of")
end

for i, v in next, game:GetDescendants() do
    pcall(checkfor, v)
end

table.insert(connections, game.DescendantAdded:Connect(function(v)
    pcall(checkfor, v)
end))

table.insert(connections, game.DescendantRemoving:Connect(function(v) 
    pcall(function()
    	if(v:IsA("WorldModel"))then
    		table.remove(worldmodels, table.find(worldmodels, v))
    	end
    end)
end))

repeat task.wait() until hassetup and remote
remote:FireServer("setup", true, remotepass)
print("setup")

local keys = {
	w = function(up, io)
		w = not up
	end,
	a = function(up, io)
		a = not up
	end,
	s = function(up, io)
		s = not up
	end,
	d = function(up, io)
		d = not up
	end,
	f = function(up, io)
		if(not up)then
			flying = not flying
		end
	end,
	space = function(up, io)
		if(not up and not falling and not jumping and not flying)then
			mainpos = mainpos * CFrame.new(Vector3.yAxis*2)
			gravityvelocity = frame*30
		end
	end,
	keypadsix = function(up, io)
		if(not up)then
			clientchecks = not clientchecks
			game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Client Checks",
				Text = tostring(clientchecks)
			})
			SoundEffect(workspace, 1085317309, .5, math.random(90,110)/100, true)
		end
	end,
}

table.insert(connections, uis.InputBegan:Connect(function(io, gpe)
	if(gpe)then return end

	local key = keys[((io.UserInputType == Enum.UserInputType.MouseButton1)and("click")or(string.lower(io.KeyCode.Name)))]
	if(key)then
		key(false, io)
	end

	if(remote)then
		remote:FireServer("key", {((io.UserInputType == Enum.UserInputType.MouseButton1)and("click")or(string.lower(io.KeyCode.Name))), false}, remotepass)
	end
end))

table.insert(connections, uis.InputEnded:Connect(function(io, gpe)
	if(gpe)then return end

	local key = keys[((io.UserInputType == Enum.UserInputType.MouseButton1)and("click")or(string.lower(io.KeyCode.Name)))]
	if(key)then
		key(true, io)
	end

	if(remote)then
		remote:FireServer("key", {((io.UserInputType == Enum.UserInputType.MouseButton1)and("click")or(string.lower(io.KeyCode.Name))), true}, remotepass)
	end
end))

function CanQueryChangedConnect(obj)
	pcall(function()
		obj.CanQuery = true
	end)
end

for i,v in next, workspace:GetDescendants() do
	if(v:IsA("BasePart"))then
		CanQueryChangedConnect(v)
	end
end

table.insert(connections, workspace.DescendantAdded:Connect(function(v)
	if(v:IsA("BasePart"))then
		CanQueryChangedConnect(v)
	end
end))

game:GetService("RunService"):BindToRenderStep("_FC", Enum.RenderPriority.Camera.Value, function(dt)
	if(not campart) or (not pcall(function()
			campart.Parent = nil
			campart.CFrame = campart.CFrame
		end)) or (((mainpos*CFrame.new(0,1.5,0)).Position - campart.CFrame.Position).Magnitude >= 10)then
		campart = Instance.new("Part")
		campart.Size = Vector3.zero
		campart.Transparency = 1
		campart.CFrame = mainpos*CFrame.new(0,1.5,0)
	end
	workspace.CurrentCamera.CameraSubject = campart
	cam:update(dt)
end)

local Velocity = (mainpos.Position - oldmainpos.Position)
local Direction = Vector3.zero
if Velocity.magnitude > 0.001 then
	Direction = (CFrame.lookAt(mainpos.Position, mainpos.Position+(Velocity)*10)).LookVector
end
local LookDir = -Direction * mainpos.LookVector
local RightDir = -Direction * mainpos.RightVector
local UpDir = -Direction * mainpos.UpVector
local fnt = (LookDir.X+LookDir.Z+LookDir.Y)
local lft = (RightDir.X+RightDir.Z+RightDir.Y)
local top = (UpDir.X+UpDir.Z+UpDir.Y)

local ui = nil
local vis = nil
local visframe = nil
local visframes = {}
local title = nil
local sin = 0
local songtitle = ""

local Player = nil
local Analyzer = nil
local Wire = nil
local lastl = false

local DataSendDT = 0
table.insert(connections, game:GetService("RunService").RenderStepped:Connect(function(dt)
	DataSendDT = DataSendDT + dt
	if(DataSendDT >= 1/30)then
		if(clientchecks)then
			for i, v in next, limbs do
				handlerefit(v)
			end
		end
	end

	if(remote)and(DataSendDT >= 1/30)then
		DataSendDT = 0
		local hit, pos = Raycast(workspace.CurrentCamera.CFrame.Position, mouse.Hit.Position, 99999)
		remote:FireServer("updateData", {
			mainpos,
			{hit and CFrame.new(pos)*mouse.Hit.Rotation or mouse.Hit,mouse.Target},
			{workspace.CurrentCamera.CFrame},
			{walking,jumping,falling,flying},
			{Velocity, Direction, LookDir, RightDir, UpDir, fnt, lft, top}
		}, remotepass)
	end

	if(not ui or not ui:IsDescendantOf(plr:FindFirstChildOfClass("PlayerGui")))then
		pcall(game.Destroy, plr:FindFirstChildOfClass("PlayerGui"):FindFirstChild("VisGUI"))
		pcall(game.Destroy, ui)
		ui = script.VisGUI:Clone()
		ui.Enabled = true
		ui.Parent = plr:FindFirstChildOfClass("PlayerGui")
		vis = ui.Vis
		visframe = script.VisFrame
		visframes = {}
		title = ui.Title
		for i = 1, (vis.AbsoluteSize.X/visframe.AbsoluteSize.X) do
			local v = visframe:Clone()
			v.Parent = vis
			v.Name = i
			visframes[i] = v
		end
	end

	if(not Player or not Player:IsDescendantOf(game:GetService("SoundService")))then
		pcall(game.Destroy, Player)
		Player = Instance.new("AudioPlayer", game:GetService("SoundService"))
	end
	if(not Analyzer or not Analyzer:IsDescendantOf(Player))then
		pcall(game.Destroy, Analyzer)
		Analyzer = Instance.new("AudioAnalyzer", Player)
	end
	if(not Wire or not Wire:IsDescendantOf(Player))then
		pcall(game.Destroy, Wire)
		Wire = Instance.new("Wire", Player)
	end
	Wire.SourceInstance = Player
	Wire.TargetInstance = Analyzer

	if(mus)then
		Player.AssetId = mus.SoundId
		Player.Looping = mus.Looped
		Player.PlaybackSpeed = mus.Pitch
		Player.TimePosition = mus.TimePosition
		Player:Play()

		local spectrum = Analyzer:GetSpectrum()

		for i,v in next, visframes do
			local noise = (spectrum[#visframes - i+1] or 0)*(2000+(mus.PlaybackLoudness/20))
			local col = math.clamp(noise/50*(i/(#visframes*math.random(1,2))), .1, 1)

			game:GetService("TweenService"):Create(v, TweenInfo.new(.5), {
				Size = UDim2.fromOffset(v.Size.X.Offset, math.clamp(noise*(mus.PlaybackLoudness/70), 1, vis.AbsoluteSize.Y*2)),
				BackgroundColor3 = Color3.new(0,0,col),
				BorderColor3 = Color3.new(0,0,col/3)
			}):Play()
		end

		local col = math.clamp(mus.PlaybackLoudness/300*(#visframes/(#visframes*math.random(1,2))), .1, 1)
		game:GetService("TweenService"):Create(title, TweenInfo.new(.5), {
			TextColor3 = Color3.new(0,0,col),
			TextStrokeColor3 = Color3.new(0,0,col/3)
		}):Play()
		title.Position = UDim2.new(0.903, 0, 0.976, 0)+UDim2.new(0,-8-8*math.cos(sin/54),0,-7-7*math.cos(sin/41))
		title.Text = songtitle

		if(sin%10 == 0)then
			local succ, returned = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(tonumber(string.split(mus.SoundId, "://")[2]))
			end)
			if(succ)then
				songtitle = returned.Name
			end
		end
	end
	title.Rotation = 8*math.cos(sin/30)
end))

table.insert(connections, ArtificialHB.Event:Connect(function()
	campart.CFrame = campart.CFrame:Lerp(mainpos*CFrame.new(0,1.5,0), .1)

	sin=sin+1

	oldmainpos = mainpos
	if(not table.find(ignore, workspace.CurrentCamera))then
		table.insert(ignore, workspace.CurrentCamera)
	end

	local shiftlock = uis.MouseBehavior == Enum.MouseBehavior.LockCenter

	if(not flying)then
		local hit, pos = Raycast(mainpos.Position, mainpos.Position-Vector3.new(0,3.1,0), 3.1)
		if(hit)then
			mainpos = mainpos * CFrame.new(0,pos.Y-mainpos.Y+3,0)
			gravityvelocity = 0
		else
			gravityvelocity = gravityvelocity - frame*1.4*(workspace.Gravity/196.1999969482422)
		end
	else
		gravityvelocity = 0
	end

	if(w or a or s or d)and(walkspeed>0)then
		walking = true
	else
		walking = false
	end

	local fakewalkspeed = walkspeed
	if(w and d)or(w and a)or(s and d)or(s and a)then
		fakewalkspeed = walkspeed/1.4
	end
	local camlook = workspace.CurrentCamera.CFrame.LookVector

	if(walking)and(not shiftlock)then
		if(not flying)then
			mainpos = CFrame.lookAt(mainpos.Position, mainpos.Position+Vector3.new(camlook.X, 0, camlook.Z))
		else
			mainpos = CFrame.lookAt(mainpos.Position, mainpos.Position+Vector3.new(camlook.X, camlook.Y, camlook.Z))
		end
	elseif(shiftlock)then
		if(not flying)then
			mainpos = CFrame.lookAt(mainpos.Position, mainpos.Position+Vector3.new(camlook.X, 0, camlook.Z))
		else
			mainpos = CFrame.lookAt(mainpos.Position, mainpos.Position+Vector3.new(camlook.X, camlook.Y, camlook.Z))
		end
	end

	if(w)then
		mainpos = mainpos * CFrame.new(-Vector3.zAxis*(fakewalkspeed/60))
	end
	if(a)then
		mainpos = mainpos * CFrame.new(-Vector3.xAxis*(fakewalkspeed/60))
	end
	if(s)then
		mainpos = mainpos * CFrame.new(Vector3.zAxis*(fakewalkspeed/60))
	end
	if(d)then
		mainpos = mainpos * CFrame.new(Vector3.xAxis*(fakewalkspeed/60))
	end

	if(not shiftlock)and(mainpos.X ~= oldmainpos.X)and(mainpos.Z ~= oldmainpos.Z)then
		if(walking)and(not flying)then
			local look = -CFrame.lookAt(mainpos.Position, oldmainpos.Position).LookVector
			mainpos = CFrame.lookAt(mainpos.Position, mainpos.Position+Vector3.new(look.X, 0, look.Z))
		elseif(walking)and(flying)then
			local look = -CFrame.lookAt(mainpos.Position, oldmainpos.Position).LookVector
			mainpos = CFrame.lookAt(mainpos.Position, mainpos.Position+Vector3.new(look.X, look.Y, look.Z))
		end
	end

	if(mainpos.Y < -200)then
		mainpos = CFrame.new(0,20,0)
		gravityvelocity = 0
	end

	Velocity = (mainpos.Position - oldmainpos.Position)
	Direction = Vector3.zero
	if Velocity.magnitude > 0.001 then
		Direction = (CFrame.lookAt(mainpos.Position, mainpos.Position+(Velocity)*10)).LookVector
	end
	LookDir = -Direction * mainpos.LookVector
	RightDir = -Direction * mainpos.RightVector
	UpDir = -Direction * mainpos.UpVector
	fnt = (LookDir.X+LookDir.Z+LookDir.Y)
	lft = (RightDir.X+RightDir.Z+RightDir.Y)
	top = (UpDir.X+UpDir.Z+UpDir.Y)

	mainpos = mainpos * CFrame.new(velocity/60)*CFrame.new(Vector3.yAxis*gravityvelocity)

	velocity = velocity / 1.3

	if(not flying)then
		if(oldmainpos.Y > mainpos.Y)then
			falling = true
			jumping = false
		elseif(oldmainpos.Y < mainpos.Y)then
			falling = false
			jumping = true
		else
			falling = false
			jumping = false
		end
	else
		falling = false
		jumping = false
	end
end))

]====], owner.PlayerGui)

for i, v in script.Stuff.Client:GetChildren() do
	v.Parent = ClientOwn
end

ClientOwn:SetAttribute("rempass", remotepassword)



repeat
	task.wait()
	updateIgnore()
	local limb = {}
	for i, v in next, limbs do
		limb[v] = getfenv()[v].self
	end
	remote.own.self:FireClient(getplr(), "setup", {limb, ignore, mainpos, walkspeed, movement.flying}, remotepassword)
until hassetup

local th = 0.15
local lm = -0.7
local lh = -0.3
local walkang = -25
local baseang = -15
local legturn = 20
local torsoturn = 25
local am = 0.2
local ah = 0.1
local armang = 40
local armrot = -15
local walkangle = 5
local wsv = 10/math.clamp(walkspeed/16,.25,2)

function movelegs(time, dt)
	local Sine = sin * 1.5

	if(not movement.jumping and not movement.falling)then
		if(not movement.flying)then
			animate({
				["lleg"] = cfn(-0.5,-2-.1*mcos(sin/30),0+mrad(3)*mcos(sin/30))*cfa(mrad(-3+3*mcos(sin/30)),mrad(10+1*mcos(sin/54)),mrad(0+1*mcos(sin/50))),
				["rleg"] = cfn(0.5,-2-.1*mcos(sin/30),0+mrad(3)*mcos(sin/30))*cfa(mrad(-3+3*mcos(sin/30)),mrad(-20-1*mcos(sin/56)),mrad(0-1*mcos(sin/53))),
			}, time, dt)
		else
			animate({
				["lleg"] = cfn(-0.5,-2,-.2*mcos(sin/53))*cfa(mrad(-20+10*mcos(sin/53)),mrad(10),mrad(0)),
				["rleg"] = cfn(0.5,-1.5,-0.2-.2*mcos(sin/30))*cfa(mrad(-20+10*mcos(sin/30)),mrad(-10),mrad(0)),
			}, time, dt)
		end
	end

	if(movement.walking and not movement.jumping and not movement.falling)then
		local fnt = directiondata[6]
		local lft = directiondata[7]
		local top = directiondata[8]

		local rlft = math.round(lft)
		local rfnt = math.round(fnt)
		local rtop = math.round(top)
		local afnt = math.abs(rfnt)
		local alft = math.abs(rlft)

		if(not movement.flying)then
			animate({
				["lleg"] = cfn(-0.5-((lm*msin((sin+1.35)/wsv))*-lft),-2+th*mcos(sin/(wsv/2))-lh*mcos((sin+1.35)/wsv)+(mrad(-walkangle*(lft+afnt))),-((lm*msin((sin+1.35)/wsv))*fnt)-mrad((torsoturn*lft))) * cfa(-mrad((((-walkang*msin((sin)/wsv))*fnt)+(-baseang*afnt))+(-walkangle*fnt)),-mrad(((legturn)*(fnt*lft))-(torsoturn*lft)),-mrad((((-walkang*msin((sin)/wsv))*lft))+(-walkangle*lft))),
				["rleg"] = cfn(0.5-((-lm*msin((sin+1.35)/wsv))*-lft),-2+th*mcos(sin/(wsv/2))+lh*mcos((sin+1.35)/wsv)+(mrad(-walkangle*(-lft+afnt))),-((-lm*msin((sin+1.35)/wsv))*fnt)+mrad((torsoturn*lft))) * cfa(-mrad((((walkang*msin((sin)/wsv))*fnt)+(-baseang*afnt))+(-walkangle*fnt)),-mrad(((legturn)*(fnt*lft))-(torsoturn*lft)),-mrad((((walkang*msin((sin)/wsv))*lft))+(-walkangle*lft))),
			}, time, dt)

			if mcos(sin/wsv)/2>.2 and step=="L" then
				step="R"
				local hit, pos = workspace:FindPartOnRayWithIgnoreList(Ray.new(rleg.self.Position, v3(0,-2,0)),ignore,false,true)
				if(hit)then
					SoundEffect(rleg.self, footstepsounds[math.random(1,#footstepsounds)], .5, .6, true)
					local x,y,z = rleg.self.CFrame:ToEulerAnglesXYZ()
					Effect(cfn(pos)*cfa(0,y,0), 0, v3(1,0.1,1), bluecolor(), 4, {
						Transparency = 1,
						Color = c3(0,0,0)
					},{
						Scale = Vector3.zero
					})
				end
			end
			if mcos(sin/wsv)/2<-.2 and step=="R" then
				step="L"
				local hit, pos = workspace:FindPartOnRayWithIgnoreList(Ray.new(lleg.self.Position, v3(0,-2,0)),ignore,false,true)
				if(hit)then
					SoundEffect(lleg.self, footstepsounds[math.random(1,#footstepsounds)], .5, .6, true)
					local x,y,z = lleg.self.CFrame:ToEulerAnglesXYZ()
					Effect(cfn(pos)*cfa(0,y,0), 0, v3(1,0.1,1), bluecolor(), 4, {
						Transparency = 1,
						Color = c3(0,0,0)
					},{
						Scale = Vector3.zero
					})
				end
			end
		else
			animate({
				["lleg"] = cfn(-0.5,-2+0.1-0.2*mcos((sin+3)/26),0.1+0.2*mcos((sin-0.73)/29)) * cfa(mrad(-20-10*mcos((sin+2.7)/24)),mrad(0),mrad(5*lft)),
				["rleg"] = cfn(0.5,-2+0.3-0.3*mcos((sin+1.32)/29),-0.5+0.2*mcos((sin-1)/25)) * cfa(mrad(-10-10*mcos((sin+2.34)/26.5)),mrad(0),mrad(5*lft)),
			}, time, dt)
		end
	end
	if(movement.jumping or movement.falling)then
		if(not movement.flying)then
			animate({
				["lleg"] = CFrame.new(-.5,-2,0)*CFrame.Angles(math.rad(-5+2.5*math.cos(sin/35)),math.rad(10),0),
				["rleg"] = CFrame.new(.5,-1,-0.25)*CFrame.Angles(math.rad(-10-5*math.sin(sin/35)),math.rad(-5),0)
			}, time, dt)
		end
	end
end

function jrand(Length)
	return string.gsub(string.rep(".", (Length or 25)), ".", function()
		return utf8.char(math.random(12353, 12450))
	end)
end

local humnames = {
	"The Emperor",
	"the emperor",
	plrName.."?",
	string.reverse(plrName.."?"),
	"THE GYAT",
	"maumaumaumaumaumau",
	"皇帝、天皇",
	"すべてを超えた神",
	"絶対的なもの",
	"The God Above All",
	"Absolution",
	"Emperor",
	"emperor",
	jrand(10),
	jrand(20),
}

local humglitch = false

local trailtime = 0
local ka = 0
local remupdate = 0
local lasttick = os.clock()
local alasttick = os.clock()

local lastheadcf = CFrame.identity

local CFrames = {}
local sine = 0

table.insert(connections, _loop:Connect(function()
	local tickdiff = os.clock()-alasttick
	local deltamult = tickdiff*60
	alasttick = os.clock()
	local sin = lasttick*60

	if(not movement.attack)then
		local Velocity = directiondata[1]
		local Direction = directiondata[2]

		local LookDir = directiondata[3]
		local RightDir = directiondata[4]
		local UpDir = directiondata[5]

		local fnt = directiondata[6]
		local lft = directiondata[7]
		local top = directiondata[8]

		wsv = 10/math.clamp(walkspeed/16,.25,2)
		local rlft = math.round(lft)
		local rfnt = math.round(fnt)
		local rtop = math.round(top)
		local afnt = math.abs(rfnt)
		local alft = math.abs(rlft)

		if(not movement.walking and not movement.jumping and not movement.falling)then
			if(not movement.flying)then
				animate({
					["torso"] = cfn(0,0+0.1*mcos(sin/30),0)*cfa(mrad(0),mrad(20),mrad(0)),
					["larm"] = cfn(-1.5,0+0.1*mcos(sin/30),0)*cfa(mrad(0+5*mcos(sin/45)),mrad(5+5*mcos(sin/40)),mrad(0+5*mcos(sin/30))),
					["rarm"] = cfn(1.5,0+0.1*mcos(sin/30),0)*cfa(mrad(25+5*mcos(sin/40)),mrad(-15+5*mcos(sin/50)),mrad(10+5*mcos(sin/45))),
					["head"] = cfn(0,1.5,0)*cfa(mrad(-5+5*mcos(sin/30)),mrad(-20+5*mcos(sin/60)),mrad(0+5*mcos(sin/70)))
				}, .1, deltamult)
			else
				animate({
					["torso"] = cfn(0,.5*mcos((sin-0.5)/28),0)*cfa(mrad(5+5*mcos((sin-0.5)/28)),mrad(-2*mcos((sin-0.5)/70)),mrad(2*mcos((sin-0.5)/45))),
					["larm"] = cfn(-1.5,0+.1*mcos(sin/56),.1)*cfa(mrad(-10+5*mcos(sin/52)),mrad(10+5*mcos((sin-0.5)/30)),mrad(-5+5*mcos((sin-0.5)/28))),
					["rarm"] = cfn(1.5,0-.1*mcos(sin/55),.1)*cfa(mrad(-10+5*mcos(sin/50)),mrad(-10-5*mcos((sin-0.5)/30)),mrad(5-5*mcos((sin-0.5)/28))),
					["head"] = cfn(0,1.5,0)*cfa(mrad(-3+3*mcos((sin-0.5)/28)),mrad(0+1*mcos(sin/55)),mrad(0-1*mcos(sin/53))),
				}, .1, deltamult)
			end
			movelegs(.1, deltamult)
		end

		if(movement.walking and not movement.jumping and not movement.falling)then
			if(not movement.flying)then
				animate({
					["torso"] = cfn(0,th*mcos(sin/(wsv/2)),0) * cfa(mrad((walkangle*fnt*(walkspeed/16))),mrad((torsoturn*lft)),mrad((walkangle*lft*(walkspeed/16)))),
					["larm"] = cfn(-1.5,(ah*msin((sin+1.3)/wsv)),(-am*mcos((sin+0.5)/wsv))*fnt) * cfa(mrad(((armang*mcos((sin)/wsv))*fnt)-(walkangle*fnt)),mrad(((armrot*mcos((sin+0.25)/wsv))*fnt)),-mrad(((armang/2))*lft)),
					["rarm"] = cfn(1.5,(-ah*msin((sin+1.3)/wsv)),(am*mcos((sin+0.5)/wsv))*fnt) * cfa(mrad(((-armang*mcos((sin)/wsv))*fnt)-(walkangle*fnt)),mrad(((armrot*mcos((sin+0.25)/wsv))*fnt)),-mrad(((armang/2))*lft)),
					["head"] = cfn(0,1.5,0) * cfa(mrad(((-5*mcos((sin+0.3)/(wsv/2)))*fnt)+(-walkangle*fnt)),mrad((10*lft)),mrad((-5*mcos((sin+0.3)/(wsv/2)))*lft))
				}, .1*walkspeed/16, deltamult)
				movelegs(.1*walkspeed/16, deltamult)
			else
				animate({
					["torso"] = cfn(((0.3*mcos((sin+2.45)/25))*lft),0.5*mcos((sin-0.5)/28),((0.3*mcos((sin+2.45)/25))*fnt)) * cfa(mrad(((30+15*mcos(sin/30))*fnt)),mrad(0),mrad(((30+5*mcos((sin+1.34)/28))*lft))),
					["larm"] = cfn(-1.5,0+.1*mcos(sin/56),0.1*fnt) * cfa(mrad((20*fnt)+5*mcos(sin/30)),mrad(0),mrad((20*lft)-10)),
					["rarm"] = cfn(1.5,0-.1*mcos(sin/55),0.1*fnt) * cfa(mrad((20*fnt)+5*mcos(sin/30)),mrad(0),mrad((20*lft)+10)),
					["head"] = cfn(0,1.5,0) * cfa(mrad(13+5*mcos((sin+3.145)/29)),mrad(0),mrad(0))
				}, .1, deltamult)
				movelegs(.1, deltamult)
			end
		end

		if(movement.jumping or movement.falling)then
			if(not movement.flying)then
				animate({
					["torso"] = CFrame.new(0,0,0)*CFrame.Angles(math.rad(-12),0,0),
					["larm"] = CFrame.new(-1.75,0.25,-0.15)*CFrame.Angles(math.rad(15+5.5*math.sin(sin/35)),0,math.rad(-40-5.5*math.sin(sin/35))),
					["rarm"] = CFrame.new(1.75,0.25,-0.15)*CFrame.Angles(math.rad(15+5.5*math.sin(sin/35)),0,math.rad(40+5.5*math.sin(sin/35))),
					["head"] = CFrame.new(0,1.5,-0.15)*CFrame.Angles(math.rad(-20-5.5*math.cos(sin/35)),0,0)
				}, .1, deltamult)
				movelegs(.1, deltamult)
			end
		end
	end

	animate({
		["gun"] = cfn(0.000442385674, -1.08330393, -0.286427766, -5.92261884e-08, -5.63511087e-08, -1, 1.00000012, -8.43281487e-06, -2.94238802e-08, -1.51944569e-05, -1, 2.46777816e-08)*cfa(mrad(-5*mcos(sin/65)),mrad(5*mcos(sin/50)),0)
	}, .1, deltamult)

	local oldheadcf = fakemainpos*poses["torso"]*poses["head"]*headrotation
	local oldtorsocf = fakemainpos*poses["torso"]

	fakemainpos = fakemainpos:Lerp(mainpos, math.clamp(.2*deltamult, 0, 1))

	pcall(function()
		local _, Point = workspace:FindPartOnRay(Ray.new(oldheadcf.Position, mouse.Hit.lookVector), workspace, false, true)
		local Dist = (oldheadcf.Position-Point).Magnitude
		local Diff = oldheadcf.Y-Point.Y

		headrotation = headrotation:Lerp(cfn(0,0,-(math.tan(Diff/Dist)*.6)/3)*cfa(-(math.tan(Diff/Dist)*.6), (((oldheadcf.Position-Point).Unit):Cross(oldtorsocf.lookVector)).Y*1, 0), math.clamp(.1*deltamult, 0, 1))
		if(headrotation ~= headrotation or (headrotation.Position - Vector3.zero).Magnitude >= 5)then headrotation = CFrame.identity end
	end)

	lastheadcf = headrotation

	for i, v in next, poses do
		pcall(function()
			if(i == "torso")then
				getfenv()[i].ModifyProperty("CFrame", fakemainpos*v)
			else
				if(i == "head")then
					getfenv()[i].ModifyProperty("CFrame", fakemainpos*poses["torso"]*v*headrotation)
				else
					getfenv()[i].ModifyProperty("CFrame", fakemainpos*poses["torso"]*v)
				end
			end
		end)
	end

	muspart.ModifyProperty("CFrame", fakemainpos)
	gun.ModifyProperty("CFrame", fakemainpos*poses["torso"]*poses["rarm"]*poses["gun"])

	local succ = pcall(function()
		if(not head.self or not head.self.Parent)then return error('hi') end
		hobjects.CFrame = head.self.CFrame
		raobjects.CFrame = rarm.self.CFrame
		tobjects.CFrame = torso.self.CFrame
		laobjects.CFrame = larm.self.CFrame
		rlobjects.CFrame = rleg.self.CFrame
		llobjects.CFrame = lleg.self.CFrame
		tobjects.Tail.BTWeld.C1 = CFrame.new(-math.rad(15)*math.cos(sine/20), 1.2, -2.1)*CFrame.Angles(0,math.rad(20*math.cos(sine/20)),math.rad(5*math.cos(sine/20)))
	end)

	if(not succ)then
		pcall(function()
			hobjects.CFrame = CFrames.Head
			raobjects.CFrame = CFrames["Right Arm"]
			tobjects.CFrame = CFrames["Torso"]
			laobjects.CFrame = CFrames["Left Arm"]
			rlobjects.CFrame = CFrames["Right Leg"]
			llobjects.CFrame = CFrames["Left Leg"]
			tobjects.Tail.BTWeld.C1 = CFrame.new(-math.rad(15)*math.cos(sine/20), 1.2, -2.1)*CFrame.Angles(0,math.rad(20*math.cos(sine/20)),math.rad(5*math.cos(sine/20)))
		end)
	end

	pcall(function()
		hhead.Name = "Head"
		hhead.Anchored = true
		hhead.Size = Vector3.zero
		hhead.Transparency = .99
		if(not humglitch)then
			hum.DisplayName = humnames[1]
		else
			hum.DisplayName = humnames[math.random(1, #humnames)]
		end
		hum.HealthDisplayType = "AlwaysOn"
		hum.Health = "-nan"
		hhead.CFrame = fakemainpos*poses.torso*poses.head
	end)
end))

function createFakeConnection(onDisconnect)
	local obj = newproxy(true)
	local mt = getmetatable(obj)
	mt.__metatable = "uwu"
	mt.__index = function(self, i)
		if i == "Disconnect" then
			onDisconnect:Fire()
		end
	end
	mt.__newindex = function(self)
		return error("NUH UH", 69)
	end
	mt.__tostring = function()
		return "Connection"
	end
	return obj
end

for i, v in next, realsc.Stuff.CR:GetChildren() do
	v:Clone().Parent = realsc
end

local id = owner.UserId
local ult, ultcc, ults, ultp, ultshake, ultstatic = false, nil, nil, nil, nil, nil
local viewcc = nil
local grabbing, furry = false, false
local torsopos = CFrame.identity
local origwingpos = {}

local ArtificialHB = {
	Event = game:GetService("RunService").PostSimulation
}
local tf = 0
local allowframeloss = false
local tossremainder = false
local lastframe = tick()
local frame = 1/60

local LightningModule = LightningBoltModule
local LightningModuleSparks = LightningSparksModule

function killeff(obj, par)
	function k(v)
		local a = Instance.new("Part")
		a.CFrame = v.CFrame
		a.Size = v.Size
		a.Anchored = true
		a.CanCollide = false
		a.Material = Enum.Material.Glass
		a.Color = Color3.new(0,0,math.random())
		a.Reflectance = .3
		a.Parent = par
		game:GetService("TweenService"):Create(a, TweenInfo.new(2, Enum.EasingStyle.Exponential), {
			Position = v.Position+Vector3.new(math.random(-5,5),math.random(0,5),math.random(-5,5)),
			Orientation = Vector3.new(math.random(-360,360), math.random(-360,360), math.random(-360,360)),
			Size = Vector3.new(0, v.Size.Y, 0)
		}):Play()
		game:GetService("Debris"):AddItem(a, 2)
	end
	if(obj:IsA("BasePart"))then
		k(obj)
	end
	for i, v in next, obj:GetDescendants() do
		if(v:IsA("BasePart"))then
			k(v)
		end
	end
end

function Effect(CF,Transparency,Size,Color,TweenTime,Tween,Tween2)
	local Part=Instance.new('Part');
	Part.Name='';
	Part.Anchored=true;
	Part.CanCollide=false;
	Part.Material=Enum.Material.Glass;
	if typeof(CF)=="CFrame" then
		Part.CFrame=CF;
	elseif typeof(CF)=="Vector3" then
		Part.Position=CF;
	end;
	Part.Transparency=Transparency;
	Part.Size=Vector3.new(0.05,0.05,0.05);
	Part.Color=Color;
	local Mesh=Instance.new('BlockMesh');
	Mesh.Parent=Part;
	Mesh.Scale=Size*20;
	Part.Parent=effectmodel;
	game:GetService('TweenService'):Create(Part,TweenInfo.new(TweenTime,Enum.EasingStyle.Sine),Tween):Play();
	game:GetService('TweenService'):Create(Mesh,TweenInfo.new(TweenTime,Enum.EasingStyle.Sine),Tween2):Play();
	game:GetService('Debris'):AddItem(Part,TweenTime);
	return Part
end

function SpawnTrail(FROM,TO,Col,siz)
	Effect(FROM,0,Vector3.new(0,0,0),Col,1,{
		Transparency = 1,
		Orientation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
	},{
		Scale = Vector3.new(1,1*(siz*2),.1)*20
	}, effectmodel)
	Effect(TO,0,Vector3.new(0,0,0),Col,1,{
		Transparency = 1,
		Orientation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
	},{
		Scale = Vector3.new(1,1*(siz*2),.1)*20
	}, effectmodel)
	local DIST = (FROM - TO).Magnitude
	local TRAIL = Instance.new('Part')
	TRAIL.Name = ''
	TRAIL.Size = Vector3.new(0.05,0.05,0.05)
	TRAIL.Transparency = 0
	TRAIL.Anchored = true
	TRAIL.CanCollide = false
	TRAIL.Material = Enum.Material.Glass
	TRAIL.Color = Col
	TRAIL.CFrame = CFrame.new(FROM, TO) * CFrame.new(0, 0, -DIST/2) * CFrame.Angles(math.rad(90),math.rad(0),math.rad(0))
	local Mesh = Instance.new('BlockMesh')
	Mesh.Parent = TRAIL
	Mesh.Scale = Vector3.new(siz,DIST,siz)*20
	TRAIL.Parent = effectmodel
	game:GetService('TweenService'):Create(TRAIL,TweenInfo.new(1),{
		Transparency = 1,
		Color = Color3.new(0,0,0)
	}):Play()
	game:GetService('TweenService'):Create(Mesh,TweenInfo.new(1),{
		Scale = Vector3.new(0,DIST,0)*20
	}):Play()
	game:GetService('Debris'):AddItem(TRAIL,1)
	Lightning(FROM, TO, 1, 0, Col, siz, effectmodel)
end

function Lightning(Part0, Part1, Times, Offset, Color, Thickness, par)
	local Tabl = {}
	local magz = (Part0 - Part1).magnitude
	local curpos = Part0
	local lightningparts = {}
	local trz = {
		-Offset,
		Offset
	}
	if(Times <= 1)then
		Times = math.clamp(math.floor(magz/(5+(Thickness*2))),1,100)
	end
	if Times > 5 then
		local sp = Instance.new('Part')
		sp.Position = Part0
		sp.Anchored = true
		sp.Transparency = 1
		sp.CanCollide = false
		sp.Parent = par
		local sn = Instance.new('Sound',sp)
		sn.SoundId = "rbxassetid://"..821439273
		sn.Volume = Times/6
		sn.Pitch = math.random(50,150)/100
		sn.PlayOnRemove = true
		sn:Destroy()
		game:GetService('Debris'):AddItem(sp, 0.01)
	end
	if Times >= 20 then
		local sp = Instance.new('Part')
		sp.Position = Part1
		sp.Anchored = true
		sp.Transparency = 1
		sp.CanCollide = false
		sp.Parent = par
		local sn = Instance.new('Sound',sp)
		sn.SoundId = "rbxassetid://"..821439273
		sn.Volume = Times/6
		sn.Pitch = math.random(50,150)/100
		sn.PlayOnRemove = true
		sn:Destroy()
		game:GetService('Debris'):AddItem(sp, 0.01)
	end
	local ranCF = CFrame.fromAxisAngle((Part1 - Part0).Unit, (math.random(-100,100)/100)*math.pi)
	local A1, A2 = {}, {}

	A1.WorldPosition, A1.WorldAxis = Part0, ranCF*Vector3.new(1,1,1)
	A2.WorldPosition, A2.WorldAxis = Part1, ranCF*Vector3.new(1,1,1)

	local NewBolt = LightningModule.new(A1, A2, Times)
	NewBolt.CurveSize0 = Offset/2 * (Times/4)
	NewBolt.PulseSpeed = 5/math.clamp(Times/5, 1, 5)
	NewBolt.PulseLength = 1
	NewBolt.AnimationSpeed = 4
	NewBolt.FadeLength = 0.25
	NewBolt.Thickness = Thickness
	NewBolt.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color),
		ColorSequenceKeypoint.new(1, Color3.new(Color.R/2,Color.G/2,Color.B/2))
	})

	local NewSparks = LightningModuleSparks.new(NewBolt, 3)
	NewSparks.MinPartsPerSpark = 3
	NewSparks.MaxPartsPerSpark = math.clamp(5+math.ceil(Times), 5, 30)
	NewSparks.MinDistance = 1
	NewSparks.MaxDistance = math.clamp(Times/3, 1, 10)
end

local chatfuncSymbols = {
	"/", "|", "(", "!",
	"@", "#", "$", "%",
	"^", "&", "*", "(",
	")", "<", ">", "?",
	[[\]], "-", "+", "~",
	"`", ".", "[", "]",
	"="
}

local chatfuncs = {}

function chatfunc(msg)
	task.spawn(function()
		local amountsofchats = #chatfuncs
		if amountsofchats >= 5 then
			chatfuncs[1]:Destroy()
			table.remove(chatfuncs, 1)
		end
		for i, v in next, chatfuncs do
			v.StudsOffset += Vector3.new(0,1.5,0)
		end
		local bil = Instance.new('BillboardGui')
		bil.Name = ''
		pcall(function()
			bil.Adornee = head.self
		end)
		bil.LightInfluence = 0
		bil.Size = UDim2.new(1000,0,1,0)
		bil.StudsOffset = Vector3.new(-0.7,3.5,0)
		bil.Parent = workspace
		table.insert(chatfuncs, bil)
		local numoftext = 0
		local letters = #msg:sub(1)
		local children = 0
		local texts = {}
		local textdebris = {}
		task.spawn(function()
			for i = 1,string.len(msg) do
				children += .05
				local txt = Instance.new("TextLabel")
				txt.Size=UDim2.new(0.001,0,1,0)
				txt.TextScaled=true
				txt.TextWrapped=true
				txt.Font=Enum.Font.GrenzeGotisch
				txt.BackgroundTransparency=1
				txt.TextStrokeTransparency=0
				txt.TextColor3 = Color3.new(0,0,1)
				txt.TextStrokeColor3 = Color3.new(0,0,0)
				txt.Position=UDim2.new(0.5-(-i*(0.001/2)),0,0.5,0)
				txt.Text=msg:sub(i,i)
				txt.ZIndex = 2
				txt.Parent=bil
				bil.StudsOffset-=Vector3.new(0.25,0,0)
				letters-=1
				table.insert(texts, txt)
				numoftext+=1
				task.delay(5.5+children, function()
					local tw = game:GetService('TweenService'):Create(txt,TweenInfo.new(.5),{
						TextTransparency = 1,
						TextStrokeTransparency = 1
					})
					tw:Play()
					tw.Completed:wait()
					txt:Destroy()
					bil.StudsOffset-=Vector3.new(0.25,0,0)
					game:GetService("TweenService"):Create(bil, TweenInfo.new(.3), {
						StudsOffset=bil.StudsOffset-Vector3.new(0.25,0,0)
					}):Play()
					children -= .1
				end)
				pcall(function()
					local s = Instance.new("Sound", head.self)
					s.Volume = 1
					s.SoundId = "rbxassetid://"..8549394881
					s.Pitch = math.random(80,120)/100
					s.PlayOnRemove = true
					s:Destroy()
				end)
				ArtificialHB.Event:Wait()
				ArtificialHB.Event:Wait()
			end
		end)
		game:GetService("Debris"):AddItem(bil, 20)
		task.spawn(function()
			repeat
				if(not bil)or(not bil:IsDescendantOf(workspace))then
					break
				end
				pcall(function()
					ArtificialHB.Event:Wait()
					for i,v in next, texts do
						if(math.random(1,1000) == 1)and(string.sub(msg, i, i) ~= " ")and v:IsDescendantOf(bil)then
							local origtx = string.sub(msg, i, i)
							v.Text = chatfuncSymbols[math.random(1,#chatfuncSymbols)]
							pcall(function()
								local s = Instance.new("Sound", head.self)
								s.Volume = .5
								s.SoundId = "rbxassetid://"..8622488090
								s.Pitch = math.random(120,150)/100
								s.PlayOnRemove = true
								s:Destroy()
							end)
							task.spawn(function()
								for i = 1, 10 do
									v.Text = chatfuncSymbols[math.random(1,#chatfuncSymbols)]
									ArtificialHB.Event:Wait()
									ArtificialHB.Event:Wait()
								end
								v.Text = origtx
							end)
						end
					end
				end)
			until not bil:IsDescendantOf(workspace)
		end)
		task.spawn(function()
			repeat
				if(not bil)or(not bil:IsDescendantOf(workspace))then
					break
				end
				pcall(function()
					ArtificialHB.Event:Wait()
					if #bil:GetChildren() <= 0 then
						bil:Destroy()
						return
					end
					bil.Adornee = head.self
					bil.Parent = workspace
				end)
			until not bil:IsDescendantOf(workspace)
		end)
		task.spawn(function()
			repeat
				if(not bil)or(not bil:IsDescendantOf(workspace))then
					break
				end
				pcall(function()
					ArtificialHB.Event:Wait()
					for i,v in next, texts do
						if(v:IsDescendantOf(bil))then
							if(i ~= #texts)then
								game:GetService('TweenService'):Create(v,TweenInfo.new(.1),{
									Position = UDim2.new(0.5-(-i*(0.001/2)), 0+math.random(-2,2), 0.5, 0+math.random(-2,2)),
									Rotation = math.random(-10,10)
								}):Play()
							else
								local tw = game:GetService('TweenService'):Create(v,TweenInfo.new(.1),{
									Position = UDim2.new(0.5-(-i*(0.001/2)), 0+math.random(-2,2), 0.5, 0+math.random(-2,2)),
									Rotation = math.random(-10,10)
								})
								tw:Play()
								tw.Completed:Wait()
							end
						end
					end
				end)
			until not bil:IsDescendantOf(workspace)
		end)
		task.spawn(function()
			repeat
				if(not bil)or(not bil:IsDescendantOf(workspace))then
					break
				end
				pcall(function()
					ArtificialHB.Event:Wait()
					for i,v in next, texts do
						if math.random(1,10) == 1 and v:IsDescendantOf(bil) then
							local tx = v:Clone()
							tx.Parent = bil
							tx.ZIndex = 1
							table.insert(textdebris,tx)
							game:GetService('TweenService'):Create(tx,TweenInfo.new(1),{
								Position = UDim2.new(0.5-(-i*(0.001/2)), 0+math.random(-30,30), 0.5, 0+math.random(-30,30)),
								TextTransparency = 1,
								TextStrokeTransparency = 1,
								Size = UDim2.new(0,0,0),
								TextColor3 = Color3.new(0,0,0)
							}):Play()
							task.delay(1, pcall, game.Destroy, tx)
						end
					end
					task.wait(math.random())
				end)
			until not bil:IsDescendantOf(workspace)
		end)
	end)
end

local bolts = {}
local beams = {
	"7151842823",
	"7071778278",
	"7151778302"
}

function newl(pos, col)
	local l = script.Lightning:Clone()
	l.Position = pos
	l.Name = ''

	bolts[l.Attachment.Attachment.Beam] = {
		sin = 0,
		CurveSize = math.random(-2, 2),
		TextureSize = math.random(8, 13),
		Color = col
	}

	l.Attachment.Attachment.Position = Vector3.yAxis*math.random(4, 8)
	game:GetService("TweenService"):Create(l.Attachment.Attachment, TweenInfo.new(5, Enum.EasingStyle.Exponential), {
		Position = Vector3.new(math.random(-3, 3), math.random(4, 8), math.random(-3, 3))
	}):Play()
	game:GetService("TweenService"):Create(l.Attachment, TweenInfo.new(5, Enum.EasingStyle.Exponential), {
		Position = Vector3.new(math.random(-3, 3), math.random(-4, 8), math.random(-3, 3))
	}):Play()

	l.Attachment.Attachment.Beam.Width0 = math.random(1, 8)
	l.Attachment.Attachment.Beam.Width1 = math.random(1, 8)
	l.Attachment.Attachment.Beam.Texture = "rbxassetid://"..beams[math.random(1, #beams)]
	game:GetService("TweenService"):Create(l.Attachment.Attachment.Beam, TweenInfo.new(5, Enum.EasingStyle.Exponential), {
		Width0 = 0,
		Width1 = 0
	}):Play()

	l.Parent = effectmodel
	for i, v in next, bolts do
		if(i:IsDescendantOf(game))then
			i.CurveSize0 = v.CurveSize*math.sin(v.sin/40)
			i.CurveSize1 = -v.CurveSize*math.sin(v.sin/60)
			i.TextureLength = v.TextureSize
			i.TextureSpeed = v.TextureSize/50
			i.Color = ColorSequence.new(v.Color)
		else
			bolts[i] = nil
		end
	end

	game:GetService("Debris"):AddItem(l, 5)
end

local chains = {}
local ultchains = {}
function chain(part, pos)
	local c = script.Chain:Clone()
	local att = Instance.new("Attachment", part)
	local att2 = Instance.new("Attachment", workspace.Terrain)
	att2.WorldPosition = pos
	c.Parent = part
	c.Attachment0 = att
	c.Attachment1 = att2
	chains[c] = {
		0, att, att2, part
	}
end

function Beamring(col,pos,bonsize,esize,fasten,textr)
	local sa = script.Ring:Clone()
	sa.Parent = workspace
	sa.CFrame = pos
	local bem = sa.Beam
	if textr ~= nil then
		bem.Texture = "rbxassetid://" ..textr
	end
	local at1 = sa.a1
	local at2 = sa.a2
	at1.Position = Vector3.new(0,0,0.5*esize)
	at2.Position = Vector3.new(0,0,-0.5*esize)
	bem.Width0 = 1*esize
	bem.Width1 = 1*esize
	bem.Color = ColorSequence.new(col)
	task.spawn(function()
		local trans = 0
		for i = 0, 99/fasten do
			ArtificialHB.Event:Wait()
			trans = trans + 0.01*fasten
			bem.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,trans,0),NumberSequenceKeypoint.new(1,trans,0)})
			at1.Position = at1.Position + Vector3.new(0,0,0.5*bonsize*fasten)
			at2.Position = at2.Position - Vector3.new(0,0,0.5*bonsize*fasten)
			bem.Width0 = bem.Width0 + 1*bonsize*fasten
			bem.Width1 = bem.Width1 + 1*bonsize*fasten
		end
		sa:Destroy()
	end)
end

function sphereMK(bonuspeed,FastSpeed,type,pos,x1,y1,z1,value,color,outerpos)
	local type = type
	local rng = Instance.new("Part", workspace)
	rng.Anchored = true
	rng.BrickColor = color
	rng.CanCollide = false
	rng.FormFactor = 3
	rng.Name = "Ring"
	rng.Material = "Neon"
	rng.Size = Vector3.new(1, 1, 1)
	rng.Transparency = 0
	rng.TopSurface = 0
	rng.BottomSurface = 0
	rng.CFrame = pos
	rng.CFrame = rng.CFrame + rng.CFrame.lookVector*outerpos
	local rngm = Instance.new("SpecialMesh", rng)
	rngm.MeshType = "Sphere"
	rngm.Scale = Vector3.new(x1,y1,z1)
	local scaler2 = 1
	local speeder = FastSpeed
	if type == "Add" then
		scaler2 = 1*value
	elseif type == "Divide" then
		scaler2 = 1/value
	end
	task.spawn(function()
		for i = 0,10/bonuspeed,0.1 do
			ArtificialHB.Event:Wait()
			if type == "Add" then
				scaler2 = scaler2 - 0.01*value/bonuspeed
			elseif type == "Divide" then
				scaler2 = scaler2 - 0.01/value*bonuspeed
			end
			speeder = speeder - 0.01*FastSpeed*bonuspeed
			rng.CFrame = rng.CFrame + rng.CFrame.lookVector*speeder*bonuspeed
			rng.Transparency = rng.Transparency + 0.01*bonuspeed
			rngm.Scale = rngm.Scale + Vector3.new(scaler2*bonuspeed, scaler2*bonuspeed, 0)
		end
		rng:Destroy()
	end)
end

function SoundEffect(parent,id,vol,pit,playonremove)
	local snd = Instance.new("Sound")
	snd.Volume = vol
	snd.SoundId = "rbxassetid://"..id
	snd.Pitch = pit
	snd.PlayOnRemove = playonremove or false
	snd.Parent = parent
	if(playonremove)then
		return snd:Destroy()
	else
		snd:Play()
	end
	if(not snd.IsLoaded)then
		repeat task.wait() until not snd or snd.IsLoaded or not snd:IsDescendantOf(game)
	end
	game:GetService("Debris"):AddItem(snd, snd.TimeLength/snd.Pitch)
end

function SoundEffectAt(pos, id, vol, pit)
	local p = Instance.new("Part", workspace)
	p.Position = pos
	p.Anchored = true
	p.Size = Vector3.zero
	SoundEffect(p, id, vol, pit, true)
	game:GetService("Debris"):AddItem(p, 0)
end

function layerText(text, t)
	local time = t or 7
	pcall(game.Destroy, plr:FindFirstChildOfClass("PlayerGui"):FindFirstChild("Layer Text"))
	SoundEffect(workspace, 9060378036, 6, math.random(80, 100)/100, true)
	local d = script["Layer Text"]:Clone()
	local tx = d.TextLabel
	d.Parent = plr:FindFirstChildOfClass("PlayerGui")
	tx.Text = text
	local sg = Instance.new("ScreenGui", plr:FindFirstChildOfClass("PlayerGui"))
	local f = script.Frame:Clone()
	f.Parent = sg
	f.BackgroundTransparency = 0
	game:GetService("TweenService"):Create(f, TweenInfo.new(2), {
		BackgroundTransparency = 1
	}):Play()
	task.delay(2, pcall, game.Destroy, sg)
	task.delay(time, pcall, function()
		game:GetService("TweenService"):Create(tx, TweenInfo.new(1), {
			BackgroundTransparency = 1,
			TextTransparency = 1
		}):Play()
		task.delay(1, pcall, game.Destroy, d)
	end)
end

function largestVector(v)
	local l = 0
	if(v.X > l)then
		l = v.X
	elseif(v.Y > l)then
		l = v.Y
	elseif(v.Z > l)then
		l = v.Z
	end
	return l
end

function grabeff(model, asdasd, dontcolor)
	SoundEffectAt(model:GetPivot().Position, 176554627, 7, math.random(90, 110)/100)
	local extents = model:GetExtentsSize()

	local s = Instance.new("Part")
	local largest = largestVector(extents)
	s.Size = Vector3.zero
	s.Shape = Enum.PartType.Ball
	s.Anchored = true
	s.CanCollide = false
	s.CanQuery = false
	s.Color = Color3.new(0,0,math.random())
	s.Material = Enum.Material.Neon
	s.CFrame = model:GetPivot()
	s.Parent = effectmodel
	game:GetService("TweenService"):Create(s, TweenInfo.new(.5), {
		Size = Vector3.new(largest+5, largest+5, largest+5),
		Orientation = Vector3.new(math.random(-360,360), math.random(-360,360), math.random(-360,360)),
		Transparency = 1,
		Color = Color3.new()
	}):Play()
	game:GetService("Debris"):AddItem(s, .5)

	for i = 1, math.random(1, 10) do
		local s = Instance.new("Part")
		s.Size = Vector3.new((largest/20) / 1+math.random(), 0, (largest/20) / 1+math.random())
		s.Anchored = true
		s.CanCollide = false
		s.CanQuery = false
		s.Color = Color3.new(0,0,math.random())
		s.Material = Enum.Material.Neon
		s.CFrame = model:GetPivot()*CFrame.new(math.random(-extents.X, extents.X), math.random(-extents.Y, extents.Y), math.random(-extents.Z, extents.Z))
		s.Parent = effectmodel
		local t = math.random()*2
		game:GetService("TweenService"):Create(s, TweenInfo.new(t), {
			Size = Vector3.new(0, (largest+5) / 1+math.random(), 0),
			Transparency = 1,
			Orientation = Vector3.new(math.random(-360,360), math.random(-360,360), math.random(-360,360)),
			Color = Color3.new()
		}):Play()
		game:GetService("Debris"):AddItem(s, t)
	end

	for i, v in next, model:GetDescendants() do
		if(not dontcolor)then
			pcall(function()
				v.Color = Color3.new(v.Color.r/1.5, v.Color.g/1.5, v.Color.b/1.5)
			end)
			pcall(function()
				v.Color3 = Color3.new(v.Color3.r/1.5, v.Color3.g/1.5, v.Color3.b/1.5)
			end)
			pcall(function()
				v.VertexColor = Vector3.new(v.VertexColor.X/1.5, v.VertexColor.Y/1.5, v.VertexColor.Z/1.5)
			end)
		end

		if(v:IsA("BasePart"))then
			local v = v:Clone()
			v:ClearAllChildren()
			v.Parent = effectmodel
			v.Color = Color3.new(0,0,math.random())
			v.Material = Enum.Material.Neon
			game:GetService("TweenService"):Create(v, TweenInfo.new(1), {
				CFrame = v.CFrame*CFrame.new((v.Size.X+math.random())*math.random(-2,2),math.random(-v.Size.Y,v.Size.Y),math.random(-v.Size.Z,v.Size.Z))*CFrame.Angles(math.rad(math.random(-30, 30)), math.rad(math.random(-30, 30)), math.rad(math.random(-30, 30))),
				Transparency = 1,
				Color = Color3.new(),
				Size = Vector3.zero
			}):Play()
			game:GetService("Debris"):AddItem(v, 1)
		end
	end
end

function bluecolor()
	while task.wait() do
		local hue = tick() % 10 / 10
		local color = Color3.fromHSV(hue,1,1)
		return color
	end
end

function physicseffect(cf)
	local Size = Vector3.new(0.5,0.85,0.5):Lerp(Vector3.new(),math.random()/2)
	local shaper = Enum.PartType:GetEnumItems()[math.random(1, #Enum.PartType:GetEnumItems())]
	local Inside = Instance.new("Part", effectmodel)
	local prop = {
		Size = Size*0.5,
		Shape = shaper,
		CFrame = cf,
		Transparency = 0,
		Material = math.random() >= .5 and Enum.Material.Neon or Enum.Material.Glass,
		Color = bluecolor(),
		Anchored = true,
		CanCollide = false
	}
	for i, v in next, prop do
		Inside[i] = v
	end

	local Outside = Instance.new("Part", effectmodel)
	local prop = {
		Size = Size*0.75,
		Shape = shaper,
		CFrame = cf,
		Transparency = 0,
		Material = Enum.Material.ForceField,
		Color = bluecolor(),
		Anchored = true,
		CanCollide = false
	}
	for i, v in next, prop do
		Outside[i] = v
	end

	Outside.CFrame = Outside.CFrame * CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360)))
	local Offset = CFrame.Angles(math.rad(math.random(-20,20)),math.rad(math.random(-20,20)),math.rad(math.random(-20,20)))
	local Distance = math.random()/2.5
	local RandomHeight = math.random(-200,200)/2500
	local T = 0
	local P = 2000
	local Loop = game:GetService("RunService").Heartbeat:Connect(function(delta)
		local mult = delta*60

		T += mult
		local Trail = Instance.new("Part", effectmodel)
		local prop = {
			Anchored = true,
			Shape = shaper,
			Size = Vector3.new(0.07, 0.07, 0.07)*math.random()*2,
			Material = math.random() >= .5 and Enum.Material.Neon or Enum.Material.Glass,
			Color = bluecolor(),
			Transparency = Inside.Transparency,
			CFrame = Outside.CFrame * CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360))),
			CanCollide = false
		}
		for i, v in next, prop do
			Trail[i] = v
		end

		game:GetService("TweenService"):Create(Trail, TweenInfo.new(0.375), {
			Transparency = 1,
			Size = Vector3.zero,
			CFrame = Trail.CFrame * CFrame.Angles(math.random(-math.pi,math.pi),math.random(-math.pi,math.pi),math.random(-math.pi,math.pi))
		}):Play()
		task.delay(0.375, pcall, game.Destroy, Trail)

		Inside.Material = math.random() >= .5 and Enum.Material.Neon or Enum.Material.Glass
		Inside.Color = bluecolor()
		Outside.Color = bluecolor()

		Offset = Offset:Lerp(CFrame.identity, T/P)

		Outside.CFrame = Outside.CFrame * CFrame.new(0,0,-Distance)*Offset

		Outside.Position = Outside.Position + Vector3.new(0,RandomHeight,0)
		Outside.Position = Outside.Position:Lerp(torsopos.Position, T/P)

		Inside.CFrame = Outside.CFrame
	end)

	task.delay(3, function()
		game:GetService("TweenService"):Create(Outside, TweenInfo.new(1.25,Enum.EasingStyle.Quad), {
			Size = Vector3.zero,
			Transparency = 1
		}):Play()
		game:GetService("TweenService"):Create(Inside, TweenInfo.new(1,Enum.EasingStyle.Quad), {
			Size = Vector3.zero,
			Transparency = 1
		}):Play()
		task.delay(1, function()
			pcall(game.Destroy, Inside)
			pcall(game.Destroy, Outside)
			Loop:Disconnect()
		end)
	end)
end

function jrand(Length)
	return string.gsub(string.rep(".", (Length or 25)), ".", function()
		return utf8.char(math.random(12353, 12450))
	end)
end

function PlayFramesUI(Frames, fps, callback)
	task.spawn(function()
		local currentFrame = 0
		local lastFrameUI = Frames[tostring(currentFrame)]
		while Frames:FindFirstChild(tostring(currentFrame)) do
			local currentFrameUI = Frames[tostring(currentFrame)]
			lastFrameUI.Visible = false
			currentFrameUI.Visible = true
			lastFrameUI = currentFrameUI

			currentFrame += 1
			task.wait(1/fps)
		end
		callback()
	end)
end

function realityBreak(objects)

end

local countering = false

function isBase(obj)
	if(not obj)then return end
	if string.lower(obj.Name) == "base" or string.lower(obj.Name) == "baseplate" then
		if(obj.Size.X > 100 and obj.Size.Z > 100)then
			return obj.Parent == workspace
		end
	end
	return false
end

local Mirage = false

local modelclone = script.CharClone:Clone()
local spinners = {}

function mirageeffect(part)
	task.spawn(function()
		local mod = Instance.new("Model")
		mod.Name = "a mirage."

		part.Anchored = true
		part.CanTouch = false
		part.CanCollide = false
		part.CanQuery = false
		part.Material = Enum.Material.Neon
		part.Color = Color3.new()
		part.Name = "a mere delusion."
		part.Parent = mod

		local h = script.Highlight:Clone()
		h.OutlineTransparency = part.Transparency
		h.Parent = mod

		local hu = Instance.new("Humanoid")
		hu.Parent = mod

		mod.Parent = workspace.Terrain

		for i = 0, 7 do
			part.Color = i % 2 == 0 and Color3.fromRGB(85, 85, 255) or Color3.new()
			task.wait(0.075)
		end

		local angle = 25
		local scale = Random.new():NextNumber(0.25, 1.25)
		game:GetService("TweenService"):Create(part, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Transparency = 1,
			Color = Color3.new(1,1,1),
			Size = part.Size * scale,
			CFrame = part.CFrame * CFrame.Angles(math.rad(Random.new():NextNumber(-angle, angle)), math.rad(Random.new():NextNumber(-angle, angle)), math.rad(Random.new():NextNumber(-angle, angle))) + Vector3.new(0, -1, 0),
		}):Play()

		game:GetService("TweenService"):Create(h, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			OutlineTransparency = 1
		}):Play()

		task.delay(1, pcall, game.Destroy, mod)
	end)
end

local miragebindable = Instance.new("BindableEvent")

miragebindable.Event:Connect(function()
	if(not Mirage)then return end
	task.spawn(function()
		local trail = modelclone:Clone()
		local backups = {}
		local numdesc = #trail:GetDescendants()

		for i, v in next, trail:GetChildren() do
			if(v:IsA("BasePart"))then
				v.CFrame = CFrames[v.Name]
			end
		end

		for i, v in next, trail:GetDescendants() do
			if(v:IsA("BasePart"))then
				v.Transparency = 0.2
			end
		end

		for i, v in next, trail:GetDescendants() do
			if(v:IsA("BasePart"))then
				backups[v] = {
					c = v.CFrame,
					s = v.Size,
					t = v.Transparency,
					co = v.Color,
					anc = v.Anchored
				}
			end
		end

		local con = game:GetService("RunService").PreSimulation:Connect(function()
			if(not trail or trail.Parent ~= workspace.Terrain or #trail:GetDescendants() ~= numdesc)then
				pcall(game.Destroy, trail)
				trail = modelclone:Clone()
				trail.Parent = workspace.Terrain
				trail.Name = "a mere delusion."
			end
			for i, v in next, trail:GetDescendants() do
				if(v:IsA("BasePart") and backups[v])then
					local bc = backups[v]
					v.CFrame = bc.c
					v.Size = bc.s
					v.Transparency = bc.t
					v.Color = bc.co
					v.Anchored = bc.anc
				end
			end
		end)

		trail.Parent = workspace.Terrain
		trail.Name = "a mere delusion."
		for i = 1, 2 do
			miragebindable.Event:Wait()
		end
		con:Disconnect()
		for i, v in next, trail:GetDescendants() do
			if(v:IsA("BasePart"))then
				v.Transparency = 0.925
				mirageeffect(v)
			end
		end
		task.wait(1)
		pcall(game.Destroy, trail)
	end)
end)

function cr_remoteevent(type, data, pass)
	if(pass)then return end

	miragebindable:Fire()

	if(type == "Effect")then
		Effect(data[1],data[2],data[3],data[4],data[5],data[6],data[7],data[8])

	elseif(type == "SpawnTrail")then
		SpawnTrail(data[1],data[2],data[3],data[4],data[5])

	elseif(type == "Lightning")then
		Lightning(data[1],data[2],data[3],data[4],data[5],data[6],data[7],data[8],data[9])

	elseif(type == "Chatfunc")then
		chatfunc(data)

	elseif(type == "Light")then
		newl(data[1], data[2], data[3])

	elseif(type == "Tween")then
		game:GetService("TweenService"):Create(data[1],TweenInfo.new(table.unpack(data[2])),data[3]):Play()

	elseif(type == "colorcor")then
		local origin = data.Origin or Vector3.new(0,0,0)
		local range = data.Range or math.huge
		local saturation = data.Saturation or 0
		local contrast = data.Contrast or 0
		local brightness = data.Brightness or 0
		local tint = data.TintColor or Color3.new(1,1,1)
		local colorcor = Instance.new("ColorCorrectionEffect",game:GetService("Lighting"))
		colorcor.Brightness = brightness
		colorcor.Contrast = contrast
		colorcor.Saturation = saturation
		colorcor.TintColor = tint
		if(data.TweenTime)then
			game:GetService('TweenService'):Create(colorcor,TweenInfo.new(data.TweenTime),data.Tween):Play()
		end
		if(data.DestroyAfter)then
			game:GetService('Debris'):AddItem(colorcor,data.DestroyAfter)
		end
	elseif(type == "killeff")then
		killeff(data[1], data[2])

	elseif(type == "physicseff")then
		physicseffect(data[1], data[2])

	elseif(type == "startult" and data)then
		if(ult)then return end
		ult = true
		ultcc = Instance.new("ColorCorrectionEffect", game:GetService("Lighting"))
		game:GetService("TweenService"):Create(ultcc, TweenInfo.new(1), {
			TintColor = Color3.new(.5,.5,1)
		}):Play()

		ults = script.Ult:Clone()
		ults.Parent = workspace
		ults:Play()

		ultp = Instance.new("Attachment", workspace.Terrain)
		ultp.WorldPosition = Vector3.new(0,100,0)
		local a = script.ParticleEmitter:Clone()
		a.Parent = ultp

		ultstatic = script.static:Clone()
		ultstatic.Parent = plr:FindFirstChildOfClass("PlayerGui")

	elseif(type == "stage" and data)then
		for i = 1,math.random(5,20) do
			local c = script.Chain:Clone()
			local part = Instance.new("Part", workspace)
			part.Anchored = true
			part.Transparency = 1
			part.Position = Vector3.new(math.random(-500,500),math.random(-500,500),math.random(-500,500))
			part.Size = Vector3.one*math.random(50, 100)
			game:GetService("TweenService"):Create(part, TweenInfo.new(5), {
				Transparency = 1,
				Size = Vector3.zero
			}):Play()
			game:GetService("Debris"):AddItem(part, 5)
			local att = Instance.new("Attachment", part)
			local att2 = Instance.new("Attachment", workspace.Terrain)
			att2.WorldPosition = Vector3.new(math.random(-500,500),math.random(-100, 50),math.random(-500,500))
			c.TextureSpeed = 3
			c.Parent = part
			c.Attachment0 = att
			c.Attachment1 = att2
			ultchains[c] = {
				math.random(0, 100), att, att2, part
			}
		end

		game:GetService("TweenService"):Create(ultcc, TweenInfo.new(.5), {
			Brightness = ultcc.Brightness - .1
		}):Play()
		layerText(("[%s] %s"):format(data[1], data[2] or "undefined"))

	elseif(type == "endult" and data)then
		local ui = script.FadeOutUI:Clone()
		pcall(function()
			ui.Parent = plr:FindFirstChildOfClass("PlayerGui")
			game:GetService("TweenService"):Create(ui.Frame, TweenInfo.new(1), {
				BackgroundTransparency = 0
			}):Play()
		end)
		task.wait(1)

		ult = false
		pcall(function()
			game:GetService("TweenService"):Create(ults,TweenInfo.new(1),{
				Volume = 1
			}):Play()
			task.delay(1, pcall, game.Destroy, ults)
		end)

		for i, v in next, chains do
			pcall(game.Destroy, v[2])
			pcall(game.Destroy, v[3])
			pcall(game.Destroy, v[4])
			pcall(game.Destroy, i)
			chains[i] = nil
		end

		task.wait(.5)
		pcall(game.Destroy, ultstatic)
		pcall(game.Destroy, ultcc)
		pcall(game.Destroy, ultp)

		pcall(function()
			game:GetService("TweenService"):Create(ui.Frame, TweenInfo.new(1), {
				BackgroundTransparency = 1
			}):Play()
			task.wait(1)
			pcall(game.Destroy, ui)
		end)

	elseif(type == "dataupdate")then
		grabbing = data[1]
		furry = data[2]
		fakemainpos = data[3]
		torsopos = data[4]
		CFrames = data[5]
		Mirage = data[6]

	elseif(type == "grabeff")then
		grabeff(data[1], data[2])

	elseif(type == "mathru")then
		countering = true
		if(data)then

			local static = script.STATIC:Clone()
			static.Parent = plr:FindFirstChildWhichIsA("PlayerGui")

			local a = script.Static:Clone()
			a.Volume = 7
			a.Parent = workspace
			a:Play()

			PlayFramesUI(static.Frames, math.random(20, 40), function()
				static:Destroy()
				a:Destroy()
			end)
		end
		task.delay(1.5, function()
			countering = false
		end)

	elseif(type == "tear")then


	elseif(type == "counter")then
		countering = true
		SoundEffect(workspace, 1085317309, .5, math.random(90,110)/100, true)

		local ado = Instance.new("Part", workspace)
		ado.Anchored = true
		ado.CanCollide = false
		ado.Size = Vector3.zero
		ado.Transparency = 1
		ado.CanQuery = false
		ado.CFrame = data.pos*CFrame.new(4.5,0,0)

		game:GetService("TweenService"):Create(ado, TweenInfo.new(3), {
			Position = (data.pos*CFrame.new(4.5,0,0)).Position - Vector3.new(0,2,0),
		}):Play()

		local bil = script.counterui:Clone()
		bil.Parent = ado
		bil.Adornee = ado
		local tx = bil.TextLabel
		game:GetService("TweenService"):Create(tx, TweenInfo.new(3), {
			TextTransparency = 1,
			TextStrokeTransparency = 1,
			Rotation = math.random(-50, 50)
		}):Play()
		task.spawn(function()
			while bil and bil:IsDescendantOf(workspace)do
				tx.Text = jrand(3).." Anti-Erasure "..jrand(3).."\n"..data.counter
				ArtificialHB.Event:Wait()
			end
		end)
		task.delay(3, function()
			countering = false
			pcall(game.Destroy, ado)
		end)
	end
end

function animwings()
	local l, l1, l2 = wings.L, wings.L.L1, wings.L.L2
	local r, r1, r2 = wings.R, wings.R.R1, wings.R.R2

	l.CFrame = origwingpos.L*CFrame.new(-.3+.3*math.cos(sine/30),1*math.cos(sine/30),-.2-.2*math.cos(sine/30))*CFrame.Angles(math.rad(-30*math.cos(sine/30)),0,0)
	l2.CFrame = origwingpos.L2*CFrame.new(.2*math.cos(sine/40),.3*math.cos(sine/50),.3*math.cos(sine/30))*CFrame.Angles(math.rad(-20*math.cos(sine/30)),0,0)

	r.CFrame = origwingpos.R*CFrame.new(.3-.3*math.cos(sine/30),1*math.cos(sine/30),-.2-.2*math.cos(sine/30))*CFrame.Angles(math.rad(-30*math.cos(sine/30)),0,0)
	r2.CFrame = origwingpos.R2*CFrame.new(-.2*math.cos(sine/40),.3*math.cos(sine/50),.3*math.cos(sine/30))*CFrame.Angles(math.rad(-20*math.cos(sine/30)),0,0)
end

function checkwings()
	if(not wings or not wings:IsDescendantOf(tobjects))then
		pcall(game.Destroy, wings)
		wings = script.WingPart.Wings:Clone()
		wings.Parent = tobjects
		for i, v in next, wings:GetDescendants() do
			if(v:IsA("Attachment"))then
				origwingpos[v.Name] = v.CFrame
			end
		end
		animwings()
	else
		animwings()
	end
end

local furrystuff = {
	"fakehead", "face", "Glasses", "Whiskers", "Ears",
	"Tail", "paw"
}

local normalstuff = {
	"Chain", "Chain2"
}

local lastorefit = tick()
local triangle = nil

table.insert(connections, game:GetService("RunService").Heartbeat:Connect(function()
	task.spawn(function()

		for i, v in next, spinners do
			v:Destroy()
			spinners[i] = nil
		end

		if(not Mirage)then
			pcall(game.Destroy, triangle)
			return
		end

		spinners = {}
		for i, v in next, modelclone:GetChildren() do
			if(v:IsA("BasePart"))then
				local spin = v:Clone()
				spin.Name = "delusion"
				spin.Parent = workspace.Terrain
				spinners[v] = spin
			end
		end

		local index = 0
		for i, v in next, spinners do
			index = index + 1
			pcall(function()
				v.Parent = workspace.Terrain
				v.Size = i.Size*.85
				v.Transparency = .5
				for ind, val in v:GetDescendants() do
					if(val:IsA("BasePart"))then
						val.Transparency = .5
					end
				end
				v.CFrame = i.CFrame*CFrame.new(v.Size.X*math.cos(tick()*index/2),v.Size.Y*math.sin(tick()*index/2),v.Size.Z*math.sin(tick()*index/2))
			end)
		end

		if(not triangle or not triangle:IsDescendantOf(workspace.Terrain) or #triangle:GetDescendants() <= 4 or (triangle:GetPivot().Position - Vector3.zero).Magnitude >= 1e5)then
			pcall(game.Destroy, triangle)

			local warning = script["!"]:Clone()
			Instance.new("Humanoid", warning)
			warning.Triangle.outline.Color = Color3.fromRGB(85, 85, 255)
			warning["!"].Color = Color3.fromRGB(85, 85, 255)
			warning.Parent = workspace.Terrain

			triangle = warning
		end

		triangle:PivotTo(CFrames.Head * CFrame.new(0, 0, -.7) * CFrame.Angles(0, -math.rad(90), math.rad(90)))
		triangle.Triangle:PivotTo(triangle.Triangle._center.CFrame * CFrame.Angles(0, math.rad(2), 0))
	end)

	if(tick() - lastorefit) >= 5 then
		for i, v in next, {hobjects, raobjects, tobjects, laobjects, llobjects, rlobjects} do
			pcall(game.Destroy, v)
		end
		lastorefit = tick()
	end

	if(not hobjects or not hobjects:IsDescendantOf(workspace))then
		pcall(game.Destroy, hobjects)
		hobjects = script.headobjects:Clone()
	end
	if(not raobjects or not raobjects:IsDescendantOf(workspace))then
		pcall(game.Destroy, raobjects)
		raobjects = script.rarmobjects:Clone()
	end
	if(not tobjects or not tobjects:IsDescendantOf(workspace))then
		pcall(game.Destroy, tobjects)
		tobjects = script.torsoobjects:Clone()
	end
	if(not laobjects or not laobjects:IsDescendantOf(workspace))then
		pcall(game.Destroy, laobjects)
		laobjects = script.larmobjects:Clone()
	end
	if(not rlobjects or not rlobjects:IsDescendantOf(workspace))then
		pcall(game.Destroying, rlobjects)
		rlobjects = script.rlobjects:Clone()
	end
	if(not llobjects or not llobjects:IsDescendantOf(workspace))then
		pcall(game.Destroying, llobjects)
		llobjects = script.llobjects:Clone()
	end

	for i, v in next, {hobjects, raobjects, tobjects, laobjects, rlobjects, llobjects} do
		v.Parent = workspace
		v.Anchored = true
		v.CanCollide = false
		v.CanQuery = false
		v.CanTouch = false
		for index, value in next, v:GetDescendants() do
			pcall(function()
				value.CanCollide = false
				value.CanQuery = false
				value.CanTouch = false
			end)
		end
	end

	checkwings()

	if(furry)then
		for i, v in next, furrystuff do
			pcall(function()
				tobjects:FindFirstChild(v, true).Transparency = 0
			end)
			pcall(function()
				hobjects:FindFirstChild(v, true).Transparency = 0
			end)
			pcall(function()
				laobjects:FindFirstChild(v, true).Transparency = 0
			end)
			pcall(function()
				raobjects:FindFirstChild(v, true).Transparency = 0
			end)
			pcall(function()
				llobjects:FindFirstChild(v, true).Transparency = 0
			end)
			pcall(function()
				rlobjects:FindFirstChild(v, true).Transparency = 0
			end)
		end

		for i, v in next, normalstuff do
			pcall(function()
				tobjects:FindFirstChild(v, true).Transparency = 1
			end)
			pcall(function()
				hobjects:FindFirstChild(v, true).Transparency = 1
			end)
			pcall(function()
				hobjects:FindFirstChild(v, true).Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1,0), NumberSequenceKeypoint.new(1,1,0)})
			end)
		end
	else
		for i, v in next, furrystuff do
			pcall(function()
				tobjects:FindFirstChild(v, true).Transparency = 1
			end)
			pcall(function()
				hobjects:FindFirstChild(v, true).Transparency = 1
			end)
			pcall(function()
				laobjects:FindFirstChild(v, true).Transparency = 1
			end)
			pcall(function()
				raobjects:FindFirstChild(v, true).Transparency = 1
			end)
			pcall(function()
				llobjects:FindFirstChild(v, true).Transparency = 1
			end)
			pcall(function()
				rlobjects:FindFirstChild(v, true).Transparency = 1
			end)
		end

		for i, v in next, normalstuff do
			pcall(function()
				tobjects:FindFirstChild(v, true).Transparency = 0
			end)
			pcall(function()
				hobjects:FindFirstChild(v, true).Transparency = 0
			end)
			pcall(function()
				hobjects:FindFirstChild(v, true).Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0), NumberSequenceKeypoint.new(1,1,0)})
			end)
		end
	end

	updateIgnore()

	pcall(function()
		if(grabbing)then
			for i, v in next, laobjects:GetDescendants() do
				if(v:IsA("Trail"))then
					v.Enabled = true
				end
			end
		else
			for i, v in next, laobjects:GetDescendants() do
				if(v:IsA("Trail"))then
					v.Enabled = false
				end
			end
		end
	end)
end))

local mirageframe = 0
table.insert(connections, ArtificialHB.Event:Connect(function()
	sine += 1
	mirageframe += 1

	if(mirageframe >= 2*60)and(Mirage)then
		mirageframe = 0
		miragebindable:Fire()
	end

	for i, v in next, bolts do
		if(i:IsDescendantOf(game))then
			bolts[i].sin += 1
			i.CurveSize0 = v.CurveSize*math.sin(v.sin/20)
			i.CurveSize1 = -v.CurveSize*math.sin(v.sin/40)
			i.TextureLength = v.TextureSize
			i.TextureSpeed = v.TextureSize/50
			i.Color = ColorSequence.new(v.Color)
		else
			bolts[i] = nil
		end
	end

	for i, v in next, ultchains do
		if(i:IsDescendantOf(game) and v[4])then
			ultchains[i][1] += 1
			local mag = (v[2].WorldPosition - v[3].WorldPosition).Magnitude
			i.CurveSize0 = mag/3*math.sin(v[1]/40)
			i.CurveSize1 = -mag/3*math.sin(v[1]/30)
			i.TextureLength = mag/2
			i.Width0 = if(v[4].Size.Z > v[4].Size.X)then v[4].Size.Z else v[4].Size.X
			i.Width1 = (if(v[4].Size.Z > v[4].Size.X)then v[4].Size.Z else v[4].Size.X)+30
			i.Transparency = NumberSequence.new(1, v[1]/(60*5))
		else
			pcall(game.Destroy, v[2])
			pcall(game.Destroy, v[3])
			pcall(game.Destroy, i)
			ultchains[i] = nil
		end
	end

	for i, v in next, chains do
		if(i:IsDescendantOf(game) and v[4])then
			chains[i][1] += 1
			local mag = (v[2].WorldPosition - v[3].WorldPosition).Magnitude
			i.CurveSize0 = mag/3*math.sin(v[1]/(mag*3))
			i.CurveSize1 = -mag/3*math.sin(v[1]/(mag*3))
			local siz = if(v[4].Size.Z > v[4].Size.X)then v[4].Size.Z else v[4].Size.X
			if(v[4]:FindFirstChild("Mesh"))then
				siz = (if(v[4].Mesh.Scale.Z > v[4].Mesh.Scale.X)then v[4].Mesh.Scale.Z else v[4].Mesh.Scale.X)/20
			end
			i.Width0 = siz
			i.Transparency = NumberSequence.new(v[4].Transparency, 1)
		else
			pcall(game.Destroy, v[2])
			pcall(game.Destroy, v[3])
			pcall(game.Destroy, i)
			chains[i] = nil
		end
	end

	if(ult)then
		local camcf = CFrame.new()
		if(ultp)then
			ultp.WorldCFrame = camcf
			ultp.ParticleEmitter:Emit(1)
		end
		local rsiz = math.random(5,25)
		for i = 0, 2 do
			sphereMK(15,math.random(50,2500)/10,"Add",CFrame.new(camcf.X,100,camcf.Z)*CFrame.new(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000))*CFrame.Angles(math.rad(-90 + math.random(-180,180)),math.rad(math.random(-180,180)),math.rad(math.random(-180,180))),1,1,5000,0,BrickColor.new("Really blue"),0)
			sphereMK(10,math.random(50,500)/50,"Add",CFrame.new(camcf.X,100,camcf.Z)*CFrame.new(math.random(-1000,1000),math.random(-1000,1000),math.random(-1000,1000))*CFrame.Angles(math.rad(-90 + math.random(-180,180)),math.rad(math.random(-180,180)),math.rad(math.random(-180,180))),rsiz,rsiz,rsiz,0,BrickColor.new("Really blue"),0)
		end
		Beamring(Color3.new(0,0,1),CFrame.new(camcf.X,50+10*math.cos(sine/45),camcf.Z)*CFrame.Angles(math.rad(0 + 30 * math.cos(sine / 58)),math.rad(0 + 30 * math.cos(sine / 61)),math.rad(0 + 30 * math.cos(sine / 65))),100,1500,20,nil)
		if(sine%10)==0 then
			local pos = Vector3.new(math.random(-500,500),0,math.random(-500,500))
			local p = Effect(pos, 0, Vector3.new(math.random()*10, math.random()*10, math.random()*10), Color3.new(0,0,math.random()), 15, {
				Position = pos+Vector3.new(math.random(-50,50),math.random(100, 400),math.random(-50,50)),
				Orientation = Vector3.new(math.random(-360,360), math.random(-360,360), math.random(-360,360)),
				Transparency = 1
			}, {
				Scale = Vector3.zero
			}, workspace)
			chain(p, pos)
		end
		if(math.random(1,50) == 1)then
			local pos = Vector3.new(math.random(-500,500),math.random(0, 200),math.random(-500,500))
			local pos2 = Vector3.new(math.random(-500,500),math.random(0, 200),math.random(-500,500))
			Lightning(pos, pos2, 0, 30, Color3.new(0,0,1), 1, workspace)
		end
	end
end))

stopscript = function()
	scriptstopped = true
	refitcore.KillOperation()
	pcall(gdestroy, effectmodel)
	pcall(gdestroy, hmod)

	anima(connections)
	anima(BlackMagic.CONNECTIONS)
	anima(decimatesignals)

	for i, v in next, workspace:GetDescendants() do
		pcall(function()
			if(v:IsA("ViewportFrame"))then
				v:Destroy()
			end
		end)
	end

	table.clear(Decimated)
	table.clear(scbackups)
	table.clear(BlackMagic)
	table.clear(ignore)
	table.clear(limbs)
	table.clear(poses)

	for i, v in next, connections do
		pcall(function()
			v:Disconnect()
		end)
	end
	if(ult)then
		ult = false
		pcall(game.Destroy, ults)
		pcall(game.Destroy, ultstatic)
		pcall(game.Destroy, ultcc)
		pcall(game.Destroy, ultp)
		pcall(function()
			ultshake:Stop()
		end)
	end
	for i, v in next, {hobjects, raobjects, tobjects, laobjects, rlobjects, llobjects} do
		pcall(game.Destroy, v)
	end
	LightningModule:Destroy()
end

table.insert(connections, game:GetService("RunService").PostSimulation:Connect(function()
	if(refitcore.settings.Mirage)and(not IsStudio)then
		print("To the dawn of time.")
		game:GetService("TestService"):Fail("Rendering tests already in progress.", nil, 0)

		local s = os.clock()
		repeat until os.clock() - s >= 1/25
	end

	if(not hassetup)then return end

	local tickdiff = os.clock()-lasttick
	deltamult = tickdiff*60
	lasttick = os.clock()
	sin = lasttick*60

	trailtime = trailtime + 1
	oldmainpos = mainpos
	ka = ka + (1*deltamult)
	remupdate = remupdate + 1

	for i, v in next, uis do
		pcall(function()
			if(not v or not v:IsDescendantOf(game))then
				table.remove(uis,i)
				return
			end
			v:FindFirstChild("grad", true).Offset = Vector2.new(os.clock()*2%1.6-0.8,0)
			v:FindFirstChild("hp", true).Size = UDim2.new(math.clamp((1/tickdiff)/60, 0, 1), -4, 1, -4)
		end)
	end

	remote.own.ModifyProperty("Parent", remoteservices[math.random(1, #remoteservices)])

	if(not effectmodel or not effectmodel:IsDescendantOf(workspace))then
		pcall(game.Destroy, effectmodel)
		effectmodel = Instance.new("Folder")
		effectmodel.Name = GenerateGUID(http, false)
		effectmodel.Parent = workspace
	end

	if(not effectmodel or not effectmodel:IsDescendantOf(workspace))then
		pcall(gdestroy, effectmodel)
		effectmodel = inew("Folder")
		effectmodel.Name = GenerateGUID(http, false)
		effectmodel.Parent = workspace
	end

	if(math.random(1, 200) == 1 and not humglitch)then
		humglitch = true
		task.delay(math.random(), function()
			humglitch = false
		end)
	end

	updateIgnore()

	if(not mus or not mus:IsDescendantOf(muspart.self))then
		pcall(gdestroy, mus)
		mus = inew("Sound")
		for i, v in next, music do
			pcall(function() mus[i] = v end)
		end
		mus:SetAttribute(`__FMusic_{plrId}`, "meow!")
		mus.Parent = muspart.self
		mus:Play()
	else
		music.TimePosition = mus.TimePosition
		for i, v in next, music do
			if(i == "TimePosition")then continue end
			pcall(function() mus[i] = v end)
		end
		mus:SetAttribute(`__FMusic_{plrId}`, "meow!")
		mus:Resume()
	end

	if(remupdate >= 2)then
		remupdate = 0

		pcall(function()
			if(getplr())then
				if(getplr().Character)then
					getplr().Character:Destroy()
				end
				getplr().Character = nil	

				local limb = {}
				for i, v in next, limbs do
					pcall(function()
						limb[v] = getfenv()[v].self
					end)
				end	

				remote.own.self:FireClient(getplr(), "updateData", {limb, ignore, walkspeed}, remotepassword)
			end
		end)

		cr_remoteevent("dataupdate", {grabbing, furry, fakemainpos, fakemainpos*poses.torso, {
			["Gun"] = fakemainpos*poses["torso"]*poses["rarm"]*poses["gun"],
			["Left Arm"] = fakemainpos*poses["torso"]*poses["larm"],
			["Right Arm"] = fakemainpos*poses["torso"]*poses["rarm"],
			["Left Leg"] = fakemainpos*poses["torso"]*poses["lleg"],
			["Right Leg"] = fakemainpos*poses["torso"]*poses["rleg"],
			["Torso"] = fakemainpos*poses["torso"],
			["Head"] = fakemainpos*poses["torso"]*poses["head"]*lastheadcf
		}, refitcore.settings.Mirage})
	end

	if(not movement.falling and not movement.flying)and(rand(1, 30, true) == 1)then
		local cf = (mainpos * cfn(math.random(-10,10),-5,math.random(-10,10)))
		Effect(cf, 0, v3(math.random(),math.random(),math.random()), bluecolor(), 2, {
			Transparency = 1,
			Color = c3(),
			Orientation = v3(math.random(-360,360),math.random(-360,360),math.random(-360,360)),
			Position = (cf * cfn(math.random(-10,10),15,math.random(-10,10))).Position
		}, {
			Scale = Vector3.zero
		})
	end

	if(rand(1, 50, true) == 1)then
		local c = bluecolor()
		Lightning((gun.self.Hole.CFrame*cfn(0,-1.5,0)).Position,gun.self.Hole.CFrame.Position,5,4,c,.1)
		Effect(gun.self.Hole.CFrame, 0, v3(.3,.3,.3), c, 2, {
			Transparency = 1,
			Color = c3(),
			Orientation = v3(math.random(-360,360),math.random(-360,360),math.random(-360,360))
		},{
			Scale = Vector3.zero
		})
	end

	if(rand(1, 60, true) == 1)then
		physicseffect(fakemainpos)
	end

	if(rand(1, 100, true) == 1)then
		newl(fakemainpos.Position+v3(math.random(-10, 10), math.random(-5, 0), math.random(-10, 10)), bluecolor())
	end

	if(smoketime > 0)then
		smoketime -= 1
		Effect(gun.self.Hole.CFrame, 0, v3(math.random()/2,math.random()/2,math.random()/2), bluecolor(), 1, {
			Transparency = 1,
			Color = c3(.4,.4,.6),
			Orientation = v3(math.random(-360,360),math.random(-360,360),math.random(-360,360)),
			Position = gun.self.Hole.CFrame.Position+v3(math.random()*1-.5,3,math.random()*1-.5)
		},{
			Scale = Vector3.zero
		})
	end

	if(killaura)then
		Aoe(mainpos.Position, 8)
		if(ka >= 10)then
			ka = 0

			local v = Instance.new("Part")
			local at = Instance.new("Attachment", v)
			local at2 = Instance.new("Attachment", v)
			local trail = Instance.new("Trail", v)

			at.Position = v3(0,.5,0)
			at2.Position = v3(0,-.5,0)

			local col = bluecolor()
			trail.Attachment0 = at
			trail.Attachment1 = at2
			trail.Texture = "rbxassetid://4527465114"
			trail.Color = ColorSequence.new(col)
			trail.LightEmission = 1
			trail.LightInfluence = 0.5
			trail.Brightness = 50
			trail.FaceCamera = true
			trail.Lifetime = .7
			trail.WidthScale = NumberSequence.new(1,0)

			v.Anchored = true
			v.CanCollide = false
			v.Position = mainpos.Position+v3(math.random(-5, 5),math.random(-5, 5),math.random(-5, 5))
			v.Size = v3(math.random(),math.random(),math.random())
			v.Color = col
			v.Material = Enum.Material.Glass
			v.Parent = effectmodel
			game:GetService("TweenService"):Create(v, TweenInfo.new(3), {
				Size = Vector3.zero,
				Transparency = 1,
				Position = v.Position+v3(math.random(-5,5),math.random(-5,5),math.random(-5,5)),
				Orientation = v.Orientation+v3(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			}):Play()
			game:GetService("Debris"):AddItem(v, 3)
		end
	end
end))
