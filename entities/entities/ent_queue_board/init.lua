AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT.Initialize(self)

	self:SetModel("models/hunter/plates/plate2x2.mdl")
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:DrawShadow( false )

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
		phys:EnableMotion( false )
		phys:EnableCollisions( false )			
	end

end