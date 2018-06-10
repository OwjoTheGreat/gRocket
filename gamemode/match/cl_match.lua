--[[

	Client Side Matchmaking

]]

GM.Match = (GAMEMODE or GM).Match or {}

function GM.Match:UpdateMatch( inMatch )

	LocalPlayer():SetInMatch( inMatch )

end

net.Receive("gRocket_UpdateMatch",function()

	local inMatch = net.ReadBool()

	GAMEMODE.Match:UpdateMatch( inMatch )

end)

local pmeta = FindMetaTable( "Player" )

function pmeta:SetInMatch( inMatch )

	self.inMatch = inMatch

end

function pmeta:IsInMatch()

	return self.inMatch or false

end