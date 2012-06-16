
Point drawLine( int x, int y, int lineLength, float angle, int recurse, Point minXY, Point maxXY )
{
  int maxXLineLength,maxYLineLength = 0; //maximum length of the line in x and y directions
  float maxXDist,maxYDist; //maximum room for the line in x and y
  int maxLineLength; //the calculated line length
  int remainder = 0; //leftover line still to draw at the new bounceAngle
  float bounceAngle = 0; //the angle after the line bounces

  //ensure angle is within 0 and 2PI
  while( angle < 0 )
  {
    angle += 2 * PI;
  }
  //println( "angle: " + angle );    

  //depending on the angle of the line, the room we have for it changes. Store this in max[XY]Dist
  if( angle  > (PI * 1.5) || angle < (PI / 2) )
    maxXDist = maxXY.x - x;
  else
    maxXDist = x - minXY.x;
  if( angle > 0&&angle < PI )
    maxYDist = maxXY.y - y;
  else
    maxYDist = y - minXY.y;

  //print( "max X: " + maxXDist );
  //println( ", max Y: " + maxYDist );
  
  //now work out the actual length of the line we could draw for both X and Y directions
  maxXLineLength = (int)abs( maxXDist / cos(angle) );
  maxYLineLength = (int)abs( maxYDist /sin(angle) );
  //print( "max Xdd: " + maxXLineLength );
  //println( ", max Ydd: " + maxYLineLength );    
  
  //now see which the shortest line is, and we use that one
  //bounce angle is different for each direction
  if( maxXLineLength < maxYLineLength )
  {
    bounceAngle = PI - angle;  
    maxLineLength = maxXLineLength;
  }
  else
  {
    bounceAngle = - angle;
    maxLineLength = maxYLineLength;
  }
  //println( "max line lenght: " + maxLineLength );

  //if the lineLength is bigger than the available room, then work out the remainder left to draw
  if( lineLength > maxLineLength )
  {
    remainder = lineLength - maxLineLength;  
    lineLength = maxLineLength;
  }

  //work out the end points of the line
  int ny = (int)(sin( angle ) * lineLength) + y;
  int nx = (int)(cos( angle ) * lineLength) + x;
  //println( "nx: " + nx + ", ny: " + ny );     

  //draw the line!
  line( x, y, nx, ny );
  
  //we return the coordinates of the end of the line
  Point retPoint = new Point(nx,ny);
  if( recurse > maxRecurse )
    maxRecurse = recurse;
    
  //catch recursion bugs, probably not necessary now the function is working
  if( recurse > 1000 )
  {
    println( "stopping recursion, broken" );
    return new Point();
  }

  //recurse if necessary to draw the rest of the line
  if( remainder > 0)
  {
    //println( "remainder = " + remainder );
    //println( "recurse level: " + recurse );
    retPoint = drawLine(nx,ny,remainder, bounceAngle, ++recurse, minXY, maxXY ); //for y
  }
  
  //otherwise return the final coords
  //println( "returing new point: " + recurse + ":" + retPoint.x + "," + retPoint.y );
  return retPoint;
}
