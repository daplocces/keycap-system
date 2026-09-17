local KeycapService = {}
KeycapService.__index = KeycapService

const TweenService = game:GetService("TweenService")

const KeycapAnimations = require("@self/KeycapAnimations")

-- Changeable Variables
const PLAY_SOUND = true :: boolean
const DEFAULT_SOUND = 113108830240353 :: number -- Else use Attributes to determine sound
const DEFAULT_ANIMATION = "NORMAL" :: string -- Create custom ones in KeycapAnimations
const KEY_NAMES = {
	"1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
}

function KeycapService:pressDown()
	const chosenTween = self.ChosenTween
	const chosenAnimation = KeycapAnimations[chosenTween] :: KeycapAnimations.AnimationData
	if not chosenAnimation then
		return
	end

	const keycapSize = self.RestSize
	const keycapPosition = self.RestPosition

	const pressedSize = Vector3.new(keycapSize.X, keycapSize.Y / 2, keycapSize.Z)
	const pressedPosition = Vector3.new(
		keycapPosition.X,
		keycapPosition.Y - (keycapSize.Y / 4),
		keycapPosition.Z
	)

	TweenService:Create(
		self.Keycap,
		chosenAnimation.TWEEN_INFO,
		{
			Size = pressedSize,
			Position = pressedPosition,
		}
	):Play()
end

function KeycapService:release()
	const chosenTween = self.ChosenTween
	const chosenAnimation = KeycapAnimations[chosenTween] :: KeycapAnimations.AnimationData
	if not chosenAnimation then
		return
	end
	
	-- Sound logic here
	if PLAY_SOUND then
		if self.PlaySound then
			const temporarySound = Instance.new("Sound")
			temporarySound.SoundId = string.format("rbxassetid://%d", self.PlaySound)
			temporarySound.Parent = self.Keycap
			temporarySound:Play()
			temporarySound.Ended:Once(function(_)
				temporarySound:Destroy()
			end)
		end
	end

	TweenService:Create(
		self.Keycap,
		chosenAnimation.TWEEN_INFO,
		{
			Size = self.RestSize,
			Position = self.RestPosition,
		}
	):Play()
end

function KeycapService:createDisplay()
	self.Display = script.Display:Clone()
	self.Display.Frame.KeyName.Text = KEY_NAMES[math.random(1, #KEY_NAMES)]
	self.Display.Parent = self.Keycap
end

function KeycapService:handle(keycap: BasePart)
	self.Keycap = keycap
	
	self.ChosenTween = keycap:GetAttribute("ChosenTween") or DEFAULT_ANIMATION
	self.PlaySound = keycap:GetAttribute("PlaySound") or DEFAULT_SOUND
	
	self.RestSize = keycap.Size
	self.RestPosition = keycap.Position
	self.TouchingParts = {}

	self:createDisplay()

	self.Keycap.Touched:Connect(function(hit: BasePart)
		if self.TouchingParts[hit] then
			return
		end

		const wasEmpty = next(self.TouchingParts) == nil
		self.TouchingParts[hit] = true

		if wasEmpty then
			self:pressDown()
		end
	end)

	self.Keycap.TouchEnded:Connect(function(hit: BasePart)
		if not self.TouchingParts[hit] then
			return
		end

		self.TouchingParts[hit] = nil

		if next(self.TouchingParts) == nil then
			self:release()
		end
	end)
end

function KeycapService.newKeycap(): KeycapService
	return setmetatable({}, KeycapService)
end

task.spawn(function()
	for _, v: Instance in workspace.Keycaps:GetChildren() do
		if v:IsA("Model") then
			for _, vChild: Instance in v:GetChildren() do
				if not vChild:IsA("BasePart") then
					continue
				end

				KeycapService.newKeycap():handle(vChild)
			end
		elseif v:IsA("BasePart") then
			KeycapService.newKeycap():handle(v)
		end
	end
end)

type KeycapData = {
	Keycap: BasePart,
	ChosenTween: string,
	RestSize: Vector3,
	RestPosition: Vector3,
	TouchingParts: { [BasePart]: boolean },
	Display: Instance,
}

type KeycapService = typeof(setmetatable({} :: KeycapData, KeycapService))

return KeycapService