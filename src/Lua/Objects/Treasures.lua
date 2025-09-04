// treasures cause we like them
// all sprites currently used by Speedcore Tempest

freeslot "SPR_TRES"

local UNGRABBED_FLAGS = 0
local GRABBED_FLAGS = MF_NOTHINK|MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT

FangsHeist.treasures = {
	{
		name = "Franklin Badge",
		desc = "This MIGHT have been used in a kite experiment.",
		frame = A
	};
	{
		name = "Light Burden",
		desc = "You only have One Shot.",
		frame = B
	};
	{
		name = "Rainy Ukelele",
		desc = "...And his music was electric.",
		frame = C
	};
	{
		name = "Jet Lotus",
		desc = "He's RAMPING!!",
		frame = D
	};
	{
		name = "Tempest Ribbon",
		desc = "The girl faced endless conflict.",
		frame = E
	};
	{
		name = "Fatalis Ribbon",
		desc = "The girl was shrouded in unyielding light.",
		frame = F
	};
	{
		name = "Galactic Talisman",
		desc = "A symbol for cool guys and intergalactic armies alike!",
		frame = G
	};
	{
		name = "Writer's Mask",
		desc = "I just can't GET ENUF!",
		frame = H
	};
	{
		name = "Strongest Plush",
		desc = "Baka! Baka!",
		frame = I
	};
	{
		name = "Saint's Knife",
		desc = "The Fickle Princess left the Hero with nothing but hate in his heart.",
		frame = J
	};
}

local function set_mobj_to_data(mobj, data)
	mobj.sprite = SPR_TRES
	mobj.frame = data.frame
end

local function spawn_mobj(x, y, z)
	local treasure = P_SpawnMobj(x, y, z, MT_THOK)
	treasure.flags = MF_NOTHINK|MF_NOBLOCKMAP
	treasure.fuse = -1
	treasure.tics = -1

	return treasure
end

function FangsHeist.defineTreasure(x, y, z)
	if not FangsHeist.isMode() then
		return
	end

	local treasure = spawn_mobj(x, y, z)
	local choice = P_RandomRange(1, #FangsHeist.treasures)

	table.insert(FangsHeist.Net.treasures, {
		mobj = treasure,
		data = FangsHeist.treasures[choice],
		spawn = {x=x, y=y, z=z}
	})
	set_mobj_to_data(treasure, FangsHeist.treasures[choice])
end

local function manage_unpicked(tres)
	local mobj = tres.mobj
	local data = tres.data

	mobj.frame = $ & ~FF_TRANS80
	local gamemode = FangsHeist.getGamemode()

	for p in players.iterate do
		if not (p.heist and p.heist:isAlive()) then continue end
		if p.powers[pw_flashing] and not p.heist:hasSign() then continue end
		if P_PlayerInPain(p) then continue end

		local dist = R_PointToDist2(mobj.x, mobj.y, p.mo.x, p.mo.y)
		local heightdist = abs(p.mo.z-mobj.z)

		if dist > 64*FU
		or heightdist > 64*FU
		or gamemode:treasureblacklist(p) then
			continue
		end

		S_StartSound(p.mo, sfx_kc30)

		p.heist.treasure_name = data.name
		p.heist.treasure_desc = data.desc
		p.heist.treasure_time = 3*TICRATE
		table.insert(p.heist.treasures, tres)

		mobj.target = p.mo
		mobj.index = #p.heist.treasures

		break
	end
end

local function manage_picked(tres)
	local mobj = tres.mobj
	local data = tres.data

	local target = mobj.target

	P_MoveOrigin(mobj,
		target.x,
		target.y,
		(target.z+target.height)+(24*FU*(mobj.index-1)))

	if target.flags2 & MF2_DONTDRAW then
		mobj.flags2 = $|MF2_DONTDRAW
	else
		mobj.flags2 = $ & ~MF2_DONTDRAW
	end
end

function FangsHeist.manageTreasures()
	if not FangsHeist.Net.treasures then
		return
	end

	for _,tres in ipairs(FangsHeist.Net.treasures) do
		local mobj = tres.mobj
		local data = tres.data
		local spawn = tres.spawn

		if not (mobj and mobj.valid) then
			local treasure = spawn_mobj(spawn.x, spawn.y, spawn.z)
			set_mobj_to_data(treasure, data)

			tres.mobj = treasure
			mobj = treasure
		end

		if mobj.target
		and not (mobj.target.valid
		and mobj.target.player
		and mobj.target.player.heist
		and mobj.target.player.heist:isAlive()) then
			mobj.target = nil
		end

		if not mobj.target then
			mobj.flags = UNGRABBED_FLAGS
			manage_unpicked(tres)
			continue
		end

		mobj.flags = GRABBED_FLAGS
		manage_picked(tres)
	end
end