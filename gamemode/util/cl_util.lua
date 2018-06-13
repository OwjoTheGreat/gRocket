--[[

	Client Side Utilities

]]

GM.Util = (GAMEMODE or GM).Util or {}

GM.Util.Images = (GAMEMODE or GM).Util.Images or {}

file.CreateDir("grocket")

function GM.Util:SaveImage(data, id)
	file.Write( "grocket/"..id..".png", data )
end

function GM.Util:CacheImage(id,name)
	self.Images[name] = Material("data/grocket/"..id..".png")
end

function GM.Util:CheckImage(id,name)
	if file.Exists( "grocket/"..id..".png", "DATA" ) then
		if !self.Images[name] then
			self:CacheImage(id,name)
		end
	else
		return false
	end
end

function GM.Util:DownloadImage(id,name)
	if self:CheckImage(id,name) then return end
	local userURL = "https://i.imgur.com/"..id..".png"
	http.Fetch( userURL,
		function( body, len, headers, code )
			self:SaveImage(body, id)
			self:CacheImage(id,name)
		end
	)
end

function GM.Util:IsTableEmpty( checkTable )

	if next(checkTable) == nil then
	   return false
	end

	return true

end