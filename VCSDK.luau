--!strict

-- Voice Chat Simpler Development Kit
-- Pretty much made by Sezei (0bBinary in Devforums) after a long gruesome process of trying to understand it (i still didn't)
-- Version 1.0 (not that there will ever be other versions unless to fix this ngl)
-- Allows the scripters to easily interact with a player's Voice Chat using the official Roblox Audio APIs.

-- hi mom

export type SDK = {
	-- General Functions
	MutePlayer:(Player:Player,Length:number?)->nil;
	UnmutePlayer:(Player:Player)->nil;
	
	PlayerHasVoice:(Player:Player)->boolean;
	
	-- Advanced? Functions
	GetDeviceInput:(Player:Player)->AudioDeviceInput?; -- If the player does not have voice chat they can't have an AudioDeviceInput.
	-- yeah that's about it. i couldn't think of anything else let's be fr
	
	-- Event for when someone gets VC banned. I don't think any other module has this.
	VoiceStripped:BindableEvent;
};

local Audios:{[number]:AudioDeviceInput} = {};

local SDK:SDK = {
	MutePlayer = function(Player:Player, Length:number?)
		if Audios[Player.UserId] then
			Audios[Player.UserId].Muted = true;
			
			if Length then
				task.delay(Length, function()
					if Audios[Player.UserId].Parent then
						Audios[Player.UserId].Muted = false;
					end
				end);
			end
		end;
		return nil; -- strict requires this
	end;
	UnmutePlayer = function(Player:Player)
		if Audios[Player.UserId] then
			Audios[Player.UserId].Muted = false;
		end;
		return nil; -- strict requires this 2: electric boogalo
	end;
	GetDeviceInput = function(Player:Player)
		return Audios[Player.UserId];
	end;
	PlayerHasVoice = function(Player:Player)
		--      v  free advice for the new scripters: you can turn basically anything into a boolean by using 'not not'. try it in the console. ;p
		return not not Audios[Player.UserId];
	end;
	VoiceStripped = Instance.new("BindableEvent");
};

function HandleJoin(Player:Player)
	task.spawn(function()
		local Audio:Instance?|AudioDeviceInput? = Player:WaitForChild("AudioDeviceInput");
		
		if Audio then
			if Audio:IsA("AudioDeviceInput") then
				Audios[Player.UserId] = Audio;
			end
			
			-- Handle players getting VC-banned in real time 💀
			Audio:GetPropertyChangedSignal("Parent"):Connect(function()
				-- that's sad
				if Audio.Parent == nil and Player.Parent then
					SDK.VoiceStripped:Fire(Player);
					Audios[Player.UserId] = nil;
				end
			end);
		end
	end)
	Player:GetPropertyChangedSignal("Parent"):Connect(function()
		if Player.Parent == nil then
			Audios[Player.UserId] = nil;
		end
	end)
end

game:GetService("Players").PlayerAdded:Connect(HandleJoin);
for _,Player in game:GetService("Players"):GetPlayers() do HandleJoin(Player) end;

return SDK
