bid = class({})
bid.gold = 1

function bid:GetGoldCost()
	return self.gold
end

function bid:OnAbilityPinged(playerID)
	local hero = self:GetCaster()
	HUDError(hero:FindModifierByName("bidmodifier").item, playerID)
end

function bid:GetIntrinsicModifierName()
	local hero = self:GetCaster()
	return "bidmodifier"
end

function bid:OnSpellStart()
	local hero = self:GetCaster()
	FireGameEvent("auction_placed_bid",{playerID = hero:GetPlayerID(), gold = self.gold })
end

-------------------------------------------------------------------------------------------------------------------------------
-- everything down from here is a modifier. LinkLuaModifier adds it to the game, so the AddNewModifier(..) knows where to find it.

--               modifiername used below ,       filepath            , weird valve thing
LinkLuaModifier( "bidmodifier", "abilities/bid", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "wishmodifier", "abilities/bid", LUA_MODIFIER_MOTION_NONE )

bidmodifier = class({})

bidmodifier.item = "item_boots"
bidmodifier.maxbidder = -1

function bidmodifier:GetTexture() return self.item end
function bidmodifier:IsDebuff()
	return self.maxbidder ~= self:GetParent():GetPlayerOwnerID()
end

function bidmodifier:IsPermanent() return true end

function bidmodifier:OnCreated( kv )

	local hero = self:GetParent()
	local ownPlayerID = hero:GetPlayerOwnerID()
	if IsServer() then
		hero:AddNewModifier(hero,nil,"wishmodifier",{})
	end

	self.eventlistener = ListenToGameEvent("auction_current_item",function(self,event)
		-- for k,v in pairs(event) do			print("modifier auction_current_item",self,k,v)		end
		self.item = event.item
		self.maxbidder = event.maxbidder_playerid
		local bids = load('return '..event.bids)()
		local ownBid = bids[ownPlayerID] or 0
		self:SetStackCount(ownBid)


	end, self)

	FireGameEvent("auction_current_item_request",{})

end

function bidmodifier:OnDetroy()
	StopListeningToGameEvent(self.eventlistener)
end
-----------------------------------------------------

wishmodifier = class({})
wishmodifier.item = ""
function wishmodifier:IsPermanent() return true end
function wishmodifier:IsHidden() return ""==self.item end
function wishmodifier:GetTexture()
	if not self.item then 
		FireGameEvent("auction_current_item_request",{})
	end
	return self.item
end

function wishmodifier:OnCreated(kv)
	local ownPlayerID = self:GetParent():GetPlayerOwnerID()
	self.eventlistener = ListenToGameEvent("auction_current_item",function(self,event)
		-- for k,v in pairs(event) do			print("wishmodifier event",self.item,k,v,wishlist,ownPlayerID)		end
		local wishlist = load('return '..event.wishlist)()
		local item = wishlist[ownPlayerID]
		self.item = item or ""
		
		self:ForceRefresh()
	end, self)
end

function wishmodifier:OnDestroy()
	StopListeningToGameEvent(self.eventlistener)
end