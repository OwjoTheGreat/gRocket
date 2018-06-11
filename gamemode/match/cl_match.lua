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

function pmeta:IsInMatch()

	return self.inMatch or false

end

function pmeta:IsInQueue()

	return self.inQueue or false

end

// QUEUE VGUI

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

	local privateButton = vgui.Create( "DButton",queuePanel )
	privateButton:SetText("")
	privateButton:SetPos(queuePanel:GetWide()/2,0)
	privateButton:SetSize( queuePanel:GetWide()/2 , queuePanel:GetTall()/2 )
	privateButton.Paint = function(self,w,h)

		draw.RoundedBox(0,0,0,w,h,Color(0,191,255))
		draw.SimpleText("Private Lobby","DermaLarge",w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	
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

end

net.Receive("gRocket_RequestQueue",function()

	local plyList = net.ReadTable()

	GAMEMODE.Match:OpenQueueMenu( plyList )

end)