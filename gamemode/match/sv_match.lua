--[[

	Server Side Matchmaking

]]

GM.Match = (GAMEMODE or GM).Match or {}

GM.Match.Cars = (GAMEMODE or GM).Match.Cars or {}

util.AddNetworkString( "gRocket_UpdateMatch" )

function GM.Match:InitialSpawn( ply )

	ply:SetInMatch( false )

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

function GM.Match:JoinMatch( ply )

	if !ply:IsInMatch() then
		
		ply:SetInMatch( true )
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

function pmeta:IsInMatch()

	return self.inMatch

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