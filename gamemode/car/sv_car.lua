--[[

	Server Side Car Files

]]

GM.Car = (GAMEMODE or GM).Car or {}

GM.Car.Boosts = (GAMEMODE or GM).Car.Boosts or {}
GM.Car.Jumps = (GAMEMODE or GM).Car.Jumps or {}

GM.Car.BoostAmounts = (GAMEMODE or GM).Car.BoostAmounts or {}

util.AddNetworkString( "gRocket_UpdateBoost" )

function UpdateBoost( ply )

	net.Start( "gRocket_UpdateBoost" )
		net.WriteInt( GAMEMODE.Car.BoostAmounts[ply:SteamID64()] , 16 )
	net.Send( ply )

end

function GM.Car:Initialize()

	timer.Create("GROCKET_BOOSTCHECK",0.2,0,function()

		for k, v in pairs( player.GetAll() ) do

			if timer.Exists( "GROCKET_BOOST"..v:SteamID64() ) then

				if !v:IsInMatch() then return end
				
				if (GAMEMODE.Car.BoostAmounts[v:SteamID64()] - 1) >= 0 then

					GAMEMODE.Car.BoostAmounts[v:SteamID64()] = GAMEMODE.Car.BoostAmounts[v:SteamID64()] - 5
					UpdateBoost( v )

				else

					timer.Remove( "GROCKET_BOOST"..v:SteamID64() )

				end

			end

		end

	end)

end

function GM.Car:PlayerJoinedMatch( ply )

	GAMEMODE.Car.BoostAmounts[ply:SteamID64()] = 33
	UpdateBoost( ply )

end

function GM.Car:Jump( ply )

	if !ply:GetCar() then return end

	local jumpAmount = 0

	if self.Jumps[ply:SteamID64()] then
		jumpAmount = self.Jumps[ply:SteamID64()][1]
	end

	if jumpAmount >= 1 then	
		if self.Jumps[ply:SteamID64()][2] + 2 > CurTime() then
			return
		else
			self.Jumps[ply:SteamID64()] = { 0 , CurTime() }
		end
	else
		self.Jumps[ply:SteamID64()] = { jumpAmount +1 , CurTime() }
	end

	local car = ply:GetCar()

	local phys = car:GetPhysicsObject()

	local speed = car:GetSpeed()
	local angle = speed / -0.80

	phys:AddAngleVelocity( Vector( angle , 0 , 0 ) )
	phys:AddVelocity( Vector( 0, 0, 500 ) )

end

function GM.Car:Boost( ply )

	if !ply:GetCar() then return end

	local car = ply:GetCar()

	local phys = car:GetPhysicsObject()

	self.Boosts[ply:SteamID64()] = car

	timer.Create( "GROCKET_BOOST"..ply:SteamID64() , 0.2 , 0 , function()

		if self.Boosts[ply:SteamID64()] then

			phys:AddVelocity( car:GetForward() * GAMEMODE.Config.BoostMultiplier )

		else

			timer.Remove( "GROCKET_BOOST"..ply:SteamID64() )

		end

	end)

end

function GM.Car:KeyPress( ply , key )

	if ( key == IN_ATTACK ) then
		
		self:Jump( ply )

	end

	if ( key == IN_ATTACK2 ) then
		
		self:Boost( ply )

	end	

end

function GM.Car:KeyRelease( ply , key )

	if ( key == IN_ATTACK2 ) then
		
		self.Boosts[ply:SteamID64()] = nil

	end	

end

local pmeta = FindMetaTable( "Player" )

function pmeta:AddBoost( amount )

	if (GAMEMODE.Car.BoostAmounts[self:SteamID64()] + amount) > 100 then
		
		GAMEMODE.Car.BoostAmounts[self:SteamID64()] = 100

	else

		GAMEMODE.Car.BoostAmounts[self:SteamID64()] = GAMEMODE.Car.BoostAmounts[self:SteamID64()] + amount

	end

	UpdateBoost( self )

end