ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "gRocket Boost Ball"
ENT.Category = "gRocket"

ENT.Spawnable = true

function ENT:SetupDataTables()

	self:NetworkVar( "Bool" , 0 , "BallAvailable" )

end