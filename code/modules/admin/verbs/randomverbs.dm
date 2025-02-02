/client/proc/cmd_admin_drop_everything(mob/M as mob in mob_list)
	set category = null
	set name = "Drop Everything"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/confirm = alert(src, "Make [M] drop everything?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	M.drop_all()

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(M)] drop everything!", 1)
	feedback_add_details("admin_verb","DEVR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/manage_religions()
	set category = "Admin"
	set name = "Manage Religions"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	holder.updateRelWindow()


/client/proc/cmd_admin_prison(mob/M as mob in mob_list)
	set category = "Admin"
	set name = "Prison"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if (ismob(M))
		if(istype(M, /mob/living/silicon/ai))
			alert("The AI can't be sent to prison you jerk!", null, null, null, null, null)
			return
		//strip their stuff before they teleport into a cell :downs:
		for(var/obj/item/W in M)
			M.drop_from_inventory(W)
		//teleport person to cell
		M.Paralyse(5)
		sleep(5)	//so they black out before warping
		M.forceMove(pick(prisonwarp))
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/prisoner(prisoner), slot_w_uniform)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), slot_shoes)
		spawn(50)
			to_chat(M, "<span class='warning'>You have been sent to the prison station!</span>")
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("<span class='notice'>[key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.</span>", 1)
		feedback_add_details("admin_verb","PRISON") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_subtle_message(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Subtle Message"

	if(!ismob(M))
		return
	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/msg = input("Message:", text("Subtle PM to [M.key]")) as null | message
	if (isnull(msg))
		return

	var/predicted_deity = DecidePrayerGod(M)

	var/deity = input("Deity: The current chosen deity is [predicted_deity]. Input a different one, or leave blank to have the message be from 'a voice'.", text("Subtle PM to [M.key]"), predicted_deity) as null | text

	if(isnull(deity)) //Hit the cancel button
		return
	else if(!deity) //Left the text field blank
		deity = "a voice"

	if(usr)
		if (usr.client)
			if(usr.client.holder)
				M.get_subtle_message(msg, deity)


	log_admin("SubtlePM: [key_name(usr)] as [deity] -> [key_name(M)] : [msg]")
	output_to_msay("<span class='notice'><B>SubtleMessage: [key_name_admin(usr)] as [deity] -> [key_name_admin(M)] : [msg]</B></span>")
	feedback_add_details("admin_verb","SMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_world_narrate() // Allows administrators to fluff events a little easier -- TLE
	set category = "Special Verbs"
	set name = "Global Narrate"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone.")) as null | message

	if(!msg)
		return

	to_chat(world, "[msg]")
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("<span class='notice'><B>GlobalNarrate: [key_name_admin(usr)] : [msg]<BR></B></span>", 1)
	feedback_add_details("admin_verb","GLN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(var/mob/M)	// Targetted narrate -- TLE
	set category = "Special Verbs"
	set name = "Direct Narrate"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(!M)
		M = input("Direct narrate to who?", "Active Players") as null|anything in player_list

	if(!M)
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to your target, input nothing to cancel.")) as null | message

	if(!msg)
		return

	to_chat(M, msg)
	log_admin("DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]")
	message_admins("<span class='notice'><B>DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]<BR></B></span>", 1)
	feedback_add_details("admin_verb","DIRN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_local_narrate()	// View targetted narration
	set category = "Special Verbs"
	set name = "Local Narrate"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to your target, input nothing to cancel.")) as null | message

	if(!msg)
		return

	for(var/mob/M in view())
		if(M in player_list)
			to_chat(M, msg)

	log_admin("LocalNarrate: [key_name(usr)] at [formatJumpTo(get_turf(usr))]: [msg]")
	message_admins("<span class='notice'><B>LocalNarrate: [key_name(usr)] at [formatJumpTo(get_turf(usr))]: [msg]<BR></B></span>", 1)
	feedback_add_details("admin_verb","LIRN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_godmode(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Godmode"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	M.status_flags ^= GODMODE
	to_chat(usr, "<span class='notice'>Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]</span>")

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	message_admins("[key_name_admin(usr)] has toggled [key_name_admin(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]", 1)
	feedback_add_details("admin_verb","GOD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/proc/cmd_admin_mute(mob/M as mob, mute_type, automute = 0)
	if(automute)
		if(!config.automute_on)
			return
	else
		if(!usr || !usr.client)
			return
		if(!usr.client.holder)
			to_chat(usr, "<span class='red'>Error: cmd_admin_mute: You don't have permission to do this.</span>")
			return
		if(!M.client)
			to_chat(usr, "<span class='red'>Error: cmd_admin_mute: This mob doesn't have a client tied to it.</span>")
		if(M.client.holder)
			to_chat(usr, "<span class='red'>Error: cmd_admin_mute: You cannot mute an admin.</span>")
	if(!M.client)
		return
	if(M.client.holder)
		return

	var/muteunmute
	var/mute_string

	switch(mute_type)
		if(MUTE_IC)
			mute_string = "IC (say and emote)"
		if(MUTE_OOC)
			mute_string = "OOC"
		if(MUTE_PRAY)
			mute_string = "pray"
		if(MUTE_ADMINHELP)
			mute_string = "adminhelp, admin PM and ASAY"
		if(MUTE_DEADCHAT)
			mute_string = "deadchat and DSAY"
		if(MUTE_ALL)
			mute_string = "everything"
		else
			return

	if(automute)
		muteunmute = "auto-muted"
		M.client.prefs.muted |= mute_type
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(M)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
		to_chat(M, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.")
		feedback_add_details("admin_verb","AUTOMUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	if(M.client.prefs.muted & mute_type)
		muteunmute = "unmuted"
		M.client.prefs.muted &= ~mute_type
	else
		muteunmute = "muted"
		M.client.prefs.muted |= mute_type

	log_admin("[key_name(usr)] has [muteunmute] [key_name(M)] from [mute_string]")
	message_admins("[key_name_admin(usr)] has [muteunmute] [key_name_admin(M)] from [mute_string].", 1)
	to_chat(M, "You have been [muteunmute] from [mute_string].")
	feedback_add_details("admin_verb","MUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_add_random_ai_law()
	set category = "Fun"
	set name = "Add Random AI Law"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		return
	log_admin("[key_name(src)] has added a random AI law.")
	message_admins("[key_name_admin(src)] has added a random AI law.", 1)

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	if(show_log == "Yes")
		command_alert(/datum/command_alert/ion_storm)

	generate_ion_law()
	feedback_add_details("admin_verb","ION") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//I use this proc for respawn character too. /N
/proc/create_xeno(ckey)
	if(!ckey)
		var/list/candidates = list()
		for(var/mob/M in get_active_candidates(ROLE_ALIEN))
			if(M.stat != DEAD)
				continue	//we are not dead!
			if(M.client.is_afk())
				continue	//we are afk
			candidates += M.ckey
		if(candidates.len)
			ckey = input("Pick the player you want to respawn as a xeno.", "Suitable Candidates") as null|anything in candidates
		else
			to_chat(usr, "<span class='red'>Error: create_xeno(): no suitable candidates.</span>")
	if(!istext(ckey))
		return 0

	var/alien_caste = input(usr, "Please choose which caste to spawn.","Pick a caste",null) as null|anything in list("Queen","Hunter","Sentinel","Drone","Larva")
	var/obj/effect/landmark/spawn_here = xeno_spawn.len ? pick(xeno_spawn) : pick(latejoin)
	var/mob/living/carbon/alien/new_xeno
	switch(alien_caste)
		if("Queen")
			new_xeno = new /mob/living/carbon/alien/humanoid/queen(spawn_here)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(spawn_here)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(spawn_here)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(spawn_here)
		if("Larva")
			new_xeno = new /mob/living/carbon/alien/larva(spawn_here)
		else
			return 0

	new_xeno.ckey = ckey
	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned [ckey] as a filthy xeno [alien_caste].</span>", 1)
	return 1

/*
Allow admins to set players to be able to respawn/bypass 30 min wait, without the admin having to edit variables directly
Ccomp's first proc.
*/

/client/proc/get_ghosts(var/notify = 0,var/what = 2)
	// what = 1, return ghosts ass list.
	// what = 2, return mob list

	var/list/mobs = list()
	var/list/ghosts = list()
	var/list/sortmob = sortNames(mob_list)                           // get the mob list.
	var/any=0
	for(var/mob/dead/observer/M in sortmob)
		mobs.Add(M)                                             //filter it where it's only ghosts
		any = 1                                                 //if no ghosts show up, any will just be 0
	if(!any)
		if(notify)
			to_chat(src, "There doesn't appear to be any ghosts for you to select.")
		return

	for(var/mob/M in mobs)
		var/name = M.name
		ghosts[name] = M                                        //get the name of the mob for the popup list
	if(what==1)
		return ghosts
	else
		return mobs


/client/proc/allow_character_respawn()
	set category = "Special Verbs"
	set name = "Allow player to respawn"
	set desc = "Let's the player bypass the 30 minute wait to respawn or allow them to re-enter their corpse."

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/list/ghosts= get_ghosts(1,1)

	var/target = input("Please, select a ghost!", "COME BACK TO LIFE!", null, null) as null|anything in ghosts
	if(!target)
		to_chat(src, "Hrm, appears you didn't select a ghost") // Sanity check, if no ghosts in the list we don't want to edit a null variable and cause a runtime error.

		return

	var/mob/dead/observer/G = ghosts[target]
	if(G.has_enabled_antagHUD && config.antag_hud_restricted)
		var/response = alert(src, "Are you sure you wish to allow this individual to play?","Ghost has used AntagHUD","Yes","No")
		if(response == "No")
			return
	G.timeofdeath=-19999						/* time of death is checked in /mob/verb/abandon_mob() which is the Respawn verb.
									   timeofdeath is used for bodies on autopsy but since we're messing with a ghost I'm pretty sure
									   there won't be an autopsy.
									*/
	G.has_enabled_antagHUD = 2
	G.can_reenter_corpse = 1

	G:show_message(text("<span class='notice'><B>You may now respawn.  You should roleplay as if you learned nothing about the round during your time with the dead.</B></span>"), 1)
	log_admin("[key_name(usr)] allowed [key_name(G)] to bypass the 30 minute respawn limit")
	message_admins("Admin [key_name_admin(usr)] allowed [key_name_admin(G)] to bypass the 30 minute respawn limit", 1)


/client/proc/toggle_antagHUD_use()
	set category = "Server"
	set name = "Toggle antagHUD usage"
	set desc = "Toggles antagHUD usage for observers"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/action=""
	if(config.antag_hud_allowed)
		for(var/mob/dead/observer/g in get_ghosts())
			if(!g.client.holder)						//Remove the verb from non-admin ghosts
				g.verbs -= /mob/dead/observer/verb/toggle_antagHUD
			if(g.antagHUD)
				g.antagHUD = 0						// Disable it on those that have it enabled
				g.has_enabled_antagHUD = 2				// We'll allow them to respawn
				to_chat(g, "<span class='danger'>The Administrator has disabled AntagHUD </span>")
		config.antag_hud_allowed = 0
		to_chat(src, "<span class='danger'>AntagHUD usage has been disabled</span>")
		action = "disabled"
	else
		for(var/mob/dead/observer/g in get_ghosts())
			if(!g.client.holder)						// Add the verb back for all non-admin ghosts
				g.verbs += /mob/dead/observer/verb/toggle_antagHUD
				to_chat(g, "<span class='notice'><B>The Administrator has enabled AntagHUD </B></span>")// Notify all observers they can now use AntagHUD

		config.antag_hud_allowed = 1
		action = "enabled"
		to_chat(src, "<span class='notice'><B>AntagHUD usage has been enabled</B></span>")


	log_admin("[key_name(usr)] has [action] antagHUD usage for observers")
	message_admins("Admin [key_name_admin(usr)] has [action] antagHUD usage for observers", 1)



/client/proc/toggle_antagHUD_restrictions()
	set category = "Server"
	set name = "Toggle antagHUD Restrictions"
	set desc = "Restricts players that have used antagHUD from being able to join this round."

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/action=""
	if(config.antag_hud_restricted)
		for(var/mob/dead/observer/g in get_ghosts())
			to_chat(g, "<span class='notice'><B>The administrator has lifted restrictions on joining the round if you use AntagHUD</B></span>")
		action = "lifted restrictions"
		config.antag_hud_restricted = 0
		to_chat(src, "<span class='notice'><B>AntagHUD restrictions have been lifted</B></span>")
	else
		for(var/mob/dead/observer/g in get_ghosts())
			to_chat(g, "<span class='danger'>The administrator has placed restrictions on joining the round if you use AntagHUD</span>")
			to_chat(g, "<span class='danger'>Your AntagHUD has been disabled, you may choose to re-enabled it but will be under restrictions </span>")
			g.antagHUD = 0
			g.has_enabled_antagHUD = 0
		action = "placed restrictions"
		config.antag_hud_restricted = 1
		to_chat(src, "<span class='danger'>AntagHUD restrictions have been enabled</span>")

	log_admin("[key_name(usr)] has [action] on joining the round if they use AntagHUD")
	message_admins("Admin [key_name_admin(usr)] has [action] on joining the round if they use AntagHUD", 1)




/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
/client/proc/respawn_character()
	set category = "Special Verbs"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/input = ckey(input(src, "Please specify which key will be respawned. Input nothing to cancel.", "Key", ""))
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(usr, "<span class='red'>There is no active key like that in the game or the person is not currently a ghost.</span>")
		return

	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		//Check if they were an alien
		if(G_found.mind.assigned_role=="Alien")
			if(alert("This character appears to have been an alien. Would you like to respawn them as such?",,"Yes","No")=="Yes")
				var/turf/T
				if(xeno_spawn.len)
					T = pick(xeno_spawn)
				else
					T = pick(latejoin)

				var/mob/living/carbon/alien/new_xeno
				switch(G_found.mind.special_role)//If they have a mind, we can determine which caste they were.
					if("Hunter")
						new_xeno = new /mob/living/carbon/alien/humanoid/hunter(T)
					if("Sentinel")
						new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(T)
					if("Drone")
						new_xeno = new /mob/living/carbon/alien/humanoid/drone(T)
					if("Queen")
						new_xeno = new /mob/living/carbon/alien/humanoid/queen(T)
					else//If we don't know what special role they have, for whatever reason, or they're a larva.
						create_xeno(G_found.ckey)
						return

				//Now to give them their mind back.
				G_found.mind.transfer_to(new_xeno)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_xeno.key = G_found.key
				to_chat(new_xeno, "You have been fully respawned. Enjoy the game.")
				message_admins("<span class='notice'>[key_name_admin(usr)] has respawned [new_xeno.key] as a filthy xeno.</span>", 1)
				return	//all done. The ghost is auto-deleted

		//check if they were a monkey
		else if(findtext(G_found.real_name,"monkey"))
			if(alert("This character appears to have been a monkey. Would you like to respawn them as such?",,"Yes","No")=="Yes")
				var/mob/living/carbon/monkey/new_monkey = new(pick(latejoin))
				G_found.mind.transfer_to(new_monkey)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_monkey.key = G_found.key
				to_chat(new_monkey, "You have been fully respawned. Enjoy the game.")
				message_admins("<span class='notice'>[key_name_admin(usr)] has respawned [new_monkey.key] as a filthy xeno.</span>", 1)
				return	//all done. The ghost is auto-deleted


	//Ok, it's not a xeno or a monkey. So, spawn a human.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	var/datum/data/record/record_found			//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		/*Try and locate a record for the person being respawned through data_core.
		This isn't an exact science but it does the trick more often than not.*/
		var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")

		record_found = find_record("id", id, data_core.locked)

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.fields["name"]
		new_character.setGender(record_found.fields["sex"])
		new_character.age = record_found.fields["age"]
	else
		new_character.setGender(pick(MALE,FEMALE))
		new_character.randomise_appearance_for(new_character.gender)
		new_character.real_name = G_found.real_name

	if(!new_character.real_name)
		new_character.generate_name()
	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
		new_character.mind.special_verbs = list()
	else
		new_character.mind_initialize()
	if(!new_character.mind.assigned_role)
		new_character.mind.assigned_role = "Assistant"//If they somehow got a null assigned role.

	//DNA
	if(record_found)//Pull up their name from database records if they did have a mind.
		new_character.dna = new()//Let's first give them a new DNA.
		new_character.dna.unique_enzymes = record_found.fields["b_dna"]//Enzymes are based on real name but we'll use the record for conformity.
		new_character.dna.b_type = record_found.fields["b_type"]
		new_character.copy_dna_data_to_blood_reagent()

		// I HATE BYOND.  HATE.  HATE. - N3X
		var/list/newSE= record_found.fields["enzymes"]
		var/list/newUI = record_found.fields["identity"]
		new_character.dna.SE = newSE.Copy() //This is the default of enzymes so I think it's safe to go with.
		new_character.dna.UpdateSE()
		new_character.UpdateAppearance(newUI.Copy())//Now we configure their appearance based on their unique identity, same as with a DNA machine or somesuch.
	else//If they have no records, we just do a random DNA for them, based on their random appearance/savefile.
		new_character.dna.ready_dna(new_character)

	new_character.key = G_found.key

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Two variables to properly announce later on.
	var/admin = key_name_admin(src)
	var/player_key = G_found.key
	/*
	//Now for special roles and equipment.
	switch(new_character.mind.special_role)
		if("traitor")
			job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)
			ticker.mode.equip_traitor(new_character)
		if("Wizard")
			new_character.forceMove(pick(wizardstart))
			//ticker.mode.learn_basic_spells(new_character)
			ticker.mode.equip_wizard(new_character)
		if("Syndicate")
			var/obj/effect/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
			if(synd_spawn)
				new_character.forceMove(get_turf(synd_spawn))
			call(/datum/game_mode/proc/equip_syndicate)(new_character)
		if("Death Commando")//Leaves them at late-join spawn.
			new_character.equip_death_commando()
			new_character.internal = new_character.s_store
			new_character.internals.icon_state = "internal1"
		else//They may also be a cyborg or AI.
			switch(new_character.mind.assigned_role)
				if("AI")
					new_character = new_character.AIize()
					if(new_character.mind.special_role=="traitor")
						call(/datum/game_mode/proc/add_law_zero)(new_character)
				if("Cyborg")//More rigging to make em' work and check if they're traitor.
					new_character = new_character.Robotize()
					if(new_character.mind.special_role=="traitor")
						call(/datum/game_mode/proc/add_law_zero)(new_character)
				//Add aliens.
				else
					job_master.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.
	*/
	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found&&new_character.mind.assigned_role!="MODE")//If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
			//Power to the user!
			if(alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,"No","Yes")=="Yes")
				data_core.manifest_inject(new_character)

			if(alert(new_character,"Would you like an active AI to announce this character?",,"No","Yes")=="Yes")
				AnnounceArrival(new_character, new_character.mind.assigned_role)


	message_admins("<span class='notice'>[admin] has respawned [player_key] as [new_character.real_name].</span>", 1)

	to_chat(new_character, "You have been fully respawned. Enjoy the game.")

	feedback_add_details("admin_verb","RSPCH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character

/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Fun"
	set name = "Add Custom AI law"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null
	if(!input)
		return
	for(var/mob/living/silicon/ai/M in mob_list)
		if (M.stat == 2)
			to_chat(usr, "Upload failed. No signal is being detected from the AI.")
		else if (M.see_in_dark == 0)
			to_chat(usr, "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power.")
		else
			M.add_ion_law(input)
			for(var/mob/living/silicon/ai/O in mob_list)
				to_chat(O, "<span class='danger'></span>" + input + "<span class='warning'>...LAWS UPDATED</span>")

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]", 1)

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	if(show_log == "Yes")
		command_alert(/datum/command_alert/ion_storm)
	feedback_add_details("admin_verb","IONC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Rejuvenate"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!mob)
		return
	if(!istype(M))
		alert("Cannot revive a ghost")
		return
	if(config.allow_admin_rev)
		var/confirm = alert(src, "Rejuvenate [M]?", "Confirm", "Yes", "No")
		if(confirm != "Yes")
			return
		if(!M)
			return
		M.revive(0)
		if(M.mind)
			M.mind.suiciding = 0

		log_admin("[key_name(usr)] healed / revived [key_name(M)]")
		message_admins("<span class='warning'>Admin [key_name_admin(usr)] healed / revived [key_name_admin(M)]!</span>", 1)
	else
		alert("Admin revive disabled")
	feedback_add_details("admin_verb","REJU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_create_centcom_report()
	set category = "Special Verbs"
	set name = "Create Command Report"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!map.linked_to_centcomm)
		var/confirmation = alert("The station is not linked to central command by a relay. Ruin immersion?",,"Yes","No")
		if(confirmation == "No")
			return
	var/input = input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as message|null
	if(!input)
		return

	var/customname = input(usr, "Pick a title for the report, or just leave it as Nanotrasen Update. \nLeaving this blank will cancel the command report.", "Choose a title", "Nanotrasen Update") as text|null
	if(!customname)
		return

	var/headsonly = FALSE

	switch(alert("\t[customname] \n\n[input] \n---------- \nIf this message is correct, who is it intended for?", "Please verify your message", "All Crew", "Heads Only", "Cancel"))
		if("All Crew")
			command_alert(input, customname,1);
		if("Heads Only")
			headsonly = TRUE
			to_chat(world, "<span class='warning'>New Nanotrasen Update available at all communication consoles.</span>")
		else
			return

	for (var/obj/machinery/computer/communications/C in machines)
		if(! (C.stat & (BROKEN|NOPOWER) ) )
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = input
			P.update_icon()
			C.messagetitle.Add("[command_name()] Update")
			C.messagetext.Add(P.info)

	world << sound('sound/AI/commandreport.ogg', volume = 60)
	log_admin("[key_name(src)] has created a [headsonly ? "heads only" : "publicly announced"] command report titled [customname]: [input]")
	message_admins("[key_name_admin(src)] has created a command report", 1)
	feedback_add_details("admin_verb","CCR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_delete(atom/O in world)
	set category = "Admin"
	set name = "Delete"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to delete:\n[O]\nat ([O.x], [O.y], [O.z])?", "Confirmation", "Yes", "No") == "Yes")
		log_admin("[key_name(usr)] deleted [O] at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] deleted [O] at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","DEL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(istype(O,/turf))
			var/turf/T=O
			T.ChangeTurf(T.get_underlying_turf())
		else
			qdel(O)

/client/proc/cmd_admin_list_open_jobs()
	set category = "Admin"
	set name = "List free slots"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(job_master)
		for(var/datum/job/job in job_master.occupations)
			to_chat(src, "[job.title]: [job.get_total_positions()]")
	feedback_add_details("admin_verb","LFS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in world)
	set category = "Special Verbs"
	set name = "Explosion"

	if(!check_rights(R_DEBUG|R_FUN))
		return

	var/devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null)
		return
	var/heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null)
		return
	var/light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null)
		return
	var/flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null)
		return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20))
			if (alert(src, "Are you sure you want to do this? It will laaag.", "Confirmation", "Yes", "No") == "No")
				return

		explosion(O, devastation, heavy, light, flash, whodunnit = usr)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","EXPL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in world)
	set category = "Special Verbs"
	set name = "EM Pulse"

	if(!check_rights(R_DEBUG|R_FUN))
		return

	var/heavy = input("Range of heavy pulse.", text("Input"))  as num|null
	if(heavy == null)
		return
	var/light = input("Range of light pulse.", text("Input"))  as num|null
	if(light == null)
		return

	if (heavy || light)

		empulse(O, heavy, light)
		log_admin("[key_name(usr)] created an EM Pulse ([heavy],[light]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an EM PUlse ([heavy],[light]) at ([O.x],[O.y],[O.z])", 1)
		feedback_add_details("admin_verb","EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		return
	else
		return

/client/proc/cmd_admin_gib(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Gib"

	if(!check_rights(R_ADMIN|R_FUN))
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)
		return

	log_admin("[key_name(usr)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(M)]", 1)

	if(!istype(M, /mob/dead/observer))
		M.gib()
	else
		gibs(M.loc, null)
	feedback_add_details("admin_verb","GIB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	set category = "Fun"

	if(!istype(mob, /mob/dead/observer))
		var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
		if(confirm != "Yes")
			return

	log_admin("[key_name(usr)] used gibself.")
	message_admins("<span class='notice'>[key_name_admin(usr)] used gibself.</span>", 1)
	if(!istype(mob, /mob/dead/observer))
		mob.gib()
	else
		gibs(mob.loc, null)
	feedback_add_details("admin_verb","GIBS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/*
/client/proc/cmd_manual_ban()
	set name = "Manual Ban"
	set category = "Special Verbs"
	if(!authenticated || !holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/mob/M = null
	switch(alert("How would you like to ban someone today?", "Manual Ban", "Key List", "Enter Manually", "Cancel"))
		if("Key List")
			var/list/keys = list()
			for(var/mob/M in world)
				keys += M.client
			var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in keys
			if(!selection)
				return
			M = selection:mob
			if ((M.client && M.client.holder && (M.client.holder.level >= holder.level)))
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

	switch(alert("Temporary Ban?",,"Yes","No"))
	if("Yes")
		var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num
		if(!mins)
			return
		if(mins >= 525600)
			mins = 525599
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		if(M)
			AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
			to_chat(M, "<span class='warning'><BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
			to_chat(M, "<span class='warning'>This is a temporary ban, it will be removed in [mins] minutes.</span>")
			to_chat(M, "<span class='warning'>To try to resolve this matter head to http:)//ss13.donglabs.com/forum/</span>"

			log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
			message_admins("<span class='warning'>[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.</span>")
			world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=[mins]&server=[replacetext(config.server_name, "#", "")]")
			del(M.client)
			qdel(M)
		else

	if("No")
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
		to_chat(M, "<span class='warning'><BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
		to_chat(M, "<span class='warning'>This is a permanent ban.</span>")
		to_chat(M, "<span class='warning'>To try to resolve this matter head to http:)//ss13.donglabs.com/forum/</span>"

		log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
		message_admins("<span class='warning'>[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.</span>")
		world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=perma&server=[replacetext(config.server_name, "#", "")]")
		del(M.client)
		qdel(M)
*/

/client/proc/update_world()
	// If I see anyone granting powers to specific keys like the code that was here,
	// I will both remove their SVN access and permanently ban them from my servers.
	return

/client/proc/cmd_admin_check_contents(mob/living/L as mob in mob_list)
	set category = "Special Verbs"
	set name = "Check Mob Contents"

	for (var/content in get_contents_in_object(L))
		if (content)
			to_chat(usr, "[bicon(content)] [content]")

	feedback_add_details("admin_verb","CC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_view_range()
	set category = "Special Verbs"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views"

	if(view == world.view)
		changeView(input("Select view range:", "FUCK YE", 7) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,128))
	else
		changeView()

	log_admin("[key_name(usr)] changed their view range to [view].")
	//message_admins("<span class='notice'>[key_name_admin(usr)] changed their view range to [view].</span>", 1)	//why? removed by order of XSI

	feedback_add_details("admin_verb","CVRA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_call_shuttle()
	set category = "Admin"
	set name = "Call Shuttle"

	if ((!( ticker ) || emergency_shuttle.location))
		return

	if(!check_rights(R_ADMIN))
		return

	if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction" || ticker.mode.name == "confliction")
		var/choice = input("The shuttle will just return if you call it. Call anyway?") in list("Confirm", "Cancel")
		if(choice == "Confirm")
			emergency_shuttle.fake_recall = rand(300,500)
		else
			return

	var/justification = stripped_input(usr, "Please input a reason for the shuttle call. You may leave it blank to not have one.", "Justification")
	var/confirm = alert(src, "Are you sure you want to call the shuttle?", "Confirm", "Yes", "Cancel")
	if(confirm != "Yes")
		return

	emergency_shuttle.incall()
	var/datum/command_alert/emergency_shuttle_called/CA = new /datum/command_alert/emergency_shuttle_called
	if(justification)
		CA.justification = justification
	command_alert(CA)
	feedback_add_details("admin_verb","CSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called the emergency shuttle.")
	message_admins("<span class='notice'>[key_name_admin(usr)] admin-called the emergency shuttle.</span>", 1)
	return

/client/proc/admin_cancel_shuttle()
	set category = "Admin"
	set name = "Cancel Shuttle"

	if(!check_rights(R_ADMIN))
		return

	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes")
		return

	if(!ticker || emergency_shuttle.location || emergency_shuttle.direction == 0)
		return

	emergency_shuttle.recall()
	feedback_add_details("admin_verb","CCSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
	message_admins("<span class='notice'>[key_name_admin(usr)] admin-recalled the emergency shuttle.</span>", 1)

	return

/client/proc/admin_deny_shuttle()
	set category = "Admin"
	set name = "Toggle Deny Shuttle"

	if (!ticker)
		return

	if(!check_rights(R_ADMIN))
		return

	emergency_shuttle.deny_shuttle = !emergency_shuttle.deny_shuttle

	log_admin("[key_name(src)] has [emergency_shuttle.deny_shuttle ? "denied" : "allowed"] the shuttle to be called.")
	message_admins("[key_name_admin(usr)] has [emergency_shuttle.deny_shuttle ? "denied" : "allowed"] the shuttle to be called.")

/client/proc/cmd_admin_attack_log(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Attack Log"

	to_chat(usr, text("<span class='danger'>Attack Log for []</span>", mob))
	for(var/t in M.attack_log)
		to_chat(usr, t)
	feedback_add_details("admin_verb","ATTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/everyone_random()
	set category = "Fun"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(!check_rights(R_FUN))
		return

	if (ticker && ticker.mode)
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!")
		return

	if(ticker.random_players)
		ticker.random_players = 0
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.", 1)
		to_chat(usr, "Disabled.")
		return


	var/notifyplayers = alert(src, "Do you want to notify the players?", "Options", "Yes", "No", "Cancel")
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.", 1)

	if(notifyplayers == "Yes")
		to_chat(world, "<span class='notice'><b>Admin [usr.key] has forced the players to have completely random identities!</span>")

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.")

	ticker.random_players = 1
	feedback_add_details("admin_verb","MER") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/toggle_random_events()
	set category = "Server"
	set name = "Toggle random events on/off"
	set desc = "Toggles random events such as meteors, black holes, blob (but not space dust) on/off"

	if(!check_rights(R_SERVER))
		return

	if(!config.allow_random_events)
		config.allow_random_events = 1
		to_chat(usr, "Random events enabled")
		message_admins("Admin [key_name_admin(usr)] has enabled random events.", 1)

	else
		config.allow_random_events = 0
		to_chat(usr, "Random events disabled")
		message_admins("Admin [key_name_admin(usr)] has disabled random events.", 1)

	feedback_add_details("admin_verb","TRE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/save_coordinates(var/x1 as num, var/y1 as num, var/z1 as num, var/x2 as num, var/y2 as num, var/z2 as num, var/mapname as text)
	set name     = "Save map by coordinates"
	set category = "Fun"
	set desc     = "(x1, y1, z1, x2, y2, z2, mapname) Saves the map beetween (x1, y1, z1) and (x2, y2, z2), and it will be sent to your client, it will also be stored in data/logs/saved_maps."

	if(!check_rights(R_SERVER))
		return

	if(!(x1 && x2 && y1 && y2 && z1 && z2))
		usr << "Not all coordinates supplied."
		return

	if(ckeyEx(mapname) != mapname || !mapname)
		usr << "Map name contains invalid characters or is empty."
		return

	var/confirm = alert("Are you sure you want to save the map between coordinates ([x1], [y1], [z1]) and ([x2], [y2], [z2])? This can cause quite a bit of lag!", "Save map", "Yes, do it!", "No")
	if(confirm == "No")
		return

	var/dmm_suite/DMM = new

	var/turf/T1 = locate(x1, y1, z1)
	var/turf/T2 = locate(x2, y2, z2)

	var/output = DMM.write_map(T1, T2, DMM_IGNORE_MOBS)

	if(fexists("data/logs/saved_maps/[mapname].dmm"))
		fdel("data/logs/saved_maps/[mapname].dmm")

	var/F = file("data/logs/saved_maps/[mapname].dmm")
	F   << output
	usr << ftp(F)

	feedback_add_details("admin_verb", "SCO") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_equip_loadout(mob/M as mob in mob_list)
	set category = "Fun"
	set name = "Equip Loadout"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!check_rights(R_SPAWN))
		to_chat(src, "You do not have the required permissions to use this command.")
		return
	if(!mob)
		return
	var/list/dropped_items
	var/delete_items
	var/strip_items = input(usr,"Do you want to strip \the [M]'s current equipment?","Equip Outfit","") as null|anything in list("Yes","No")
	if(!strip_items)
		return
	if(strip_items == "Yes")
		delete_items = input(usr,"Delete stripped items?","Equip Outfit","") as null|anything in list("Yes","No")
		if(!delete_items)
			return
	var/list/outfits = (typesof(/datum/outfit/) - /datum/outfit/ - /datum/outfit/striketeam/)
	var/outfit_type = input(usr,"Outfit Type","Equip Outfit","") as null|anything in outfits
	if(!outfit_type || !ispath(outfit_type))
		return
	if(strip_items == "Yes")
		dropped_items = M.unequip_everything()
		if(delete_items == "Yes")
			for(var/atom/A in dropped_items)
				qdel(A)
	var/datum/outfit/concrete_outfit = new outfit_type
	concrete_outfit.equip(M, TRUE)
	log_admin("[key_name(usr)] has equipped an loadout of type [outfit_type] to [key_name(M)].")
	message_admins("<span class='notice'>[key_name(usr)] has equipped an loadout of type [outfit_type] to [key_name(M)].</span>", 1)

	feedback_add_details("admin_verb","ELO") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/select_loadout()
	var/list/outfits = (subtypesof(/datum/outfit/) - /datum/outfit/striketeam/)
	var/outfit_type = input(usr,"Outfit Type","Equip Outfit","") as null|anything in outfits
	if(!outfit_type || !ispath(outfit_type))
		return
	return outfit_type
