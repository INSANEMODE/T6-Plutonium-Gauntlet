//Tower Defense– Moving Causes Damage

tower_defense()
{
	foreach ( player in level.players )
	{
		player thread monitor_player_movement();
	}
}

monitor_player_movement()
{
	level endon( "end_game" );
	level endon( "end_round_think" );
	level endon( "end_of_round" );
	while ( true )
	{
		org_1 = self.origin;
		wait 0.5;
		org_2 = self.origin;
		if ( org_1 != org_2 )
		{
			self doDamage( 20, ( 0, 0, 0 ) );
		}
	}
}