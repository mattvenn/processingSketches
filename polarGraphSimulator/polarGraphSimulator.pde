int lString,rString;
int penWidth = 1;
int maxString = 600;
int stepSize = 5;


int w= 600;
int h= 600;

// Coordinates of current (starting) point
int x1= w/2;
int y1= h;

// Approximate length of strings from marker to staple
int a1= (int)sqrt(pow(x1,2)+pow(y1,2));
int b1= (int)sqrt(pow((w-x1),2)+pow(y1,2));

void setup()
{
  size(w,h);
  lString = a1; // - 100;
   rString = b1; // - 100; 
   background(0);
   stroke(255);
   noLoop();
   draw();
}

void draw()
{
  background(0);
  int cellWidth = 50;
  for( int i = cellWidth; i < width ; i += cellWidth )
  {
    for( int j = cellWidth; j < height ; j += cellWidth )  
    {
      println( i + "," + j );
      drawCircle( i,j,cellWidth/2);
    }
  }
//  while(true)
 // {}
}
void drawPoint()
{
  
  float x2  = ( pow(rString,2) - pow(lString,2) + pow(width,2) ) / (2*width);
  float y = sqrt( pow(rString,2) - pow( x2,2));
  float x = width - x2;
  fill( 255);
  ellipse( x, y, penWidth, penWidth );

}

void mousePressed()
{
  if( mouseX < width/2 )
  {
    lString = mouseY;
  println( "lString = " + lString );
  }
  else
  {
    rString = mouseY;
    println( "rString = " + rString );
  }

}
