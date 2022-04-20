#include maps\_utility;
#include common_scripts\utility;
#include maps\_anim;
#include maps\_music;

//SELF = Player Bike or AI Bike
init_motorcycle_audio()
{
    self thread bike_setup_player();
    //Add check to see if self is an AI bike if you want to add them in
}

//SELF = Player Bike
bike_setup_player()
{
	self.is_accelerating = false;			//DEFAULT: Motorcycle starts not accelerating
	self.is_braking	     = false;			//DEFAULT: Motorcycle starts not breaking
	self.is_on_ground	 = true;            //DEFAULT: Motorcycle starts on the ground
	self.is_jumping		 = false;           //DEFAULT: Motorcycle starts on the ground
	self.moto_stage		 = "vMi";           //DEFAULT: Motorcycle starts in idle
    
    self bike_start_audio_plr();            //Until an animation goes in, this plays the motorcycle turning on
    self thread send_moto_clientnotify();   //Sends clientnotifies
    self thread set_moto_stage();           //This sets the stage the Motorcycle is in and determines what clientnotifies are sent

	self thread track_bike_liftoff();       //Updates is_jumping and is_on_ground based on notifies from code
	self thread track_bike_landing();       //Updates is_jumping and is_on_ground based on notifies from code

	self gear_setup();						//Exact copy of clientside funtion that setups gear state timers
	self thread set_gear_state();			//Exact copy of clientside funtion that sets the gear state
}

//SELF = Player Bike
//Plays a Motorcycle Activate sound; should have a waittill tied to an anim notetrack
bike_start_audio_plr()
{
    player = get_players()[0];
    //insert notetrack wait here
    player PlaySound( "veh_moto_activate_plr" );
    clientnotify( "vM" );  //Activates the _motorcycle_audio.csc
}

//SELF = Player Bike
//Sends a Client Notify every time self.moto_stage changes with a .5 second minimum buffer between sends
send_moto_clientnotify()
{
    self endon( "death" );
    self endon( "crashed" );
    level endon( "evM" );
    
    current_stage = undefined;
    previous_stage = undefined;
    notify_timer = 0;
    
    while(1)
    {
        if( !IsDefined( self.moto_stage ) )
        {
            wait(.05);
            continue;
        }
        
        if( !IsDefined( current_stage ) || !IsDefined( previous_stage ) )
        {
            current_stage = self.moto_stage;
            previous_stage = self.moto_stage;
            //clientnotify( current_stage );
        }
        
        current_stage = self.moto_stage;
        
        if( ( current_stage != previous_stage ) && ( notify_timer >= .5 ) )
        {
            previous_stage = current_stage;
            clientnotify( current_stage );
            notify_timer = 0;
        }
        
        notify_timer = notify_timer + .05;
        wait(.05);
    }
}

//SELF = Player Bike
//Changes self.moto_stage based on button input and speed; determines which client notify to send
set_moto_stage()
{
    self endon( "death" );
    self endon( "crashed" );
    level endon( "evM" );
    
    player = get_players()[0];
    
    while(1)
    {
        if( self.is_on_ground == false )
        {
            self.moto_stage = "vMj";  //Vorkuta Moto Jump
        }
        else if( player AttackButtonPressed() == false && self GetSpeedMPH() <= 20  )
        {
            self.moto_stage = "vMi";  //Vorkuta Moto Idle
			self.is_accelerating = false;
			self.is_idling = true;
        }
        else if( player AttackButtonPressed() == false && self GetSpeedMPH() <= 80 )
		{
            self.moto_stage = "vMd";  //Vorkuta Moto Decelerate
			self.is_accelerating = false;
			self.is_idling = false;
        }
        else if( player AttackButtonPressed() == true )
        {
            self.moto_stage = "vMa";  //Vorkuta Moto Accelerate
			self.is_accelerating = true;
			self.is_idling = false;
        }
        wait(.05);
    }
}

//SELF = Player Bike
//Updates is_jumping and is_on_ground based on notifies from code
track_bike_liftoff()
{
	while(1)
	{
		self waittill("veh_inair"); // this notify is sent by physics code 
		self.is_on_ground = false;  
		self.is_jumping = true;
	}
}

//SELF = Player Bike
//Updates is_jumping and is_on_ground based on notifies from code
track_bike_landing() 
{
    while(1)
    {
        self waittill( "veh_landed" ); // this notify is sent by physics code 
		self.is_on_ground = true;  
		self.is_jumping = false;
    }
}


//SELF = Player
//Exact copy of clientside funtion that setups gear state timers
gear_setup()
{
	self.moto_gear_trans = [];
	p = 1;
	n = 0;
	m = 0;

	for(i=0;i<8;i++)
	{
		self.moto_gear_trans[i] = [];

		if( i == 0 )
			self.moto_gear_trans[i]["pitch_time"] = 1;
		else
			self.moto_gear_trans[i]["pitch_time"] = p*2;

		self.moto_gear_trans[i]["min_pitch"] = .75 + n;
		self.moto_gear_trans[i]["max_pitch"] = 1.15 + m;
		
		p = self.moto_gear_trans[i]["pitch_time"];
		n = n + .055;
		m = m + .045;
	}
}

// self = player bike
//Exact copy of clientside funtion that sets the gear state
set_gear_state()
{
	level endon( "evM" );

	self.gear_state = 0;
	current_time = undefined;
	decelerate_time = undefined;
		
	while(1)
	{
		while( IsDefined( self ) && self.is_accelerating && !self.is_jumping && !self.is_braking )
		{
			if( !IsDefined( current_time ) )
				current_time = 0;

			gear_change_time = self.moto_gear_trans[self.gear_state]["pitch_time"];
						
			if( current_time >= gear_change_time )
			{
				current_time = undefined;
				self.gear_state = self.gear_state + 1;
				//IPrintLn( "Server : gear changed ++" );
				self.gearStateChanged = true;
				self notify( "gear_changed" );
				wait(.05);
			}
			else
			{
				wait(.05);
				current_time = current_time + .05;
			}
		}

		while( IsDefined( self ) && (!self.is_accelerating || self.is_jumping || self.is_braking) )
		{
			current_time = undefined;

			if( !IsDefined( decelerate_time ) )
				decelerate_time = 0;

			if( decelerate_time >= 1 )
			{
				if( self.gear_state == 0 )
				{
					decelerate_time = undefined;
					wait(.05);
				}
				else
				{
					decelerate_time = undefined;
					self.gear_state = self.gear_state - 1;
					//IPrintLn( "Server : gear changed -- " );
					self.gearStateChanged = true;
					self notify( "gear_changed" );
					wait(.05);
				}
			}
			else
			{
				wait(.05);
				decelerate_time = decelerate_time + .05;
			}

		}
		
		wait(.05);
	}
}
