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

local boost = 0
local oldBoost = 0

hook.Add("HUDPaint", "gRocket_BoostHud" , function()

	if !LocalPlayer():IsInMatch() then return end

	if tonumber(GAMEMODE.Car.Boost) then
		boost = GAMEMODE.Car.Boost
	end

	boost = Lerp(0.01,oldBoost,boost)
	oldBoost = boost

	draw.RoundedBox(0,ScrW()/2-200,ScrH()-100,400,50,Color(0,0,0,240))

	draw.RoundedBox(0,ScrW()/2-(390/2),ScrH()-95, 390 ,40,Color(220,220,220,20))
	draw.RoundedBox(0,ScrW()/2-(390/2),ScrH()-95, boost *3.9 ,40,Color(255,0,0,240))

	//draw.SimpleText(boost,"DermaLarge",ScrW()-70,ScrH()-75,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

end)