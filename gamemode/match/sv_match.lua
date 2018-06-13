--[[

	Server Side Matchmaking

]]

GM.Match = (GAMEMODE or GM).Match or {}

GM.Match.Queue = (GAMEMODE or GM).Match.Queue or {}

GM.Match.Cars = (GAMEMODE or GM).Match.Cars or {}

util.AddNetworkString( "gRocket_UpdateMatch" )
util.AddNetworkString( "gRocket_UpdatePlayerQueue" )
util.AddNetworkString( "gRocket_UpdateQueue" )
util.AddNetworkString( "gRocket_RequestQueue" )

util.AddNetworkString( "gRocket_RequestRandom" )
util.AddNetworkString( "gRocket_RequestLeave" )

util.AddNetworkString( "gRocket_AdminKick" )
util.AddNetworkString( "gRocket_AdminDisband" )

function GM.Match:InitialSpawn( ply )

	ply:SetInMatch( false )
	ply:SetInQueue( false )

	self:UpdateQueue()

end

function GM.Match:OnCarSpawned( ply , car )

	--[[for k, v in pairs( ents.FindByClass( "ent_boost_ball" ) ) do

		local yes = constraint.NoCollide( v, car, 0, 0 )

		if !yes then print("MEME") end

	end]]

end

function GM.Match:SpawnPlayerCar( ply )

	local car = ents.Create( "prop_vehicle_jeep_old" )
	car:SetModel("models/tdmcars/focusrs.mdl")
	car:SetKeyValue("vehiclescript","scripts/vehicles/TDMCars/focusrs.txt")
	car:SetPos( GAMEMODE.Config.CarPos )
	car:SetAngles( GAMEMODE.Config.CarAng )
	car.Owner = ply
	car:Spawn()
	car:Activate()

	ply:EnterVehicle( car )

	self.Cars[ply:SteamID64()] = car

	self.OnCarSpawned( ply , car )

end

function GM.Match:CreateLobby( ply , security )

	local lobbyTable = {

		["Security"] = security,
		["Leader"] = ply,
		["Players"] = {

			["Team1"] = {},
			["Team2"] = {},

		}

	}

	local index = table.insert( self.Queue , lobbyTable )

	self:JoinQueue( ply , index )

end

function GM.Match:JoinQueue( ply , queueID )

	local plyName = ply:Nick()

	if (#self.Queue[queueID]["Players"]["Team1"] > #self.Queue[queueID]["Players"]["Team2"]) then
		table.insert( self.Queue[queueID]["Players"]["Team2"] , ply )
		ply:SetTeamName("Team2")
	else
		table.insert( self.Queue[queueID]["Players"]["Team1"] , ply )
		ply:SetTeamName("Team1")
	end

	ply:SetInQueue( true )
	ply:SetQueueID( queueID )

	self:UpdatePlayerQueue( ply , true )
	self:UpdateQueue()

end

function GM.Match:JoinRandomQueue( ply )

	if !ply:IsInMatch() and !ply:IsInQueue() then

		local foundQueue = false

		// Find Open Random Queue:
		for k, v in pairs(self.Queue) do
			if v["Security"] == "open" then

				// If team is full
				if (#v["Players"]["Team1"] == 3) and (#v["Players"]["Team2"] == 3) then return end

				// If everything is good, set the queue id
				foundQueue = k
				break // quit loop
			end
		end

		// Check if queue is set
		if foundQueue then
			self:JoinQueue( ply , foundQueue )
		else // If not then create a new open lobby
			self:CreateLobby( ply , "open" )
		end		

	end

end

net.Receive("gRocket_RequestRandom",function(len,ply)

	GAMEMODE.Match:JoinRandomQueue( ply )

end)

function GM.Match:JoinMatch( ply )

	if !ply:IsInMatch() and ply:IsInQueue() then
		
		ply:SetInMatch( true )
		ply:SetInQueue( false )
		self:SpawnPlayerCar( ply )
		GAMEMODE.Car:PlayerJoinedMatch( ply )

		self:UpdateMatch( ply , true )

	end

end

function GM.Match:UpdateMatch( ply , inMatch )

	net.Start("gRocket_UpdateMatch")
		net.WriteBool( inMatch )
	net.Send( ply )

end

function GM.Match:UpdatePlayerQueue( ply , inQueue )

	net.Start("gRocket_UpdatePlayerQueue")
		net.WriteBool( inQueue )
	net.Send( ply )

end

function GM.Match:UpdateQueue()

	net.Start("gRocket_UpdateQueue")
		net.WriteTable( self.Queue )
	net.Broadcast()

end

function GM.Match:GetGroupPlayers( groupID )

	local plyTable = {}

	if !self.Queue[groupID] then return end

	for k, v in pairs(self.Queue[groupID]["Players"]["Team1"]) do

		table.insert( plyTable , v )

	end

	for k, v in pairs(self.Queue[groupID]["Players"]["Team2"]) do

		table.insert( plyTable , v )

	end

	return plyTable

end

function GM.Match:RequestQueue( ply )

	local plyTable = {}

	for k, v in pairs( player.GetAll() ) do

		if !v:IsInQueue() and !v:IsInMatch() then
			table.insert( plyTable, v )
		end

	end

	net.Start( "gRocket_RequestQueue" )
		net.WriteTable( plyTable )
	net.Send( ply )

end

function GM.Match:PlayerLeaveMatch( ply )

	if !ply:GetCar() then return end

	ply:RemoveCar()

	ply:SetInMatch( false )

	self:UpdateMatch( ply , false )

end

function GM.Match:PlayerLeaveQueue( ply )

	if !ply:IsInQueue() then return end
	if !ply:GetQueueID() then return end

	local queueID = ply:GetQueueID()

	table.RemoveByValue( self.Queue[queueID]["Players"]["Team1"] , ply )
	table.RemoveByValue( self.Queue[queueID]["Players"]["Team2"] , ply )

	if (#self.Queue[queueID]["Players"]["Team1"] == 0) and (#self.Queue[queueID]["Players"]["Team2"] == 0) then
		self.Queue[queueID] = nil
	end

	ply:SetInQueue( false )
	ply:SetQueueID( nil )

	self:UpdatePlayerQueue( ply , false )
	self:UpdateQueue()	

end

function GM.Match:KickPlayer( ply , kickPlayer )

	if !ply:GetQueueID() then return end
	if !kickPlayer:GetQueueID() then return end

	local queueID = ply:GetQueueID()
	local kickQueueID = kickPlayer:GetQueueID()

	if !( queueID == kickQueueID ) then return end

	if !ply:IsTeamLeader( queueID ) then return end

	table.RemoveByValue( self.Queue[queueID]["Players"][kickPlayer:GetTeamName()] , kickPlayer )

	if (#self.Queue[queueID]["Players"]["Team1"] == 0) and (#self.Queue[queueID]["Players"]["Team2"] == 0) then
		self.Queue[queueID] = nil
	end

	ply:SetInQueue( false )
	ply:SetQueueID( nil )	

	self:UpdatePlayerQueue( kickPlayer , false )
	self:UpdateQueue()

end
net.Receive("gRocket_AdminKick",function( len,ply )
	local kickply = net.ReadEntity()
	GAMEMODE.Match:KickPlayer( ply , kickply )
end)

function GM.Match:DisbandGroup( ply )

	if !ply:GetQueueID() then return end

	local queueID = ply:GetQueueID()

	if !ply:IsTeamLeader( queueID ) then return end

	for k, v in pairs( self:GetGroupPlayers(queueID) ) do

		self:KickPlayer( ply , v )

	end

end
net.Receive("gRocket_AdminDisband",function( len,ply )
	GAMEMODE.Match:DisbandGroup( ply )
end)

net.Receive("gRocket_RequestLeave",function(len,ply)

	GAMEMODE.Match:PlayerLeaveQueue(ply)

end)

concommand.Add("join_match",function( ply, cmd, args )

	GAMEMODE.Match:JoinMatch( ply )

end)

concommand.Add("leave_match",function( ply, cmd, args )

	GAMEMODE.Match:PlayerLeaveMatch( ply )

end)

concommand.Add("get_queue",function( ply, cmd, args )

	PrintTable( GAMEMODE.Match.Queue )

end)

local pmeta = FindMetaTable( "Player" )

function pmeta:SetInMatch( inMatch )

	self.inMatch = inMatch

end

function pmeta:SetInQueue( inQueue )

	self.inQueue = inQueue

end

function pmeta:SetQueueID( queueID )

	self.queueID = queueID

end

function pmeta:GetQueueID()

	return self.queueID or false

end

function pmeta:SetTeamName( teamName )

	self.teamName = teamName

end

function pmeta:GetTeamName()

	return self.teamName or false

end

function pmeta:IsTeamLeader( queueID )

	if (GAMEMODE.Match.Queue[queueID]["Leader"] == self) then
		return true
	else
		return false
	end

end

function pmeta:IsInMatch()

	return self.inMatch

end

function pmeta:IsInQueue()

	return self.inQueue

end

function pmeta:GetCar()

	if !GAMEMODE.Match.Cars[self:SteamID64()] then return end

	return GAMEMODE.Match.Cars[self:SteamID64()]

end

function pmeta:RemoveCar()

	local car = self:GetCar()
	local driver = car:GetDriver() or false

	if driver then
		driver:ExitVehicle()
		driver:SetPos( GAMEMODE.Config.SpawnPos )
	end

	car:Remove()
	GAMEMODE.Match.Cars[self:SteamID64()] = nil

end