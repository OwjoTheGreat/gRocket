--[[

	Server Side Map Setup

]]

GM.Map = (GAMEMODE or GM).Map or {}

function GM.Map:InitPostEntity()

	// Spawning default props

	local board = ents.Create("ent_match_board")
	board:SetPos( GAMEMODE.Config.BoardPos )
	board:Spawn()
	board:Activate()

	local ball = ents.Create("ent_match_ball")
	ball:SetPos( GAMEMODE.Config.BallPos )
	ball:Spawn()
	ball:Activate()	

end