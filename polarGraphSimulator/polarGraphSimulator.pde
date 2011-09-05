
import java.awt.Point;
int lString,rString;
int penWidth = 1;
int maxString = 600;
//int ceiling = 100; //how much space to leave at the top

//int w= 1000;
//int h= 600 + ceiling;

float diameter = 1.24; //1.29
float circumference = 3.1415 * diameter;

int StepUnit = (int)(200 / circumference / 4);   


// Approximate dimensions (in steps) of the total drawing area
int w= 68*StepUnit;
int ceiling = 10*StepUnit;
int h= 34 * StepUnit + ceiling;
int margin = w / 4;

// Coordinates of current (starting) point
int x1= w/2;
int y1= h;

Point lastPoint,currPoint;
// Approximate length of strings from marker to staple
int a1= (int)sqrt(pow(x1,2)+pow(y1,2));
int b1= (int)sqrt(pow((w-x1),2)+pow(y1,2));

void setup()
{
  lastPoint = new Point(x1,y1);
  currPoint = new Point(x1,y1);
  size(w,h);
  lString = a1 ; // - 100;
   rString = b1; // - 100; 
   background(255);
   setupData();
   stroke(color(255,0,0));
    strokeWeight(2);
   //drawN();
   //   noLoop();
}
int i = 0;
void draw()
{
 //  for( int days = 0; days < numDays ; days ++ )
 int w = width;
 int h = height;
/*
      drawCircleSegment( w/2, h/2 + ceiling , h/4,0,8);
      drawCircleSegment( w/2, h/2 + ceiling , h/4,8,12 );
      drawCircleSegment( w/2, h/2 + ceiling , h/4,12,20 );
*/
 
  circles( energyArray[0][i], i );     
  i ++;
  
  if( i >= numBuckets )
  {
    println( "finished" );
    while(true)
    {
    }
  }
 /*
  {
    for( int i = 0; i < numBuckets ; i ++ )
    {
     
    }
  }
  */
}
void drawPoint()
{
  
  float x2  = ( pow(rString,2) - pow(lString,2) + pow(width,2) ) / (2*width);
  int y = (int)sqrt( pow(rString,2) - pow( x2,2));
  int x = (int)( width - x2 );

  currPoint.x = x;
  currPoint.y = y;
//  ellipse( x, y, penWidth, penWidth );
  line( lastPoint.x,lastPoint.y,currPoint.x,currPoint.y);
  lastPoint = currPoint;

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
