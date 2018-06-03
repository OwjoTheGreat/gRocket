--[[

	Server Side Initialization

]]

// AddCSLua Files:
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

// Include Lua Files:
include( "shared.lua" )
include( "sv_manifest.lua" )

function GM:Initialize()

end

function GM:CanPlayerSuicide()
	return false
end