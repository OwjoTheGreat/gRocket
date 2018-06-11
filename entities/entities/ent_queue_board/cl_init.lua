include("shared.lua")

function ENT:Draw()

	local mainWide = 950
	local mainTall = 950

	local camPos = self:LocalToWorld( Vector( -(mainTall/10)/2 , -(mainWide/10)/2 , -1 ) )
	local camAng = self:LocalToWorldAngles( Angle( 0, 90, 0 ) )

	//self:DrawModel()

	cam.Start3D2D( camPos , camAng , 0.1)

		draw.RoundedBox(0,0,0,mainWide,mainTall,Color(255,0,0))
		draw.SimpleText("JOIN QUEUE","DermaLarge",mainWide/2,mainTall/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	cam.End3D2D()	

end