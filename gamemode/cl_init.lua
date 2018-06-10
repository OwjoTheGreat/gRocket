--[[

	Client Side Initialization

]]

// Include Lua Files:

include( "shared.lua" )

include( "cl_manifest.lua" )

function GM:Initialize()

end

hook.Add( "HUDShouldDraw", "hide hud", function( name )
     if ( name == "CHudHealth" or name == "CHudBattery" ) then
         return false
     end
end )