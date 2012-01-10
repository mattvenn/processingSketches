float centreX = w / 2;
float centreY = h / 2;
float energyR = 150;
float energyScalingFactor = 100000;
void drawEnergy( float energy, int minute )
{
  energyR -= energy / energyScalingFactor;
  if( energyR >= 0 )
  {
  float angle = - minute * ( 360.0 / 1440.0 ); //1440 minutes in a day
  angle += 180; //start from 12 oclock
//  println( angle );
  float opp = energyR * sin( rads((int)angle) );
  float adj = energyR * cos( rads((int)angle) );

  moveTo( (int)(centreX + opp),(int)( centreY + adj) );
  }
}
