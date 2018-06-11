include("shared.lua")

surface.CreateFont( "queue_font", {
	font = "Roboto",
	extended = false,
	size = 20,
	antialias = true
} )

local queue1 = {
	
	["Team1"] = { "Jake Butts", "Owain Owjo", "Mike Sano" },
	["Team2"] = { "DinglePringle", "Pedz", "Keron" }

}

local function DrawGame( queueID , xPos , yPos )

	draw.RoundedBox(0,xPos,yPos,260,260,Color(255,255,255))

	draw.RoundedBox(0,xPos,yPos,260,50,Color(0,0,0))
	draw.SimpleText("Queue: "..queueID,"DermaLarge",xPos+130,yPos+25,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	local boxYPos = yPos + 50
	local boxColor = { Color(34,139,34), Color(0,100,0) }
	local boxCol = boxColor[2]

	for k, v in pairs( GAMEMODE.Match.Queue[queueID]["Team1"] ) do

		draw.RoundedBox(0,xPos,boxYPos,260,35,boxCol)
		draw.SimpleText(v,"queue_font",xPos+130,boxYPos + 17.5,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

		boxYPos = boxYPos + 35
		if boxCol == boxColor[1] then
			boxCol = boxColor[2]
		else
			boxCol = boxColor[1]
		end

	end

	local boxColor = { Color(255,99,71), Color(255,69,0) }
	local boxCol = boxColor[2]	

	for k, v in pairs( GAMEMODE.Match.Queue[queueID]["Team2"] ) do

		draw.RoundedBox(0,xPos,boxYPos,260,35,boxCol)
		draw.SimpleText(v,"queue_font",xPos+130,boxYPos + 17.5,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

		boxYPos = boxYPos + 35
		if boxCol == boxColor[1] then
			boxCol = boxColor[2]
		else
			boxCol = boxColor[1]
		end

	end	

end

function ENT:Draw()

	local mainWide = 950
	local mainTall = 950

	local camPos = self:LocalToWorld( Vector( -(mainTall/10)/2 , -(mainWide/10)/2 , -1 ) )
	local camAng = self:LocalToWorldAngles( Angle( 0, 90, 0 ) )

	//self:DrawModel()

	cam.Start3D2D( camPos , camAng , 0.1)

		draw.RoundedBox(0,0,0,mainWide,mainTall,color_white)
		draw.RoundedBox(0,25,25,mainWide-50,mainTall-50,Color(0,150,244))

		local drawX1 = 25 + 30
		local drawX2 = drawX1 + 260 + 30
		local drawX3 = drawX2 + 260 + 30

		local drawY1 = 150
		local drawY2 = drawY1 + 260 + 30

		if GAMEMODE.Match.Queue[1] then
			DrawGame( 1 , drawX1 , drawY1 )
		end

		if GAMEMODE.Match.Queue[2] then
			DrawGame( 2 , drawX2 , drawY1 )
		end

		if GAMEMODE.Match.Queue[3] then
			DrawGame( 3 , drawX3 , drawY1 )
		end

		if GAMEMODE.Match.Queue[4] then
			DrawGame( 4 , drawX1 , drawY2 )
		end

		if GAMEMODE.Match.Queue[5] then
			DrawGame( 5 , drawX2 , drawY2 )
		end

		if GAMEMODE.Match.Queue[6] then
			DrawGame( 6 , drawX3 , drawY2 )
		end

		draw.SimpleText("gRocket Queue","DermaLarge",mainWide/2,70,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	cam.End3D2D()

end