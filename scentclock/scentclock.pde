/**
scent clock software
Matthew Venn 2012
 */

import controlP5.*;
import processing.serial.*;

Serial myPort;  // Create object from Serial class
ControlP5 controlP5;
int myColor = color(0,0,0);

int fan = 50;
int heat = 20;
int heatTime = 5;
int ventOpenDelay = 3;
int ventOpenTime = 5;
int switchInterval = 10;
//intermittent fan options
int fanOn = 10;
int fanOff = 10;

int maxHeat = 160;
int maxHeatTime = 60 * 60 * 2;
int maxVentOpenTime = 60 * 60 * 2;
int maxFanOn = 1200;
int maxFanOff = 1200;
int maxVentOpenDelay = maxHeatTime / 2;
int maxFan = 100;
int maxSwitchInterval = 600;

int slid_w = 40;
int slid_h = 200;
int slid_margin = 40;
int butt_h = 100;
int butt_margin = 50;
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
  size(900,400,P2D);
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
  s = controlP5.addSlider("fan",0,maxFan,fan,pos_x,pos_y,slid_w,slid_h); //min, max, start, x, top y, width, height
  pos_x += slid_w + slid_margin;
  s = controlP5.addSlider("switchInterval",0,maxSwitchInterval,switchInterval,pos_x,pos_y,slid_w,slid_h); //min, max, start, x, top y, width, height
  pos_x += slid_w + slid_margin;
  s = controlP5.addSlider("fanOn",10,maxFanOn,fanOn,pos_x,pos_y,slid_w,slid_h); //min, max, start, x, top y, width, height
  pos_x += slid_w + slid_margin;
  s = controlP5.addSlider("fanOff",0,maxFanOff,fanOff,pos_x,pos_y,slid_w,slid_h); //min, max, start, x, top y, width, height
  pos_x += slid_w + slid_margin;
  
  controlP5.addButton("load",0,pos_x,pos_y,butt_h,slid_w);
  pos_y += butt_margin;
  controlP5.addButton("release1",0,pos_x,pos_y,butt_h,slid_w);
  pos_y += butt_margin;
  controlP5.addButton("release2",0,pos_x,pos_y,butt_h,slid_w);
  pos_y += butt_margin;
  controlP5.addButton("release3",0,pos_x,pos_y,butt_h,slid_w);
  
  ttLabel = controlP5.addTextlabel("tt","end time",width - 30, height-60);
  controlP5.addTextlabel("start","0 s",10, height-60);
  
  //show starting vals
  myPort.write( 'B' );

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
       
     float ventBarWidth =  40;
     for( int i = tmap(ventOpenDelay,tt); i < tmap(ventOpenTime + ventOpenDelay,tt); i += tmap(fanOn+fanOff,tt))
     {  
       rect(i,height-ventBarWidth-40,tmap(fanOn,tt),ventBarWidth);
     }
       //rect(tmap( ventOpenDelay,tt),height-ventBarWidth-40,tmap(ventOpenTime,tt),ventBarWidth);
     
   //time bar
     stroke(255);
     line(0,height-40,width,height-40);
     int lineStart = height -40;
     int markerHeight = 10;
     for( int i = tmap(0,tt); i < width; i += tmap(60,tt) )
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

public void release1(int val)
{
  myPort.write( 'C' );
  writeInt( 1 );
}
public void release2(int val)
{
  myPort.write( 'C' );
  writeInt( 2 );
}
public void release3(int val)
{
  myPort.write( 'C' );
  writeInt( 3 );
}

void writeInt( int x )
{
  byte upper = (byte)(x >> 8); //Get the upper 8 bits
  byte lower = (byte)(x & 0xFF); //Get the lower 8bits
  myPort.write(upper);
  myPort.write(lower);
}

public void load(int val) 
{
  println("loading vals to scentclock");
  //println( heat + "," + heatTime + "," + ventOpenDelay  + "," + ventOpenTime + "," + fan);
  myPort.write( 'A' );
  writeInt( heat );
  writeInt( heatTime );
  writeInt( ventOpenDelay );
  writeInt(ventOpenTime );
  writeInt( fan );
  writeInt( switchInterval );
  writeInt( fanOn );
  writeInt( fanOff );
  
  delay(100);
  myPort.write( 'B' );
  delay(100);

}

