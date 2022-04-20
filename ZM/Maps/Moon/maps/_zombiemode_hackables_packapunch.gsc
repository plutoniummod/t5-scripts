#include common_scripts\utility;
#include maps\_utility;
#include maps\_zombiemode_utility;

hack_packapunch()
{
	//flag_wait("power_on");
	
	vending_weapon_upgrade_trigger = GetEntArray("zombie_vending_upgrade", "targetname");

	perk = getent(vending_weapon_upgrade_trigger[0].target, "targetname");	
	
	if(IsDefined(perk))
	{
		struct = SpawnStruct();
		struct.origin = perk.origin + (AnglesToRight(perk.angles) * 26) + (0,0,48);
		struct.radius = 48;
		struct.height = 48;
		struct.script_float = 5;
		struct.script_int = -1000;
		level._pack_hack_struct = struct;
		maps\_zombiemode_equip_hacker::register_pooled_hackable_struct(level._pack_hack_struct, ::packapunch_hack);		
		
		
		level._pack_hack_struct pack_trigger_think();
		
		//level thread packapunch_hack_think();
	}
}

pack_trigger_think()
{
	while(1)
	{
		flag_wait("enter_nml");
		self.script_int = -1000;
		
		while(flag("enter_nml"))
		{
			wait(1.0);
		}
	}	
}

packapunch_hack(hacker)
{
	maps\_zombiemode_equip_hacker::deregister_hackable_struct(level._pack_hack_struct);
	level._pack_hack_struct.script_int = 0;
	level notify("packapunch_hacked");
}