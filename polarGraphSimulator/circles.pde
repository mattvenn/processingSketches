int smallestRadius = 5;
int lastSegment = 0;
boolean newCell = false;
int radius;
void circles( float energy, int number )
{
  if( number % 10 == 0 )
  {
    newCell = true;
    radius = smallestRadius;
    println( "new cell" + number);
  }
  else
  {
    newCell = false; 
  }
  number /= 10;
  
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
  
  if( newCell )
     moveTo( x, y );
  //println( "x: " + x * cellWidth + " y: " + y * cellWidth );
  //int radius = (int)map( energy, 0, maxEnergy, 0, cellWidth / 2 );
  int numSegments = (int)map( energy, 0, maxEnergy, 0, 10 );
 //  println( energy + " = " + radius );

   if( numSegments + lastSegment <= 20 )
   {
    drawCircleSegment( x, y, radius, lastSegment, lastSegment + numSegments );
    lastSegment += numSegments;
   }
   else
   {
     drawCircleSegment( x, y, radius, lastSegment, 20 );
     radius += 5;
     drawCircleSegment( x, y, radius, 0, lastSegment - numSegments);
     lastSegment = lastSegment - numSegments;
   }

}
