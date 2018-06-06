--[[

	Server Side Car Files

]]

GM.Car = (GAMEMODE or GM).Car or {}

GM.Car.Boosts = (GAMEMODE or GM).Car.Boosts or {}

function GM.Car:Jump( ply )

	if !ply:GetCar() then return end

	local car = ply:GetCar()

	local phys = car:GetPhysicsObject()

	local speed = car:GetSpeed()
	local angle = speed / -0.90

	print( angle )

	phys:AddAngleVelocity( Vector( angle , 0 , 0 ) )
	phys:AddVelocity( Vector( 0, 0, 750 ) )

end

function GM.Car:Boost( ply )

	if !ply:GetCar() then return end

	local car = ply:GetCar()

	local phys = car:GetPhysicsObject()

	self.Boosts[ply:SteamID64()] = car

	timer.Create( "GROCKET_BOOST"..ply:SteamID64() , 0.1 , 0 , function()

		if self.Boosts[ply:SteamID64()] then

			phys:AddVelocity( Vector( 200 , 0 , 0 ) )

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