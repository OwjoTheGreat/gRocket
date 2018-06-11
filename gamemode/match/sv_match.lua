--[[

	Server Side Matchmaking

]]

GM.Match = (GAMEMODE or GM).Match or {}

GM.Match.Queue = (GAMEMODE or GM).Match.Queue or {}
GM.Match.Queue_Client = (GAMEMODE or GM).Match.Queue_Client or {}

GM.Match.Cars = (GAMEMODE or GM).Match.Cars or {}

util.AddNetworkString( "gRocket_UpdateMatch" )
util.AddNetworkString( "gRocket_UpdatePlayerQueue" )
util.AddNetworkString( "gRocket_UpdateQueue" )

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

function GM.Match:JoinQueue( ply )

	if !ply:IsInMatch() and !ply:IsInQueue() then

		ply:SetInQueue( true )

		// Temp
		if !self.Queue[1] then
			self.Queue[1] = {}
			self.Queue[1]["Team1"] = {}
			self.Queue[1]["Team2"] = {}
		end

		self.Queue[1]["Team1"][ply:SteamID64()] = true

		if !self.Queue_Client[1] then

			self.Queue_Client[1] = {}
			self.Queue_Client[1]["Team1"] = {}
			self.Queue_Client[1]["Team2"] = {}

		end

		table.insert( self.Queue_Client[1]["Team1"] , ply:Name() )

		self:UpdatePlayerQueue( ply , true )

		self:UpdateQueue()

	end

end

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
		net.WriteTable( self.Queue_Client )
	net.Broadcast()

end

function GM.Match:PlayerLeaveMatch( ply )

	if !ply:GetCar() then return end

	ply:RemoveCar()

	ply:SetInMatch( false )

	self:UpdateMatch( ply , false )

end

concommand.Add("leave_match",function( ply, cmd, args )

	GAMEMODE.Match:PlayerLeaveMatch( ply )

end)

local pmeta = FindMetaTable( "Player" )

function pmeta:SetInMatch( inMatch )

	self.inMatch = inMatch

end

function pmeta:SetInQueue( inQueue )

	self.inQueue = inQueue

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