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
	hero:AddNewModifier(hero,nil,"wishmodifier",nil)
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
	self:GetAbility().modifier = self

	local hero = self:GetParent()
	local ownPlayerID = hero:GetPlayerOwnerID()

	ListenToGameEvent("auction_current_item",function(self,event)
		for k,v in pairs(event) do			print("modifier auction_current_item",self,k,v)		end

		self.item = event.item
		self.maxbidder = event.maxbidder_playerid
		local bids = load('return '..event.bids)()
		local ownBid = bids[ownPlayerID] or 0
		self:SetStackCount(ownBid)

	end, self)

	FireGameEvent("auction_current_item_request",{})

end

wishmodifier = class({})

wishmodifier.item = ""

function wishmodifier:IsPermanent() return true end
function wishmodifier:IsHidden() return ""~=self.item end
function bidmodifier:GetTexture() return self.item end

function wishmodifier:OnCreated(kv)
	local ownPlayerID = hero:GetPlayerOwnerID()
	ListenToGameEvent("auction_current_item",function(self,event)
		local wishlist = load('return '..event.wishlist)()
		self.item = wishlist[ownPlayerID] or ""
	end, self)
end