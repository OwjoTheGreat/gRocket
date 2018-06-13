--[[

	Client Side Matchmaking

]]

GM.Match = (GAMEMODE or GM).Match or {}

GM.Match.Queue = (GAMEMODE or GM).Match.Queue or {}

function GM.Match:UpdateMatch( inMatch )

	LocalPlayer():SetInMatch( inMatch )

end

function GM.Match:UpdateQueue( queueTable )

	self.Queue = queueTable

end

function GM.Match:UpdatePlayerQueue( inQueue )

	LocalPlayer():SetInQueue( inQueue )

end

function GM.Match:KickPlayer( ply )

	net.Start("gRocket_AdminKick")
		net.WriteEntity( ply )
	net.SendToServer()

end

function GM.Match:LeaveGroup( ply )

	net.Start("gRocket_RequestLeave")
		net.WriteEntity( ply )
	net.SendToServer()

end

function GM.Match:DisbandGroup( ply )

	net.Start("gRocket_AdminDisband")
	net.SendToServer()

end

function GM.Match:GetFreePlayers()

	local queuedPlayers = {}

	local freePlayers = {}

	for k, v in pairs(self.Queue) do

		for key, val in pairs(v["Players"]["Team1"]) do
			table.insert( queuedPlayers , val )
		end

		for key, val in pairs(v["Players"]["Team2"]) do
			table.insert( queuedPlayers , val )
		end		

	end

	for k, v in pairs( player.GetAll() ) do

		if !table.HasValue( queuedPlayers , v ) then
			table.insert( freePlayers , v )
		end

	end

	return freePlayers

end

net.Receive("gRocket_UpdateMatch",function()

	local inMatch = net.ReadBool()

	GAMEMODE.Match:UpdateMatch( inMatch )

end)

net.Receive("gRocket_UpdateQueue",function()

	local queueTable = net.ReadTable()

	GAMEMODE.Match:UpdateQueue( queueTable )

end)

net.Receive("gRocket_UpdatePlayerQueue",function()

	local inQueue = net.ReadBool()

	GAMEMODE.Match:UpdatePlayerQueue( inQueue )

end)

local pmeta = FindMetaTable( "Player" )

function pmeta:SetInMatch( inMatch )

	self.inMatch = inMatch

end

function pmeta:SetInQueue( inQueue )

	self.inQueue = inQueue

end

function pmeta:GetQueueID()

	local queueID = false

	if self:IsInQueue() then

		for k, v in pairs( GAMEMODE.Match.Queue ) do
			for _, teamList in pairs( v["Players"] ) do
				for _, name in pairs(teamList) do
					if name:Nick() == self:Nick() then
						queueID = k
					end
				end
			end
		end

	end

	return queueID

end

function pmeta:SetInQueue( inQueue )

	self.inQueue = inQueue

end

function pmeta:IsInMatch()

	return self.inMatch or false

end

function pmeta:IsInQueue()

	return self.inQueue or false

end

function pmeta:IsTeamLeader( queueID )

	if (GAMEMODE.Match.Queue[queueID]["Leader"] == self) then
		return true
	else
		return false
	end
	
end

--[[


	Queue Menu VGUI


]]

local queueMenu

function GM.Match:OpenQueueMenu( playerList )

	if IsValid(queueMenu) then return end

	queueMenu = vgui.Create("DFrame")
	queueMenu:SetSize(500,500)
	queueMenu:Center()
	queueMenu:MakePopup()
	queueMenu:SetTitle("gRocket Queue Menu")
	queueMenu:SetDraggable(false)

	local bgPanel = vgui.Create("DPanel",queueMenu)
	bgPanel:SetPos(0,25)
	bgPanel:SetSize(500,475)
	bgPanel.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,color_white)
	end

	local queuePanel = vgui.Create("DPanel",bgPanel)
	queuePanel:SetPos(5,5)
	queuePanel:SetSize(bgPanel:GetWide()-10,bgPanel:GetTall()-10)
	queuePanel.Paint = function(self,w,h)end

	local randomButton = vgui.Create( "DButton",queuePanel )
	randomButton:SetText("")
	randomButton:SetPos(0,0)
	randomButton:SetSize( queuePanel:GetWide()/2 , queuePanel:GetTall()/2 )
	randomButton.Paint = function(self,w,h)

		draw.RoundedBox(0,0,0,w,h,Color(135,206,250))
		draw.SimpleText("Random Lobby","DermaLarge",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
	end

	randomButton.DoClick = function()

		net.Start("gRocket_RequestRandom")
		net.SendToServer()

		queueMenu:Close()

	end

	local leaveButton = vgui.Create( "DButton",queuePanel )
	leaveButton:SetText("")
	leaveButton:SetPos(0,queuePanel:GetTall()/2)
	leaveButton:SetSize( queuePanel:GetWide()/2 , queuePanel:GetTall()/2 )
	leaveButton.Paint = function(self,w,h)

		draw.RoundedBox(0,0,0,w,h,Color(0,191,255))
		draw.SimpleText("Leave Lobby","DermaLarge",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
	end

	leaveButton.DoClick = function()

		net.Start("gRocket_RequestLeave")
		net.SendToServer()

		queueMenu:Close()

	end

	local plyList = vgui.Create( "DListView", queuePanel )
	plyList:SetPos(queuePanel:GetWide()/2,queuePanel:GetTall()/2)
	plyList:SetSize( queuePanel:GetWide()/2 , queuePanel:GetTall()/2 )
	plyList:SetMultiSelect( true )
	plyList:SetDataHeight( 15 )
	plyList:AddColumn( "Players" )

	for k, v in pairs( playerList ) do

		plyList:AddLine( v:Name() )

	end	

	local privateButton = vgui.Create( "DButton",queuePanel )
	privateButton:SetText("")
	privateButton:SetPos(queuePanel:GetWide()/2,0)
	privateButton:SetSize( queuePanel:GetWide()/2 , queuePanel:GetTall()/2 )
	privateButton.Paint = function(self,w,h)

		draw.RoundedBox(0,0,0,w,h,Color(0,191,255))
		draw.SimpleText("Private Lobby","DermaLarge",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
	end
	privateButton.DoClick = function()

		local plyNames = {}

		for k, v in pairs(plyList:GetSelected()) do

			table.insert( plyNames , v:GetColumnText(1) )

		end

		if !GAMEMODE.Util:IsTableEmpty( plyNames ) then

			net.Start("gRocket_CreatePrivate")
				net.WriteTable( plyNames )
			net.SendToServer()

		end

		queueMenu:Close()

	end

end

net.Receive("gRocket_RequestQueue",function()
	local plyList = net.ReadTable()
	GAMEMODE.Match:OpenQueueMenu( plyList )
end)

--[[


	Queue Spawn Menu


]]

surface.CreateFont( "queueMenuFont", {
	font = "Roboto",
	extended = false,
	size = 25,
	antialias = true
} )

surface.CreateFont( "queueMenuFontLarge", {
	font = "Roboto",
	extended = false,
	size = 40,
	antialias = true
} )

local queueSpawnMenu
local starMat = Material( "icon16/shield.png" )

function GM.Match:OpenQueueSpawnMenu()

	if LocalPlayer():IsInMatch() then return end

	if IsValid(queueSpawnMenu) then return end

	queueSpawnMenu = vgui.Create("DFrame")
	queueSpawnMenu:SetSize(500,500)
	queueSpawnMenu:Center()
	queueSpawnMenu:MakePopup()
	queueSpawnMenu:SetTitle("gRocket Queue Menu")
	queueSpawnMenu:SetDraggable(false)
	queueSpawnMenu:ShowCloseButton(false)
	queueSpawnMenu.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,color_white)
	end	

	local queuePanel = vgui.Create("DPanel",queueSpawnMenu)
	queuePanel:SetPos(5,5)
	queuePanel:SetSize(queueSpawnMenu:GetWide()-10,queueSpawnMenu:GetTall()-10)
	queuePanel.Paint = function(self,w,h)end

	local titlePanel = vgui.Create("DPanel",queuePanel)
	titlePanel:SetPos(0,0)
	titlePanel:SetSize(queuePanel:GetWide(),queuePanel:GetTall()/10)
	titlePanel.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,191,255))
		draw.SimpleText("gRocket Queue Menu:","queueMenuFont",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local currentGamePanel = vgui.Create("DPanel",queuePanel)
	currentGamePanel:SetPos(0,queuePanel:GetTall()/10 + 5)
	currentGamePanel:SetSize(queuePanel:GetWide(),queuePanel:GetTall()/5)
	currentGamePanel.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(135,206,250))
		draw.SimpleText("Current Game:","queueMenuFont",w/2,h/5,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		draw.SimpleText("0 ".." | ".." 0","queueMenuFontLarge",w/2,h/1.6,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	// Left Panel

	local playerTitle = vgui.Create("DPanel",queuePanel)
	playerTitle:SetPos(0,queuePanel:GetTall()/10 + queuePanel:GetTall()/5 + 10)
	playerTitle:SetSize(queuePanel:GetWide()/2-2.5,queuePanel:GetTall()/10)
	playerTitle.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,191,255))
		draw.SimpleText("Your Queue:","queueMenuFont",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local queueID = LocalPlayer():GetQueueID()
	local groupLeader
	if queueID then
		groupLeader = LocalPlayer():IsTeamLeader( queueID )
	end

	local playerPanel = vgui.Create("DPanel",queuePanel)
	playerPanel:SetPos(0,(queuePanel:GetTall()/10)*2 + queuePanel:GetTall()/5 + 15)
	playerPanel:SetSize(queuePanel:GetWide()/2-2.5,queuePanel:GetTall()/3)
	playerPanel.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(135,206,250))

		if !queueID then
			draw.SimpleText("You're not in a queue!","queueMenuFont",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end

	local boxPosY = 0

	local chosenButton
	local chosenPly

	if queueID then

		local matchTable = GAMEMODE.Match.Queue[queueID]["Players"]

		for k, v in pairs( matchTable["Team1"] ) do

			local button = vgui.Create("DButton",playerPanel)
			button:SetSize( playerPanel:GetWide() , playerPanel:GetTall()/6 )
			button:SetPos( 0 , boxPosY )
			button:SetText("")
			button.Paint = function(self,w,h)

				local col = Color(34,139,34)

				if self:IsHovered() then
					col = Color(0,100,0)
				elseif self == chosenButton then
					col = Color(0,100,0)
				else
					col = Color(34,139,34)
				end

				draw.RoundedBox(0,0,0,w,h,col)

				draw.SimpleText(v:Nick(),"DermaDefault",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

				if v:IsTeamLeader(queueID) then
					local iconSize = 13
					surface.SetMaterial( starMat )
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.DrawTexturedRect( w/2-42, h/2 -iconSize/2, iconSize, iconSize )
					draw.NoTexture()
					draw.SimpleText(v:Nick(),"DermaDefault",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				else
					draw.SimpleText(v:Nick(),"DermaDefault",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
				end

			end
			button.DoClick = function(self)
				chosenButton = self
				chosenPly = v
			end

			boxPosY = boxPosY + playerPanel:GetTall()/6

		end	

		for k, v in pairs( matchTable["Team2"] ) do

			local button = vgui.Create("DButton",playerPanel)
			button:SetSize( playerPanel:GetWide() , playerPanel:GetTall()/6 )
			button:SetPos( 0 , boxPosY )
			button:SetText("")
			button.Paint = function(self,w,h)

				local col = Color(255,99,71)

				if self:IsHovered() then
					col = Color(255,69,0)
				elseif self == chosenButton then
					col = Color(255,69,0)
				else
					col = Color(255,99,71)
				end

				draw.RoundedBox(0,0,0,w,h,col)
				draw.SimpleText(v:Nick(),"DermaDefault",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

			end
			button.DoClick = function(self)
				chosenButton = self
				chosenPly = v
			end			

			boxPosY = boxPosY + playerPanel:GetTall()/6

		end

	end	

	// Right Panel

	local utilityTitle = vgui.Create("DPanel",queuePanel)
	utilityTitle:SetPos(queuePanel:GetWide()/2+2.5,queuePanel:GetTall()/10 + queuePanel:GetTall()/5 + 10)
	utilityTitle:SetSize(queuePanel:GetWide()/2-2.5,queuePanel:GetTall()/10)
	utilityTitle.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(0,191,255))
		draw.SimpleText("Utilities:","queueMenuFont",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local utilityPanel = vgui.Create("DPanel",queuePanel)
	utilityPanel:SetPos(queuePanel:GetWide()/2+2.5,(queuePanel:GetTall()/10)*2 + queuePanel:GetTall()/5 + 15)
	utilityPanel:SetSize(queuePanel:GetWide()/2-2.5,queuePanel:GetTall()/3)
	utilityPanel.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(135,206,250))

		if !queueID then
			draw.SimpleText("You're not in a queue!","queueMenuFont",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end		
	end		

	if queueID then

		local leaveButton = vgui.Create("DButton",utilityPanel)
		leaveButton:SetPos(0,0)
		leaveButton:SetSize(utilityPanel:GetWide(),utilityPanel:GetTall()/3)
		leaveButton:SetText("Leave Lobby")
		leaveButton.DoClick = function(self)

			GAMEMODE.Match:LeaveGroup( chosenPly )
			queueSpawnMenu:Close()

		end

		if groupLeader then

			local disbandButton = vgui.Create("DButton",utilityPanel)
			disbandButton:SetPos(0,utilityPanel:GetTall()/3)
			disbandButton:SetSize(utilityPanel:GetWide(),utilityPanel:GetTall()/3)
			disbandButton:SetText("Disband Lobby")
			disbandButton.DoClick = function(self)

				GAMEMODE.Match:DisbandGroup( LocalPlayer() )
				queueSpawnMenu:Close()

			end

			local kickButton = vgui.Create("DButton",utilityPanel)
			kickButton:SetPos(0,utilityPanel:GetTall()/3*2)
			kickButton:SetSize(utilityPanel:GetWide(),utilityPanel:GetTall()/3)
			kickButton:SetText("Kick Player")
			kickButton.DoClick = function(self)
				if !chosenButton then return end
				if !chosenPly then return end

				GAMEMODE.Match:KickPlayer( chosenPly )
				queueSpawnMenu:Close()

			end

		end

	end

	local invitePanel = vgui.Create("DPanel",queuePanel)
	invitePanel:SetPos(0,(queuePanel:GetTall()/10)*2 + queuePanel:GetTall()/5 + queuePanel:GetTall()/3 + 20)
	invitePanel:SetSize(queuePanel:GetWide(),110)
	invitePanel.Paint = function(self,w,h)
		draw.RoundedBox(0,0,0,w,h,Color(135,206,250))

		if !queueID then
			draw.SimpleText("Visit the spawn area to join a lobby!","queueMenuFont",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		elseif !groupLeader then
			draw.SimpleText("Your match will start shortly!","queueMenuFont",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		elseif GAMEMODE.Match.Queue[queueID]["Security"] == "open" then
			draw.SimpleText("Your match will start shortly!","queueMenuFont",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end

	local inviteList

	if groupLeader then

		if GAMEMODE.Match.Queue[queueID]["Security"] == "open" then return end

		local inviteButton = vgui.Create( "DButton" , invitePanel )
		inviteButton:SetText("Invite Players")
		inviteButton:SetPos(invitePanel:GetWide()/2-100 , invitePanel:GetTall()/2-30)
		inviteButton:SetSize(200,60)
		inviteButton.DoClick = function(self)

			if IsValid(inviteFrame) then return end

			local inviteFrame = vgui.Create("DFrame")
			inviteFrame:SetSize( 300 , 425 )
			inviteFrame:MakePopup()
			inviteFrame:SetTitle("Invite Players")
			inviteFrame:Center()

			local invPanel = vgui.Create("DPanel",inviteFrame)
			invPanel:SetPos(0,25)
			invPanel:SetSize(300,400)
			invPanel.Paint = function() end

			local invitePanel = vgui.Create("DPanel",invPanel)
			invitePanel:SetPos(0,0)
			invitePanel:SetSize(inviteFrame:GetWide(), inviteFrame:GetTall()-100)
			invitePanel.Paint = function(self,w,h) end

			local inviteList = vgui.Create("DListView",invitePanel)
			inviteList:Dock( FILL )
			inviteList:SetMultiSelect( true )
			inviteList:SetDataHeight( 15 )
			inviteList:AddColumn( "Free Players" )

			for k, v in pairs( GAMEMODE.Match:GetFreePlayers() ) do

				inviteList:AddLine( v:Name() )

			end

			local inviteButton = vgui.Create("DButton",invPanel)
			inviteButton:SetPos( 0, 325 )
			inviteButton:SetSize( inviteFrame:GetWide(),75 )
			inviteButton:SetText("Invite Player")
			inviteButton.DoClick = function()

				local plyNames = {}

				for k, v in pairs(plyList:GetSelected()) do

					table.insert( plyNames , v:GetColumnText(1) )

				end

				if !GAMEMODE.Util:IsTableEmpty( plyNames ) then

					net.Start("gRocket_RequestInvite")
						net.WriteTable(plyNames)
					net.SendToServer()

				end

			end

			queueSpawnMenu:Close()

		end

	end

end

hook.Add( "OnSpawnMenuOpen", "gRocket_SpawnMenuOpen", function()
	if IsValid(queueSpawnMenu) then return end
	GAMEMODE.Match:OpenQueueSpawnMenu()
end )

hook.Add( "OnSpawnMenuClose", "gRocket_SpawnMenuClose", function()
	if !IsValid(queueSpawnMenu) then return end
	queueSpawnMenu:Close()
end )