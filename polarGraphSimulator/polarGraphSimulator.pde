
import java.awt.Point;
int lString, rString;
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

Point lastPoint, currPoint;
// Approximate length of strings from marker to staple
int a1= (int)sqrt(pow(x1, 2)+pow(y1, 2));
int b1= (int)sqrt(pow((w-x1), 2)+pow(y1, 2));
BufferedReader in;
void setup()
{
  lastPoint = new Point(x1, y1);
  currPoint = new Point(x1, y1);
  size(w, h);
 println( "started" );
  lString = a1 ; // - 100;
  rString = b1; // - 100; 
  background(255);
  //   setupData();
  stroke(color(255, 0, 0));
  strokeWeight(2);

  try {
     in = new BufferedReader(new FileReader("/home/matthew/energy.data"));
  } 
  catch (IOException e) 
  {
    println( e );
    exit();
  }
  //   drawN();

  //   noLoop();
}
int number = 0;
boolean drawn = false;
void draw()
{


  String s;
 // if( number < 20 )
  {
  try{
    
    if((  s = in.readLine()) != null )
  {
    println( s );
    String [] datum = s.split(",");
    try
    {
    int minute = parseMinutes( datum[0] );

    try
    {
      number ++;
      float energy =Float.valueOf(datum[1].trim()).floatValue();
    println( "==" +  minute + ", " + energy );
      circles( energy, minute );
    //  delay(100);
    }
    catch (NumberFormatException nfe)
    {
      System.out.println("NumberFormatException: " + nfe.getMessage());
    }
    }
    catch( Exception e )
    {
      println( "couldn't parse minutes" + e );
    }
  } 
    else
    {
      //wait for another line
  //    delay(10);
    }
  

  }
catch( IOException e )
{
  println( e );
}
  }
}

void drawPoint()
{

  float x2  = ( pow(rString, 2) - pow(lString, 2) + pow(width, 2) ) / (2*width);
  int y = (int)sqrt( pow(rString, 2) - pow( x2, 2));
  int x = (int)( width - x2 );

  currPoint.x = x;
  currPoint.y = y;
  //  ellipse( x, y, penWidth, penWidth );
  line( lastPoint.x, lastPoint.y, currPoint.x, currPoint.y);
  lastPoint = currPoint;
}

void mousePressed()
{
  if ( mouseX < width/2 )
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

