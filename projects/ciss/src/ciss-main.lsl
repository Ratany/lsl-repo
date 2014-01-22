// CUFF INTEGRATED SUPPORT SYSTEM: CISS main script v1.3
// Copyright (c) 2008, Shan Bright & Innula Zenovka.
// All rights reserved.

// Released under the "Simplified BSD License".
// http://www.opensource.org/licenses/bsd-license.php

// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
// * Redistributions of source code must retain the above copyright
// * notice, this list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright
// * notice, this list of conditions and the following disclaimer in
// * the documentation and/or other materials provided with the
// * distribution.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
// OF THE POSSIBILITY OF SUCH DAMAGE.

// INTRODUCTION

// The Cuff Integrated Support System allows sex toys to generate
// chains between their prims and cuffs worn by avatars using them. It
// consists of two scripts: The "CISS main script", which you are
// reading, should be dropped into the prim which contains the
// animation items: usually the root. The "CISS sit script" should be
// dropped into any prim on which the avatar might sit to use the toy
// (including the prim containing the main script, if a user might sit
// on it). If the toy works by rezzing pose-balls (as, for instance,
// the MLP scripts do), then this script must inside the pose ball
// pose ball when it is rezzed.

// SETTINGS

// (To tell the script which cuffs to chain where and when, you must
// answer question 1. Questions 2, 3 and 4 are optional: the default
// values will generally work well.)

// 1. For each animation, which cuffs should be chained to which
// prims? Load the list below with "animation",
// ""leftwrist,prim1,rightwrist,prim2"" values. For instance, if while
// kneeling, the back of an avatar's collar should be chained to the
// iron ring, add "kneeling", "collarbackloop,iron ring". The prim to
// which you chain each cuff must be part of the same object as the
// prim containing this script. The word "collarbackloop" is a
// Lockguard tag, the most common of which are "collarfrontloop",
// "leftwrist", "rightwrist", "leftankle" and "rightankle": the full
// list of tags can be read at
// http://www.lslwiki.net/lslwiki/wakka.php?wakka=exchangeLockGuardItem

list    animations                = [
				     "kneeling", "collarbackloop,iron ring",
				     "animationB", "leftwrist,prim1,rightwrist,prim2",
				     "animationC", "leftwrist,prim3,rightwrist,prim4"
				     ];

// 2. Do you wish to specify any special Lockguard parameters? For a
// description of their use, see Lockguard documentation: and note
// that if you do not specify these parameters, the type of chain will
// be controlled by the cuffs worn. Commonly used parameters are
// "gravity g", "life secs", "color red green blue", "size x y",
// "texture uuid". For example, "color 1 0 0 texture
// 6808199d-e4c8-22f9-cf8a-2d9992ab630d" will bind with red ropes. For
// more information on these parameters, consult
// http://www.lslwiki.net/lslwiki/wakka.php?wakka=exchangeLockGuard

string  CHAIN_PARAMETERS        = "";

// 3. How many seconds should the script leave between each update of
// the chain's positions?

float   UPDATE_CYCLE            = 2.0;

// 4. Though it is infrequent, sometimes Second Life loses
// messages. If a message from the prim an avatar is sitting was lost,
// this script might not realise that the avatar is no longer using
// the toy, and continue to run. To avoid wasting resources, the
// script periodically scans to see if the avatars it thinks are there
// really are. How many update cycles should it wait before conducting
// this check, and how far should it scan?

integer UPDATES_PER_SCAN        = 3;
float   SCAN_RANGE              = 5.0;

// REVISION HISTORY

// Note: please remember to update the version number in the first
// line of this script and in the description field.


// 080808 1.3 Shan Bright: Added protocols to send this toy's key to a
//            rezzed poseball, and listen for it in replies, to stop
//            toys fighting over nearby poseballs.
//
// 080802 1.2 Innula Zenovka/Shan Bright: New revision history &
//            documentation changes.
//
// 080801 1.1 Shan Bright: Name changed to CISS (Cuff Integrated
//            Support System) to avoid existing product name, and
//            CHAIN_PARAMETER variable added to SETTINGS section.
//
// 080731 1.0 Shan Bright: First release of "CCS" (Cuff Consciousness
//            System).

// PROGRAM

// (Beyond this point is the script itself: you do not need to
// understand or change this to use CISS.)

// Declare global variables. (Note that while LSL doesn't provide
// constants, capitalised variables denote pseudo-constants which will
// not change value during the operation of the program.)

integer CISS_CHANNEL            = -1991;
integer LOCKGUARD_CHANNEL       = -9119;
integer NO_ANIMATION_INDEX      = -1;

list    avatars                 = [];
integer timer_running           = FALSE;
integer updates_since_scan      = 0;


// Start the script.

start()
{
	// Listen out for messages from the "CISS sit script".

	llListen(CISS_CHANNEL, "", NULL_KEY, "");

	// If animation keys cannot be read, they must be triggered to read their keys.

	integer permissions_needed = FALSE;
	integer animation_index = 0;

	while(animation_index < llGetListLength(animations)
	      && !permissions_needed)
		{
			string animation = llList2String(animations, animation_index);

			if(llGetInventoryType(animation) != INVENTORY_ANIMATION)
				{
					animations = llDeleteSubList(animations, animation_index, animation_index + 1);
					llOwnerSay("CISS problem: no animation called '" + animation + "'.");
				}
			else
				{
					if(llGetInventoryKey(llList2String(animations, animation_index)) == NULL_KEY)
						{
							permissions_needed = TRUE;
						}

					animation_index += 2;
				}
		}

	if(permissions_needed)
		{
			llOwnerSay("CISS: This device needs to briefly test its animations: please grant permission for it to animate your avatar.");
			llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
		}
	else
		{
			find_keys(FALSE);
		}
}


// Find animation and prim keys.

find_keys(integer can_animate)
{
	// Build a list of the names and keys of prims in this object.

	list prims = [];
	integer prim_index = 1;

	while(prim_index <= llGetNumberOfPrims())
		{
			prims += (prims = []) + prims + [llGetLinkName(prim_index), llGetLinkKey(prim_index)];
			prim_index++;
		}

	// Loop round the animations.

	integer animation_index = 0;

	while(animation_index < llGetListLength(animations))
		{
			string animation = llList2String(animations, animation_index);
			llOwnerSay("CISS: Testing animation " + animation + ".");

			// Find the animation key for each animation name: report any missing.

			key animation_key = llGetInventoryKey(animation);

			if(animation_key == NULL_KEY && can_animate)
				{
					list old_keys = llGetAnimationList(llGetOwner());
					llStartAnimation(animation);
					list new_keys = llGetAnimationList(llGetOwner());
					llStopAnimation(animation);
					integer key_index = 0;

					while(key_index < llGetListLength(new_keys) && llListFindList(old_keys, [llList2Key(new_keys, key_index)]) >= 0)
						{
							key_index++;
						}

					if(key_index < llGetListLength(new_keys))
						{
							animation_key = llList2Key(new_keys, key_index);
						}
				}

			// Loop round the chains associated with this animation.

			list chains = llCSV2List(llList2String(animations, animation_index + 1));
			integer chain_index = 0;

			while(chain_index < llGetListLength(chains))
				{

					// Replace the prim name this chain leads to with a key: report if missing.

					string prim_name = llList2String(chains, chain_index + 1);
					integer prim_position = llListFindList(prims, [prim_name]);
					key prim_key = NULL_KEY;

					if(prim_position < 0)
						{
							llOwnerSay("CISS problem: no prim called '" + prim_name + "'.");
						}
					else
						{
							prim_key = llList2Key(prims, prim_position + 1);
						}

					chains = llListReplaceList(chains, [prim_key], chain_index + 1, chain_index + 1);
					chain_index += 2;
				}

			// Update the animation with its key and the updated chain definitions.

			animations = llListReplaceList(animations, [animation_key, llList2CSV(chains)], animation_index, animation_index + 1);
			animation_index += 2;
		}

	llOwnerSay("CISS: Animation tests complete. " + (string) llGetFreeMemory() + " bytes of memory free.");
}


// Act on messages reporting avatars sitting on the toy, or standing up again.

handle_message(string message, key avatar)
{
	// Update the list of avatars as they sit and stand.

	if(message == "CISS: someone sat")
		{
			if(llListFindList(avatars, [avatar]) < 0)
				{
					avatars = (avatars = []) + avatars + [avatar, NO_ANIMATION_INDEX];
				}
		}
	else
		if(message == "CISS: someone stood")
			{
				integer avatar_index = llListFindList(avatars, [avatar]);

				if(avatar_index >= 0)
					{
						change_animation(avatar, llList2Integer(avatars, avatar_index + 1), NO_ANIMATION_INDEX);
						avatars = llDeleteSubList(avatars, avatar_index, avatar_index + 1);
					}
			}

	// The timer should be running while anyone is using the toy.

	if(llGetListLength(avatars) == 0)
		{
			if(timer_running)
				{
					llSetTimerEvent(0.0);
					timer_running = FALSE;
				}
		}
	else
		{
			if(!timer_running)
				{
					llSetTimerEvent(UPDATE_CYCLE);
					timer_running = TRUE;
				}
		}
}


// Cycle through the list of avatars using the toy, updating their chains.

update_chains()
{
	integer avatar_index = 0;

	while(avatar_index < llGetListLength(avatars))
		{
			// Find the first of the avatar's animations for which chains are defined.

			key avatar = llList2Key(avatars, avatar_index);
			integer new_animation_index = NO_ANIMATION_INDEX;
			list avatar_animations = llGetAnimationList(avatar);
			integer avatar_animation_index = 0;

			while(avatar_animation_index < llGetListLength(avatar_animations) && new_animation_index < 0)
				{
					new_animation_index = llListFindList(animations, [llList2Key(avatar_animations, avatar_animation_index)]);
					avatar_animation_index++;
				}

			// If the animation is different to the former one, reposition the chains.

			integer old_animation_index = llList2Integer(avatars, avatar_index + 1);

			if(new_animation_index != old_animation_index)
				{
					change_animation(avatar, old_animation_index, new_animation_index);
					avatars = llListReplaceList(avatars, [new_animation_index], avatar_index + 1, avatar_index + 1);
				}

			avatar_index += 2;
		}
}


// Switch an avatar from one animation to another.

change_animation(key avatar, integer old_animation_index, integer new_animation_index)
{
	// Read the lists of chains for the old and new animations.

	list new_chains = [];

	if(new_animation_index >= 0)
		{
			new_chains = llCSV2List(llList2String(animations, new_animation_index + 1));
		}

	list old_chains = [];

	if(old_animation_index >= 0)
		{
			old_chains = llCSV2List(llList2String(animations, old_animation_index + 1));
		}

	// Cycle round the chained cuffs, releasing and rechaining where necessary.

	integer old_chain_index = 0;
	integer new_chain_index = 0;

	while(old_chain_index < llGetListLength(old_chains))
		{
			string old_cuff = llList2String(old_chains, old_chain_index);
			string old_prim = llList2String(old_chains, old_chain_index + 1);
			integer new_chain_index = llListFindList(new_chains, [old_cuff]);
			string new_prim = "";

			if(new_chain_index >= 0)
				{
					new_prim = llList2String(new_chains, new_chain_index + 1);
				}

			if(old_prim != new_prim)
				{
					llWhisper(LOCKGUARD_CHANNEL, "lockguard " + (string) avatar + " " + old_cuff + " unlink");

					if(new_prim != "")
						{
							llWhisper(LOCKGUARD_CHANNEL, "lockguard " + (string) avatar + " " + old_cuff + " link " + new_prim + " " + CHAIN_PARAMETERS);
						}
				}

			old_chain_index += 2;
		}

	// Chain any cuffs not previously chained.

	new_chain_index = 0;

	while(new_chain_index < llGetListLength(new_chains))
		{
			string new_cuff = llList2String(new_chains, new_chain_index);

			if(llListFindList(old_chains, [new_cuff]) < 0)
				{
					string new_prim = llList2String(new_chains, new_chain_index + 1);
					llWhisper(LOCKGUARD_CHANNEL, "lockguard " + (string) avatar + " " + new_cuff + " link " + new_prim + " " + CHAIN_PARAMETERS);
				}

			new_chain_index += 2;
		}
}


// Handle events.

default
{
	// Reset when the object is rezzed.

	on_rez(integer start_parameter)
		{
			llResetScript();
		}

	state_entry()
		{
			start();
		}

	// On getting permission to animate, use it to find the animation keys.

	run_time_permissions(integer permissions)
		{
			find_keys(permissions & PERMISSION_TRIGGER_ANIMATION);
		}

	// Tell the "CSS sit script" in any object rezzed to communicate with *this* toy.

	object_rez(key id)
		{
			llSleep(0.5);
			llWhisper(CISS_CHANNEL, "CISS: i rezzed you," + (string) id);
		}

	// "CISS sit script" communicates by link message if it can, and chat otherwise.

	link_message(integer sender, integer number, string message, key id)
		{
			if(llGetSubString(message, 0, 4) == "CISS:")
				{
					handle_message(message, id);
				}
		}

	listen(integer channel, string name, key id, string message)
		{
			if(llGetOwnerKey(id) == llGetOwner() && llGetSubString(message, 0, 4) == "CISS:")
				{
					key sender_rezzed_by = (key)llList2String(llCSV2List(message), 1);
					key sitter = (key)llList2String(llCSV2List(message), 2);
					message = llList2String(llCSV2List(message), 0);

					if(sender_rezzed_by == llGetKey())
						{
							handle_message(message, sitter);
						}
				}
		}

	// Keep updating the chains, periodically making sure the avatars are still there.

	timer()
		{
			update_chains();

			if(++updates_since_scan >= UPDATES_PER_SCAN)
				{
					llSensor("", NULL_KEY, AGENT, SCAN_RANGE, PI);
					updates_since_scan = 0;
				}
		}

	// No one is near the toy: remove all chains and kill the timer.

	no_sensor()
		{
			integer avatar_index = 0;

			while(avatar_index < llGetListLength(avatars))
				{
					change_animation(llList2Key(avatars, avatar_index),
							 llList2Integer(avatars, avatar_index + 1),
							 NO_ANIMATION_INDEX);
					avatar_index += 2;
				}

			timer_running = FALSE;
			llSetTimerEvent(0.0);
		}
}
