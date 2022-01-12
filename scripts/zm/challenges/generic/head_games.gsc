//Head Games - Kill Zombies with Headshots Only.

double_trouble()
{
	level endon( "end_game" );
	level endon( "end_round_think" );
	level endon( "end_game" );
	level.headshots_only = true;
	level waittill( "end_of_round" );
	level.headshots_only = false;
}