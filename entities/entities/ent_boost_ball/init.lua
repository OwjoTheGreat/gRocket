AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT.Initialize(self)

	self:SetModel("models/dav0r/hoverball.mdl")
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetColor( 255, 127, 0 )

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
	end

end

function ENT:StartTouch( ent )

	if ent:GetClass() == "prop_vehicle_jeep_old" then
		
		if self:GetBallAvailable() then
			
			local ply = ent:GetDriver()
			if !IsValid( ply ) then return end

			ply:AddBoost( GAMEMODE.Config.BigBoostAmount )
			self:Remove()

		end

	end

end