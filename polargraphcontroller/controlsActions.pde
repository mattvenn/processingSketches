/**
  Polargraph controller
  Copyright Sandy Noble 2012.

  This file is part of Polargraph Controller.

  Polargraph Controller is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Polargraph Controller is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Polargraph Controller.  If not, see <http://www.gnu.org/licenses/>.
    
  Requires the excellent ControlP5 GUI library available from http://www.sojamo.de/libraries/controlP5/.
  Requires the excellent Geomerative library available from http://www.ricardmarxer.com/geomerative/.
  
  This is an application for controlling a polargraph machine, communicating using ASCII command language over a serial link.

  sandy.noble@gmail.com
  http://www.polargraph.co.uk/
  http://code.google.com/p/polargraph/
*/
void button_mode_begin()
{
  button_mode_clearQueue();
}
void numberbox_mode_changeGridSize(float value)
{
  setGridSize(value);
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
  }
}
void numberbox_mode_changeSampleArea(float value)
{
  setSampleArea(value);
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
  }
}
void minitoggle_mode_showImage(boolean flag)
{
  this.displayingImage = flag;
}
void minitoggle_mode_showVector(boolean flag)
{
  this.displayingVector = flag;
}
void minitoggle_mode_showDensityPreview(boolean flag)
{
  this.displayingDensityPreview = flag;
}
void minitoggle_mode_showQueuePreview(boolean flag)
{
  this.displayingQueuePreview = flag;
}
void minitoggle_mode_showGuides(boolean flag)
{
  this.displayingGuides = flag;
}
void unsetOtherToggles(String except)
{
  for (String name : getAllControls().keySet())
  {
    if (name.startsWith("toggle_"))
    {
      if (name.equals(except))
      {
//        println("not resetting this one.");
      }
      else
      {
        getAllControls().get(name).setValue(0);
      }
    }
  }
}
void toggle_mode_inputBoxTopLeft(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_INPUT_BOX_TOP_LEFT);
    setMode(MODE_INPUT_BOX_TOP_LEFT);
  }
  else
    currentMode = "";
}
void toggle_mode_inputBoxBotRight(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_INPUT_BOX_BOT_RIGHT);
    setMode(MODE_INPUT_BOX_BOT_RIGHT);
    // unset topleft
  }
  else
    currentMode = "";
}
void button_mode_drawOutlineBox()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
    sendOutlineOfBox();
}
void button_mode_drawOutlineBoxRows()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendOutlineOfRows(pixels, DRAW_DIR_SE);
  }
}
void button_mode_drawShadeBoxRowsPixels()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendOutlineOfPixels(pixels);
  }
}
void toggle_mode_drawToPosition(boolean flag)
{
  // unset other toggles
  if (flag)
  {
    unsetOtherToggles(MODE_DRAW_TO_POSITION);
    setMode(MODE_DRAW_TO_POSITION);
  }
}
void button_mode_renderSquarePixel()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendSquarePixels(pixels);
  }
}
void button_mode_renderSawPixel()
{
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendSawtoothPixels();
}
void button_mode_renderCirclePixel()
{
//  if (pixelCentresForMachine != null && !pixelCentresForMachine.isEmpty())
//    sendCircularPixels();
}
void button_mode_renderVectors()
{
  // turn off vector view and turn queue preview on
  minitoggle_mode_showVector(false);
  minitoggle_mode_showQueuePreview(true);
  sendVectorShapes();
}

void toggle_mode_setPosition(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_SET_POSITION);
    setMode(MODE_SET_POSITION);
  }
}
void button_mode_drawTestPattern()
{
  sendTestPattern();
}

void button_mode_drawGrid()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendGridOfBox(pixels);
  }
}
void button_mode_loadImage()
{
  if (getDisplayMachine().getImage() == null)
  {
    loadImageWithFileChooser();
    if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
    {
      getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    }
  }
  else
  {
    getDisplayMachine().setImage(null);
    getDisplayMachine().setImageFilename(null);
  }
}
void button_mode_loadVectorFile()
{
  if (getVectorShape() == null)
  {
    loadVectorWithFileChooser();
    minitoggle_mode_showVector(true);
  }
  else
  {
    vectorShape = null;
    vectorFilename = null;
  }
}
void numberbox_mode_pixelBrightThreshold(float value)
{
  pixelExtractBrightThreshold = int(value+0.5);
}
void numberbox_mode_pixelDarkThreshold(float value)
{
  pixelExtractDarkThreshold = int(value+0.5);
}

void button_mode_pauseQueue()
{
}
void button_mode_runQueue()
{
}
void button_mode_clearQueue()
{
  resetQueue();
}
void button_mode_setPositionHome()
{
  sendSetHomePosition();
}
void button_mode_drawTestPenWidth()
{
  sendTestPenWidth();
}
void button_mode_renderScaledSquarePixels()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendScaledSquarePixels(pixels);
  }
}
void button_mode_renderSolidSquarePixels()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendSolidSquarePixels(pixels);
  }
}
void button_mode_renderScribblePixels()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    // get the pixels
    Set<PVector> pixels = getDisplayMachine().extractNativePixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    sendScribblePixels(pixels);
  }
}
void button_mode_changeMachineSpec()
{
  sendMachineSpec();
}
void button_mode_requestMachineSize()
{
  sendRequestMachineSize();
}
void button_mode_resetMachine()
{
  sendResetMachine();
}
void button_mode_saveProperties()
{
  savePropertiesFile();
  // clear old properties.
  props = null;
  loadFromPropertiesFile();
}
void button_mode_saveAsProperties()
{
  saveNewPropertiesFileWithFileChooser();
}
void button_mode_loadProperties()
{
  loadNewPropertiesFilenameWithFileChooser();
}
void toggle_mode_moveImage(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_MOVE_IMAGE);
    setMode(MODE_MOVE_IMAGE);
  }
  else
  {
    setMode("");
  }
}

void toggle_mode_chooseChromaKeyColour(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_CHOOSE_CHROMA_KEY_COLOUR);
    setMode(MODE_CHOOSE_CHROMA_KEY_COLOUR);
  }
  else
    setMode("");
}

void button_mode_convertBoxToPictureframe()
{
  setPictureFrameDimensionsToBox();
}
void button_mode_selectPictureframe()
{
  setBoxToPictureframeDimensions();
}
void button_mode_exportQueue()
{
  exportQueueToFile();
}
void button_mode_importQueue()
{
  importQueueFromFile();
}
void toggle_mode_drawDirect(boolean flag)
{
  if (flag)
  {
    unsetOtherToggles(MODE_DRAW_DIRECT);
    setMode(MODE_DRAW_DIRECT);
  }
}

void numberbox_mode_resizeImage(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  Rectangle r = getDisplayMachine().getImageFrame();
  float ratio = r.getHeight() / r.getWidth();

  float oldSize = r.getSize().x;
  
  r.getSize().x = steps;
  r.getSize().y = steps * ratio;

  float difference = (r.getSize().x / 2.0)-(oldSize/2.0);
  r.getPosition().x -= difference;
  r.getPosition().y -= difference * ratio;
  
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), getSampleArea());
}

void numberbox_mode_resizeVector(float value)
{
  vectorScaling = value;
}
void toggle_mode_moveVector(boolean flag)
{
  // unset other toggles
  if (flag)
  {
    unsetOtherToggles(MODE_MOVE_VECTOR);
    setMode(MODE_MOVE_VECTOR);
  }
  else
  {
    setMode("");
  }
}

void numberbox_mode_changeMachineWidth(float value)
{
  clearBoxVectors();
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getSize().x = steps;
}
void numberbox_mode_changeMachineHeight(float value)
{
  clearBoxVectors();
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getSize().y = steps;
}
void numberbox_mode_changeMMPerRev(float value)
{
  clearBoxVectors();
  getDisplayMachine().setMMPerRev(value);
}
void numberbox_mode_changeStepsPerRev(float value)
{
  clearBoxVectors();
  getDisplayMachine().setStepsPerRev(value);
}
void numberbox_mode_changePageWidth(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().setWidth(steps);
}
void numberbox_mode_changePageHeight(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().setHeight(steps);
}
void numberbox_mode_changePageOffsetX(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().getTopLeft().x = steps;
}
void numberbox_mode_changePageOffsetY(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getDisplayMachine().getPage().getTopLeft().y = steps;
}
void button_mode_changePageOffsetXCentre()
{
  float pageWidth = getDisplayMachine().getPage().getWidth();
  float machineWidth = getDisplayMachine().getSize().x;
  float diff = (machineWidth - pageWidth) / 2.0;
  getDisplayMachine().getPage().getTopLeft().x = diff;
  initialiseNumberboxValues(getAllControls());
}

void numberbox_mode_changeHomePointX(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getHomePoint().x = steps;
}
void numberbox_mode_changeHomePointY(float value)
{
  float steps = getDisplayMachine().inSteps(value);
  getHomePoint().y = steps;
}
void button_mode_changeHomePointXCentre()
{
  float halfWay = getDisplayMachine().getSize().x / 2.0;
  getHomePoint().x = halfWay;
  getHomePoint().y = getDisplayMachine().getPage().getTop();
  initialiseNumberboxValues(getAllControls());
}


void numberbox_mode_changePenWidth(float value)
{
  currentPenWidth =  Math.round(value*100.0)/100.0;
}
void button_mode_sendPenWidth()
{
  NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
  DecimalFormat df = (DecimalFormat)nf;  
  df.applyPattern("###.##");
  realtimeCommandQueue.add(CMD_CHANGEPENWIDTH+df.format(currentPenWidth)+",END");
}  

void numberbox_mode_changePenTestStartWidth(float value)
{
  testPenWidthStartSize = Math.round(value*100.0)/100.0;
}
void numberbox_mode_changePenTestEndWidth(float value)
{
  testPenWidthEndSize = Math.round(value*100.0)/100.0;
}
void numberbox_mode_changePenTestIncrementSize(float value)
{
  testPenWidthIncrementSize = Math.round(value*100.0)/100.0;
}

void numberbox_mode_changeMachineMaxSpeed(float value)
{
  currentMachineMaxSpeed =  Math.round(value*100.0)/100.0;
}
void numberbox_mode_changeMachineAcceleration(float value)
{
  currentMachineAccel =  Math.round(value*100.0)/100.0;
}
void button_mode_sendMachineSpeed()
{
  NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
  DecimalFormat df = (DecimalFormat)nf;  

  df.applyPattern("###.##");
  realtimeCommandQueue.add(CMD_SETMOTORSPEED+df.format(currentMachineMaxSpeed)+",END");

  df.applyPattern("###.##");
  realtimeCommandQueue.add(CMD_SETMOTORACCEL+df.format(currentMachineAccel)+",END");
}

void setMode(String m)
{
  lastMode = currentMode;
  currentMode = m;
}
void revertToLastMode()
{
  currentMode = lastMode;
}

/*------------------------------------------------------------------------
    Details about the "serial port" subwindow
------------------------------------------------------------------------*/

void button_mode_serialPortDialog()
{
  ControlWindow serialPortWindow = cp5.addControlWindow("changeSerialPortWindow",100,100,150,150);
  serialPortWindow.hideCoordinates();
  
  serialPortWindow.setBackground(getBackgroundColour());
  Radio r = cp5.addRadio("radio_serialPort",10,10);

  if (getSerialPortNumber() >= 0)
    r.setValue(getSerialPortNumber());
    
  r.add("setup", -2);
  r.add("No serial connection", -1);
  
  String[] ports = Serial.list();
  for (int i = 0; i < ports.length; i++)
  {
    r.add(ports[i], i);
  }
  
  int portNo = getSerialPortNumber();
  if (portNo > -1)
    r.activate(ports[portNo]);
  else
    r.activate("No serial connection");
    
  r.removeItem("setup");
  r.setWindow(serialPortWindow);
}

void radio_serialPort(int newSerialPort) 
{
  if (newSerialPort == -2)
  {
  }
  else if (newSerialPort == -1)
  {
    println("Disconnecting serial port.");
    useSerialPortConnection = false;
    if (myPort != null)
    {
      myPort.stop();
      myPort = null;
    }
    drawbotReady = false;
    drawbotConnected = false;
    serialPortNumber = newSerialPort;
  }
  else if (newSerialPort != getSerialPortNumber())
  {
    println("About to connect to serial port in slot " + newSerialPort);
    // Print a list of the serial ports, for debugging purposes:
    if (newSerialPort < Serial.list().length)
    {
      try 
      {
        drawbotReady = false;
        drawbotConnected = false;
        if (myPort != null)
        {
          myPort.stop();
          myPort = null;
        }
        if (getSerialPortNumber() >= 0)
          println("closing " + Serial.list()[getSerialPortNumber()]);
        
        serialPortNumber = newSerialPort;
        String portName = Serial.list()[serialPortNumber];
  
        myPort = new Serial(this, portName, 57600);
        //read bytes into a buffer until you get a linefeed (ASCII 10):
        myPort.bufferUntil('\n');
        useSerialPortConnection = true;
        println("Successfully connected to port " + portName);
      }
      catch (Exception e)
      {
        println("Attempting to connect to serial port in slot " + getSerialPortNumber() 
        + " caused an exception: " + e.getMessage());
      }
    }
    else
    {
      println("No serial ports found.");
      useSerialPortConnection = false;
    }
  }
  else
  {
    println("no serial port change.");
  }
}


/*------------------------------------------------------------------------
    Details about the "machine store" subwindow
------------------------------------------------------------------------*/

ControlWindow dialogWindow = null;

void button_mode_machineStoreDialog()
{
  this.dialogWindow = cp5.addControlWindow("chooseStoreFilenameWindow",100,100,450,150);
  dialogWindow.hideCoordinates();
  
  dialogWindow.setBackground(getBackgroundColour());

  Textfield filenameField = cp5.addTextfield("storeFilename",20,20,150,20);
  filenameField.setText(getStoreFilename());
  filenameField.setLabel("Filename to store to");
  filenameField.setWindow(dialogWindow);

  Button submitButton = cp5.addButton("submitStoreFilenameWindow",0,180,20,60,20);
  submitButton.setLabel("Submit");
  submitButton.setWindow(dialogWindow);

  Toggle overwriteToggle = cp5.addToggle("toggleAppendToFile",true,180,50,20,20);
  overwriteToggle.setCaptionLabel("Overwrite existing file");
  overwriteToggle.setWindow(dialogWindow);

  filenameField.setFocus(true);

}

void storeFilename(String filename)
{
  println("Filename event: "+ filename);
  if (filename != null && filename.length() <= 12)
  {
    setStoreFilename(filename);
    sendMachineStoreMode();
  }
}

void toggleAppendToFile(boolean theFlag) 
{
  setOverwriteExistingStoreFile(theFlag);
}

void submitStoreFilenameWindow(int theValue) 
{
  Textfield tf = (Textfield) cp5.controller("storeFilename");
  tf.submit();
}

void button_mode_machineExecDialog()
{
  this.dialogWindow = cp5.addControlWindow("chooseExecFilenameWindow",100,100,450,150);
  dialogWindow.hideCoordinates();
  
  dialogWindow.setBackground(getBackgroundColour());

  Textfield filenameField = cp5.addTextfield("execFilename",20,20,150,20);
  filenameField.setText(getStoreFilename());
  filenameField.setLabel("Filename to execute from");
  filenameField.setWindow(dialogWindow);

  Button submitButton = cp5.addButton("submitExecFilenameWindow",0,180,20,60,20);
  submitButton.setLabel("Submit");
  submitButton.setWindow(dialogWindow);

  filenameField.setFocus(true);

}

void execFilename(String filename)
{
  println("Filename event: "+ filename);
  if (filename != null && filename.length() <= 12)
  {
    setStoreFilename(filename);
    sendMachineExecMode();
  }
}
void submitExecFilenameWindow(int theValue) 
{
  Textfield tf = (Textfield) cp5.controller("execFilename");
  tf.submit();
}

void button_mode_sendMachineLiveMode()
{
  sendMachineLiveMode();
}





/*------------------------------------------------------------------------
    Details about the "drawing" subwindow
------------------------------------------------------------------------*/
void button_mode_drawPixelsDialog()
{
  this.dialogWindow = cp5.addControlWindow("drawPixelsWindow",100,100,450,150);
  dialogWindow.hideCoordinates();
  
  dialogWindow.setBackground(getBackgroundColour());

  Radio rPos = cp5.addRadio("radio_startPosition",10,10);
  rPos.add("Top-right", DRAW_DIR_NE);
  rPos.add("Bottom-right", DRAW_DIR_SE);
  rPos.add("Bottom-left", DRAW_DIR_SW);
  rPos.add("Top-left", DRAW_DIR_NW);
  rPos.setWindow(dialogWindow);

  Radio rSkip = cp5.addRadio("radio_pixelSkipStyle",10,80);
  rSkip.add("Lift pen over masked pixels", 1);
  rSkip.add("Draw masked pixels as blanks", 2);
  rSkip.setWindow(dialogWindow);

//  Radio rDir = cp5.addRadio("radio_rowStartDirection",100,10);
//  rDir.add("Upwards", 0);
//  rDir.add("Downwards", 1);
//  rDir.setWindow(dialogWindow);

  Radio rStyle = cp5.addRadio("radio_pixelStyle",100,10);
  rStyle.add("Variable frequency square wave", PIXEL_STYLE_SQ_FREQ);
  rStyle.add("Variable size square wave", PIXEL_STYLE_SQ_SIZE);
  rStyle.add("Solid square wave", PIXEL_STYLE_SQ_SOLID);
  rStyle.add("Scribble", PIXEL_STYLE_SCRIBBLE);
  if (currentHardware >= HARDWARE_VER_MEGA)
  {
    rStyle.add("Circles", PIXEL_STYLE_CIRCLE);
    rStyle.add("Sawtooth", PIXEL_STYLE_SAW);
  }
  rStyle.setWindow(dialogWindow);

  Button submitButton = cp5.addButton("submitDrawWindow",0,280,10,120,20);
  submitButton.setLabel("Generate commands");
  submitButton.setWindow(dialogWindow);
  

}

public Integer renderStartPosition = DRAW_DIR_NE; // default top right hand corner for start
public Integer renderStartDirection = DRAW_DIR_SE; // default start drawing in SE direction (DOWN)
public Integer renderStyle = PIXEL_STYLE_SQ_FREQ; // default pixel style square wave
void radio_startPosition(int pos)
{
  this.renderStartPosition = pos;
  radio_rowStartDirection(1);
}
void radio_rowStartDirection(int dir)
{
  if (renderStartPosition == DRAW_DIR_NE || renderStartPosition == DRAW_DIR_SW)
    renderStartDirection = (dir == 0) ? DRAW_DIR_NW : DRAW_DIR_SE;
  else if (renderStartPosition == DRAW_DIR_SE || renderStartPosition == DRAW_DIR_NW)
    renderStartDirection = (dir == 0) ? DRAW_DIR_NE : DRAW_DIR_SW;
}
void radio_pixelStyle(int style)
{
  renderStyle = style;
}
void radio_pixelSkipStyle(int style)
{
  if (style == 1)
    liftPenOnMaskedPixels = true;
  else if (style == 2)
    liftPenOnMaskedPixels = false;
}
void submitDrawWindow(int theValue) 
{
  println("draw.");
  println("Style: " + renderStyle);
  println("Start pos: " + renderStartPosition);
  println("Start dir: " + renderStartDirection);
 
  switch (renderStyle)
  {
    case PIXEL_STYLE_SQ_FREQ: button_mode_renderSquarePixel(); break;
    case PIXEL_STYLE_SQ_SIZE: button_mode_renderScaledSquarePixels(); break;
    case PIXEL_STYLE_SQ_SOLID: button_mode_renderSolidSquarePixels(); break;
    case PIXEL_STYLE_SCRIBBLE: button_mode_renderScribblePixels(); break;
    case PIXEL_STYLE_CIRCLE: button_mode_renderCirclePixel(); break;
    case PIXEL_STYLE_SAW: button_mode_renderSawPixel(); break;
  }
  
   
}




