import controlP5.*;
/*
sensors # (from closest wall and walking clockwise)
 1,4,5,3,2,0
 
 dmx # 
 
 */

import dmxP512.*;
import processing.serial.*;
import ddf.minim.*;

//global config
boolean useDMX = true;
boolean useAudio = true;
boolean useCosm = true;

DmxP512 dmxOutput;
int universeSize=128;

AudioPlayer [] players = new AudioPlayer[5];
AudioPlayer mainLoop;
Minim minim;

//dmx stuff
String DMXPRO_PORT="COM3";//case matters ! on windows port must be upper cased.
int DMXPRO_BAUDRATE=115200;

//interface
ControlP5 controlP5;

//global state
boolean beams[] = { 
  false, false, false, false, false, false
};
int dmx[] = {
  0, 0, 0, 0, 0, 0
};
Fader [] faders = new Fader[6];

int beamCounter[] = {
  0, 0, 0, 0, 0, 0
};

//arduino port
Serial arduino;
//easter egg sequence
int seqNumber = 0;
int sequence[] = {0,0,0,0,0,0};
int targetSequence[] = {2,0,1,4,5,3};

//how often to update cosm
int sendCosmInterval = 1000 * 60; //how often to send an update to cosm
SimpleThread cosmUpdate;

void setup() {

  size(500, 250,JAVA2D);
  minim = new Minim(this);
  frameRate(30);
  background(120);
  controlP5 = new ControlP5(this);
  for (int i=0;i<beams.length;i++) {
    controlP5.addBang("beam"+i, 20+i*80, 20, 40, 40).setId(i);
  }

  println(Serial.list());
  String portName = Serial.list()[2];

  arduino = new Serial(this, portName, 57600);
  dmxOutput=new DmxP512(this, universeSize, false);

  dmxOutput.setupDmxPro(DMXPRO_PORT, DMXPRO_BAUDRATE);

  if ( useCosm )
  {
    cosmUpdate = new SimpleThread(this, beamCounter, sendCosmInterval);
    cosmUpdate.start();
  }

  //load sounds
  players[0] = minim.loadFile("Astrand.wav", 2048);
  players[1] = minim.loadFile("Bstrand.wav", 2048);
  players[2] = minim.loadFile("Cstrand.wav", 2048);
  players[3] = minim.loadFile("Dstrand.wav", 2048);
  players[4] = minim.loadFile("Estrand.wav", 2048);
  //main loop
  mainLoop = minim.loadFile("mix28min.wav", 2048);

  if ( useAudio )
    mainLoop.loop();

  for ( int i = 0; i<faders.length; i ++ )
    faders[i] = new Fader();

  //faders[0].debug();
}

void draw() {
  background(120);

  //check for data from arduino
  checkArduino();

  //update the dmx values with the faders
  for (int i = 0; i < faders.length; i ++ )
    dmx[i] = faders[i].update();

  //send the dmx
  if ( useDMX )
    dmxOutput.set(1, dmx);  

  //draw the beam breaks to the gui
  for ( int i = 0; i < beams.length; i ++ )
  {
    fill(beams[i]? color(255,0,0) : 0);
      rect(20+i*80, 90, 40, 40);
    fill(dmx[i]);
      rect(20+i*80, 150, 40, 40);
  }
}

void checkArduino()
{
  arduino.write('a');
  if ( arduino.available() > 0) {  // If data is available,
    int val = arduino.read();         // read it and store it in val
    //println(binary(val));

    for ( int i = 0; i < beams.length; i ++)
    {
      boolean state = false;
      if ( (val & (1 << i)) > 0)
        state = true;

      setBeam(i, state);
    }
  }
}

void checkEaster()
{
  for( int start = 0; start < sequence.length; start ++ )
  {
    boolean easter = true;

    for( int i = 0; i < sequence.length; i ++ )
    {
      if( sequence[(i+start)%sequence.length] != targetSequence[i])
        easter = false;
        
    }
    if( easter )
    {
      println("easter!!!");
      if( useCosm )
        cosmUpdate.incEaster();
      easter();
    }
    
  }
}

//do something funky
void easter()
{
  //reset sequence
  for(int i = 0; i<sequence.length; i ++ )  
  {
      sequence[i] = 0;
  }
  
  //turn off all audio
  mainLoop.pause();
  for(int i = 0; i<players.length; i ++ )
  {
    players[i].pause();
    players[i].rewind();
  }
  

  //turn off all lights
  for( int i = 0; i < dmx.length; i ++ )
  {
    dmxOutput.set(i+1, 0 );
    faders[i].finish();
  }
    

  //start all audio
    for(int i = 0; i<players.length; i ++ )
    players[i].play();

  //wait for audio to kick in
  delay(3000);
  int reps = 60;
  for( int r = 0; r < reps; r ++ )
  {
      for( int i = 0; i < dmx.length; i ++ )
    dmxOutput.set(i+1, 255 );
    delay(50);
       for( int i = 0; i < dmx.length; i ++ )
    dmxOutput.set(i+1, (255/reps) * r );
    delay(50);
  }
  delay(10000);
 
  //start again. 
  mainLoop.loop();
}
  
  
//this triggers the fader envelopes
void setBeam(int channel, boolean state)
{

  if ( beams[channel] != state )
  {
    println("set " + channel + " to " + state );
    beams[channel]=state;
    //increment beam counter at every beam break, to post to cosm.
    if (state)
    {
      sequence[seqNumber ++ % sequence.length]=channel;
      checkEaster();
      beamCounter[channel]++;
    }


    //define the triggers and fades
    ////////// 0
    if ( channel == 0 )
      if ( state )
      {
        playAudio(0);
        faders[0].fade(255, 100, 350);
        faders[1].fade(255, 100, 350);
        //spots to come on later
        faders[4].fade(255, 200, 150);
        faders[5].fade(255, 200, 150);
      }
      else
      {
        //all to come down slowly
        faders[0].release();
        faders[1].release();
        faders[4].release();
        faders[5].release();
      }
    /////////// 1
    if ( channel == 1 )
      if ( state )
      {
        playAudio(2);
        faders[0].fade(255, 100, 200);
        faders[2].fade(150, 200, 200);
        //spots to come on later
        faders[3].fade(255, 300, 100);
        faders[5].fade(255, 300, 50);
      }
      else
      {
        faders[0].release();
        faders[2].release();
        faders[3].release();
        faders[5].release();
      }
    /////////// 2
    if ( channel == 2 )
      if ( state )
      {
        faders[2].fade(255, 100, 500);
        faders[3].fade(255, 200, 150);
      }
      else
      {
        faders[2].release();
        faders[3].release();
      }

    /////////// 3
    if ( channel == 3 )
      if ( state )
      {
        playAudio(1);
        faders[1].fade(255, 100, 500);
      }
      else
      {
        faders[1].release();
      }

    ////////// 4
    if ( channel == 4 )
      if ( state )
      {
        playAudio(4);
        faders[0].fade(255, 100, 500);
      }
      else
      {
        faders[0].release();
      }

    ////////// 5
    if ( channel == 5 )
      if ( state )
      {
        playAudio(3);
        faders[4].fade(255, 100, 500);
      }
      else
      {
        faders[4].release();
      }
  }
}

void playAudio(int num)
{
  if ( ! useAudio )
    return;
  if ( num > 4 || num < 0 )
  {
    println( "no such sound");
    return;
  }

  if ( ! players[num].isPlaying() )     
  {
    println( num+" turn on audio");
    //have to rewind first
    players[num].rewind();
    players[num].play();
  }
}

public void controlEvent(ControlEvent theEvent) {
  for (int i=0;i<beams.length;i++) {
    if (theEvent.controller().name().equals("beam"+i)) {
      setBeam(i, true);
    }
  }
  println(
  "## controlEvent / id:"+theEvent.controller().id()+
    " / name:"+theEvent.controller().name()+
    " / label:"+theEvent.controller().label()+
    " / value:"+theEvent.controller().value()
    );
}

void stop()
{
  // always close Minim audio classes when you are done with them
  for ( int i =0; i < players.length; i ++)
    players[i].close();

  minim.stop();

  super.stop();
}

