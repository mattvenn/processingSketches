import controlP5.*;

ControlP5 controlP5;

String dmxprogram = "/home/matthew/work/pySimpleDMX/test.py";
boolean useDMX = false;

boolean beams[] = {
  false,false,false,false,false,false
};

import processing.serial.*;

Serial arduino;

int dmx[] = {
  0,0,0,0,0,0
};

void setup() {
  size(600,400);
  frameRate(30);
  background(120);
  controlP5 = new ControlP5(this);
  for(int i=0;i<beams.length;i++) {
    controlP5.addBang("beam"+i,20+i*80,50,40,40).setId(i);
  }
  // change the trigger event, by default it is PRESSED.
  controlP5.addBang("bang",40,250,120,40).setTriggerEvent(Bang.RELEASE);

  String portName = Serial.list()[0];
  arduino = new Serial(this, portName, 57600);
}

void sendDMX()
{
  for(int i = 0; i < dmx.length; i ++ )
  {
    String[] params = { 
      dmxprogram, String.valueOf(i), String.valueOf(dmx[i])
      };
      //      println(  params[1]+" "+ params[2]);
      //    println(  exec(params));
      exec(params);
  }
}


void draw() {
  background(120);
  for( int i = 0; i < beams.length; i ++ )
  {
    fill(dmx[i]);
    rect(20+i*80,110,40,40);
  }
  if( useDMX )
    sendDMX();
  checkArduino();
}

void checkArduino()
{
  arduino.write('a');
  if ( arduino.available() > 0) {  // If data is available,
    int val = arduino.read();         // read it and store it in val
    //println(binary(val));

    for( int i = 0; i < beams.length; i ++)
    {
      if( (val & (1 << i)) == 1)
        beams[i]=true;
      else
        beams[i]=false;
    }
    bang();
  }
}

void bang()
{
  //println("got event");

  /*
  if( beams[0] == true && beams[1] == true )
   println("dmx" + );
   
   */
  for( int i = 0; i < beams.length; i ++ )
  {
    if( beams[i] == true )
    {
      //println(" turn on dmx "+i);
      dmx[i] = 255;
    }
    else
    {
      dmx[i] = 0;
    }
    print(beams[i]+",");
    beams[i]=false;
  }
  println();
}

public void controlEvent(ControlEvent theEvent) {
  for(int i=0;i<beams.length;i++) {
    if(theEvent.controller().name().equals("beam"+i)) {
      beams[i] = true;
    }
  }
  println(
  "## controlEvent / id:"+theEvent.controller().id()+
    " / name:"+theEvent.controller().name()+
    " / label:"+theEvent.controller().label()+
    " / value:"+theEvent.controller().value()
    );
}

