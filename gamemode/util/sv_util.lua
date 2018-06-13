--[[

	Server Side Utilities

]]

GM.Util = (GAMEMODE or GM).Util or {}

function GM.Util:FindPlayerByName( plyName )

	for k, v in pairs( player.GetAll() ) do

		if v:Nick() == plyName then

			return v

		end

	end

end

function GM.Util:IsTableEmpty( checkTable )

	if next(checkTable) == nil then
	   return false
	end

	return true

end