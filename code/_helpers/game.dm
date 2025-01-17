//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/proc/is_on_same_plane_or_station(var/z1, var/z2)
	if(z1 == z2)
		return 1
	if(isStationLevel(z1) && isStationLevel(z2))
		return 1
	return 0

/proc/max_default_z_level()
	var/max_z = 0
	for(var/z in current_map.station_levels)
		max_z = max(z, max_z)
	for(var/z in current_map.admin_levels)
		max_z = max(z, max_z)
	for(var/z in current_map.player_levels)
		max_z = max(z, max_z)
	return max_z

/proc/get_area(O)
	var/turf/loc = get_turf(O)
	if(loc)
		.= loc.loc

/proc/get_area_name(N) //get area by its name
	for(var/area/A in all_areas)
		if(A.name == N)
			return A
	return 0

/proc/get_area_master(const/O)
	var/area/A = get_area(O)
	if (isarea(A))
		return A

/proc/in_range(source, user)
	if(get_dist(source, user) <= 1)
		return 1

	return 0 //not in range and not telekinetic

// Like view but bypasses luminosity check

/proc/hear(var/range, var/atom/source)

	var/lum = source.luminosity
	source.luminosity = 6

	var/list/heard = view(range, source)
	source.luminosity = lum

	return heard

/proc/circlerange(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/atoms = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/A in view(radius, centerturf))
		var/dx = A.x - centerturf.x
		var/dy = A.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			atoms += A

	//turfs += centerturf
	return atoms

/proc/get_dist_euclidian(atom/Loc1 as turf|mob|obj,atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	var/dist = sqrt(dx**2 + dy**2)

	return dist

/proc/circlerangeturfs(center=usr,radius=3)
	var/turf/centerturf = get_turf(center)
	if(radius == 1)
		return list(centerturf)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

/proc/circleviewturfs(center=usr,radius=3)		//Is there even a diffrence between this proc and circlerangeturfs()?

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

// Will recursively loop through an atom's locs until it finds the atom loc above a turf or its target_atom
/proc/recursive_loc_turf_check(var/atom/O, var/recursion_limit = 3, var/atom/target_atom)
	if(recursion_limit <= 0 || isturf(O.loc) || O == target_atom)
		return O
	else
		O = O.loc
		recursion_limit--
		return recursive_loc_turf_check(O, recursion_limit)

// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
// being unable to hear people due to being in a box within a bag.
// Does not return list, as list is passed as reference.

/proc/recursive_content_check(var/atom/O,  var/list/L = list(), var/recursion_limit = 3, var/client_check = 1, var/sight_check = 1, var/include_mobs = 1, var/include_objects = 1)

	if(!recursion_limit)
		return 

	for(var/I in O.contents)

		if(ismob(I))
			if(!sight_check || isInSight(I, O))
				recursive_content_check(I, L, recursion_limit - 1, client_check, sight_check, include_mobs, include_objects)
				if(include_mobs)
					if(client_check)
						var/mob/M = I
						if(M.client)
							L += M
					else
						L += I

		else if(isobj(I))
			if(!sight_check || isInSight(I, O))
				recursive_content_check(I, L, recursion_limit - 1, client_check, sight_check, include_mobs, include_objects)
				if(include_objects)
					L += I

// Returns a list of mobs and/or objects in range of R from source. Used in radio and say code.

/proc/get_mobs_in_radio_ranges(var/list/obj/item/device/radio/radios)

	set background = 1

	. = list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	var/list/speaker_coverage = list()
	for(var/obj/item/device/radio/R in radios)
		if(R)
			//Cyborg checks. Receiving message uses a bit of cyborg's charge.
			var/obj/item/device/radio/borg/BR = R
			if(istype(BR) && BR.myborg)
				var/mob/living/silicon/robot/borg = BR.myborg
				var/datum/robot_component/CO = borg.get_component("radio")
				if(!CO)
					continue //No radio component (Shouldn't happen)
				if(!borg.is_component_functioning("radio") || !borg.cell_use_power(CO.active_usage))
					continue //No power.

			var/turf/speaker = get_turf(R)
			if(speaker)
				for(var/turf/T in hear(R.canhear_range,speaker))
					speaker_coverage[T] = T

	var/list/listeners = player_list.Copy()
	for(var/mob/M as anything in player_list)
		if(M.old_mob)
			listeners += M.old_mob

	// Try to find all the players who can hear the message
	for(var/mob/M as anything in listeners)
		if(M.can_hear_radio(speaker_coverage))
			. += M

/proc/get_mobs_or_objs_in_view(turf/T, range, list/mobs, list/objs, checkghosts = GHOSTS_ALL_HEAR)
	var/list/hear = list()
	DVIEW(hear, range, T, INVISIBILITY_MAXIMUM)
	var/list/hearturfs = list()

	for(var/am in hear)
		var/atom/movable/AM = am
		if (!AM.loc)
			continue

		var/turf/AM_turf = get_turf(AM)

		if(ismob(AM))
			mobs[AM] = TRUE
			hearturfs[AM_turf] = TRUE
		else if(isobj(AM))
			objs[AM] = TRUE
			hearturfs[AM_turf] = TRUE

	for(var/m in player_list)
		var/mob/M = m
		if(istype(M, /mob/living/test))
			if (!mobs[M])
				mobs[M] = TRUE
			continue
		if(checkghosts == GHOSTS_ALL_HEAR && M.stat == DEAD && !isnewplayer(M) && (M.client && M.client.prefs.toggles & CHAT_GHOSTEARS))
			if (!mobs[M])
				mobs[M] = TRUE
			continue

		var/turf/M_turf = get_turf(M)
		if(M.loc && hearturfs[M_turf])
			if (!mobs[M])
				mobs[M] = TRUE

	for(var/o in listening_objects)
		var/obj/O = o
		var/turf/O_turf = get_turf(O)
		if(O && O.loc && hearturfs[O_turf])
			if (!objs[O])
				objs[O] = TRUE

proc
	inLineOfSight(X1,Y1,X2,Y2,Z=1,PX1=16.5,PY1=16.5,PX2=16.5,PY2=16.5)
		var/turf/T
		if(X1==X2)
			if(Y1==Y2)
				return 1 //Light cannot be blocked on same tile
			else
				var/s = SIGN(Y2-Y1)
				Y1+=s
				while(Y1!=Y2)
					T=locate(X1,Y1,Z)
					if(T.opacity)
						return 0
					Y1+=s
		else
			var/m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
			var/b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
			var/signX = SIGN(X2-X1)
			var/signY = SIGN(Y2-Y1)
			if(X1<X2)
				b+=m
			while(X1!=X2 || Y1!=Y2)
				if(round(m*X1+b-Y1))
					Y1+=signY //Line exits tile vertically
				else
					X1+=signX //Line exits tile horizontally
				T=locate(X1,Y1,Z)
				if(T.opacity)
					return 0
		return 1

proc/isInSight(var/atom/A, var/atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return 0

	if(inLineOfSight(Aturf.x,Aturf.y, Bturf.x,Bturf.y,Aturf.z))
		return 1

	else
		return 0

/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/proc/get_mob_by_key(var/key)
	for(var/mob/M in mob_list)
		if(M.ckey == lowertext(key))
			return M
	return null


// Will return a list of active candidates. It increases the buffer 5 times until it finds a candidate which is active within the buffer.
/proc/get_active_candidates(var/buffer = 1)

	var/list/candidates = list() //List of candidate KEYS to assume control of the new larva ~Carn
	var/i = 0
	while(candidates.len <= 0 && i < 5)
		for(var/mob/abstract/observer/G in player_list)
			if(((G.client.inactivity/10)/60) <= buffer + i) // the most active players are more likely to become an alien
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					candidates += G.key
		i++
	return candidates

// Same as above but for alien candidates.

/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))	O = new /obj/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/proc/Show2Group4Delay(obj/O, list/group, delay=0)
	if(!isobj(O))	return
	if(!group)	group = clients
	for(var/client/C in group)
		C.screen += O
	if(delay)
		spawn(delay)
			for(var/client/C in group)
				C.screen -= O

datum/projectile_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/projectile_data/New(var/src_x, var/src_y, var/time, var/distance, \
						   var/power_x, var/power_y, var/dest_x, var/dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

/proc/projectile_trajectory(var/src_x, var/src_y, var/rotation, var/angle, var/power)

	var/g = 9.81
	var/h = 10
	var/power_x = power * cos(angle)
	var/power_y = power * sin(angle)
	var/time = (power_y + sqrt((power_y*power_y)+(2*g*h)))/g
	var/distance = time * power_x

	var/dest_x = src_x + distance*sin(rotation);
	var/dest_y = src_y + distance*cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)

/proc/GetRedPart(const/hexa)
	return hex2num(copytext(hexa,2,4))

/proc/GetGreenPart(const/hexa)
	return hex2num(copytext(hexa,4,6))

/proc/GetBluePart(const/hexa)
	return hex2num(copytext(hexa,6,8))

/proc/GetHexColors(const/hexa)
	return list(
			GetRedPart(hexa),
			GetGreenPart(hexa),
			GetBluePart(hexa)
		)

/proc/MixColors(const/list/colors)
	var/list/reds = list()
	var/list/blues = list()
	var/list/greens = list()
	var/list/weights = list()

	for (var/i = 0, ++i <= colors.len)
		reds.Add(GetRedPart(colors[i]))
		blues.Add(GetBluePart(colors[i]))
		greens.Add(GetGreenPart(colors[i]))
		weights.Add(1)

	var/r = mixOneColor(weights, reds)
	var/g = mixOneColor(weights, greens)
	var/b = mixOneColor(weights, blues)
	return rgb(r,g,b)

/proc/mixOneColor(var/list/weight, var/list/color)
	if (!weight || !color || length(weight)!=length(color))
		return 0

	var/contents = length(weight)
	var/i

	//normalize weights
	var/listsum = 0
	for(i=1; i<=contents; i++)
		listsum += weight[i]
	for(i=1; i<=contents; i++)
		weight[i] /= listsum

	//mix them
	var/mixedcolor = 0
	for(i=1; i<=contents; i++)
		mixedcolor += weight[i]*color[i]
	mixedcolor = round(mixedcolor)

	//until someone writes a formal proof for this algorithm, let's keep this in
//	if(mixedcolor<0x00 || mixedcolor>0xFF)
//		return 0
	//that's not the kind of operation we are running here, nerd
	mixedcolor=min(max(mixedcolor,0),255)

	return mixedcolor

/**
* Gets the highest and lowest pressures from the tiles in cardinal directions
* around us, then checks the difference.
*/
/proc/getOPressureDifferential(var/turf/loc)
	var/minp=16777216;
	var/maxp=0;
	for(var/dir in cardinal)
		var/turf/simulated/T=get_turf(get_step(loc,dir))
		var/cp=0
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			cp = environment.return_pressure()
		else
			if(istype(T,/turf/simulated))
				continue
		if(cp<minp)minp=cp
		if(cp>maxp)maxp=cp
	return abs(minp-maxp)

/proc/convert_k2c(var/temp)
	return ((temp - T0C))

/proc/convert_c2k(var/temp)
	return ((temp + T0C))

/proc/getCardinalAirInfo(var/turf/loc, var/list/stats=list("temperature"))
	var/list/temps = new/list(4)
	for(var/dir in cardinal)
		var/direction
		switch(dir)
			if(NORTH)
				direction = 1
			if(SOUTH)
				direction = 2
			if(EAST)
				direction = 3
			if(WEST)
				direction = 4
		var/turf/simulated/T=get_turf(get_step(loc,dir))
		var/list/rstats = new /list(stats.len)
		if(T && istype(T) && T.zone)
			var/datum/gas_mixture/environment = T.return_air()
			for(var/i=1;i<=stats.len;i++)
				if(stats[i] == "pressure")
					rstats[i] = environment.return_pressure()
				else
					rstats[i] = environment.vars[stats[i]]
		else if(istype(T, /turf/simulated))
			rstats = null // Exclude zone (wall, door, etc).
		else if(istype(T, /turf))
			// Should still work.  (/turf/return_air())
			var/datum/gas_mixture/environment = T.return_air()
			for(var/i=1;i<=stats.len;i++)
				if(stats[i] == "pressure")
					rstats[i] = environment.return_pressure()
				else
					rstats[i] = environment.vars[stats[i]]
		temps[direction] = rstats
	return temps

/proc/MinutesToTicks(var/minutes)
	return SecondsToTicks(60 * minutes)

/proc/SecondsToTicks(var/seconds)
	return seconds * 10

/proc/round_is_spooky(var/spookiness_threshold = config.cult_ghostwriter_req_cultists)
	if(enabled_spooking)
		return 1
	else
		return (cult.current_antagonists.len > spookiness_threshold)

/// Removes an image from a client's `.images`. Useful as a callback.
/proc/remove_image_from_client(image/image, client/remove_from)
	remove_from?.images -= image

/proc/remove_images_from_clients(image/I, list/show_to)
	for(var/client/C in show_to)
		C.images -= I

/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	addtimer(CALLBACK(GLOBAL_PROC, /.proc/remove_images_from_clients, I, show_to), duration)

/proc/flick_overlay_view(image/I, atom/target, duration) //wrapper for the above, flicks to everyone who can see the target atom
	var/list/viewing = list()
	for(var/m in viewers(target))
		var/mob/M = m
		if(M.client)
			viewing += M.client
	flick_overlay(I, viewing, duration)

// makes peoples byond icon flash on the taskbar
/proc/window_flash(client/C)
	if(ismob(C))
		var/mob/M = C
		if(M.client)
			C = M.client
	if(!C)
		return
	winset(C, "mainwindow", "flash=5")
