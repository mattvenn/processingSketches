/**
 * ControlP5 Slider. Horizontal and vertical sliders, 
 * with and without tick marks and snap-to-tick.
 * by andreas schlegel, 2010
 */

import controlP5.*;
import processing.serial.*;

Serial myPort;  // Create object from Serial class
ControlP5 controlP5;
int myColor = color(0,0,0);

int fan = 50;
int holeSize = 1;
int heat = 150;
int heatTime = 5;
int ventOpenDelay = 3;
int ventOpenTime = 5;

int maxHeat = 255;
int maxHeatTime = 60;
int maxVentOpenTime = 100;
int maxVentOpenDelay = maxHeatTime / 2;
int maxHoleSize = 4;
int maxFan = 100;

int slid_w = 40;
int slid_h = 200;
int slid_margin = 40;
int butt_h = 100;
int butt_margin = 80;
int start_x = 50;
int start_y = 50; //slid_h + 50;

//globals
boolean run = false;
int runPos = 0;
int time = 0;

String myString;
int lf = 10;    // Linefeed in ASCII

Textlabel ttLabel;
void setup()
{
  size(700,400,P2D);
  controlP5 = new ControlP5(this);
  
  //serial

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
  println( portName );
  //hole size
  int pos_x = start_x;
  int pos_y = start_y;
  Slider s;
  
  s = controlP5.addSlider("heat",0,maxHeat,heat,pos_x,pos_y,slid_w,slid_h); 
  pos_x += slid_w + slid_margin;
  s = controlP5.addSlider("heatTime",0,maxHeatTime,heatTime,pos_x,pos_y,slid_w,slid_h); 
  pos_x += slid_w + slid_margin;
  s = controlP5.addSlider("ventOpenDelay",0,maxVentOpenDelay,ventOpenDelay,pos_x,pos_y,slid_w,slid_h); 
  pos_x += slid_w + slid_margin;
  s = controlP5.addSlider("ventOpenTime",0,maxVentOpenTime,ventOpenTime,pos_x,pos_y,slid_w,slid_h);   
  pos_x += slid_w + slid_margin;
  s = controlP5.addSlider("holeSize",1,maxHoleSize,holeSize,pos_x,pos_y,slid_w,slid_h); //min, max, start, x, top y, width, height
  s.setNumberOfTickMarks(5);
  pos_x += slid_w + slid_margin;
  s = controlP5.addSlider("fan",0,maxFan,fan,pos_x,pos_y,slid_w,slid_h); //min, max, start, x, top y, width, height
  pos_x += slid_w + slid_margin;
       
  controlP5.addButton("load",0,pos_x,pos_y,butt_h,slid_w);
  pos_y += butt_margin;
  controlP5.addButton("release",0,pos_x,pos_y,butt_h,slid_w);
  ttLabel = controlP5.addTextlabel("tt","end time",width - 30, height-60);
  controlP5.addTextlabel("start","0 s",10, height-60);
  
}

void draw()
{
  background(0);
  
  int tt;
    if( ventOpenDelay + ventOpenTime > heatTime )
      tt = ventOpenDelay + ventOpenTime;
    else
      tt = heatTime;
  
    ttLabel.setValue( Integer.toString( tt ) + " s" );
   
     //heat bar
     fill(color(255,0,0));
     float heatBarWidth = map(heat,0,maxHeat,0,40);
     rect(0,height-heatBarWidth,tmap(heatTime,tt),heatBarWidth);
   
     //vent bar
     int ventC = 50 + fan * 2;
     fill(color(ventC,ventC,ventC));
   //  if( fan )
   //    fill(color(180,180,180));
       
     float ventBarWidth =  map(holeSize,0,maxHoleSize,0,40);
     rect(tmap( ventOpenDelay,tt),height-ventBarWidth-40,tmap(ventOpenTime,tt),ventBarWidth);
     
   //time bar
     stroke(255);
     line(0,height-40,width,height-40);
     int lineStart = height -40;
     int markerHeight = 10;
     for( int i = tmap(10,tt); i < width; i += tmap(10,tt) )
     {
       line(i,lineStart - markerHeight, i , lineStart + markerHeight );

     } 
     //time marker
     fill(0);
     ellipse( tmap( time,tt ), lineStart, 10,10 );
    controlP5.draw();     

  //serial stuff
  while( myPort.available() > 0 )
  {
     myString = myPort.readStringUntil(lf);
    if (myString != null) {
      print(myString);
      myString = trim( myString );
      if( myString.startsWith( "t=" ) )
      {
        //
        String []list = split(myString, '=' );
        if( list.length == 2 )
       {
       //  println( "time = " + list[1] );
         time = Integer.parseInt(list[1]);
       }
      }
    }

  }
}

int tmap(int val,int totalTime)
{
  return (int)map(val,0,totalTime,0,width);
}


public void release(int val)
{
  myPort.write( 'C' );
  delay(100);
}
public void load(int val) 
{
  println("loading vals to scentclock");
  println( fan + "," + holeSize + "," + heat + "," + heatTime + "," + ventOpenDelay  + "," + ventOpenTime);
  myPort.write( 'A' );
  myPort.write( fan );
  myPort.write( holeSize );
  myPort.write( heat );
  myPort.write( heatTime );
  myPort.write(  ventOpenDelay );
  myPort.write(ventOpenTime );

  delay(100);
  myPort.write( 'B' );
  delay(100);

}

