include("shared.lua")

function ENT:Draw()

	local camPos = self:LocalToWorld( Vector( -0.5, -10, 1 ) )

	local camAng = self:LocalToWorldAngles( Angle( 0, 0, 90 ) )

	self:DrawModel()

	cam.Start3D2D( camPos , camAng , 0.1)	
	cam.End3D2D()	

end