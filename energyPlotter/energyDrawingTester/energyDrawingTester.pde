/*
todo:
points seem to be bouncing off the side multiple times
*/
import controlP5.*;
import java.awt.Point;
ControlP5 controlP5;
int myColor = color(0,0,0);

int sliderValue = 100;
List<Integer> minutes = new ArrayList<Integer>();
List<Float> energies = new ArrayList<Float>();
List<Float> angles = new ArrayList<Float>();

Point minXY, maxXY;
int paperWidth, paperHeight;
int leftMargin, topMargin, bottomMargin;
int nowIndex = 0;
int maxRecurse = 0;
boolean update = false;

int MAXENERGY = 5000;
int MAXLINE = 50;
  
void setua() {
  
  paperWidth = 400;
  paperHeight = 400;
  leftMargin = 20;
  bottomMargin = 40;
  topMargin = 20;

  int sliderSpace = 10;
  size(paperWidth + 2 * leftMargin, paperHeight + topMargin + bottomMargin + sliderSpace);
  
  minXY = new Point( leftMargin,topMargin);
  maxXY = new Point ( leftMargin + paperWidth, paperHeight + topMargin );
  controlP5 = new ControlP5(this);
  // add a vertical slider
  controlP5.addSlider("slider",0,1000,0,leftMargin,paperHeight + topMargin + sliderSpace,paperWidth,bottomMargin);
  println( "reading energy data" );
  readenergydata();
  int lines = energies.size();
  for( int i = 0; i < lines; i ++ )
    angles.add( random( 2 * PI ) );
}

void draw() {
  if( update )
  {
  background(100);

  fill(255);
  //paper
  stroke(0);
  rect(leftMargin,topMargin, paperWidth, paperHeight ); 
 // rect( leftMargin + border, topMargin + border, leftMargin + paperWidth - border, paperHeight + topMargin - border ); 

 
    drawEnergy();
    print( maxRecurse );
  }
  
}

void drawEnergy( )
{
  update= false;
  stroke(0);
  Point oldPoint = new Point(paperWidth / 2 + leftMargin, paperHeight / 2 + topMargin );
  Point newPoint;
  
 
  for( int i = 0 ; i < nowIndex; i ++ )
  {
    float lineLength = map( energies.get(i), 0, MAXENERGY, 0, MAXLINE );
    //println( "old point x: " + oldPoint.x + " y: " + oldPoint.y );
      newPoint = drawLine( oldPoint.x, oldPoint.y, (int)lineLength, angles.get(i), 0 , minXY, maxXY);
    //println( "new point x: " + newPoint.x + " y: " + newPoint.y );
    oldPoint.x = newPoint.x;
        oldPoint.y = newPoint.y;
   }
}


// utils 



void slider(float index) {
  nowIndex = (int)map( index, 0, 1000, 0, minutes.size() -1 );
//  println( nowIndex + " -> " + minutes.get(nowIndex) + "," + energies.get(nowIndex) );
  update = true;
}

//needs more robustness for reading data.
void readenergydata()
{
  int line = 0;
  String s;

  BufferedReader in;  
  try {
//    String filename = "/home/matthew/work/python/feedPolargraph/office.csv";
      String filename = "/home/matthew/energy.data";
    //String filename = "/data/logs/futr.MOSI.log";
    in = new BufferedReader(new FileReader(filename));
    try 
    {
      while((  s = in.readLine()) != null )
      {
        //if( line > 5 )
        //  break;
        if( line ++ % 1000 == 0 )
          println( "processed " + line );

        {
          String [] datum = s.split(",");
          int minute = 0;
          try
          {   
            minute = parseMinutes( datum[0] ); // + datum[1] );
          }
          catch( Exception e )
          {
            println( "couldn't parse minutes: " + e );
          }
          try
          {
            float energy =Float.valueOf(datum[1].trim()).floatValue();
            minutes.add( minute );
            energies.add( energy );
          }
          catch (NumberFormatException nfe)
          {
            System.out.println("NumberFormatException: " + nfe.getMessage());
          }
        }
      }
    }
    catch( IOException e )
    {
      println( e );
    }
  } 
  catch (IOException e) 
  {
    println( e );
    exit();
  }
}

public int parseMinutes(String timestamp)
throws Exception {
  /*
   ** we specify Locale.US since months are in english
   */
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
//   SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyyHH:mm");
  Date d = sdf.parse(timestamp);
  Calendar cal = Calendar.getInstance();
  cal.setTime(d);
  return cal.get(Calendar.HOUR_OF_DAY) * 60 + cal.get(Calendar.MINUTE);
}


