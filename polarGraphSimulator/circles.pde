int smallestRadius = 3;
void circles( float energy, int number )
{
  int y = number / 14;
  int x = number % 14;
  int cellWidth = width / 15;
  x *= cellWidth;
  x += cellWidth;

  y *= cellWidth;
  y += cellWidth;
  y += ceiling;
  int r = cellWidth / 2;
  //println( "x: " + x * cellWidth + " y: " + y * cellWidth );
  int radius = (int)map( energy, 0, maxEnergy, 0, cellWidth / 2 );
   println( energy + " = " + radius );
  for( int i = smallestRadius; i < radius; i += 5 )
  {
    drawCircle( x, y, i ); 
  }
}
