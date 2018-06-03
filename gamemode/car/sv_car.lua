--[[

	Server Side Matchmaking

]]

GM.Car = (GAMEMODE or GM).Car or {}

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

function GM.Car:KeyPress( ply , key )

	if ( key == IN_ATTACK ) then
		
		self:Jump( ply )

	end

end