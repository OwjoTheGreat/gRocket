include("shared.lua")

surface.CreateFont( "queue_font", {
	font = "Roboto",
	extended = false,
	size = 20,
	antialias = true
} )

surface.CreateFont( "queue_font_mid", {
	font = "Roboto",
	extended = false,
	size = 25,
	antialias = true
} )

surface.CreateFont( "queue_font_large", {
	font = "Roboto",
	extended = false,
	size = 50,
	antialias = true
} )

surface.CreateFont( "queue_font_larger", {
	font = "Roboto",
	extended = false,
	size = 100,
	antialias = true
} )

local starMat = Material( "icon16/shield.png" )

local function DrawGame( queueID , xPos , yPos )

	if !GAMEMODE.Match.Queue[queueID] then return end
	if !GAMEMODE.Match.Queue[queueID]["Players"]["Team1"] then return end
	if !GAMEMODE.Match.Queue[queueID]["Players"]["Team2"] then return end

	draw.RoundedBox(0,xPos,yPos,260,260,Color(255,255,255))

	draw.RoundedBox(0,xPos,yPos,260,50,Color(0,0,0))

	local lobbyText = "Lobby: "

	if GAMEMODE.Match.Queue[queueID]["Security"] == "open" then
		lobbyText = "Public Lobby: "
	else
		lobbyText = "Private Lobby: "
	end

	draw.SimpleText(lobbyText..queueID,"queue_font_mid",xPos+130,yPos+25,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	local boxYPos = yPos + 50
	local boxColor = { Color(34,139,34), Color(0,100,0) }
	local boxCol = boxColor[2]

	for k, v in pairs( GAMEMODE.Match.Queue[queueID]["Players"]["Team1"] ) do

		if !IsValid(v) then return end

		draw.RoundedBox(0,xPos,boxYPos,260,35,boxCol)

		if v:IsTeamLeader(queueID) then
			local iconSize = 16
			surface.SetMaterial( starMat )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( xPos + 70, boxYPos +10, iconSize, iconSize )
			draw.NoTexture()
			draw.SimpleText(v:Nick(),"queue_font",xPos+130,boxYPos + 17.5,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(v:Nick(),"queue_font",xPos+130,boxYPos + 17.5,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end

		boxYPos = boxYPos + 35
		if boxCol == boxColor[1] then
			boxCol = boxColor[2]
		else
			boxCol = boxColor[1]
		end

	end

	local boxColor = { Color(255,99,71), Color(255,69,0) }
	local boxCol = boxColor[2]	

	for k, v in pairs( GAMEMODE.Match.Queue[queueID]["Players"]["Team2"] ) do

		draw.RoundedBox(0,xPos,boxYPos,260,35,boxCol)

		if v:IsTeamLeader(queueID) then
			local iconSize = 16
			surface.SetMaterial( starMat )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( xPos + 70, boxYPos +10, iconSize, iconSize )
			draw.NoTexture()
			draw.SimpleText(v:Nick(),"queue_font",xPos+130,boxYPos + 17.5,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(v:Nick(),"queue_font",xPos+130,boxYPos + 17.5,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end

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

		draw.SimpleText("gRocket Queue","queue_font_large",mainWide/2,80,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

		local drawX1 = 25 + 30
		local drawX2 = drawX1 + 260 + 30
		local drawX3 = drawX2 + 260 + 30

		local drawY1 = 150
		local drawY2 = drawY1 + 260 + 30
		local drawY3 = drawY2 + 260 + 30

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

		// Bottom Left Box
		draw.RoundedBox(0,drawX1,drawY3,260,165,Color(255,255,255))
		draw.SimpleText("0","queue_font_larger",drawX1 +130,drawY3 +82.5,Color(0,100,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

		draw.RoundedBox(0,drawX2,drawY3,260,165,Color(255,255,255))
		draw.SimpleText("5:00","queue_font_larger",drawX2 +130,drawY3 +82.5,Color(0,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

		draw.RoundedBox(0,drawX3,drawY3,260,165,Color(255,255,255))
		draw.SimpleText("0","queue_font_larger",drawX3 +130,drawY3 +82.5,Color(255,69,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	cam.End3D2D()

end