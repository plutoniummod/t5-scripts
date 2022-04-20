#include maps\_utility;
#include common_scripts\utility;
#include maps\wmd_util;
#include maps\_anim;
#include maps\_music;


/*------------------------------------
player can control his descent onto a surface but must use the brake or he will fail
------------------------------------*/

#using_animtree("wmd");
player_controllable_rappel(node_targetname)
{
	self._rappel = SpawnStruct();
	self._rappel.fail_speed = 500.0;
	self._rappel.rumble_speed = 200.0;
	self._rappel.current_speed = 0;
	self._rappel.fov_max = 100;

	node = GetEnt(node_targetname, "targetname");
	
	self HideViewModel();
	self disableweapons();

	self do_player_hookup(node);
	self do_player_rappel(node);
}

do_player_hookup(node)
{
	self.body = spawn_anim_model( "player_body", node.origin);
	self.body Hide();

	self.body SetClientFlag(6);// for scrolling rope texture

	/#
		RecordEnt(self.body);
	#/

	node thread anim_single_aligned(self.body, "rappel_hookup");
	
	wait .05;

	self StartCameraTween(.2);
	self PlayerLinktoAbsolute(self.body, "tag_player");

	wait .3;
	
	self.body Show();

	wait 3.5;

	self SetClientDvar("r_enablePlayerShadow", 0);
	self SetDepthOfField(5, 33, 0, 0, 4, 0);

	vec = AnglesToForward(node.angles);
	rope_start_pos = self.body GetTagOrigin("J_Pinky_RI_1") + (0, 0, 50) + vec * -700;
	rope_end_pos = GetEnt( "trigger_on_roof", "targetname" );
	
	self.rope = CreateRope(rope_start_pos, ( 0, 0, 0 ), 800, self.body, "J_Pinky_RI_1");
	
	self thread check_player_height();
		
	RopeSetFlag( self.rope, "collide", 1 );
	RopeSetFlag( self.rope, "no_wind", 1 );
	RopeSetFlag( self.rope, "no_lod", 1 );
	
	wait 2;
	
	RopeRemoveAnchor(self.rope, 0);

	node waittill("rappel_hookup");
}


check_player_height()
{
	/*while(1)
	{
		player_height = self.origin[2];
		
		iprintlnbold("height: "+player_height);
		
		wait(0.25);
	}*/
	
	while(1)
	{
		if (self.origin[2] < 41850)
		{
			RopeSetFlag( self.rope, "collide", 0 );
			break;
		}
		
		wait(0.05);
	}
}


do_player_rappel(node)
{
	//these are set up in the anim file
	self._rappel.anim_rappel_loop			= level.scr_anim["player_body"]["player_rappel_loop"][0];
	self._rappel.anim_rappel_compress		= level.scr_anim["player_body"]["player_rappel_compress"];
	self._rappel.anim_rappel_compress_loop	= level.scr_anim["player_body"]["player_rappel_compress_loop"][0];
	self._rappel.anim_rappel_idle			= level.scr_anim["player_body"]["player_rappel_idle"][0];
	self._rappel.anim_rappel_brake			= level.scr_anim["player_body"]["player_rappel_brake"];
	self._rappel.anim_rappel_brake_loop		= level.scr_anim["player_body"]["player_rappel_brake_loop"][0];
	self._rappel.anim_rappel_brake_succeed	= level.scr_anim["player_body"]["player_rappel_brake_succeed"];
	self._rappel.anim_rappel_kickoff		= level.scr_anim["player_body"]["player_rappel_kickoff"];
	self._rappel.anim_rappel_2_fall			= level.scr_anim["player_body"]["player_rappel_2_fall"];
	self._rappel.anim_rappel_fall_loop		= level.scr_anim["player_body"]["player_rappel_fall_loop"][0];

	//set the idle anim
	self.body thread anim_loop(self.body, "player_rappel_idle", "stoploop", undefined);
	self PlayLoopSound("evt_rappel_idle");
	
	clientNotify("gtg");

	set_near_plane(1);

	self.body.bRappelling = false;
	bCharging = false;
	self.body.bBraking = false;
	bShowBrakePrompt = true;
	self.can_rappel_brake = true;
	self.body.hit_wall = false;
	self.body.hit_ground = false;
	self.body.last_origin = self.origin;
	self.body.velocity = (0, 0, 0);
	self.body.acceleration = (0, 0, -385.0);
	self.body.wall_normal = (0, 0, 0);
	dir = AnglesToForward(node.angles);
	self.body.wall_normal = dir * -1.0;

	min_impulse_v = 160.0;
	max_impulse_v = 200.0;
	
	ground_tolerance = 55.0;
	fail_ground_tolerance = 40.0;
	
	rappel_charge = 0.0;
	xy_vel_damp = 0.995;
	dt = 0.05;

	flight_time = 0.0;
	
	current_rope_sound = "evt_rappel_idle";
	
	while (1)
	{
		if (!self.body.hit_wall)
		{
			cliff_dist = get_dist_to_cliff_face(self.body.origin, node.angles);
			//IPrintLnBold("Cliff Dist: " + cliff_dist);

    		// Player is idle
			if (!self.body.bRappelling && !self.body.bBraking)
			{
				if (is_true(level.rappel_break_success))
				{
					screen_message_create(&"WMD_RAPPEL_LT");
				}
				else
				{
					screen_message_create(&"WMD_RAPPEL_LT", &"WMD_RAPPEL_RT");
				}
				
				if (current_rope_sound != "evt_rappel_idle")
				{
					self PlayLoopSound("evt_rappel_idle");
					current_rope_sound = "evt_rappel_idle";
				}

				// On button press
				if (self ThrowButtonPressed())
				{
					// First press of the button start charging
					if (!bCharging)
					{
						bCharging = true;

						self PlaySound ("evt_rappel_compress");

						// Not sure why but this fixes my initial "sticking" problem. 
						self.body StopAnimScripted();
						self.body SetAnim(self._rappel.anim_rappel_idle, 1);
					}
					else
					{
						// Charge at specified rate
						rappel_charge = rappel_charge + (1.0 * dt);

						// Clamp to 1.0
						bFullCharge = false;
						if (rappel_charge > 1.0)
						{
							rappel_charge = 1.0;
							bFullCharge = true;
						}

						//IPrintLnBold("Charge: " + rappel_charge);

						if (!bFullCharge)
						{
							// Do the blend
							self.body SetAnim(self._rappel.anim_rappel_idle, 1.0 - rappel_charge);
							self.body SetAnim(self._rappel.anim_rappel_compress, rappel_charge);
						}
						else
						{
							self.body SetAnimKnobAll(self._rappel.anim_rappel_compress_loop, %root, 1, 1, 1);
						}
					}
				}
				else
				{
					// if we let go of the button, start the rappel with the scaled start velocity
					if (bCharging)
					{
						// start the rappel
						xy_vel_damp = 0.995;
						self.body.bRappelling = true;


						self PlaySound ("evt_rappel_push");

						self playloopsound ("evt_rappel_slide");
						current_rope_sound = "evt_rappel_slide";

						// Calculate the start velocity
						v = min_impulse_v + (max_impulse_v - min_impulse_v) * rappel_charge;

						self rappel_start(v, node.angles);

						self PlayRumbleOnEntity("rappel_falling");

						self.body ClearAnim(%root, 1);
						self thread rappel_kickoff_to_loop_anim();

						// Clean up variables
						bCharging = false;
						rappel_charge = 0.0;

						// Play effect when kicking off
						fx_pos = self.body GetTagOrigin("J_Ankle_RI");
						PlayFx(level._effect["snow_fall_off_rock_hvy"], fx_pos);

						if (is_true(level.rappel_break_success))
						{
							screen_message_delete();
						}

						bShowBrakePrompt = true;
						flight_time = 0.0;	// reset the flight time
					}
				}
			}
			else if (self.body.bBraking)
			{
				// check for on ground
				if (self.body is_on_ground(ground_tolerance))
				{
					self.body.hit_ground = true;
					self end_rappel();
					RopeRemoveAnchor(self.rope, 1);
					DeleteRope(self.rope);
					post_rappel_rope();
					self PlayRumbleOnEntity("damage_heavy");
					break;
				}

				// Player let go of the brake
				if (!self AttackButtonPressed())
				{
					self.body.bBraking = false;
					self.body.bRappelling = true;
					self.body.acceleration = (0, 0, -385.0);
					xy_vel_damp = 0.5;
					
					// Start the player into the death/fall sequence
					//if (self.can_rappel_brake && !self AttackButtonPressed())
					//{
					//	self PlaySound("evt_rappel_fail");
					//	iprintlnbold ("FAILED!");
					//	playsoundatposition ("evt_rappel_wind_fall", (0,0,0));
					//	self StopLoopSound(0.5);
					//	self thread update_fall_anims();
					//	self.can_rappel_brake = false;
					// }
					
					continue;
				}

				if (cliff_dist > 50.0)
				{
					wall_pos = self.body get_cliff_face_pos(node.angles);

					// If we're still far enough away integrate velocity
					self.body.velocity = self.body.velocity + vector_multiply(self.body.acceleration, dt);
					if (self.body.velocity[2] > 0.0)
					{
						self.body.velocity = (self.body.velocity[0], self.body.velocity[1], 0);
					}

					// Predict the next position to see if we would go through the wall or be close enough
					// to stop...not an ideal solution but seems to fix most of the ugly
					new_pos = self.body.origin + vector_multiply(self.body.velocity, dt);
					new_cliff_dist = get_dist_to_cliff_face(new_pos, node.angles);
					//IPrintLn("New Cliff Dist: " + new_cliff_dist);

					if (new_cliff_dist == 1000/* || new_cliff_dist < 50.0*/)
					{
						// Hit the wall end braking
						self thread hit_wall();
					}
					else
					{
						// move the body
						self.body.origin = new_pos;
					}
				}
				else
				{
					// Hit the wall end braking
					self thread hit_wall();
				}
			}
			else // not braking
			{
				// If we able to land properly use normal tolerance...if we're
				// in our fail state use a smaller tolerance
				tolerance = ground_tolerance;
				if (!self.can_rappel_brake)
				{
					tolerance = fail_ground_tolerance;
					
					// Push out from wall if too close so we don't clip through
					if (cliff_dist < 15)
					{
						//IPrintLnBold("push out");
						acc = 3000;
						self.body.acceleration = (self.body.wall_normal[0] * acc, self.body.wall_normal[1] * acc, self.body.acceleration[2]);
					}					
				}

				self.body.velocity = (self.body.velocity[0] * xy_vel_damp, self.body.velocity[1] * xy_vel_damp, self.body.velocity[2]);
				self.body.velocity = self.body.velocity + vector_multiply(self.body.acceleration, dt);
				
				// check for on ground
				if (self.body is_on_ground( Abs(self.body.velocity[2]) * 4 * dt )) 
				{
					self.body.hit_ground = true;
					self end_rappel();
					RopeRemoveAnchor(self.rope, 1);
					DeleteRope(self.rope);
					post_rappel_rope();
					break;
				}

				// integrate velocity
				new_pos = self.body.origin + vector_multiply(self.body.velocity, dt);

				// move the body
				self.body.origin = new_pos;

				if (self._rappel.current_speed > self._rappel.rumble_speed)
				{
					self do_brake_warning_rumble(Abs(self.body.velocity[2]));

					if (self._rappel.current_speed > self._rappel.fail_speed)
					{
						self.body.velocity = (0, 0, self.body.velocity[2]);
						self.body.acceleration = (0, 0, 0);

						if (self.can_rappel_brake)
						{
							self PlaySound("evt_rappel_fail");
							playsoundatposition ("evt_rappel_wind_fall", (0,0,0));
							self StopLoopSound(0.5);
							self thread update_fall_anims();
							self.can_rappel_brake = false;
						}
					}
				}

				flight_time += dt;
				if (flight_time > 0.5)
				{
					if (bShowBrakePrompt && is_true(level.rappel_break_success))
					{
						// Show the brake prompt
						screen_message_create(&"WMD_RAPPEL_RT");
						bShowBrakePrompt = false;
					}

					// Brake Press
					if (self AttackButtonPressed() && self.can_rappel_brake)
					{
						self notify("brake");

						self StopLoopSound(1);
						self PlaySound ("evt_rappel_slow");
						current_rope_sound = "evt_rappel_slow";					

						screen_message_delete();

						self.body.bRappelling = false;
						self.body.bBraking = true;

						dir = self.body.wall_normal * -1.0;
						acc = 750;
						self.body.acceleration = (dir[0] * acc, dir[1] * acc, 500.0);

						self thread rappel_brake_to_loop_anim();
					}
				}
			}
		}

		//IPrintLn("Velocity X: " + self.body.velocity[0] + " Y: " + self.body.velocity[1] + " Z: " + self.body.velocity[2]);

		self._rappel.current_speed = Abs(self.body.velocity[2]);

		set_fov();
		set_bloom();

		wait(dt);
	}
}


hit_wall()
{
	self.body.hit_wall = true;
	self.body.bBraking = false;
	self.body.bRappelling = false;
	//self.body.velocity = (0, 0, 0);

	level notify("rappel_break_success");
	level.rappel_break_success = true;

	self.body ClearAnim(%root, 0.2);
	self do_brake_rumble();

	self PlaySound("evt_rappel_hit_wall");
	
	self PlayRumbleOnEntity("damage_heavy");

	// Play effect when reaching wall
	fx_pos = self.body GetTagOrigin("J_Ankle_RI");
	PlayFx(level._effect["snow_fall_off_rock_hvy"], fx_pos);
	
	self.body thread anim_single(self.body, "player_rappel_brake_succeed");
	
	wait(0.6);	// wait until rappel button can be pressed again
	
	self.body.hit_wall = false;	// reset
	
	wait(1.3);
	
	self.body SetAnim(self._rappel.anim_rappel_idle, 1.0);

	//self.body.hit_wall = false;	// reset
}

rappel_start(velocity, angles)
{
	// set the initial velocity
	self.body.acceleration = (0, 0, -385.0);
	self.body.velocity = vector_multiply(self.body.wall_normal, velocity);
}

rappel_kickoff_to_loop_anim()
{
	self.body SetAnim(self._rappel.anim_rappel_kickoff, 1);

	anim_time = GetAnimLength(self._rappel.anim_rappel_kickoff);
	t = 0.0;
	while (!self.body.hit_wall && !self.body.hit_ground && !self.body.bBraking)
	{
		if (t < anim_time)
		{
			t += 0.05;
		}
		else
		{
			self.body SetAnimKnobAll(self._rappel.anim_rappel_loop, %root, 1, .05, 1);
			break;
		}

		wait(0.05);
	}
}

rappel_brake_to_loop_anim()
{
	self.body SetAnimKnobAll(self._rappel.anim_rappel_brake, %root, 1, 0, 1);

	anim_time = GetAnimLength(self._rappel.anim_rappel_brake);
	t = 0.0;
	while (!self.body.hit_wall && !self.body.hit_ground && !self.body.bRappelling && self.can_rappel_brake)
	{
		if (t < anim_time)
		{
			t += 0.05;
		}
		else
		{
			self.body SetAnimKnobAll(self._rappel.anim_rappel_brake_loop, %root, 1, 0, 1);

			break;
		}

		wait(0.05);
	}
}

update_fall_anims()
{
	self.body SetAnimKnobAll(self._rappel.anim_rappel_2_fall, %root, 1, .2, 1);

	anim_time = GetAnimLength(self._rappel.anim_rappel_2_fall);
	t = 0.0;
	while (!self.body.hit_ground)
	{
		if (t < anim_time)
		{
			t += 0.05;
		}
		else
		{
			
			self.body SetAnimKnobAll(self._rappel.anim_rappel_fall_loop, %root, 1, .2, 1);
			break;
		}

		wait(0.05);
	}
}

do_brake_rumble()
{
	StopAllRumbles();
	Earthquake( 0.35, 0.2, self.origin, 500 );
	self PlayRumbleOnEntity("grenade_rumble");	
}

do_brake_warning_rumble(speed)
{
	norm_speed = linear_map(speed, self._rappel.rumble_speed, self._rappel.fail_speed, 0, 1) + 0.01;
	Earthquake( 0.5 * norm_speed, 1.0, self.origin, 500 );
}

is_on_ground(tolerance)
{
	trace_start = self.origin + vector_multiply(self.wall_normal, 70);
	trace_end = trace_start + (0, 0, tolerance * -1);
	trace = BulletTrace(trace_start, trace_end, 0, undefined);
	
	check = tolerance * tolerance;
	
	if(trace["fraction"] < 1)
	{
		self.origin = (self.origin[0], self.origin[1], trace["position"][2] + 10 );
		return true;
	}

	return false;
}

end_rappel()
{
	set_fov(0);
	set_bloom(0);

	reset_near_plane();

	self SetDepthOfField(0, 0, 0, 0, 4, 0);

	PlayFx(level._effect["snow_puff_land"], self.origin);

	screen_message_delete();

	StopAllRumbles();
	self.body ClearClientFlag(6);// for scrolling rope texture
	self PlayRumbleOnEntity("grenade_rumble");	
	self StopLoopSound(0.5);

	if (self.can_rappel_brake)
	{
		self.body ClearAnim(%root, .2);
		
		self PlaySound("evt_rappel_land");
		
		Earthquake( 0.35, 0.2, self.origin, 500 );
		self.body anim_single(self.body, "player_rappel_land");
		
		flag_set("player_on_roof");
		
		self Unlink();
		self.body Hide();	// keep this around for the breach

		self ShowViewModel();
		self EnableWeapons();
		
		self trace_adjust();  //make sure player isn't stuck in snow
	}
	else
	{
		self.body ClearAnim( %root, 0.0 );
		self PlaySound("evt_rappel_splat");		
		level thread play_player_death_sound();
		Earthquake( 1.0, 0.5, self.origin, 500 );
		self.body anim_single(self.body, "player_rappel_fall_hit_a");
		MissionFailed();
	}

	// make sure everything gets reset
}


trace_adjust()
{
	trace_start = self.origin + (0,0,100);
	trace_end = self.origin + (0,0,-100);
	player_trace = BulletTrace(trace_start, trace_end, false, undefined);

	link = Spawn("script_origin", self.origin);
	self PlayerLinkTo(link);

	link moveto(player_trace["position"],0.05);

	link waittill("movedone");

	link Delete();
}


play_player_death_sound()
{
	wait (0.35);
	playsoundatposition ("evt_player_death", (0,0,0));	
		
}
get_dist_to_cliff_face(start_pos, angles)
{
	dir_cliff = AnglesToForward(angles);

	start_pos += dir_cliff * -100;

	trace = BulletTrace( start_pos, start_pos + vector_multiply(dir_cliff,1000) ,0,undefined);
	org = trace["position"];
	dist = Distance(start_pos, org);
	return dist - 100;
}

get_cliff_face_pos(angles)
{
	dir_cliff = AnglesToForward(angles);

	trace_start = self.origin + vector_multiply(dir_cliff, -1000);
	trace_end = self.origin + vector_multiply(dir_cliff, 1000);
	//Line(trace_start, trace_end, (1, 0, 0), false, 1000);
	trace = BulletTrace(trace_start, trace_end, 0, undefined);
	pos = trace["position"];

	return pos;
}

set_fov(speed)
{
	if (!IsDefined(speed))
	{
		speed = self._rappel.current_speed;
	}

	fov = linear_map(speed, 0, self._rappel.fail_speed, GetDvarFloat( #"cg_fov_default"), self._rappel.fov_max);
	self SetClientDvar( "cg_fov", fov );

// 	PrintLn("fov: " + fov);
}

set_bloom(speed)
{
	if (!IsDefined(speed))
	{
		speed = self._rappel.current_speed;
	}

	use_glow = (speed > 0.1);

	bloom = linear_map(speed, 0, self._rappel.fail_speed, 0, 5);

	self SetClientDvars(	"r_glowUseTweaks", use_glow
							,"r_glowTweakEnable", use_glow
							,"r_glowTweakBloomIntensity0", bloom
						);

// 	PrintLn("bloom: " + bloom);
}


post_rappel_rope()
{
	rope_start_pos = getstruct("rope_start_pos", "targetname");
	rope_seg1 = getstruct("rope_seg1", "targetname");
	rope_seg2 = getstruct("rope_seg2", "targetname");
	rope_seg3 = getstruct("rope_seg3", "targetname");
	rope_seg4 = getstruct("rope_seg4", "targetname");
	rope_seg5 = getstruct("rope_seg5", "targetname");
	rope_seg6 = getstruct("rope_seg6", "targetname");
	
	rope1 = CreateRope(rope_start_pos.origin, rope_seg1.origin, 220);
	rope2 = CreateRope(rope_seg1.origin, rope_seg2.origin, 190);
	rope3 = CreateRope(rope_seg2.origin, rope_seg3.origin + (0, -10, 0), 145);
	rope4 = CreateRope(rope_seg3.origin + (0, -10, 0), rope_seg4.origin + (0, -20, 0), 275);
	rope5 = CreateRope(rope_seg4.origin + (0, -20, 0), rope_seg5.origin + (0, -20, 200), 30);
	rope6 = CreateRope(rope_seg5.origin + (0, -20, 200), rope_seg6.origin + (0, 0, 0), 420);
	
	RopeSetFlag(rope5, "collide", 1);
	RopeSetFlag(rope6, "collide", 1);
	
	//RopeRemoveAnchor(rope6, 1);
	
	flag_wait("window_breached");
	
	DeleteRope(rope1);
	DeleteRope(rope2);
	DeleteRope(rope3);
	DeleteRope(rope4);
	DeleteRope(rope5);
	DeleteRope(rope6);
}