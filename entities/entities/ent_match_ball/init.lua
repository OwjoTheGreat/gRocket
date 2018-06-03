AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT.Initialize(self)

	self:SetModel("models/props_phx/misc/soccerball.mdl")
	self:SetModelScale( 10 , 0 )
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
		phys:SetMass( 10 )
	end

end

function ENT:Use(activator)

	if activator:IsPlayer() and activator:Alive() then

		GAMEMODE.Match:JoinMatch( activator )

	end

end