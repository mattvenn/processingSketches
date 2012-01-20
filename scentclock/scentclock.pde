/**
 * ControlP5 Slider. Horizontal and vertical sliders, 
 * with and without tick marks and snap-to-tick.
 * by andreas schlegel, 2010
 */

import controlP5.*;

ControlP5 controlP5;
int myColor = color(0,0,0);

boolean fan = false;
int holeSize = 25;
int heat = 50;
int heatTime = 20;
int ventOpenDelay = 10;
int ventOpenTime = 20;

int maxHeat = 100;
int maxHeatTime = 60;
int maxVentOpenTime = 100;
int maxVentOpenDelay = maxHeatTime / 2;
int maxHoleSize = 100;

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
   
Textlabel ttLabel;
void setup()
{
  size(600,400);
  controlP5 = new ControlP5(this);
  
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
  s = controlP5.addSlider("holeSize",0,maxHoleSize,holeSize,pos_x,pos_y,slid_w,slid_h); //min, max, start, x, top y, width, height
  s.setNumberOfTickMarks(5);
  pos_x += slid_w + slid_margin;
       
  //fan
  controlP5.addToggle("fan",false,pos_x,pos_y,butt_h,slid_w).setMode(ControlP5.SWITCH);
  pos_y += butt_margin;
  controlP5.addButton("load",0,pos_x,pos_y,butt_h,slid_w);

  ttLabel = controlP5.addTextlabel("tt","end time",width - 30, height-60);
  controlP5.addTextlabel("start","0 s",10, height-60);
  
}

void draw()
{
  background(0);
  
  int tt;
    if( ventOpenDelay > heatTime )
      tt = ventOpenDelay + ventOpenTime;
    else
      tt = heatTime + ventOpenTime;
  
    ttLabel.setValue( Integer.toString( tt ) + " s" );
   
     //heat bar
     fill(color(255,0,0));
     float heatBarWidth = map(heat,0,maxHeat,0,40);
     rect(0,height-heatBarWidth,tmap(heatTime,tt),heatBarWidth);
   
     //vent bar
     fill(color(100,100,100));
     if( fan )
       fill(color(180,180,180));
       
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
}

int tmap(int val,int totalTime)
{
  return (int)map(val,0,totalTime,0,width);
}

public void load(int val) 
{
  println("loading vals to scentclock");
  println( fan + "," + holeSize + "," + heat + "," + heatTime + "," + ventOpenDelay  + "," + ventOpenTime);
}

