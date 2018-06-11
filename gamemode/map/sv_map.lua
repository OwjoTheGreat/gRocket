--[[

	Server Side Map Setup

]]

GM.Map = (GAMEMODE or GM).Map or {}

function GM.Map:InitPostEntity()

	// Spawning default props

	local board = ents.Create("ent_match_board")
	board:SetPos( GAMEMODE.Config.BoardPos )
	board:SetAngles( GAMEMODE.Config.BoardAng )
	board:Spawn()
	board:Activate()

	local queue = ents.Create("ent_queue_board")
	queue:SetPos( GAMEMODE.Config.QueuePos )
	queue:SetAngles( GAMEMODE.Config.QueueAng )
	queue:Spawn()
	queue:Activate()	

	local ball = ents.Create("ent_match_ball")
	ball:SetPos( GAMEMODE.Config.BallPos )
	ball:Spawn()
	ball:Activate()

	for k, v in pairs(GAMEMODE.Config.BoostPos) do

		local boost = ents.Create("ent_boost_ball")
		boost:SetPos( v )
		boost:Spawn()
		boost:Activate()

	end

end