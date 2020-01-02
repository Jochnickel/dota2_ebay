local Thinker = class({})

ListenToGameEvent("game_rules_state_game_in_progress", function()
		Timers:CreateTimer( 0, Thinker.Minute00 )
		Timers:CreateTimer( 20, Thinker.DontForgetToSubscribe )
		Timers:CreateTimer( Thinker.VeryVeryOften )
end, GameMode)

function Thinker:Minute00()
	print("The Game begins!")
	return nil -- does not repeat
end

function Thinker:DontForgetToSubscribe()
	HUDError("Dont forget To Subscribe",0)
	return nil -- does not repeat
end

local allitems = LoadKeyValues("scripts/npc/items.txt")

local REFUND = 0.5

local bids = {}
local wishlist = {}
local highestBid = 0
local highestBidder = nil
local currentItem = "item_boots"

ListenToGameEvent("placed_bid",function(event)
	print("placed_bid")
	PrintTable(event)
	local playerID = event.playerID
	local gold = event.gold
end,nil)

ListenToGameEvent("current_item_request",function()
	FireGameEvent("current_item",{item = currentItem,bidders = bids, maxbidder_playerid = highestBidder})
end,nil)




function Thinker:VeryVeryOften()
	if highestBidder then
		HUDError(currentItem.." got sold for "..highestBid.." gold",-1)
		bids[highestBidder] = nil
		local hero = PlayerResource:GetSelectedHeroEntity(highestBidder)
		hero:AddItemByName(currentItem)
		for pid,gold in pairs(bids) do
			PlayerResource:ModifyGold(pid,(REFUND*gold),(reliable==false),DOTA_ModifyGold_PurchaseItem)
			bids[pid] = nil
		end
	end
	
	bids = {}
	return 10
end
