//No Gen – No Health Regeneration

no_gen()
{
	foreach ( player in level.players )
	{
		player thread disable_regen();
	}
}

disable_regen()
{
	level endon( "end_game" );
	level endon( "end_round_think" );
	self endon( "bled_out" );
	self notify( "playerHealthRegen" );
	level waittill( "end_of_round" );
	self thread playerhealthregen();
}

