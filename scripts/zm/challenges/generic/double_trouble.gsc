//Double Trouble – Enemies do Double Damage

double_trouble()
{
	level endon( "end_game" );
	level endon( "end_round_think" );
	level endon( "end_game" );
	level.gauntlet_double_trouble = true;
	level waittill( "end_of_round" );
	level.gauntlet_double_trouble = false;
}

