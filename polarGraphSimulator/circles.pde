int smallestRadius = 3;
void circles( float energy, int number )
{
  int y = number / 12;
  int x = number % 12;
  int cellWidth = ( w - 2 * margin ) / 13;
  x *= cellWidth;
  x += cellWidth;
  x += margin;

  y *= cellWidth;
  y += cellWidth;
  y += ceiling;
  int r = cellWidth / 2;
  //println( "x: " + x * cellWidth + " y: " + y * cellWidth );
  int radius = (int)map( energy, 0, maxEnergy, 0, cellWidth / 2 );
 //  println( energy + " = " + radius );
   moveTo( x, y );
  for( int i = smallestRadius; i < radius; i += 10 )
  {
    drawCircle( x, y, i ); 
     println( "drawCircle( " + x + ", " + y + ", " + i + " );" );
  }
}
