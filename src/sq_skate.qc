void() water_die;

void() switch_skating =
{
        if (!cvar("sq_walking") && self.skating)
        {
                bprint("Walking mode not allowed, use sq_walking 1 to enable it.\n");
                return;
        }

	if (self.skating && self.board_falling == FALSE) // check if skating already
	{ // walk
		self.skating = FALSE;
                self.board_falling = FALSE;
                self.busting = FALSE;
                self.diff_grinds = 0;
                self.trick = 0;

		if(self.cam_on) switch_cam();

		W_SetCurrentAmmo();
		sprint(self,"now walking\n");
	}
	else
	{ // skate
		self.skating = TRUE;

		if(!self.cam_on) switch_cam();

		W_SetCurrentAmmo();
		sprint(self, "now skating\n");
	}
};

//----------------------
void() push_off_anim =
//----------------------
{
	if (!(self.trick == TRICK_GRIND) && (self.flags & FL_ONGROUND) && (self.board_falling == FALSE))
	{
		sound (self, CHAN_BODY, "player/skaterol.wav", 1, ATTN_NORM);
		self.walkframe = 20;
		self.push_time = time;
	}
};

//-----------------------
void() skate_walkframes =
//-----------------------
{
        local float new_trick;

        //  1-12 stand
        // 13-19 jump
        // 20-26 push
        // 27-32 kickflip
        // 33-36 grind
        // 37-43 olliegrap
        // 44-50 frontside 180
        // 51-61 360 flip
        // 62-97 fall
        // 98-104 damage
        // 105-108 backside boardslide
        // 109-119 backside 360 rotation

	if (self.walkframe == 12 || self.walkframe == 19)
		self.walkframe = 0;
	if (self.walkframe == 26 || self.walkframe == 32)
		self.walkframe = 0;
	if (self.walkframe == 43 || self.walkframe == 50)
		self.walkframe = 0;
	if (self.walkframe == 61 || self.walkframe == 119)
		self.walkframe = 0;


	if (self.walkframe == 31)
	{
		new_trick = TRICK_KICKFLIP;
		self.busting = FALSE;			    // finished stunt
	}
	if (self.walkframe == 41) // 41:42
	{
		new_trick = TRICK_GRAP;
		self.busting = FALSE;			    // finished stunt
	}
	if (self.walkframe == 48)		            // 48:49
	{
		new_trick = TRICK_FRONTONEEIGHTY;
		self.busting = FALSE;		    	    //finished stunt
	}
	if (self.walkframe == 60)
	{
		new_trick = TRICK_THREESIXFLIP;		    //test code
		self.busting = FALSE;			    //finished stunt
	}
	if (self.walkframe < 60 && self.walkframe >= 51 )
	{
		self.nextthink = time + 0.07;		    //play animation faster
	}

	if (self.walkframe == 118)
	{
		new_trick = TRICK_BACKROT;
		self.busting = FALSE;			    //finished stunt
	}
	if (self.walkframe < 119 && self.walkframe >= 109 ) //
		self.nextthink = time + 0.07;		    //play animation faster



	if (new_trick != 0)
	{
		if (self.trick)
			self.second_trick = new_trick;		//.trick or .second_trick ?
		else
			self.trick = new_trick;
	}

        // replay grind animation
	if (self.walkframe == 36)
		self.walkframe = 33;
	if (self.walkframe == 108)
		self.walkframe = 105;

        // play falling animation faster
	if (self.walkframe <= 97 && self.walkframe >= 62 )
		self.nextthink = time + 0.06;		    
        // falling
	if (self.walkframe == 97 || self.walkframe == 104)
	{
		self.walkframe = 0;
		self.pausetime = 0;
		self.board_falling = FALSE; // player can turn again
	}
};

//-----------------------
void() skate_fire =
//-----------------------
{
	if (self.push_fast_time < time && self.flags & FL_ONGROUND && (self.velocity_x || self.velocity_y))
	{ // player must be onground and not standing
                local float push_stamina_cost = cvar("sq_stamina_cost_push");

                if(!sq_stamina)
                        push_stamina_cost = 0;

                if (self.ammo_shells >= push_stamina_cost && self.board_falling == FALSE && self.trick != TRICK_GRIND)
                { // don't push while falling
                        self.ammo_shells = self.ammo_shells - push_stamina_cost;
                        sound(self, CHAN_BODY, "player/skaterol.wav", 1, ATTN_NORM);
                        self.push_fast_time = time + 2;
                        self.walkframe = 20;
                        self.attack_finished = time + 0.2; // don't mess up, hehe (?)
                }
	}

	if (!(self.flags & FL_ONGROUND) && !(self.busting))
	{ // TRICKS MID AIR
		sound(self, CHAN_VOICE, "player/plyrjmp8.wav", 1, ATTN_NORM);

		//check key combinations first...
		if(self.key_trick4 == TRUE)
		{
			self.walkframe = 109;               // Backside rotation
                        if (self.invincible_finished != 0)  // pentagram jump
                            self.velocity_z = 1300;
		}
		else if (self.key_trick1 == TRUE)
		{
			self.walkframe = 37;		    // Ollie grap
                        if (self.invincible_finished != 0)  // pentagram jump
                            self.velocity_z = 500;
		}

		else if(self.key_trick2 == TRUE)
		{
			self.walkframe = 44;		    // Front 180
                        if (self.invincible_finished != 0)  // pentagram jump
                            self.velocity_z = 600;
		}

		else if(self.key_trick3 == TRUE)
		{
			self.walkframe = 51;                // 360 flip
                        if (self.invincible_finished != 0)  // pentagram jump
                            self.velocity_z = 700;
		}
		else
			self.walkframe = 27; // Kickflip

                self.busting = TRUE;
	} 
};

//-------- checks if self is on a rail
float() onrail =
//-------- only one side (right or left) has to be empty
{
        local vector spot;

	makevectors(self.angles);

        //check the right side
	spot = self.origin - '0 0 36' + (v_right * 16);	//grinding ?
	traceline(self.origin, spot, TRUE, self);
	if (trace_fraction == 1.0 && pointcontents(trace_endpos) == CONTENT_EMPTY)
		return TRUE;

        //check the left side
	spot = self.origin - '0 0 36' - (v_right * 16);	 //grinding ?
	traceline(self.origin, spot, TRUE, self);
	if (trace_fraction == 1.0 && pointcontents(trace_endpos) == CONTENT_EMPTY)
		return TRUE;

	return FALSE;
};

//----------
void() skate_fall =
//----------
{
        local float rand_dmg;

        rand_dmg = 0;
        if(sq_fail_damage)
                rand_dmg = random() * 5 + 15;

	T_Damage(self, world, world, rand_dmg);
	sound(self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
	self.deathtype = "falling";


	self.pausetime = time + 4;
	if (self.jump_flag <= -500)
	{
		self.walkframe = 62;
		T_Damage(self, world, world, 0);
	}
	else
		self.walkframe = 98;

        self.board_falling = TRUE; // turn this way immediately
	self.mangle = self.angles;
	self.busting = FALSE;
	self.trick = 0; // no grinds
	self.skatespeed = 0;
	self.jump_flag = 0;
};

float() check_wrong_direction =
{
	local vector vec;
	local vector spot;
	local float dot;
	
        if(!sq_sidedrop)
                return FALSE;

	if (self.spawn_time + 1 > time) // player just respawned, exit
		return FALSE; 	

	spot = self.origin + (self.velocity * 0.15); //a spot where player will be in a short time
	makevectors(self.angles);
	vec = normalize(spot - self.origin);
	dot = vec * v_forward;
	
	if (dot > -0.3)	// -0.1 : 0.3 the higher the number, the lower the degree spectrum
		return FALSE; // player looks in right direction

        sprint(self, "You have to look in the direction you are moving!\n");
	return TRUE;
};

//-----------------------
void() skate_land =
//-----------------------
{
        local float trick_points;
        local string trick_name;
        local string random_sentence;
        local float fell;

	fell = FALSE;

	if (self.trick == TRICK_GRIND && (self.grind_stop_time + 0.2 > time))
		return; // just a little gap in the reel. No landing

	if (self.watertype == CONTENT_WATER)
		sound(self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
	else if (self.jump_flag < -650 && self.invisible_finished == 0 && sq_fail_fall) //fell down
	{
		sprint(self, self.netname);
		sprint(self, " fell down.\n");
		self.trick = 0;	// no good landing no trick points !
		fell = TRUE;
	}
	else if (check_wrong_direction() || self.busting || (self.grind_stop_time + 0.4 > time && !onrail()) && self.invisible_finished == 0 && sq_fail_trick)
	{
		self.trick = 0; // no good landing no trick points !
		fell = TRUE;
	}
	else
		sound(self, CHAN_VOICE, "player/skatelnd.wav", 1, ATTN_NORM);

	if (self.trick)
	{ // PLAYER BUSTING A TRICK !
		if (self.trick == TRICK_KICKFLIP)
		{
			trick_points = 1;
			trick_name = "Kickflip";

			if (self.second_trick)
			{
				if (self.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 2;
					trick_name = "Double Kickflip";
				}
				else if (self.second_trick == TRICK_GRAP)
				{
					trick_points = 3;
					trick_name = "Kickflip to Indy Grab";
				}
				else if (self.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 3;
					trick_name = "Kickflip to Pop Shove-it";
				}
				else if (self.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Kickflip to 360 Shove-it";
				}
				else if (self.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Kickflip to Backside 360";
				}
			}
		}
		else if (self.trick == TRICK_GRIND) //also used for boardslide
		{
			trick_points = 1;

			if (self.diff_grinds == GRIND_NORMAL)
			{
				trick_name = "Grind";
				if (self.second_trick)
				{
				if (self.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 2;
					trick_name = "Grind to Kickflip";
				}
				else if (self.second_trick == TRICK_GRAP)
				{
					trick_points = 3;
					trick_name = "Grind to Indy Grab";
				}
				else if (self.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 3;
					trick_name = "Grind to Pop Shove-it";
				}
				else if (self.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Grind to 360 Shove-it";
				}
				else if (self.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Grind to Backside 360";
				}
				}
			}
			else if (self.diff_grinds == GRIND_BOARDSLIDE)
			{
				trick_name = "Boardslide";
				if (self.second_trick)
				{
				if (self.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 2;
					trick_name = "Boardslide to Kickflip";
				}
				else if (self.second_trick == TRICK_GRAP)
				{
					trick_points = 3;
					trick_name = "Boardslide to Indy Grab";
				}
				else if (self.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 3;
					trick_name = "Boardslide to Pop Shove-it";
				}
				else if (self.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Boardslide to 360 Shove-it";
				}
				else if (self.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Boardslide to Backside 360";
				}
				}
			}
			else if (self.diff_grinds == GRIND_BACKBOARDSLIDE)
			{
				trick_name = "Backside Boardslide";
					if (self.second_trick)
				{
				if (self.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 2;
					trick_name = "Backside Boardslide to Kickflip";
				}
				else if (self.second_trick == TRICK_GRAP)
				{
					trick_points = 3;
					trick_name = "Backside Boardslide to Indy Grab";
				}
				else if (self.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 3;
					trick_name = "Backside Boardslide to Pop Shove-it";
				}
				else if (self.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Backside Boardslide to 360 Shove-it";
				}
				else if (self.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Backside Boardslide to Backside 360";
				}
				}
			}
		}
		else if (self.trick == TRICK_GRAP)
		{
			trick_points = 1;
			trick_name = "Indy Grab";

			if (self.second_trick)
			{
				if (self.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 3;
					trick_name = "Indy Grab to Kickflip";
				}
				else if (self.second_trick == TRICK_GRAP)
				{
					trick_points = 2;
					trick_name = "Double Indy Grab";
				}
				else if (self.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 3;
					trick_name = "Indy Grab to Pop Shove-it";
				}
				else if (self.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Indy Grab to 360 Shove-it";
				}
				else if (self.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Indy Grab to Backside 360";
				}
			}
		}
		else if (self.trick == TRICK_FRONTONEEIGHTY)
		{
			trick_points = 1;
			trick_name = "Pop Shove-it";

			if (self.second_trick)
			{
				if (self.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 3;
					trick_name = "Pop Shove-it to Kickflip";
				}
				else if (self.second_trick == TRICK_GRAP)
				{
					trick_points = 3;
					trick_name = "Pop Shove-it to Indy Grab";
				}
				else if (self.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 2;
					trick_name = "Double Pop Shove-it";
				}
				else if (self.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 4;
					trick_name = "Pop Shove-it to 360 Shove-it";
				}
				else if (self.second_trick == TRICK_BACKROT)
				{
					trick_points = 4;
					trick_name = "Pop Shove-it to Backside 360";
				}
			}
		}
		else if (self.trick == TRICK_THREESIXFLIP)
		{
			trick_points = 2;
			trick_name = "360 Shove-it";

			if (self.second_trick)
			{
				if (self.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 4;
					trick_name = "360 Shove-it to Kickflip";
				}
				else if (self.second_trick == TRICK_GRAP)
				{
					trick_points = 4;
					trick_name = "360 Shove-it to Indy Grab";
				}
				else if (self.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 4;
					trick_name = "360 Shove-it to Pop Shove-it";
				}
				else if (self.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 5;
					trick_name = "Double 360 Shove-it";
				}
				else if (self.second_trick == TRICK_BACKROT)
				{
					trick_points = 5;
					trick_name = "360 Shove-it to Backside 360";
				}
			}
		}
		else if (self.trick == TRICK_BACKROT)
		{
			trick_points = 2;
			trick_name = "Backside 360";

			if (self.second_trick)
			{
				if (self.second_trick == TRICK_KICKFLIP)
				{
					trick_points = 4;
					trick_name = "Backside 360 to Kickflip";
				}
				else if (self.second_trick == TRICK_GRAP)
				{
					trick_points = 4;
					trick_name = "Backside 360 to Indy Grab";
				}
				else if (self.second_trick == TRICK_FRONTONEEIGHTY)
				{
					trick_points = 4;
					trick_name = "Backside 360 to Pop Shove-it";
				}
				else if (self.second_trick == TRICK_THREESIXFLIP)
				{
					trick_points = 5;
					trick_name = "Backside 360 to 360 Shove-it";
				}
				else if (self.second_trick == TRICK_BACKROT)
				{
					trick_points = 5;
					trick_name = "Double Backside 360";
				}
			}
		}

		self.frags = self.frags + trick_points;

                // reset points
		self.trick = 0;
		self.second_trick = 0;
	}

	self.walkframe = 0;
	self.busting = FALSE;
	self.skatespeed = 0;

	//landed on a rail, don't stand and grind:
	if (onrail() && (self.velocity_x || self.velocity_y) && fell == FALSE)
	{
		if (self.key_trick1 == TRUE)
		{
			self.diff_grinds = GRIND_NORMAL;
		}
		else if (self.key_trick2 == TRUE)
		{
			self.diff_grinds = GRIND_BACKBOARDSLIDE;
			self.walkframe = 105;				//start backside boardsliding frames
		}
		else if (self.key_trick3 == TRUE)
		{
			self.diff_grinds = GRIND_BOARDSLIDE;
			self.walkframe = 33;				//start boardsliding frames
		}
		else if (self.key_trick4 == TRUE)
		{
			self.diff_grinds = GRIND_BOARDSLIDE;
			self.walkframe = 33;				//start boardsliding frames
		}
		else
		{
			self.diff_grinds = 0;
		}

		if (self.diff_grinds != 0)	//if no trick key is pressed nothing should happen
		{
			self.trick = TRICK_GRIND;
			self.grind_start_time = time;
		}
	}


	if (trick_points != 0) // If the player busted a trick, print it !
	{
		//init the random sentence
		if (random() < 0.5)
			random_sentence = "You busted a ";
		else
			random_sentence = "You did a ";

		sprint(self, random_sentence);
		sprint(self, trick_name);			//print the trick
		if (self.trick)			//trick is set again because of grind
		{
			if (self.diff_grinds == GRIND_NORMAL)
			{
				sprint(self, " to Grind");		//also print...
			}
			else if(self.diff_grinds == GRIND_BOARDSLIDE)
			{
				sprint(self, " to Boardslide");	//...grind or boardslide
			}
			else if(self.diff_grinds == GRIND_BACKBOARDSLIDE)
			{
				sprint(self, " to Backside Boardslide");	//......
			}
		}
		sprint(self, "!\n");

		if (trick_points > 1)
		{
			if (random() < 0.5)
				sound (self, CHAN_ITEM, "player/yeah1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_ITEM, "player/yeah2.wav", 1, ATTN_NORM);
		}
	}

	if (fell == TRUE && self.invisible_finished == 0)
		skate_fall();

	self.jump_flag = 0;
};

//-----
float() check_stairs =
//-----
{
        // shallow waters are being seen as steps, which is why you get stuck in them on maps like e1m3
        // water stuff is defined in minus values, check defs.qc
        local vector spot;
        local vector fake_angles;

	fake_angles = self.angles;
	fake_angles_x = -10;

        if(cvar("sq_skip_stair") && self.watertype)
            return FALSE;

        if(cvar("sq_skip_water") && self.watertype < -2)
            return FALSE;


	makevectors(fake_angles);

	//check infront right of the feet
	spot = self.origin - '0 0 16' + (v_forward * 26) + (v_right * 16);
	traceline(self.origin, spot, TRUE, self);
	if (trace_fraction != 1.0 || pointcontents(trace_endpos) != CONTENT_EMPTY)
        {
                // ignores doors
                if (trace_ent && trace_ent.classname == "door")
                    return FALSE;
                return TRUE; //stairs infront of player !
        }

	//check infront left of the feet
	spot = self.origin - '0 0 16' + (v_forward * 26) - (v_right * 16);
	traceline(self.origin, spot, TRUE, self);
	if (trace_fraction != 1.0 || pointcontents(trace_endpos) != CONTENT_EMPTY)
        {
                // ignores doors
                if (trace_ent && trace_ent.classname == "door") return FALSE;

                return TRUE; //stairs infront of player !
        }


	return FALSE; // flat ground
};

//---------------------
void() adjust_x_angle =
//---------------------
{
        local vector spot;
        local float front_space;
        local float back_space;
        local float new_x;

	makevectors(self.angles);

	//check infront of the feet
	spot = self.origin - '0 0 36' + (v_forward * 16);
	traceline(self.origin, spot, TRUE, self);
	front_space = trace_fraction;

	//check behind the feet
	spot = self.origin - '0 0 36' - (v_forward * 16);
	traceline(self.origin, spot, TRUE, self);
	back_space = trace_fraction;

	new_x = back_space - front_space;
	new_x = new_x * 80;
	self.angles_x = new_x;
};

//-------------------------
void() skate_drive =
//-------------------------
{
        local vector new_vel;

	if (self.flags & FL_ONGROUND)
	{ // don't drive in air
		self.jump_vel = '0 0 0'; // reset initial jumping velocity

		makevectors(self.angles);

		new_vel_x = self.velocity_x; // use new_vel to seperate x and y from z
 		new_vel_y = self.velocity_y;

		if (vlen(new_vel) > self.skatespeed) 
			self.skatespeed = vlen(new_vel);        // calc new speed

		if (self.skatespeed > 10)                       // slow down
			self.skatespeed = self.skatespeed - 10; //
		else                                            // stop
			self.skatespeed = 0;                    //

		new_vel = self.skatespeed * v_forward;	        // only forward
		//new_vel = vlen(new_vel) * v_forward;	        // only forward

		if (self.push_fast_time - 0.5 > time)		// if player pressed fire key. pause for 1 seconds
			new_vel = 460 * v_forward;		// push player

                // GRINDING
		if (onrail() && (self.trick == TRICK_GRIND))
                {
                        // check if player is slower than expected
                        if (vlen(self.velocity) <= 320)
                        {
                            new_vel = 320 * v_forward;          // grind to the right (with frames)
                            self.velocity_z = -120;		// If skating forward or up hill, activate feather falling
                        }
                        if (vlen(self.velocity) > 320)
                        {
                            vlen(new_vel) = vlen(self.velocity);// grind to the right (with frames)
                            self.velocity_z = -280;		// If skating downhill, activate fox shoes
                        }
                        // end check

			self.grind_stop_time = time;		// update stop time. when in air, it won't be set

			if (self.super_sound < time)		// play grinding sound
			{					// use super_sound for right timing
				self.super_sound = time + 1.2;
				sound(self, CHAN_BODY, "player/skategnd.wav", 1, ATTN_NORM);
			}
		}

                // GRIND SKIP
		if (!onrail() && (self.trick == TRICK_GRIND) && self.invisible_finished == 0)
		{
			sprint(self,"You skipped a grind!\n");
			self.jump_flag = -1000;
			skate_fall();
			return;
			//self.trick = 0;
			//self.walkframe = 0;
		}


		if (check_stairs()) // don't drive up stairs
			new_vel = '0 0 0';

		self.velocity_x = new_vel_x; // don't change up or down movement
		self.velocity_y = new_vel_y; //
	}
	else if (self.trick == TRICK_GRIND)
	{ // reset animation when falling down after grind
		if (self.grind_stop_time + 0.4 < time) // player has to been in air for x(0.4) seconds, if not he falls
		{
			if ((self.walkframe >= 33 && self.walkframe <= 36) || (self.walkframe >= 105 && self.walkframe <= 108))
				self.walkframe = 0;
		//	self.busting = FALSE;
		}
		//else
		//{
		//	self.busting = TRUE;
		//}
	}
	else if (!cvar("sq_airstrafe") && vlen(self.jump_vel) != 0 && self.super_time == 0)
	{ // realistic jumping movement (player can't change direction)
		self.velocity_x = self.jump_vel_x;  //don't change up or down movement
		self.velocity_y = self.jump_vel_y;  //
	}

	water_die();
	adjust_x_angle();
};

//-----------------
void() Regenerate_Health =
//-----------------
{
        local float old_health;
	if (self.health_regen_time < time)
	{
		old_health = self.health;
		self.health = self.health + 1;

		if (self.health > 250)
			self.health = 250;

		if (old_health <= 100 && self.health > 100)
			self.health = 100;

		self.health_regen_time = time + 1;
	}
};

//----------------- using ammo_shells as stamina
void() Regenerate_Stamina =
//-----------------
{
	if (self.stamina_regen_time < time)
	{
                if (cvar("sq_stamina_recovery")) 
                        self.ammo_shells = self.ammo_shells + cvar("sq_stamina_recovery");

		if (self.ammo_shells > 100)
			self.ammo_shells = 100;

		self.currentammo = self.ammo_shells;
		self.items = self.items | IT_SHELLS;

		self.stamina_regen_time = time + 0.1;
	}
};

//------------------- works only in deep waters
void() water_die =
//-------------------
{
        local float m;
        local float sq_dmg;
	makevectors(self.angles);
	m = pointcontents(self.origin + v_forward*16);

	if (cvar("sq_waterkill") && (m == CONTENT_WATER || m == CONTENT_SLIME || m == CONTENT_LAVA))
	{
		sq_dmg = self.health + 10;
		self.watertype = 0;		//not those drown messages
		self.trick = 0;			//no good landing no trick points !
		if (m == CONTENT_WATER)
			self.deathtype = "water";
		else if(m == CONTENT_LAVA)
			self.deathtype = "lava";
		else if(m == CONTENT_SLIME)
			self.deathtype = "slime";

		T_Damage(self, world, world, sq_dmg); //always die in water
	}
};
