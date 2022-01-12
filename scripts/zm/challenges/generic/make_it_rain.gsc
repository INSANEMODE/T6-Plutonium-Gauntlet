//Make It Rain – Take Damage While you Have Over 5000 Points

make_it_rain()
{
	foreach ( player in level.players )
	{
		player thread take_damage_based_on_points_owned();
	}
}

take_damage_based_on_points_owned()
{
	level endon( "end_game" );
	level endon( "end_round_think" );
	level endon( "end_of_round" );
	while ( true )
	{
		wait 1;
		if ( self.score > 5000 )
		{
			self doDamage( 10, ( 0, 0, 0 ) );
		}
	}
}