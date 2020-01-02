bid = class({})
bid.gold = 1

function bid:GetGoldCost()
	return self.gold
end

function bid:GetIntrinsicModifierName()
	return "bidmodifier"
end

function bid:OnSpellStart()
	local hero = self:GetCaster()
	FireGameEvent("placed_bid",{playerID = hero:GetPlayerID(), gold = self.gold })
end


bid50 = class(bid)
bid50.gold = 50
bid250 = class(bid)
bid250.gold = 250

-------------------------------------------------------------------------------------------------------------------------------
-- everything down from here is a modifier. LinkLuaModifier adds it to the game, so the AddNewModifier(..) knows where to find it.

--               modifiername used below ,       filepath            , weird valve thing
LinkLuaModifier( "bidmodifier", "abilities/bid", LUA_MODIFIER_MOTION_NONE )

bidmodifier = class({})

bidmodifier.item = "item_lifesteal"
bidmodifier.maxbidder = -1

function bidmodifier:GetTexture() return self.item end
function bidmodifier:IsDebuff()
	return self.maxbidder ~= self:GetParent():GetPlayerID()
end

function bidmodifier:IsPermanent() return true end

function bidmodifier:OnCreated( kv )
	local hero = self:GetParent()
	local ownPlayerID = hero:GetPlayerID()
	ListenToGameEvent("current_item",function(event)
		local item = event.currentItem
		local bids = event.bids
		local maxbidder = event.maxbidder_playerid
		local ownBid = bids[ownPlayerID]
	end,nil)
end

function bidmodifier:OnRefresh( kv )
end

