local time = (3*60)*TICRATE

return {
	gamemode = 1,

	map_choices = {},
	attacks = {},

	game_over = false,
	game_over_ticker = 0,
	game_over_length = 20*TICRATE,
	game_over_winline = "",

	pregame = true,
	pregame_time = 30*TICRATE,
	pregame_transparency = 0,
	pregame_cam = {enabled = false, x=0,y=0,z=0,angle=0,dist=0},

	placements = {},
	teams = {},
	treasures = {},

	last_profit = -1
}