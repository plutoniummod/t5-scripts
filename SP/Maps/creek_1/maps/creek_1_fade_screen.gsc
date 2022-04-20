#include common_scripts\utility; 
#include maps\_utility;


////////////////////////////////////////////////////////////////////////////
// CUSTOM WHITE SCREEN FADE

/*
	SAMPLE USAGE:

		custom_fade_screen();				// basic fade out then back in:
		custom_fade_screen( text_array );	// fade out, display text, fade text away, then fade back in
		custom_fade_screen( text_array, "bottom_right" );  
		custom_fade_screen( text_array, "bottom_right", "white" );  

	Note: The sub-functions can be called individually. 

		Ex: To fade out at the end of the level (no fade in)

			custom_fade_screen_out();

		Ex: To fade text in and out (no background shader)

			custom_fade_screen_text( text_array );

	//------------------------------------------------------------------------

	NOTIFIES SENT
	
		level notify( "screen_fade_out_complete" ); 	// the moment screen turns completely black/white

		level notify( "text_line_fade_in" );			// The moment when a single line of text begins to fade in
														// This will be sent once for each line of text

		level notify( "text_begin_fade_out" );			// The moment when all text is starting to fade out

		level notify( "text_fade_out_complete" );		// The moment when all text is faded out

		level notify( "screen_fade_in_begins" ); 		// the moment screen start to fade back into the game

		level notify( "screen_fade_in_complete" ); 		// the moment screen completely returns back into the game

	//------------------------------------------------------------------------

	PARAMETERS: No required parameters

		text_array			- Array of text strings, in order they will be displayed (any size)
								undefined ( default )

		alignment_type		- Position of text 
							  	"center"
								"bottom_left" ( default )
								"bottom_right"
								"top_left"
								"top_right"

		shader				- Color of background
								"black" ( default )
								"white"

		fade_out_time		- Time to completely fade out
								2.0 ( default )

		fade_in_time 		- Time to completely fade back in
								2.0 ( default )

		space_between_text	- 30 ( default )

		text_scale_first_line	- 1.75 ( default )

		text_scale_other_lines	- 1.5 ( default )

		font				- "default" ( default )

		pause_before_text	- Time between screen fades out and first line of text appearing
								0 ( default )

		pause_time_after_line1 - Time between first line of text appearing and the second line
								 appearing, in case the first line has some significance
								2.0 ( default )

		pause_time_after_other_lines - Time between each line of text appearing (except between
									   the first and second line)								 
										1.5 ( default )

		text_fade_in_time	- Time for each line of text to fade in
								1.2 ( default )

		text_fade_out_time	- Time for text to fade out (all lines fade out together)
								1.2 ( default )

		time_before_fade_out - Time for all text to be displayed on screen, before fading out starts.

*/

custom_fade_screen( text_array, alignment_type, shader, fade_out_time, fade_in_time, space_between_text, 
					text_scale_first_line, text_scale_other_lines, font, pause_before_text, pause_time_after_line1, 
					pause_time_after_other_lines, text_fade_in_time, text_fade_out_time, time_before_fade_out )
{
	custom_fade_screen_out( shader, fade_out_time );

	custom_fade_screen_text( text_array, alignment_type, space_between_text, text_scale_first_line, 
					text_scale_other_lines, font, pause_before_text, pause_time_after_line1, 
					pause_time_after_other_lines, text_fade_in_time, text_fade_out_time, time_before_fade_out );

	custom_fade_screen_in( fade_in_time );
}


custom_fade_screen_out( shader, time )
{
	// define default values
	if( !isdefined( shader ) )
	{
		shader = "black";
	}

	if( !isdefined( time ) )
	{
		time = 2.0;
	}

	if( isdefined( level.fade_screen ) )
	{
		level.fade_screen Destroy();
	}

	level.fade_screen = NewHudElem(); 
	level.fade_screen.x = 0; 
	level.fade_screen.y = 0; 
	level.fade_screen.horzAlign = "fullscreen"; 
	level.fade_screen.vertAlign = "fullscreen"; 
	level.fade_screen.foreground = true;
	level.fade_screen SetShader( shader, 640, 480 );

	if( time == 0 )
	{
		level.fade_screen.alpha = 1; 
	}
	else
	{
		level.fade_screen.alpha = 0; 
		level.fade_screen FadeOverTime( time ); 
		level.fade_screen.alpha = 1; 
		wait( time );
	}
	level notify( "screen_fade_out_complete" );
}

custom_fade_screen_in( time )
{
	level notify( "screen_fade_in_begins" );

	if( !isdefined( time ) )
	{
		time = 2.0;
	}

	if( !isdefined( level.fade_screen ) )
	{
		// error: the screen was not faded in in the first place
		//        for now, simply do nothing.
		return;
	}

	if( time == 0 )
	{
		level.fade_screen.alpha = 0; 
	}
	else
	{
		level.fade_screen.alpha = 1; 
		level.fade_screen FadeOverTime( time ); 
		level.fade_screen.alpha = 0; 
	}
	
	wait( time );
	level notify( "screen_fade_in_complete" );
}

custom_fade_screen_text( text_array, alignment_type, space_between_text, text_scale_first_line, 
					text_scale_other_lines, font, pause_before_text, pause_time_after_line1, 
					pause_time_after_other_lines, fade_in_time, fade_out_time, time_before_fade_out )
{
	// setting up default values
	if( !isdefined( time_before_fade_out ) )
	{
		time_before_fade_out = 2.0;
	}

	if( !isdefined( text_array ) || text_array.size == 0 )
	{
		// no text to display. Simply wait out the time and exit
		wait( time_before_fade_out );
		return;
	}

	if( !isdefined( space_between_text ) )
	{
		space_between_text = 30;
	}

	if( !isdefined( text_scale_first_line ) )
	{
		if ( level.splitscreen && !level.hidef )
			text_scale_first_line = 2.75;
		else
			text_scale_first_line = 1.75;
	}

	if( !isdefined( text_scale_other_lines ) )
	{
		if ( level.splitscreen && !level.hidef )
			text_scale_other_lines = 2.00;
		else
			text_scale_other_lines = 1.5;
	}

	if( !isdefined( alignment_type ) )
	{
		alignment_type = "bottom_left";
	}

	if( !isdefined( pause_before_text ) )
	{
		pause_before_text = 0;
	}

	if( !isdefined( pause_time_after_line1 ) )
	{
		pause_time_after_line1 = 2.0;
	}

	if( !isdefined( pause_time_after_other_lines ) )
	{
		pause_time_after_other_lines = 1.5;
	}

	if( !isdefined( fade_in_time ) )
	{
		fade_in_time = 1.2;
	}

	if( !isdefined( fade_out_time ) )
	{
		fade_out_time = 1.2;
	}

	// determine the general alignment
	
	// default is bottom left of screen
	align_x = "left";
	align_y = "bottom";
	horz_align = "left";
	vert_align = "bottom";
	first_line_y_offset = ( text_array.size - 1 ) * space_between_text * -1;

	if( alignment_type == "center" )
	{
		align_x = "center";
		align_y = "middle";
		horz_align = "center";
		vert_align = "middle";
		first_line_y_offset = ( text_array.size - 1 ) * space_between_text * -0.5;
	}
	else if( alignment_type == "bottom_right" )
	{
		align_x = "right";
		align_y = "bottom";
		horz_align = "right";
		vert_align = "bottom";
		first_line_y_offset = ( text_array.size - 1 ) * space_between_text * -1;
	}
	else if( alignment_type == "top_left" )
	{
		align_x = "left";
		align_y = "top";
		horz_align = "left";
		vert_align = "top";
		first_line_y_offset = 0;
	}
	else if( alignment_type == "top_right" )
	{
		align_x = "right";
		align_y = "top";
		horz_align = "right";
		vert_align = "top";
		first_line_y_offset = 0;
	}

	// create the hud elements
	level.fade_screen_text = [];

	for( i = 0; i < text_array.size; i++ )
	{
		level notify( "text_line_fade_in" );

		y_pos = first_line_y_offset + ( i * space_between_text );

		level.fade_screen_text[i] = NewHudElem(); 
		level.fade_screen_text[i].x = 0; 
		level.fade_screen_text[i].y = y_pos; 
		level.fade_screen_text[i].alignX = align_x; 
		level.fade_screen_text[i].alignY = align_y; 
		level.fade_screen_text[i].horzAlign = horz_align; 
		level.fade_screen_text[i].vertAlign = vert_align; 
		level.fade_screen_text[i].sort = 1; // force to draw after the background
		level.fade_screen_text[i].foreground = true; 
		level.fade_screen_text[i] SetText( text_array[i] ); 

		if( i == 0 )
		{
			level.fade_screen_text[i].fontScale = text_scale_first_line; 
		}
		else
		{
			level.fade_screen_text[i].fontScale = text_scale_other_lines; 
		}

		if( fade_in_time == 0 )
		{
			level.fade_screen_text[i].alpha = 1; 
		}
		else
		{
			level.fade_screen_text[i].alpha = 0; 
			level.fade_screen_text[i] FadeOverTime( fade_in_time ); 
			level.fade_screen_text[i].alpha = 1; 
		}
	
		if( IsDefined( font ) )
		{
			level.fade_screen_text[i].font = font;
		}

		// wait between the lines 
		if( i < text_array.size - 1 ) // there are still more lines
		{
			if( i == 0 )
			{
				wait( pause_time_after_line1 );
			}
			else
			{
				wait( pause_time_after_other_lines );
			}
		}
	}

	// all text is drawn. Time to begin fading them out
	wait( time_before_fade_out );

	level notify( "text_begin_fade_out" );

	for( i = 0; i < level.fade_screen_text.size; i++ )
	{
		level.fade_screen_text[i] FadeOverTime( fade_out_time );
		level.fade_screen_text[i].alpha = 0; 
	}	

	// destroy the hud elements once fade out is complete
	wait( fade_out_time );

	for( i = 0; i < level.fade_screen_text.size; i++ )
	{
		level.fade_screen_text[i] Destroy();
	}	

	level notify( "text_fade_out_complete" );
}