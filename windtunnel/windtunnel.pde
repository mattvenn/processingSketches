/* these are the things you may need to edit */
String school = "test";
int powerBarMax = 50; //mw
int speedBarMax = 2500; //rpm

import ddf.minim.*;

import fullscreen.*; 
import processing.serial.*;
import controlP5.*;
import de.bezier.data.sql.*;
import gnu.io.CommPortIdentifier;

FullScreen fs; 
//change at startup



ControlP5 controlP5;
Serial myPort;  // Create object from Serial class
int encoder, voltage, current;
Slider knobSlider, powerSlider, highPowerSlider, speedSlider, highSpeedSlider;
static int highScoreRows = 15;

//Textfield teamNameField;
Textfield schoolNameField;
Textlabel teamScoreLabel;
Textlabel highScores [][] = new Textlabel[highScoreRows][4];  //plus 1 for the header
int [] highScoreIds = new int[highScoreRows];
//samples
AudioSample unsafeSound, safeSound, startSound, stopSound;
Minim minim;

double rawTurbineTacho;
int rawTurbineVoltage;
float LOAD = 26.8; // 0.22; //ohms
float highPower = 0;
float highSpeed = 0;
int lf = 10;
MySQL dbconnection;

//global state
String state = "";


float latestPower;
float latestSpeed;
float highestSpeed;
float highestPower;
int lastHighScoreID;

void setup() 
{
  size(1280,800,P2D);
  // size(1024,768,P2D);
  fs = new FullScreen(this); 
  println( "sounds:" );
  minim = new Minim(this);

  startSound = minim.loadSample("start.wav", 2048);
  if ( startSound == null ) println("start");
  stopSound = minim.loadSample("stop.wav", 2048);
  if( stopSound == null ) println( "stop.wav" );
  unsafeSound = minim.loadSample( "unsafe.wav", 2048);
  if( unsafeSound == null ) println( "unsafe.wav" );
  safeSound = minim.loadSample("safe.wav", 2048);
  if( safeSound == null ) println( "safe.wav" );
  println( "ok" );

  println( "setup:" );
  println( "db connection" );

  //problem with alt-tabbing which leaves controlp5 in command mode. so, we trap alt key presses
  //  Keyboard k = new Keyboard(); 
  // KeyboardFocusManager.getCurrentKeyboardFocusManager().addKeyEventDispatcher( k ); 

  //db connection
  String user     = "wind";
  String pass     = "wind";
  String database = "windturbines";
  dbconnection = new MySQL( this, "localhost", database, user, pass );
  println("ok");

  // serial stuff ***************************************
  println( "serial connection" );

  try
  {  
    String portName = Serial.list()[0];
    println( portName );
    if( ! portName.contains( "USB" ) )
    {
      println( "bad port, is /dev/ttyUSB already in use?" );
      System.exit(1);
    }
    try
    {
      CommPortIdentifier portIdentifier = CommPortIdentifier.getPortIdentifier(portName);
      if ( portIdentifier.isCurrentlyOwned() )
      {
        println("Error: Port is currently in use");
        System.exit(1);
      }
    }
    catch( Exception e )
    {
      println( "no such port" );
      System.exit(1);
    } 
    myPort = new Serial(this, portName, 115200);

    //empty the port
    while( myPort.available() > 0 )
    {
      int buff = myPort.read();
    }
  } 
  catch ( ArrayIndexOutOfBoundsException e )
  {
    println( "no serial ports found!" );
    System.exit(1);
  }
  println("ok");


  // UI stuff ****************************************
  println( "p5 controls" );
  controlP5 = new ControlP5(this);
  controlP5.Label label;
  int voltageColor = color( 150, 0, 0 );
  int knobColor = color( 0, 150, 0 );



  int xSpace, xSpacing, xInit, yInit,barWidth,barHeight;
  xSpace = 0;
  xSpacing = 220;
  xInit = 30;
  yInit = 50;

  //slider stuff ****************************************
  barWidth = 145;
  int highScoreWidth = 50;
  barHeight = 600;
  int highScoreColour = color( 0, 150, 0 );

  knobSlider = controlP5.addSlider("knob",0,100,0,xInit + xSpace,yInit,barWidth,barHeight);
  knobSlider.setNumberOfTickMarks(10);
  knobSlider.snapToTickMarks( false );
  knobSlider.moveTo( "data" );
  label = knobSlider.captionLabel();
  label.style().marginTop = 4;
  label.set( "wind speed (%)" );
  label.setControlFont(new ControlFont(createFont("Times",20),20));
  label = knobSlider.valueLabel();    
  label.style().marginLeft = -barWidth;
  label.style().marginTop = - 10;
  label.setControlFont(new ControlFont(createFont("Times",20),20));

  xSpace += xSpacing;


  highSpeedSlider = controlP5.addSlider("highspeed",0, speedBarMax,0,xInit + xSpace,yInit,highScoreWidth,barHeight);
  highSpeedSlider.moveTo("data");
  highSpeedSlider.setColorBackground( 0 );
  highSpeedSlider.setColorForeground( highScoreColour );
  xSpace += highScoreWidth;

  speedSlider = controlP5.addSlider("speed",0, speedBarMax,0,xInit + xSpace,yInit,barWidth,barHeight);
  speedSlider.setNumberOfTickMarks(10);
  speedSlider.snapToTickMarks( false );
  speedSlider.moveTo("data");
  label = speedSlider.captionLabel();
  label.set( "speed (rpm)" );
  label.style().marginTop = 4;
  label.setControlFont(new ControlFont(createFont("Times",20),20));
  label = speedSlider.valueLabel();    
  label.style().marginLeft = -barWidth;
  label.style().marginTop = - 10;
  label.setControlFont(new ControlFont(createFont("Times",20),20));

  xSpace += xSpacing;

  highPowerSlider = controlP5.addSlider("highpower",0, powerBarMax,0,xInit + xSpace,yInit,highScoreWidth,barHeight);
  highPowerSlider.setColorBackground( 0 );
  highPowerSlider.moveTo( "data");
  highPowerSlider.setColorForeground( highScoreColour );
  xSpace += highScoreWidth;

  powerSlider = controlP5.addSlider("power",0, powerBarMax,0,xInit + xSpace,yInit,barWidth,barHeight);
  powerSlider.setNumberOfTickMarks(10);
  powerSlider.snapToTickMarks( false );
  powerSlider.moveTo( "data");
  label = powerSlider.captionLabel();
  label.style().marginTop = 4;
  label.toUpperCase( false );
  label.set( "POWER (mW)" );
  label.setControlFont(new ControlFont(createFont("Times",20),20));
  label = powerSlider.valueLabel();    
  label.style().marginLeft = -barWidth;
  label.style().marginTop = - 10;
  label.setControlFont(new ControlFont(createFont("Times",20),20));


  // save your name stuff *************************

  teamScoreLabel = controlP5.addTextlabel( "teamScore", "init", 150, 40 );
  //  teamScoreLabel.moveTo( "saveScore" );
  teamScoreLabel.hide();
  label = teamScoreLabel.valueLabel();    
  label.setControlFont(new ControlFont(createFont("Times",40),40));    

  schoolNameField = controlP5.addTextfield("saveSchoolName",100,160,300,40);
  schoolNameField.moveTo( "schoolName" );
  label = schoolNameField.valueLabel();
  label.setControlFont(new ControlFont(createFont("Times",30),30));
  label.set( school );
  label = schoolNameField.captionLabel();
  label.set( "type the new school/class name" );
  label.setControlFont(new ControlFont(createFont("Times",20),20));

  /*
  teamNameField = controlP5.addTextfield("saveTeamName",100,160,300,40);
   teamNameField.moveTo( "saveScore" );
   
   label = teamNameField.captionLabel();
   label.set( "type your teamname" );
   label.setControlFont(new ControlFont(createFont("Times",20),20));
   
   label = teamNameField.valueLabel();    
   label.setControlFont(new ControlFont(createFont("Times",30),30));
   */
  //high score table stuff ****************************
  yInit = 80;
  xInit = 150;
  int xWidth;
  println( "creating high score table" );
  for( int row = 0; row < highScoreRows; row ++ )
  {
    xWidth = xInit;
    for( int column = 0; column < 4 ; column ++ )
    {

      highScores[row][column] = controlP5.addTextlabel("label_" + row + "_" + column,"-", xWidth, yInit + row * 40); 
      if( column == 0 )
        highScores[row][column].setValue( "" );
      label =  highScores[row][column].valueLabel();
      label.setControlFont(new ControlFont(createFont("Times",23),23));
      label.setColor( color( 0, 255, row * (200 / highScoreRows ) )  );

      if( row == 0 )
        label.setColor( color( 255,255,255) );

      //custom column width for #

      if( column == 0 )
        xWidth += 50;   
      else
        xWidth += 150;
      /* //name
       else if( column == 1 )
       xWidth += 250;      
       else
       xWidth += 150;*/
    }
  }
  println("ok");
  print( "loading high score table" );
  loadHighScoreTable();
  println("ok" );
  println( "finished" );

  controlP5.tab( "schoolName" ).setActive( true );
  controlP5.tab( "default" ).setActive( false );
  //enter fullscreen mode
  // fs.enter();
}

void stop()
{
  // always close Minim audio classes when you are done with them
  startSound.close();
  stopSound.close();
  unsafeSound.close();
  minim.stop();
}
void draw()
{
  background( 0 );
  controlP5.draw() ;

  //this blocks till a full line is read or for some time
  String buff = getLineFromSerialPort();
  if( buff.equals( "" ) )
  {
    //do nothing
  }
  else
  {
    if( buff.startsWith( "state" ) )
    {
      String []list = split(buff, ':' );
      state = list[1];
      if( state.equals( "running" ) )
      {
        state = "running";

        String values = getLineFromSerialPort();
        readValues( values );
        doCalcs();
      } 
      if( state.equals( "off" ) || state.equals( "unsafe" ) )
      {
        if( state.equals( "off" ) )
          stopSound.trigger();
        if( state.equals( "unsafe" ) )
          unsafeSound.trigger();

        if( highSpeed != 0 )
        {
          controlP5.tab( "data" ).setActive( false );
          //            controlP5.tab( "saveScore" ).setActive( true );
          controlP5.tab( "default" ).setActive( true );
          if( state.equals( "off" ))
            saveScores( );

          loadHighScoreTable();
          //            teamNameField.setFocus(true);
          loadPositionInHighScoreTable();
        }
        else
        {
          controlP5.tab( "data" ).setActive( false );
          //            controlP5.tab( "saveScore" ).setActive( false );
          controlP5.tab( "default" ).setActive( true );
        }
      }
      else if( state.equals( "on" ) )
      {

        startSound.trigger();
        println( "on" );
        controlP5.tab( "data" ).setActive( true );
        controlP5.tab( "default" ).setActive( false );
        //        controlP5.tab( "saveScore" ).setActive( false );

        loadHighestValues();
        highPower = 0;
        highSpeed = 0;
        teamScoreLabel.hide();
      }
      else if( state.equals( "safe" ) )
      {
        safeSound.trigger();
      }
    }
    else
    {
      println( "got unexpected data from serial: " + buff );
    }
  }
}
public void saveSchoolName(String schoolName)
{
  println( schoolName ); 
  school = schoolName;
  loadHighScoreTable();
  controlP5.tab( "default" ).setActive( true );
  controlP5.tab( "schoolName" ).setActive( false );
}
/*
public void saveTeamName(String teamName) {
 // receiving text from controller texting 
 if( teamName.length() > 15 )
 teamName = teamName.substring( 0, 15 );
 
 println( "save" );
 saveScores( teamName );
 println( "loading scores" );
 loadHighScoreTable();
 
 controlP5.tab( "data" ).setActive( false );
 controlP5.tab( "saveScore" ).setActive( false );
 controlP5.tab( "default" ).setActive( true );
 
 }
 */
void saveScores( )
{
  if ( dbconnection.connect() )
  {    

    String insert =  "insert into highscores ( school, highspeed, highpower ) values ( '" + school + "', " + highSpeed + ", " + highPower + ");";
    println( insert );
    dbconnection.execute( insert );         
    String getId = "select last_insert_id() as id";
    dbconnection.query( getId );
    while (dbconnection.next())
    {
      lastHighScoreID = dbconnection.getInt( "id" );
    }
    println( "last score id = " + lastHighScoreID );
  }
  else
  {
    // connection failed !
    println( "failed" );
  }
}


void loadPositionInHighScoreTable()
{
  if ( dbconnection.connect() )
  {
    dbconnection.query( "select count(id) as count from highscores where highpower >= " + highPower + "and school = '" + school + "';"  );
    println( "select count(id) as count from highscores where highpower >= " + highPower + "and school = '" + school + "';" );
    while (dbconnection.next())
    {
      teamScoreLabel.setValue( "You came number " + ( dbconnection.getInt( "count" )  ) );
      teamScoreLabel.show(  );
    }
  }
}


void loadHighScoreTable()
{
  if ( dbconnection.connect() )
  {
    String query = "select id, time, highspeed, highpower from highscores where school = '" + school + "' order by highpower desc limit " + (highScoreRows - 1) + ";";
    println( query );
    dbconnection.query( query ) ;



    int rows = 0; 
    highScores[rows][1].setValue( "#" );
    //    highScores[row][1].setValue( "teamname" );
    //    highScores[row][2].setValue( "school" );
    highScores[rows][2].setValue( "power (mW)" );
    highScores[rows][3].setValue( "tries" );

    for( int row = 1; row < highScoreRows; row ++ )
    {
      highScores[row][1].setValue("-");
      highScores[row][2].setValue("-");
      highScores[row][3].setValue("-");
    }

    // String [] names = new String [highScoreRows];
    String [] timestamps = new String [highScoreRows];

    while (dbconnection.next())
    {
      rows ++;
      highScores[rows][1].setValue( Integer.toString( rows ) );
      // highScores[row][1].setValue( dbconnection.getString( "name" ) );
      // highScores[row][2].setValue( dbconnection.getString( "school" ) );
      highScores[rows][2].setValue( Float.toString( dbconnection.getFloat("highpower") ) );
      //      names[row] = dbconnection.getString( "name" );
      highScoreIds[rows] = dbconnection.getInt("id" );
      timestamps[rows] = dbconnection.getString( "time" );

      //      highScores[row][4].setValue( Float.toString( dbconnection.getFloat("highpower") ) );
    }

    //get # of attempts

    for( int highscore = 1; highscore <= rows ; highscore ++ )
    {
      if( highScoreIds[highscore] == lastHighScoreID )
        highScores[highscore][0].setValue( ">>" );
      else
        highScores[highscore][0].setValue( "" );
      query = "select count(id) as tries from highscores where school = '" + school + "' and time < '" + timestamps[highscore] + "';";
      // println( query );
      dbconnection.query( query );
      if(dbconnection.next())
      {
        highScores[highscore][3].setValue( Integer.toString( 1 + dbconnection.getInt( "tries" ) ) );
      }
      else
      {
        highScores[highscore][3].setValue( 1 );
      }
    }
  }
  else
  {
    // connection failed !
    println( "failed" );
  }
}


void loadHighestValues()
{
  //high scores
  if ( dbconnection.connect() )
  {
    dbconnection.query( "select highspeed, highpower from highscores where school = '" + school + "'order by highpower desc limit 1;"  );
    while (dbconnection.next())
    {
      //      println( dbconnection.getFloat("highspeed") );
      //      println( dbconnection.getFloat("highpower") );
      highestSpeed = dbconnection.getFloat("highspeed");
      highestPower = dbconnection.getFloat("highpower");
      highSpeedSlider.setValue( highestSpeed );
      highPowerSlider.setValue( highestPower );
    }
  }
  else
  {
    // connection failed !
    println( "failed" );
  }
}
//calcs
void doCalcs()
{
  float voltage, power;
  Double speed = new Double("0.0");
  speed = rawTurbineTacho;

  //fix the voltage to the speed if the voltage is broken
  // voltage = (float)(speed / 1000.0);
  // println( rawTurbineVoltage );
  //p=iv, i=v/r so p = (v*v)/r
  //voltage *= 10;
  //get voltage in real terms
  voltage = (float)rawTurbineVoltage / ( 1024 / 5 );
  power = ( voltage * voltage )/LOAD;
  power *= 1000; //mw

  //update display
  if( speed.floatValue() > highSpeed )
  {
    highSpeed = speed.floatValue();
    if( highSpeed > highestSpeed )
    {
      highestSpeed = highSpeed;
      highSpeedSlider.setValue( highSpeed );
    }
  }
  if( power > highPower )
  {
    highPower = power;
    if( highPower > highestPower )
    {
      highestPower = highPower;
      highPowerSlider.setValue( highPower );
    }
  }

  knobSlider.setValue( encoder * ( 100.0 / 255.0 ));
  speedSlider.setValue( speed.floatValue() );
  powerSlider.setValue( power );

  latestPower = power;
  latestSpeed = speed.floatValue();
}

void readValues( String buff )
{
  String []list = split(buff, ',' );

  if( list.length == 3 )
  {
    try
    {
      encoder = Integer.parseInt(list[0]);
      rawTurbineTacho = Double.parseDouble(list[1]);
      rawTurbineVoltage = Integer.parseInt(list[2]);
    }
    catch( NumberFormatException e )
    {
      //write off that read
      println( "bad number format" );
    }
  }
  else
  {
    println( "wrong number of values in list" );
  }
}
/*
class Keyboard implements KeyEventDispatcher 
 { 
 Keyboard() 
 { } 
 
 public boolean dispatchKeyEvent( KeyEvent ke ) 
 { 
 int kc = ke.getKeyCode();
 if ( kc == 18 )  //18 = Alt key
 {
 return true;
 }
 else {
 return false;  //retarget key event to application
 }
 } 
 } 
 */

//will block for 100ms
String getLineFromSerialPort()
{


  String buff = null;
  int loop = 0;
  try
  {
    while( buff == null && loop < 10)
    {
      buff = myPort.readStringUntil(lf);
      loop ++;
      delay( 10 );
    }
    if( loop == 10 )
    {         
      //println( "gave up waiting for serial" );
      return "";
    }
  }
  catch(NullPointerException e )
  {
    println( "null pointer reading from port" );
  }
  buff = trim( buff );
  println( buff ); 
  return buff;
}


