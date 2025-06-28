local module = {}

local sglib = FangsHeist.require "Modules/Libraries/sglib"
local fracformat = FangsHeist.require "Modules/Libraries/fracformat"

local function draw_player(v, p, tp, mo, x, y, args)
	local arrow = v.cachePatch("FH_ARROW"..(leveltime/2 % 6))
	local arrow_scale = FU/2
	local dist = R_PointToDist2(mo.x, mo.y, p.mo.x, p.mo.y)

	if not args then return end

	local plyr_spr, plyr_scale
	if skins[p.mo.skin].sprites[SPR2_SIGN].numframes then
		plyr_spr = v.getSprite2Patch(p.mo.skin, SPR2_SIGN, false, A, 0)
		plyr_scale = skins[p.mo.skin].highresscale
	else
		plyr_spr = v.getSpritePatch(SPR_SIGN, S, 0)
		plyr_scale = FU
	end
	local color = v.getColormap(p.mo.skin, p.mo.color)

	v.drawScaled(x, y, plyr_scale/4, plyr_spr, 0, color)
	y = $-8*FU*2

	--[[if #p.heist.treasures then
		v.drawString(x, y, "TREASURE", 0, "thin-fixed-center")
		y = $-8*FU
	end
	if p.heist:hasSign() then
		v.drawString(x, y, "SIGN", 0, "thin-fixed-center")
		y = $-8*FU
	end
	if p.heist:isPartOfTeam(tp) then
		v.drawString(x, y, "TEAM", 0, "thin-fixed-center")
		y = $-8*FU
	end]]

	for _,str in ipairs(args) do
		v.drawString(x, y, str, V_ALLOWLOWERCASE, "thin-fixed-center")
		y = $-8*FU
	end

	v.drawString(x, y, fracformat(dist), V_ALLOWLOWERCASE, "thin-fixed-center")
	y = $-arrow.height*arrow_scale

	v.drawScaled(x - arrow.width*arrow_scale/2,
		y,
		arrow_scale,
		arrow,
		0,
		v.getColormap(nil, p.mo.color))
end

local function isSpecial(p, sp)
	return #sp.heist.treasures
	or sp.heist:hasSign()
	or (p and p.heist and p.heist:isPartOfTeam(sp))
end

function module.init() end
function module.draw(v,p,c)
	if FangsHeist.Net.pregame then return end
	local gamemode = FangsHeist.getGamemode()

	if not (p and p.mo and p.mo.valid) then return end

	for sp in players.iterate do
		if p == sp then continue end
		if not (sp.heist and sp.heist:isAlive()) then continue end

		local variables = gamemode:trackplayer(sp)
		if not variables
		or #variables == 0 then
			continue
		end

		if P_CheckSight(p.mo, sp.mo) then continue end
		if sp.heist.exiting then continue end

		local result = sglib.ObjectTracking(v,p,c,sp.mo)
		if not result.onScreen then continue end

		draw_player(v, sp, p, p.mo, result.x, result.y, variables)
	end
end

return module