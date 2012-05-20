void setup()
{
  size(400,400);
}
void draw()
{
  background( 0 );
  stroke(255);
  float angle = 2 * PI / 360 * 80;
  drawRndLine( width/2, height/2 , mouseX * 2 , angle);
}

void drawRndLine( int x, int y, int lineLength, float angle)
{

    
    float maxXDist,maxYDist;
    if( angle > -(PI / 2) && angle < (PI / 2) )
      maxXDist = width - x;
    else
      maxXDist = x;
    if( angle > 0 && angle < PI )
      maxYDist = height - y;
    else
      maxYDist = y;

    println( "max X: " + maxXDist );
    println( "max Y: " + maxYDist );
//    int maxLineLength = (int)abs( maxXDist / cos(angle) );
        int maxLineLength = (int)abs( maxYDist /sin(angle) );
    int remainder = 0;
    println( "max line lenght: " + maxLineLength );
    if( lineLength > maxLineLength )
    {
      remainder = lineLength - maxLineLength;  
      lineLength = maxLineLength;
    }
    
    int ny = (int)(sin( angle ) * lineLength) + y;
    int nx = (int)(cos( angle ) * lineLength) + x;
    
     
    line( x, y, nx, ny );
    if( remainder > 0)
    {
      //draw next line
      println( "remainder = " + remainder );
   // for x   drawRndLine(nx,ny,remainder, PI - angle );
          drawRndLine(nx,ny,remainder, - angle ); //for y
    }

}
  
