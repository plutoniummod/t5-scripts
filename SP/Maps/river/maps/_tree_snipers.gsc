/* _tree_snipers.gsc

TO USE:

- Drop in _prefabs/scripter/tree_with_platform.map
- Put in trigger with TRIGGER_SPAWN set, targetname "tree_snipers"
- Put in spawner, give him "script_noteworthy" if you want him to climb the tree
- Point at node on top of platform aligned with front, cover_conceal_crouch, point forward
- Node targets script_struct, pointed 180 degrees from cover node.
- Check out js_treeguys for how to do it!


//-CP
 can now give a "script_int" value between 0 and 100 on the spawner to give him a percentage chance of 
 doing his swinging death. 

*/
#include maps\_utility;
#include maps\_anim;
#include common_scripts\utility;

#using_animtree ("generic_human");
main()
{	
	//necessaey model precaches
	precachemodel("t5_foliage_tree_palm_hideout_single");  // old = dest_test_palm_spawnfrond1
	//precachemodel("dest_test_palm_spawnfrond2");  
	precachemodel("anim_foliage_pacific_palmtree_hideout_rope");
	
	// Anims
	level.scr_anim["tree_guy"]["climb_into"]					= %ch_climb_tree_a;
	level.scr_anim["tree_guy"]["hang_death"]					= %ch_fall_tree_a;
	level.scr_anim["tree_guy"]["hang_idle"][0]				= %ch_fall_tree_idle_a;
	addNotetrack_customFunction( "tree_guy", "footstep_left_small", 	::play_footfx_up_tree_left, "climb_into" );
	addNotetrack_customFunction( "tree_guy", "footstep_right_small",	::play_footfx_up_tree_right, "climb_into" );
	

	
	// sets up the rope model animations
//	rope_model_anim_setup();		//commented this out because we are now using rope tech, not an animated rope. ( SHABS 2/20/09 )
		
	// FX
	level._effect["foot_step_up_tree"]				= loadfx("bio/player/fx_dust_tsniper_foot_kickup");	
	level._effect["fall_out_fx"]							= loadfx("bio/player/fx_dust_tsniper_fall");	

	sniper_trigs = getentarray ("tree_snipers","targetname");
		
	array_thread (sniper_trigs, ::init_tree_snipers);
}

init_tree_snipers()
{
	spawners = getentarray(self.target, "targetname");
	if(isDefined(spawners) && spawners.size)
	{
		for(i=0;i<spawners.size;i++)
		{
			if(issubstr(spawners[i].classname, "actor"))
			{
				spawners[i] thread tree_sniper();
			}
		}
	}
	
	
//	self waittill ("trigger");
	
}
tree_sniper()
{
	self waittill( "spawned", spawn );
	
	//modify so that it can use any nearby node
	nodes = getnodearray(self.target,"targetname");
	anim_node = random(nodes);
	anim_point = getent(anim_node.target,"targetname");
	
	// must do this or else we get nasty asserts
	if (maps\_utility::spawn_failed(spawn))
	{
			return;
	}
	
	spawn endon ("death");
	
	spawn.animname = "tree_guy";
	
	if (spawn.script_noteworthy == "climb")
	{
		spawn do_climb(anim_point);
	}

	if (isdefined(spawn))
	{
		spawn allowedstances ("crouch");
	}
	spawn thread tree_death(spawn, anim_point);
}

do_climb(anim_point)
{
	self endon ("death");
	
	self animscripts\traverse\shared::TraverseStartRagdollDeath();

	self.allowdeath = true;
	self.ignoreall = true;
	self.goalradius = 32;
	anim_point anim_reach(self, "climb_into");
	anim_point anim_single_aligned(self, "climb_into");
	self.ignoreall = false;

	self animscripts\traverse\shared::TraverseStopRagdollDeath();
}

tree_death(guy, anim_point, no_fronds)
{
	guy linkto (anim_point);
	
	guy thread watch_for_fake_death();
		//self.allowdeath = false;
	guy waittill ("fake tree death", attacker);
	
	//do his swinging death
	swingdeath = true;
	
	// if he's to be killed in script for a canned instance and needs to always swing
	canned_death = false;

	if( isdefined( guy.script_noteworthy ) && ( guy.script_noteworthy == "no_climb_canned" ) )
	{
		canned_death = true;
	}

	rand_death = randomint(3);
	
	//SCRIPTER_MOD: chrisP - added script_int check on guy to determine if he should do his swinging_death
	if(!isDefined(guy.script_int))
	{
		// do swing death
		if (rand_death == 0 || canned_death )
		{
			swingdeath = true;

		}
		else if (rand_death == 1)
		{
			swingdeath = true;
		}
	}
	else
	{
		rand_death = randomint(100);
		if (guy.script_int >= rand_death)
		{
			swingdeath = true;
		}		
	}
	
	if(swingdeath)
	{
		guy animscripts\shared::DropAIWeapon();				
		//guy = convert_guy_to_drone(guy);	
		guy thread fall_and_hang(anim_point);
	//	guy thread helmet_eject();	
		//guy thread rope_spawn_and_animate(anim_point);
		
		start = anim_point.origin;
		end = ( 0, 0, 0 );		

		if (randomint(10) < 5 )
			createrope( start, end, 70, guy, "j_ankle_le", 1 );
		else
			createrope( start, end, 70, guy, "j_ankle_ri", 1 );

		wait 1.0;
		
		guy startragdoll();
		guy.a.nodeath = true;
		if( !IsDefined(attacker) )
		{
			attacker = get_closest_player( guy.origin );
		}
		guy dodamage( guy.health + 1, (0,0,0), attacker );
	}
	else
	{
		guy.health = 1;
		guy waittill ("death");
		self unlink();
	}
	
	
	//self animscripted("tree_fall_done", anim_point.origin, anim_point.angles, %ch_fall_tree_a);
//	wait 3;
//	self dodamage (self.health + 1, (0,0,0));

	//self waittill ("death");
	
	wait randomfloatrange (0.1, 0.5);
	
	// play the leafy fx
	playfx(level._effect["fall_out_fx"], anim_point.origin - (0,0,75));
	
	if( IsDefined( no_fronds ) && ( no_fronds == true ) )  // effect is being played elsewhere - don't create fronds
	{
		return;
	}
	
	frondnum = randomintrange(1,3);
	
	fronds = [];
	for (i = 0; i < frondnum; i++)
	{
		fronds[i] = spawn ("script_model", anim_point.origin + (randomintrange(-40, 40), randomintrange(-40, 40), randomintrange(-20, 20)));
		
//		frondmodel = randomint(2);
//		
//		if (frondmodel)
//		{
//			fronds[i] setmodel("t5_foliage_tree_palm_hideout_single");		
//		}
//		else
//		{
//			fronds[i] setmodel("t5_foliage_tree_palm_hideout_single");		
//		}

		fronds[i] SetModel( "t5_foliage_tree_palm_hideout_single" );

		fronds[i] physicslaunch( (randomint(360),randomint(360),randomint(360)), (randomint(10),randomint(10),randomint(10)) );
		
		wait randomfloatrange (0.05, 0.4);	
	}
	
	wait 10;
	
	for (i = 0; i < fronds.size; i++)
	{
		fronds[i] delete();
	}
}

fall_and_hang(anim_point)
{
		self unlink();
		anim_point anim_single	(self, "hang_death");
		//self anim_loop		(self, "hang_idle", undefined, 	"stop rope idle", anim_point);
}

convert_guy_to_drone( guy, bKeepguy )
{
	if ( !isdefined( bKeepguy ) )
		bKeepguy = false;
	model = spawn( "script_model", guy.origin );
	model.angles = guy.angles;
	model setmodel( guy.model );
	size = guy getattachsize();
	for ( i = 0;i < size;i++ )
	{
		model attach( guy getattachmodelname( i ), guy getattachtagname( i ) );
// 		struct.attachedtags[ i ] = guy getattachtagname( i );
	}
	model useanimtree( #animtree );
	if ( isdefined( guy.team ) )
		model.team = guy.team;
	if ( !bKeepguy )
		guy delete();
	if ( isdefined( guy.animname ) )	// need this for playing anims
		model.animname = guy.animname;
	model makefakeai();
	return model;
}

watch_for_fake_death()
{
	self endon ("fake tree death");
	self endon ("death");
	
	self.realhealth = self.health;
	self.health = 1000000;
	
	total_damage = 0;
	while (1)
	{
		self waittill ("damage", amount, attacker);
		
		total_damage = total_damage + amount;
		if (total_damage >= self.realhealth)
		{
			arcademode_assignpoints( "arcademode_score_treehugger", attacker );

			// CODER_MOD: Austin (9/5/08): force tree sniper to do the coop challenge since he doesn't go through the normal death anim
			/*if( isdefined( level.missionCallbacks ) )
			{
				// removing coop challenges for now MGORDON
				// maps\_challenges_coop::doMissionCallback( "actorKilled", self ); 
			}*/

			self notify ("fake tree death", attacker);
		}
	}
}

//footstep_left_small
//footstep_right_small
//		playFootStep( "J_Ball_LE" );
//	else
//		playFootStep( "J_BALL_RI" );

play_footfx_up_tree_right(guy)
{
	playfxontag(level._effect["foot_step_up_tree"], guy, "J_BALL_RI");
}

play_footfx_up_tree_left(guy)
{
	playfxontag(level._effect["foot_step_up_tree"], guy, "J_Ball_LE");
}


//===SHABS 2/20/09 (commented these out because we will not be using tree_sniper.atr in the T5.) ===\\
//#using_animtree( "tree_sniper" );
//rope_model_anim_setup()
//{
///#
//	level.scr_animtree["sniper_rope"] = #animtree;	
//	level.scr_anim["sniper_rope"]["rope_fall"]		= %o_fall_tree_rope_a;	
//	level.scr_anim["sniper_rope"]["rope_idle"][0]	= %o_fall_tree_idle_rope_a;	
//#/	
//}
//
//rope_spawn_and_animate(anim_point)
//{
///#
//	rope = spawn("script_model", anim_point.origin);
//	
//	rope.angles = anim_point.angles;
//	rope setmodel("anim_foliage_pacific_palmtree_hideout_rope");
//	rope useanimtree(#animtree);
//	rope.animname = "sniper_rope";
//	
//	rope anim_single (rope, "rope_fall", undefined, "stop rope idle", anim_point);
//	rope anim_loop 	(rope, "rope_idle", undefined, "stop rope idle", anim_point);
//#/	
//}