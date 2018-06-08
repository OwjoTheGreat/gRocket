--[[

	Client Side Car Files

]]

GM.Car = (GAMEMODE or GM).Car or {}

GM.Car.Boost = (GAMEMODE or GM).Car.Boost or {}

function GM.Car:UpdateBoost( boostAmount )

	self.Boost = boostAmount

end

net.Receive("gRocket_UpdateBoost",function(len)

	local boost = net.ReadInt(16)

	GAMEMODE.Car:UpdateBoost( boost )

end)

hook.Add("HUDPaint", "gRocket_BoostHud" , function()

	local boost = 0

	if tonumber(GAMEMODE.Car.Boost) then
		
		boost = GAMEMODE.Car.Boost

	end

	draw.RoundedBox(0,ScrW()-120,ScrH()-275,100,50,Color(0,0,0,255))

	draw.SimpleText(boost,"DermaLarge",ScrW()-70,ScrH()-250,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

end)