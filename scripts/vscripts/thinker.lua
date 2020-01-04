local Thinker = class({})

ListenToGameEvent("game_rules_state_game_in_progress", function()
		Timers:CreateTimer( 0, Thinker.Minute00 )
		Timers:CreateTimer( 1195, Thinker.DontForgetToSubscribe )
end, GameMode)


function Thinker:Minute00()
	FireGameEvent("auction_start",{interval = 10})
	return nil -- does not repeat
end

function Thinker:DontForgetToSubscribe()
	HUDError("Dont forget To Subscribe",0)
	return nil -- does not repeat
end
