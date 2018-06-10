AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT.Initialize(self)

	self:SetModel("models/dav0r/hoverball.mdl")
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetColor( 255, 127, 0 )

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
		phys:EnableMotion( false )
		phys:EnableCollisions( false )
	end

	self:SetBallAvailable( true )

end

function ENT:BoostTouch( ent )

	if ent:GetClass() == "prop_vehicle_jeep" then
		
		if self:GetBallAvailable() then
			
			local ply = ent:GetDriver()
			if !IsValid( ply ) then return end

			ply:AddBoost( GAMEMODE.Config.BigBoostAmount )
			self:SetBallAvailable( false )

			timer.Simple(GAMEMODE.Config.BoostDelay,function()

				self:SetBallAvailable( true )

			end)

		end

	end

end

function ENT:Think()

	for k, v in pairs( ents.FindInSphere( self:GetPos() , 10 ) ) do

		self:BoostTouch( v )

	end

end