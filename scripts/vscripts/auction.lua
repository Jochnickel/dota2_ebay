require("internal/utils/timers")

auction = class({})

local STARTVALUE = 750
local MAXPLAYERS = 10
local REFUND = 0.5

local ebayItems = {}
local allitems = {}

local wishlist = {}
local bids = {}
local wishlist = {}
local highestBidder = nil
local currentItem = "item_boots"

ListenToGameEvent("created_game_mode_entity", function()
	allitems = LoadKeyValues("scripts/npc/items.txt") or {}
	allitems.Version = nil
	for itemname, itemvalues in pairs(allitems) do
		if itemvalues.ItemShopTags and itemvalues.ItemShopTags:find("consumable") 
		or itemname:find("recipe")
		or itemvalues.ItemPurchasable==0
		or itemvalues.ItemCost==0
		then
		else
			ebayItems[itemname] = itemvalues
		end
	end
	print("[ Auction module initiated ]")
end, nil)


---------------------------------------------------------------------------------------------


ListenToGameEvent("auction_placed_bid", function(event)
	-- print("placed_bid")
	-- PrintTable(event)
	local playerID = event.playerID
	local gold = event.gold
	bids[playerID] = bids[playerID] or 0
	bids[playerID] = bids[playerID] + gold
	local highestBid = bids[highestBidder] or 0
	if bids[playerID]>highestBid then
		highestBidder = playerID
	end
	-- say("highestBidder", highestBidder, bids[highestBidder])
	FireGameEvent("auction_current_item_request", {})
end, nil)

ListenToGameEvent("auction_current_item_request", function()
	local maxbidder = highestBidder or -1
	FireGameEvent("auction_current_item", {item = currentItem, bids = tableToString(bids), wishlist = tableToString(wishlist), maxbidder_playerid = maxbidder})
end, nil)




function auction:IsAuctionItem(itemname)
	for itemName,value in pairs(ebayItems) do
		if itemName==itemname then return true end
	end
	return false
end

function auction:GetRandomItem( difficulty ) -- from 0 to 100
	local maxValue = STARTVALUE + difficulty * 50
	for i=1,100 do
		for itemname,v in pairs(ebayItems) do
			if RollPercentage(1) and v.ItemCost<maxValue then
				return itemname
			end
		end	
	end
	return "item_boots"
end

function auction:GetWishItem() -- from 0 to 100
	local luckyPlayer = RandomInt(0,MAXPLAYERS*1.5)
	local luckyItem = wishlist[luckyPlayer]
	if luckyItem then
		wishlist[luckyPlayer] = nil
		return luckyItem
	end
	return nil
end

function auction:WishlistItem( playerID, itemname )
	wishlist[playerID] = itemname
	FireGameEvent("auction_current_item_request",{})
end

ListenToGameEvent("auction_start", function(event)
	print("Auction starts!")
	local interval = event.interval
	Timers:CreateTimer(function()
		-- print("next auction round", interval, highestBidder)
		local highestBidderHero = highestBidder and PlayerResource:GetSelectedHeroEntity(highestBidder)
		local highestBid = bids[highestBidder]

		if highestBidderHero then
			highestBidderHero:AddItemByName(currentItem)
		end
		if currentItem and highestBid then
			HUDError(currentItem.." got sold for "..highestBid.." gold", -1)
		end
		if highestBidder then
			bids[highestBidder] = nil
		end
		for pid, gold in pairs(bids) do
			local hero = PlayerResource:GetSelectedHeroEntity(pid)
			local refund = REFUND*gold
			PlayerResource:ModifyGold(pid, refund, (false and notreliable), DOTA_ModifyGold_PurchaseItem)
			if hero then
				SendOverheadEventMessage(hero:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, hero, refund, nil)
			end
			bids[pid] = nil
		end
		currentItem = auction:GetWishItem() or auction:GetRandomItem(GameRules:GetDOTATime(false,false)*0.1)
		bids = {}
		highestBid = 0
		highestBidder = nil
		FireGameEvent("auction_current_item_request", {})
		return interval
	end)
end, nil)

function auction:GetItemnameByID(id)
	for k,v in pairs(allitems) do
		if v.ID==id then
			return k
		end
	end
	return ""
end