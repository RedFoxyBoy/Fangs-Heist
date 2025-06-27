local PR = CBW_PowerCards

local appearsfx = sfx_itmspn

PR.PowerCardSpawn = function(mo)
	mo.item = 1
	mo.active = false
	mo.dropped = false
	mo.shadowscale = FRACUNIT>>1
end

PR.SpawnItem = function(itemnum, mapthing, func, rogue)
	//Get spawnpoint -- make sure spawn is vacant first!
	if mapthing == nil //Global spawn
		local retry = #PR.SpawnPoints
		while retry > 0 do
			mapthing = PR.GetNextSpawnPoint()
			if PR.SpawnOccupied(mapthing) and not(rogue) //No vacancy
				retry = $-1
			else
				break
			end
		end
		//Did we run out of space?
		if retry == 0
			PR.DPrint("No vacant spawnpoints!","warning")
			return
		end
	else //Local spawn
		if PR.SpawnOccupied(mapthing) and not(rogue)
			PR.DPrint("Attempted to locally spawn on occupied mapthing","warning")
			return
		end
	end
	assert(userdataType(mapthing) == "mapthing_t", "Wrong userdata for PR.SpawnItem mapthing (got "..userdataType(mapthing)..")")
	
	//Get spawnpoint properties
	if not(itemnum)
	and mapthing.type != 0
	and mapthing.type != 1
	and mapthing.type != 321
		itemnum = mapthing.angle //For all "primary" spawns, angle stores itemnum type
	end
	local flip = 1
	local permanent = mapthing.options&MTF_EXTRA and not(rogue)
	local x,y,z = mapthing.x*FRACUNIT, mapthing.y*FRACUNIT, (mapthing.z+16)*FRACUNIT
	//Objectflip
	if mapthing.options&MTF_OBJECTFLIP
		flip = -1
		local s = R_PointInSubsectorOrNil(x,y)
		if s != nil
			local ceil = s.sector.ceilingheight
			z = ceil-16*FRACUNIT-mobjinfo[MT_POWERCARD].height
		end
	end

	// If itemnum is already defined, check if in bounds
	if itemnum
	and (itemnum < 1 or itemnum > #PR.Item)
		CBW_Battle.Warning("Power ring type "..itemnum.." is out of range!")
		itemnum = nil //Remove definition
	end
	
	// Get itemnum, if not already defined
	if not(itemnum)
		PR.DPrint("No mapthing itemtype, pulling random")
		itemnum = PR.GetRandomType()
	end
	
	// Still nothing?
	if not(itemnum)
		PR.DPrint("Could not generate item type. Are all random spawns disabled?")
		return
	end
	
	//Get item data
	local item = PR.Item[itemnum]
	PR.DPrint("Spawning power ring, type "..itemnum)
	
	//Spawn object
	local mt = item.mobj or MT_POWERCARD
	local mo = P_SpawnMobj(x,y,z, mt)
	if not(mo and mo.valid) return end //Something prevented the item from spawning
	
	//Set orientation
	if flip == -1
		mo.flags2 = $|MF2_OBJECTFLIP
	end

	//Set properties
	mo.item = itemnum
	if not(rogue)
		mapthing.mobj = mo
	end
	mo.mapthing = mapthing
	if not(permanent)
		mo.fuse = TICRATE*30 //!Needs adjustable value
	end


	//If item is "custom", don't run additional instructions
	if item.flags&PCF_CUSTOM 
		return
	end

	//Apply additional properties
	mo.state = item.state
	mo.health = item.health
	if not(func)
		CBW_Battle.ZLaunch(mo,FRACUNIT*20,false)
		if not(item.func_spawn(mo))
			S_StartSound(mo,sfx_itmspn)
			P_SpawnParaloop(mo.x,mo.y,mo.z,FRACUNIT*128,16,MT_BOXSPARKLE,ANGLE_90,nil,true)
		end
	else
		func(mo)
		item.func_spawn(mo)
	end
end