--[[

	Client Side Matchmaking

]]

GM.Match = (GAMEMODE or GM).Match or {}

GM.Match.Queue = (GAMEMODE or GM).Match.Queue or {}

function GM.Match:UpdateMatch( inMatch )

	LocalPlayer():SetInMatch( inMatch )

end

function GM.Match:UpdateQueue( queueTable )

	self.Queue = queueTable

end

function GM.Match:UpdatePlayerQueue( inQueue )

	LocalPlayer():SetInQueue( inQueue )

end

net.Receive("gRocket_UpdateMatch",function()

	local inMatch = net.ReadBool()

	GAMEMODE.Match:UpdateMatch( inMatch )

end)

net.Receive("gRocket_UpdateQueue",function()

	local queueTable = net.ReadTable()

	GAMEMODE.Match:UpdateQueue( queueTable )

end)

net.Receive("gRocket_UpdatePlayerQueue",function()

	local inQueue = net.ReadBool()

	GAMEMODE.Match:UpdatePlayerQueue( inQueue )

end)

local pmeta = FindMetaTable( "Player" )

function pmeta:SetInMatch( inMatch )

	self.inMatch = inMatch

end

function pmeta:SetInQueue( inQueue )

	self.inQueue = inQueue

end

function pmeta:IsInMatch()

	return self.inMatch or false

end

function pmeta:IsInQueue()

	return self.inQueue or false

end

concommand.Add("getQueue",function()

	PrintTable( GAMEMODE.Match.Queue )

end)