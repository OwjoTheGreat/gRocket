--[[

	Server Side Manifest

]]

// Server Side Includes

include( "config/sh_config.lua" )
include( "config/sv_config.lua" )

include( "match/sv_match.lua" )

include( "map/sv_map.lua" )

include( "car/sv_car.lua" )


// ClientSide AddCSLua Files:

AddCSLuaFile( "cl_manifest.lua" )

AddCSLuaFile( "config/sh_config.lua" )

AddCSLuaFile( "car/cl_car.lua" )

AddCSLuaFile( "match/cl_match.lua" )