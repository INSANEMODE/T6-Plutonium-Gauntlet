

add_challenge( screen_name, func )
{
	if ( !isDefined( level.gauntlet_challenges ) )
	{
		level.gauntlet_challenges = [];
	}
	level.gauntlet_challenges[ level.gauntlet_challenges.size ] = spawnStruct();
	level.gauntlet_challenges[ level.gauntlet_challenges.size - 1 ].name = screen_name;
	level.gauntlet_challenges[ level.gauntlet_challenges.size - 1 ].func = func;
}

challenge_manager()
{
	level endon( "end_game" );
	level.gauntlet_challenge_index = 0;
	while ( true )
	{
		level waittill( "start_of_round" );
		level thread [[ level.gauntlet_challenges[ level.gauntlet_challenge_index ].func ]]();
		level waittill( "end_of_round" );
		level.gauntlet_challenge_index++;
	}
}

round_restart()
{
	// if ( isDefined( level._grief_reset_message ) )
	// {
	// 	level thread [[ level._grief_reset_message ]]();
	// }
	level notify( "end_round_think" );
	level.zombie_vars[ "spectators_respawn" ] = 1;
	zombie_goto_round( level.round_number );
	level thread maps/mp/zombies/_zm::round_think( 1 );
	level thread [[ level.gauntlet_challenges[ level.gauntlet_challenge_index ].func ]]();
}