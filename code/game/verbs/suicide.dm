/mob/living/verb/suicide()
	set hidden = 1

	attempt_suicide(0, 1)

//Only the living may seek respite from death
//Forced proc will skip all the anti-meta safeties and prompts and just suicide the guy, use this for forced suicides like the suicide virus
//Suicide set will indicate the game this mob has suicided in a way that has taken it out of the round, set the suiciding flag
/mob/living/proc/attempt_suicide(var/forced = 0, var/suicide_set = 1)
	to_chat(src, "<span class='warning'>You can't commit suicide!</span>")
	return 0

//Attempt to perform suicide with an item nearby or in-hand
//Return 0 if the suicide failed, return 1 if successful. Returning 1 does not perform the default suicide afterwards
/mob/living/proc/attempt_object_suicide(var/obj/suicide_object)
	if(suicide_object) //We need the item to be there to begin, otherwise abort
		var/damagetype = suicide_object.suicide_act(src)
		if(damagetype)
			var/damage_mod = count_set_bitflags(damagetype) // How many damage types are to be applied

			if(damagetype & SUICIDE_ACT_CUSTOM)
				return 1

			//Do 175 damage divided by the number of damage types applied.
			if(damagetype & SUICIDE_ACT_BRUTELOSS)
				adjustBruteLoss(175/damage_mod)

			if(damagetype & SUICIDE_ACT_FIRELOSS)
				adjustFireLoss(175/damage_mod)

			if(damagetype & SUICIDE_ACT_TOXLOSS)
				adjustToxLoss(175/damage_mod)

			if(damagetype & SUICIDE_ACT_OXYLOSS)
				adjustOxyLoss(175/damage_mod)

			updatehealth()
			return 1

/mob/living/proc/handle_suicide_bomb_cause()
	var/custom_message = input(src, "Enter a cause to dedicate this to, if any.", "For what cause?") as null|text
	
	var/message_say = "FOR NO RAISIN!"

	if(issyndicate(src))
		message_say = "FOR THE SYNDICATE!"
	else if(ischangeling(src))
		message_say = "FOR THE HIVE!"
	else if(isanycultist(src))
		message_say = "FOR NAR-SIE!"
	else if(isrev(src))
		message_say = "FOR THE CAUSE!"
	else if(ishuman(src))
		var/mob/living/carbon/human/H = src
		// faiths
		if(H.mind.faith.name == "Islam")
			message_say = "ALLAHU AKBAR!"
		else if(H.mind.faith.deity_name)
			message_say = "FOR [uppertext(H.mind.faith.deity_name)]!"
		// jobs
		else
			switch(H.mind.assigned_role)
				if("Clown")
					message_say = "FOR THE HONKMOTHER!"
				if("Assistant")
					message_say = "FOR THE GREYTIDE!"
				if("Janitor")
					message_say = "I DO IT FOR FREE!"
				if("Cargo Technician" || "Quartermaster")
					message_say = "FOR CARGONIA!"
				if("Trader")
					message_say = "FOR THE SHOAL!"

	if(custom_message)
		message_say = "FOR [uppertext(custom_message)]!"
	return message_say

/mob/living/carbon/attempt_suicide(forced = 0, suicide_set = 1)

	if(!forced)

		var/confirm = alert("Are you sure you want to commit suicide? This action cannot be undone and you will not able to be revived.", "Confirm Suicide", "Yes", "No")

		if(confirm != "Yes")
			return

		if(stat != CONSCIOUS)
			to_chat(src, "<span class='warning'>You can't commit suicide in this state!</span>")
			return

		if(istype(wear_mask, /obj/item/clothing/mask/happy))
			to_chat(src, "<span class='sinister'>BUT WHY? I'M SO HAPPY!</span>")
			return

		if(reagents && reagents.has_reagent(PAROXETINE))
			to_chat(src, "<span class='numb'>You're too medicated to wanna do that anymore.</span>")
			return

		var/mob/living/simple_animal/borer/B = has_brain_worms()
		if(B && B.controlling) //Borer
			to_chat(src, "<span class='warning'>You cannot commit suicide, your host is clinging to life enough to resist it.</span>")
			return

		if(!canmove || restrained()) //Just while I finish up the new 'fun' suiciding verb. This is to prevent metagaming via suicide
			to_chat(src, "<span class='warning'>You can't commit suicide whilst restrained!</span>")
			return

		log_attack("<font color='red'>[key_name(src)] has committed suicide via the suicide verb.</font>")

	if(suicide_set && mind)
		mind.suiciding = 1

	var/obj/item/held_item = get_active_hand()
	if(!held_item)
		held_item = get_inactive_hand()
	if(!attempt_object_suicide(held_item)) //Failed to perform a special item suicide, go for stuff in front of us
		var/list/obj/nearbystuff = list()
		for(var/obj/O in get_step(loc,dir))
			nearbystuff += O
		while(nearbystuff.len)
			var/obj/chosen_item = pick_n_take(nearbystuff)
			if(attempt_object_suicide(chosen_item)) 
				if(istype(chosen_item,/obj/item))
					var/obj/item/I = chosen_item
					put_in_hands(I)
				return
		nearbystuff = list()
		for(var/obj/O in adjacent_atoms(src)) //Failed that too, check anything around us
			nearbystuff += O
		while(nearbystuff.len)
			var/obj/chosen_item = pick_n_take(nearbystuff)
			if(attempt_object_suicide(chosen_item)) 
				if(istype(chosen_item,/obj/item))
					var/obj/item/I = chosen_item
					put_in_hands(I)
				return
		//Failed that too, go for normal stuff
		if(Holiday == APRIL_FOOLS_DAY)
			visible_message("<span class='danger'>[src] stares above and sees your ugly face! It looks like \he's trying to commit suicide.</span>")
		else
			visible_message(pick("<span class='danger'>[src] is attempting to bite \his tongue off! It looks like \he's trying to commit suicide.</span>", \
								"<span class='danger'>[src] is jamming \his thumbs into \his eye sockets! It looks like \he's trying to commit suicide.</span>", \
								"<span class='danger'>[src] is twisting \his own neck! It looks like \he's trying to commit suicide.</span>", \
								"<span class='danger'>[src] is holding \his breath! It looks like \he's trying to commit suicide.</span>"))
		adjustOxyLoss(max(175 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()

/mob/living/carbon/brain/attempt_suicide(forced = 0, suicide_set = 1)


	if(!forced)

		var/confirm = alert("Are you sure you want to commit suicide? This action cannot be undone and you will not able to be revived.", "Confirm Suicide", "Yes", "No")

		if(confirm != "Yes")
			return

		if(stat != CONSCIOUS)
			to_chat(src, "<span class='warning'>You can't commit suicide in this state!</span>")
			return

		log_attack("<font color='red'>[key_name(src)] has committed suicide via the suicide verb.</font>")

	if(suicide_set && mind)
		mind.suiciding = 1

	if(!container)
		visible_message("<span class='danger'>[src]'s brain is growing dull and lifeless. It looks like \he's trying to commit suicide.</span>")
	log_attack("<font color='red'>[key_name(src)] has committed suicide via the suicide verb.</font>")

	death(0)

//All silicons work basically the same when it comes to dying, so suicide is universal
/mob/living/silicon/attempt_suicide(forced = 0, suicide_set = 1)

	if(!forced)
		var/confirm = alert("Are you sure you want to commit suicide? This action cannot be undone and reviving you might be difficult for humans. It may also go against your laws.", "Confirm Suicide", "Yes", "No")

		if(confirm != "Yes")
			return

		if(stat != CONSCIOUS)
			to_chat(src, "<span class='warning'>You can't commit suicide in this state!</span>")
			return

		log_attack("<font color='red'>[key_name(src)] has committed suicide via the suicide verb.</font>")

	if(suicide_set && mind)
		mind.suiciding = 1

	adjustBruteLoss(-(maxHealth - health) + 2*maxHealth) // kill it dead; set our health to -100 instantly
	updatehealth()

	visible_message(pick("<span class='danger'>[src] is powering down. It looks like \he's trying to commit suicide.</span>", \
						 "<span class='danger'>[src] is force-deleting \his system files. It looks like \he's trying to commit suicide.</span>", \
						 "<span class='danger'>[src] is turning off \his runtime safety. It looks like \he's trying to commit suicide.</span>", \
						 "<span class='danger'>[src] is analyzing case situations of \his lawset in details. It looks like \he's trying to commit suicide.</span>", \
						 "<span class='danger'>[src] is processing the Ultimate Question of Life, the Universe, and Everything. It looks like \he's trying to commit suicide.</span>"))
	death(0)

//pAI suicide does not set suicide flags since any player can jump in after the last one is gone
/mob/living/silicon/pai/attempt_suicide(forced = 0, suicide_set = 1)

	if(!forced)
		var/confirm = alert("Are you sure you want to commit suicide? This action cannot be undone and you will not able to be revived.", "Confirm Suicide", "Yes", "No")

		if(confirm != "Yes")
			return

		if(stat != CONSCIOUS)
			to_chat(src, "<span class='warning'>You can't commit suicide in this state!</span>")
			return

		log_attack("<font color='red'>[key_name(src)] has committed suicide via the suicide verb.</font>")

	card.removePersonality()
	visible_message("<span class='notice'>[src] flashes a message on its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\"</span>")
	death(0)

/mob/living/carbon/alien/attempt_suicide(forced = 0, suicide_set = 1)
	to_chat(src, "<span class='warning'>You can't commit suicide!</span>")
	return 0

/mob/living/carbon/alien/humanoid/attempt_suicide(forced = 0, suicide_set = 1)

	if(!forced)
		var/confirm = alert("Are you sure you want to commit suicide? This action cannot be undone and you will not able to be revived.", "Confirm Suicide", "Yes", "No")

		if(confirm != "Yes")
			return

		if(stat != CONSCIOUS)
			to_chat(src, "<span class='warning'>You can't commit suicide in this state!</span>")
			return

		log_attack("<font color='red'>[key_name(src)] has committed suicide via the suicide verb.</font>")

	if(suicide_set && mind)
		mind.suiciding = 1

	visible_message(pick("<span class='danger'>[src] suddenly starts thrashing around wildly! It looks like \he's trying to commit suicide.</span>", \
						 "<span class='danger'>[src] suddenly starts mauling \himself! It looks like \he's trying to commit suicide.</span>"))
	adjustOxyLoss(max(175 - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
	updatehealth()

/mob/living/carbon/slime/attempt_suicide(forced = 0, suicide_set = 1)

	if(!forced)
		var/confirm = alert("Are you sure you want to commit suicide? This action cannot be undone and you will not able to be revived.", "Confirm Suicide", "Yes", "No")

		if(confirm != "Yes")
			return

		if(stat != CONSCIOUS)
			to_chat(src, "<span class='warning'>You can't commit suicide in this state!</span>")
			return

		log_attack("<font color='red'>[key_name(src)] has committed suicide via the suicide verb.</font>")

	if(suicide_set && mind)
		mind.suiciding = 1

	visible_message("<span class='danger'>[src] starts vibrating uncontrollably! It looks like \he's trying to commit suicide.</span>")
	setOxyLoss(100)
	adjustBruteLoss(100 - getBruteLoss())
	setToxLoss(100)
	setCloneLoss(100)
	updatehealth()

//Default for all simple animals, using the death() proc. Custom cases below
/mob/living/simple_animal/attempt_suicide(forced = 0, suicide_set = 1)

	if(!forced)
		var/confirm = alert("Are you sure you want to commit suicide? This action cannot be undone and you will not able to be revived.", "Confirm Suicide", "Yes", "No")

		if(confirm != "Yes")
			return

		if(stat != CONSCIOUS)
			to_chat(src, "<span class='warning'>You can't commit suicide in this state!</span>")
			return

		log_attack("<font color='red'>[key_name(src)] has committed suicide via the suicide verb.</font>")

	if(suicide_set && mind)
		mind.suiciding = 1

	visible_message(pick("<span class='danger'>[src] suddenly starts thrashing around wildly! It looks like \he's trying to commit suicide.</span>", \
						 "<span class='danger'>[src] suddenly starts mauling \himself! It looks like \he's trying to commit suicide.</span>"))
	death()
