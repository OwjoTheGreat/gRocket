include("shared.lua")

function ENT:Draw()

	//self:DrawModel()

	local entOpacity = 255

	if self:GetBallAvailable() then
		entOpacity = 255
	else
		entOpacity = 100
	end

	render.SetColorMaterial()

	render.DrawSphere( self:GetPos() , 10, 50, 50, Color( 255, 127, 0, entOpacity ) )

end