import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;
import java.util.zip.CRC32;

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

  2012-04-08 Changed serial comms to use a checksum CRC to verify instead of repeat-and-confirm.  
  2012-04-09 Added feature to lift pen while moving over skipped pixels.
*/
import javax.swing.*;
import processing.serial.*;
import controlP5.*;
import java.awt.event.*;

int majorVersionNo = 1;
int minorVersionNo = 1;
int buildNo = 6;

String programTitle = "Polargraph Controller v" + majorVersionNo + "." + minorVersionNo + " build " + buildNo;
ControlP5 cp5;

boolean drawbotReady = false;
boolean drawbotConnected = false;

static final int HARDWARE_VER_UNO = 1;
static final int HARDWARE_VER_MEGA = 100;
int currentHardware = HARDWARE_VER_UNO;

final int HARDWARE_ATMEGA328_SRAM = 2048;
final int HARDWARE_ATMEGA1280_SRAM = 8096;
int currentSram = HARDWARE_ATMEGA328_SRAM;

//Machine machine = new Machine(5000, 5000, 800.0, 95.0);
String newMachineName = "PGXXABCD";
PVector machinePosition = new PVector(130.0, 50.0);
float machineScaling = 1.0;
DisplayMachine displayMachine = null;

int homeALengthMM = 400;
int homeBLengthMM = 400;

final String PRESET_A3_SHORT = "A3SHORT";
final String PRESET_A3_LONG = "A3LONG";
final String PRESET_A2_SHORT = "A2SHORT";
final String PRESET_A2_LONG = "A2LONG";
final String PRESET_A2_IMP_SHORT = "A2+SHORT";
final String PRESET_A2_IMP_LONG = "A2+LONG";
final String PRESET_A1_SHORT = "A1SHORT";
final String PRESET_A1_LONG = "A1LONG";

final int A3_SHORT = 297;
final int A3_LONG = 420;
final int A2_SHORT = 418;
final int A2_LONG = 594;
final int A2_IMP_SHORT = 450;
final int A2_IMP_LONG = 640;
final int A1_SHORT = 594;
final int A1_LONG = 841;

int leftEdgeOfQueue = 800;
int rightEdgeOfQueue = 1100;
int topEdgeOfQueue = 0;
int bottomEdgeOfQueue = 0;
int queueRowHeight = 15;


Serial myPort;                       // The serial port
int[] serialInArray = new int[1];    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive

final JFileChooser chooser = new JFileChooser();

SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yy hh:mm:ss");

String commandStatus = "Waiting for a click.";

float sampleArea = 10;
float gridSize = 75.0;
float currentPenWidth = 0.8;
float penIncrement = 0.05;

float currentMachineMaxSpeed = 600.0;
float currentMachineAccel = 400.0;
float MACHINE_ACCEL_INCREMENT = 25.0;
float MACHINE_MAXSPEED_INCREMENT = 25.0;

List<String> commandQueue = new ArrayList<String>();
List<String> realtimeCommandQueue = new ArrayList<String>();
List<String> commandHistory = new ArrayList<String>();

String lastCommand = "";
String lastDrawingCommand = "";
Boolean commandQueueRunning = false;
static final int DRAW_DIR_NE = 1;
static final int DRAW_DIR_SE = 2;
static final int DRAW_DIR_SW = 3;
static final int DRAW_DIR_NW = 4;
static final int DRAW_DIR_N = 5;
static final int DRAW_DIR_E = 6;
static final int DRAW_DIR_S = 7;
static final int DRAW_DIR_W = 8;

static final int DRAW_DIR_MODE_AUTO = 1;
static final int DRAW_DIR_MODE_PRESET = 2;
static final int DRAW_DIR_MODE_RANDOM = 3;
static int pixelDirectionMode = DRAW_DIR_MODE_PRESET;

static final int PIXEL_STYLE_SQ_FREQ = 0;
static final int PIXEL_STYLE_SQ_SIZE = 1;
static final int PIXEL_STYLE_SQ_SOLID = 2;
static final int PIXEL_STYLE_SCRIBBLE = 3;
static final int PIXEL_STYLE_CIRCLE = 4;
static final int PIXEL_STYLE_SAW = 5;


PVector currentMachinePos = new PVector();
PVector currentCartesianMachinePos = new PVector();
int machineAvailMem = 0;
int machineUsedMem = 0;
int machineMinAvailMem = 2048;


//String testPenWidthCommand = "TESTPENWIDTHSCRIBBLE,";
String testPenWidthCommand = CMD_TESTPENWIDTHSQUARE;
float testPenWidthStartSize = 0.5;
float testPenWidthEndSize = 2.0;
float testPenWidthIncrementSize = 0.5;

int maxSegmentLength = 2;

static final String MODE_BEGIN = "button_mode_begin";
static final String MODE_DRAW_OUTLINE_BOX = "button_mode_drawOutlineBox";
static final String MODE_DRAW_OUTLINE_BOX_ROWS = "button_mode_drawOutlineBoxRows";
static final String MODE_DRAW_SHADE_BOX_ROWS_PIXELS = "button_mode_drawShadeBoxRowsPixels";
static final String MODE_RENDER_SQUARE_PIXELS = "button_mode_renderSquarePixel";
static final String MODE_RENDER_SAW_PIXELS = "button_mode_renderSawPixel";
static final String MODE_RENDER_CIRCLE_PIXELS = "button_mode_renderCirclePixel";
static final String MODE_RENDER_PIXEL_DIALOG = "button_mode_drawPixelsDialog";

static final String MODE_INPUT_ROW_START = "button_mode_inputRowStart";
static final String MODE_INPUT_ROW_END = "button_mode_inputRowEnd";
static final String MODE_DRAW_TESTPATTERN = "button_mode_drawTestPattern";
static final String MODE_INC_ROW_SIZE = "button_mode_incRowSize";
static final String MODE_DEC_ROW_SIZE = "button_mode_decRowSize";
static final String MODE_DRAW_GRID = "button_mode_drawGrid";
static final String MODE_PLACE_IMAGE = "button_mode_placeImage";
static final String MODE_LOAD_IMAGE = "button_mode_loadImage";
static final String MODE_PAUSE_QUEUE = "button_mode_pauseQueue";
static final String MODE_RUN_QUEUE = "button_mode_runQueue";
static final String MODE_SET_POSITION_HOME = "button_mode_setPositionHome";
static final String MODE_INPUT_SINGLE_PIXEL = "button_mode_inputSinglePixel";
static final String MODE_DRAW_TEST_PENWIDTH = "button_mode_drawTestPenWidth";
static final String MODE_RENDER_SCALED_SQUARE_PIXELS = "button_mode_renderScaledSquarePixels";
static final String MODE_RENDER_SOLID_SQUARE_PIXELS = "button_mode_renderSolidSquarePixels";
static final String MODE_RENDER_SCRIBBLE_PIXELS = "button_mode_renderScribblePixels";
static final String MODE_CHANGE_MACHINE_SPEC = "button_mode_changeMachineSpec";
static final String MODE_REQUEST_MACHINE_SIZE = "button_mode_requestMachineSize";
static final String MODE_RESET_MACHINE = "button_mode_resetMachine";

static final String MODE_SAVE_PROPERTIES = "button_mode_saveProperties";
static final String MODE_SAVE_AS_PROPERTIES = "button_mode_saveAsProperties";
static final String MODE_LOAD_PROPERTIES = "button_mode_loadProperties";

static final String MODE_INC_SAMPLE_AREA = "button_mode_incSampleArea";
static final String MODE_DEC_SAMPLE_AREA = "button_mode_decSampleArea";
static final String MODE_INPUT_IMAGE = "button_mode_inputImage";
static final String MODE_IMAGE_PIXEL_BRIGHT_THRESHOLD = "numberbox_mode_pixelBrightThreshold";
static final String MODE_IMAGE_PIXEL_DARK_THRESHOLD = "numberbox_mode_pixelDarkThreshold";

static final String MODE_CONVERT_BOX_TO_PICTUREFRAME = "button_mode_convertBoxToPictureframe";
static final String MODE_SELECT_PICTUREFRAME = "button_mode_selectPictureframe";
static final String MODE_EXPORT_QUEUE = "button_mode_exportQueue";
static final String MODE_IMPORT_QUEUE = "button_mode_importQueue";
static final String MODE_CLEAR_QUEUE = "button_mode_clearQueue";
static final String MODE_FIT_IMAGE_TO_BOX = "button_mode_fitImageToBox";
static final String MODE_RESIZE_IMAGE = "numberbox_mode_resizeImage";
static final String MODE_RENDER_COMMAND_QUEUE = "button_mode_renderCommandQueue";

static final String MODE_MOVE_IMAGE = "toggle_mode_moveImage";
static final String MODE_SET_POSITION = "toggle_mode_setPosition";
static final String MODE_INPUT_BOX_TOP_LEFT = "toggle_mode_inputBoxTopLeft";
static final String MODE_INPUT_BOX_BOT_RIGHT = "toggle_mode_inputBoxBotRight";
static final String MODE_DRAW_TO_POSITION = "toggle_mode_drawToPosition";
static final String MODE_DRAW_DIRECT = "toggle_mode_drawDirect";

static final String MODE_CHANGE_SAMPLE_AREA = "numberbox_mode_changeSampleArea";
static final String MODE_CHANGE_GRID_SIZE = "numberbox_mode_changeGridSize";

static final String MODE_SHOW_DENSITY_PREVIEW = "minitoggle_mode_showDensityPreview";
static final String MODE_SHOW_IMAGE = "minitoggle_mode_showImage";
static final String MODE_SHOW_QUEUE_PREVIEW = "minitoggle_mode_showQueuePreview";
static final String MODE_SHOW_VECTOR = "minitoggle_mode_showVector";
static final String MODE_SHOW_GUIDES = "minitoggle_mode_showGuides";

static final String MODE_CHANGE_MACHINE_WIDTH = "numberbox_mode_changeMachineWidth";
static final String MODE_CHANGE_MACHINE_HEIGHT = "numberbox_mode_changeMachineHeight";
static final String MODE_CHANGE_MM_PER_REV = "numberbox_mode_changeMMPerRev";
static final String MODE_CHANGE_STEPS_PER_REV = "numberbox_mode_changeStepsPerRev";
static final String MODE_CHANGE_PAGE_WIDTH = "numberbox_mode_changePageWidth";
static final String MODE_CHANGE_PAGE_HEIGHT = "numberbox_mode_changePageHeight";
static final String MODE_CHANGE_PAGE_OFFSET_X = "numberbox_mode_changePageOffsetX";
static final String MODE_CHANGE_PAGE_OFFSET_Y = "numberbox_mode_changePageOffsetY";
static final String MODE_CHANGE_PAGE_OFFSET_X_CENTRE = "button_mode_changePageOffsetXCentre";

static final String MODE_CHANGE_HOMEPOINT_X = "numberbox_mode_changeHomePointX";
static final String MODE_CHANGE_HOMEPOINT_Y = "numberbox_mode_changeHomePointY";
static final String MODE_CHANGE_HOMEPOINT_X_CENTRE = "button_mode_changeHomePointXCentre";

static final String MODE_CHANGE_PEN_WIDTH = "numberbox_mode_changePenWidth";
static final String MODE_SEND_PEN_WIDTH = "button_mode_sendPenWidth";

static final String MODE_CHANGE_PEN_TEST_START_WIDTH = "numberbox_mode_changePenTestStartWidth";
static final String MODE_CHANGE_PEN_TEST_END_WIDTH = "numberbox_mode_changePenTestEndWidth";
static final String MODE_CHANGE_PEN_TEST_INCREMENT_SIZE = "numberbox_mode_changePenTestIncrementSize";

static final String MODE_CHANGE_MACHINE_MAX_SPEED = "numberbox_mode_changeMachineMaxSpeed";
static final String MODE_CHANGE_MACHINE_ACCELERATION = "numberbox_mode_changeMachineAcceleration";
static final String MODE_SEND_MACHINE_SPEED = "button_mode_sendMachineSpeed";

static final String MODE_RENDER_VECTORS = "button_mode_renderVectors";
static final String MODE_LOAD_VECTOR_FILE = "button_mode_loadVectorFile";

static final String MODE_CHANGE_SERIAL_PORT = "button_mode_serialPortDialog";
static final String MODE_SEND_MACHINE_STORE_MODE = "button_mode_machineStoreDialog";
static final String MODE_SEND_MACHINE_LIVE_MODE = "button_mode_sendMachineLiveMode";
static final String MODE_SEND_MACHINE_EXEC_MODE = "button_mode_machineExecDialog";

static final String MODE_RESIZE_VECTOR = "numberbox_mode_resizeVector";
static final String MODE_MOVE_VECTOR = "toggle_mode_moveVector";

static final String MODE_CHOOSE_CHROMA_KEY_COLOUR = "toggle_mode_chooseChromaKeyColour";



static String currentMode = MODE_BEGIN;
static String lastMode = MODE_BEGIN;

static PVector boxVector1 = null;
static PVector boxVector2 = null;

static PVector rowsVector1 = null;
static PVector rowsVector2 = null;

static final float MASKED_PIXEL_BRIGHTNESS = -1.0;
static int pixelExtractBrightThreshold = 255;
static int pixelExtractDarkThreshold = 0;
static boolean liftPenOnMaskedPixels = true;
int numberOfPixelsTotal = 0;
int numberOfPixelsCompleted = 0;

Date timerStart = null;
Date timeLastPixelStarted = null;

boolean pixelTimerRunning = false;
boolean displayingSelectedCentres = false;
boolean displayingRowGridlines = false;
boolean displayingInfoTextOnInputPage = false;

boolean displayingImage = true;
boolean displayingVector = true;
boolean displayingQueuePreview = true;
boolean displayingDensityPreview = false;

boolean displayingGuides = true;

boolean useSerialPortConnection = false;

static final char BITMAP_BACKGROUND_COLOUR = 0x0F;

PVector homePointCartesian = null;

public color chromaKeyColour = color(0,255,0);

// used in the preview page
public color pageColour = color(220);
public color frameColour = color(200,0,0);
public color machineColour = color(150);
public color guideColour = color(255);
public color backgroundColour = color(100);
public color densityPreviewColour = color(0);


public boolean showingSummaryOverlay = true;
public boolean showingDialogBox = false;

public Integer windowWidth = 650;
public Integer windowHeight = 400;

public static Integer serialPortNumber = -1;


Properties props = null;
public static String propertiesFilename = "default.properties.txt";
public static String newPropertiesFilename = null;

public static final String TAB_NAME_INPUT= "default";
public static final String TAB_LABEL_INPUT = "input";
public static final String TAB_NAME_PREVIEW = "tab_preview";
public static final String TAB_LABEL_PREVIEW = "Preview";
public static final String TAB_NAME_DETAILS = "tab_details";
public static final String TAB_LABEL_DETAILS = "Setup";
public static final String TAB_NAME_QUEUE = "tab_queue";
public static final String TAB_LABEL_QUEUE = "Queue";

// Page states
public String currentTab = TAB_NAME_INPUT;


public static final String PANEL_NAME_INPUT = "panel_input";
public static final String PANEL_NAME_PREVIEW = "panel_preview";
public static final String PANEL_NAME_DETAILS = "panel_details";
public static final String PANEL_NAME_QUEUE = "panel_queue";

public static final String PANEL_NAME_GENERAL = "panel_general";

public final PVector DEFAULT_CONTROL_SIZE = new PVector(100.0, 20.0);
public final PVector CONTROL_SPACING = new PVector(2.0, 2.0);
public PVector mainPanelPosition = new PVector(10.0, 85.0);

public final Integer PANEL_MIN_HEIGHT = 400;

public Set<String> panelNames = null;
public List<String> tabNames = null;
public Set<String> controlNames = null;
public Map<String, List<Controller>> controlsForPanels = null;

public Map<String, Controller> allControls = null;
public Map<String, String> controlLabels = null;
public Set<String> controlsToLockIfBoxNotSpecified = null;
public Set<String> controlsToLockIfImageNotLoaded = null;

public Map<String, Set<Panel>> panelsForTabs = null;
public Map<String, Panel> panels = null;

// machine moving
PVector machineDragOffset = new PVector (0.0, 0.0);
PVector lastMachineDragPosition = new PVector (0.0, 0.0);
public final float MIN_SCALING = 0.1;
public final float MAX_SCALING = 5.0;

RShape vectorShape = null;
String vectorFilename = null;
float vectorScaling = 100;
PVector vectorPosition = new PVector(0.0,0.0);

String storeFilename = "comm.txt";
boolean overwriteExistingStoreFile = true;

void setup()
{
  println("Running polargraph controller");
  frame.setResizable(true);

  RG.init(this);
  RG.setPolygonizer(RG.ADAPTATIVE);

  try 
  { 
    UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName()); 
  } 
  catch (Exception e) 
  { 
    e.printStackTrace();   
  }   
  loadFromPropertiesFile();
  
  this.cp5 = new ControlP5(this);
  initTabs();

  String[] serialPorts = Serial.list();
  println("Serial ports available on your machine:");
  println(serialPorts);

//  println("getSerialPortNumber()"+getSerialPortNumber());
  if (getSerialPortNumber() >= 0)
  {
    println("About to connect to serial port in slot " + getSerialPortNumber());
    // Print a list of the serial ports, for debugging purposes:
    if (serialPorts.length > 0)
    {
      String portName = null;
      try 
      {
        println("Get serial port no: "+getSerialPortNumber());
        portName = serialPorts[getSerialPortNumber()];
        myPort = new Serial(this, portName, 57600);
        //read bytes into a buffer until you get a linefeed (ASCII 10):
        myPort.bufferUntil('\n');
        useSerialPortConnection = true;
        println("Successfully connected to port " + portName);
      }
      catch (Exception e)
      {
        println("Attempting to connect to serial port " 
        + portName + " in slot " + getSerialPortNumber() 
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
    useSerialPortConnection = false;
  }

  currentMode = MODE_BEGIN;
  preLoadCommandQueue();
  size(windowWidth, windowHeight);
  changeTab(TAB_NAME_INPUT, TAB_NAME_INPUT);

  addEventListeners();
  
}
void addEventListeners()
{
  frame.addComponentListener(new ComponentAdapter() 
    {
      public void componentResized(ComponentEvent event) 
      {
        if (event.getSource()==frame) 
        {
  	  windowResized();
        }
      }
    }
  ); 
  addMouseWheelListener(new java.awt.event.MouseWheelListener() 
    { 
      public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) 
      { 
        mouseWheel(evt.getWheelRotation());
      }
    }
  ); 
}  


void preLoadCommandQueue()
{
  commandQueue.add(CMD_CHANGEPENWIDTH+currentPenWidth+",END");
  commandQueue.add(CMD_SETMOTORSPEED+currentMachineMaxSpeed+",END");
  commandQueue.add(CMD_SETMOTORACCEL+currentMachineAccel+",END");
  
}

void windowResized()
{
  windowWidth = frame.getWidth();
  windowHeight = frame.getHeight();
  for (String key : getPanels().keySet())
  {
    Panel p = getPanels().get(key);
    p.setHeight(frame.getHeight() - p.getOutline().getTop() - (DEFAULT_CONTROL_SIZE.y*2));
  }
  
}
void draw()
{
  if (getCurrentTab() == TAB_NAME_INPUT)
  {
    drawImagePage();
  }
  else if (getCurrentTab() == TAB_NAME_QUEUE)
  {
    drawCommandQueuePage();
  }
  else if (getCurrentTab() == TAB_NAME_DETAILS)
  {
    drawDetailsPage();
  }
  else
  {
    drawDetailsPage();
  }


  if (isShowingSummaryOverlay())
  {
    drawSummaryOverlay();
  }
  if (isShowingDialogBox())
  {
    drawDialogBox();
  }

  if (drawbotReady)
  {
    dispatchCommandQueue();
  }
  
}

String getCurrentTab()
{
  return this.currentTab;
}

boolean isShowingSummaryOverlay()
{
  return this.showingSummaryOverlay;
}
void drawSummaryOverlay()
{
}
boolean isShowingDialogBox()
{
  return false;
}
void drawDialogBox()
{
  
}
String getVectorFilename()
{
  return this.vectorFilename;
}
void setVectorFilename(String filename)
{
  this.vectorFilename = filename;
}
RShape getVectorShape()
{
  return this.vectorShape;
}
void setVectorShape(RShape shape)
{
  this.vectorShape = shape;
}

color getPageColour()
{
  return this.pageColour;
}
color getMachineColour()
{
  return this.machineColour;
}
color getBackgroundColour()
{
  return this.backgroundColour;
}
color getGuideColour()
{
  return this.guideColour;
}
color getFrameColour()
{
  return this.frameColour;
}


Panel getPanel(String panelName)
{
  return getPanels().get(panelName);
}

void drawImagePage()
{
  strokeWeight(1);
  background(getBackgroundColour());
  noFill();
  stroke(255, 150, 255, 100);
  strokeWeight(3);
  stroke(150);
  noFill();
  getDisplayMachine().draw();
  drawMoveImageOutline();
  stroke(255, 0, 0);
 
  for (Panel panel : getPanelsForTab(TAB_NAME_INPUT))
  {
    panel.draw();
  }
  stroke(200,200);
  text(propertiesFilename, getPanel(PANEL_NAME_GENERAL).getOutline().getLeft(), getPanel(PANEL_NAME_GENERAL).getOutline().getTop()-7);

  showGroupBox();
  showCurrentMachinePosition();
  if (displayingQueuePreview)
    previewQueue();
  if (displayingInfoTextOnInputPage)
    showText(250,45);
  drawStatusText(170, 12);

  showCommandQueue((int) getDisplayMachine().getOutline().getRight()+6, 20);
}

void drawMachineOutline()
{
  rect(machinePosition.x,machinePosition.y, machinePosition.x+getDisplayMachine().getWidth(), machinePosition.y+getDisplayMachine().getHeight());
}
void drawDetailsPage()
{
  strokeWeight(1);
  background(100);
  noFill();
  stroke(255, 150, 255, 100);
  strokeWeight(3);
  stroke(150);
  noFill();
  getDisplayMachine().drawForSetup();
  stroke(255, 0, 0);
 
  for (Panel panel : getPanelsForTab(TAB_NAME_DETAILS))
  {
    panel.draw();
  }
  text(propertiesFilename, getPanel(PANEL_NAME_GENERAL).getOutline().getLeft(), getPanel(PANEL_NAME_GENERAL).getOutline().getTop()-7);

//  showCurrentMachinePosition();
  if (displayingInfoTextOnInputPage)
    showText(250,45);
  drawStatusText(170, 12);

  showCommandQueue((int) getDisplayMachine().getOutline().getRight()+6, 20);
}

void drawCommandQueuePage()
{
  cursor(ARROW);
  background(100);

  // machine outline
  fill(100);
  drawMachineOutline();
  showingSummaryOverlay = false;
  

  
  int right = 0;
  for (Panel panel : getPanelsForTab(TAB_NAME_QUEUE))
  {
    panel.draw();
    float r = panel.getOutline().getRight();
    if (r > right)
      right = (int) r;
  }
  text(propertiesFilename, getPanel(PANEL_NAME_GENERAL).getOutline().getLeft(), getPanel(PANEL_NAME_GENERAL).getOutline().getTop()-7);
  showCommandQueue(right, (int)mainPanelPosition.y);
  
  drawStatusText(245, 12);
  
}

void drawImageLoadPage()
{
  drawImagePage();
}

void drawMoveImageOutline()
{
  if (MODE_MOVE_IMAGE == currentMode && getDisplayMachine().getImage() != null)
  {
    // get scaled size of the  image
    PVector imageSize = getDisplayMachine().inMM(getDisplayMachine().getImageFrame().getSize());
    PVector imageSizeOnScreen = getDisplayMachine().scaleToScreen(imageSize);
    imageSizeOnScreen.sub(getDisplayMachine().getOutline().getTopLeft());
    PVector offset = new PVector(imageSizeOnScreen.x/2.0, imageSizeOnScreen.y/2.0);
    
    PVector mVect = getMouseVector();
    PVector imagePos = new PVector(mVect.x-offset.x, mVect.y-offset.y);

    fill(80,50);
    noStroke();
    rect(imagePos.x+imageSizeOnScreen.x, imagePos.y+4, 4, imageSizeOnScreen.y);
    rect(imagePos.x+4, imageSizeOnScreen.y+imagePos.y, imageSizeOnScreen.x-4, 4);
    tint(255,180);
    image(getDisplayMachine().getImage(), imagePos.x, imagePos.y, imageSizeOnScreen.x, imageSizeOnScreen.y);
    noTint();
    // decorate image
    noFill();
  }
  else if (MODE_MOVE_VECTOR == currentMode && getVectorShape() != null)
  {
    RPoint[][] pointPaths = getVectorShape().getPointsInPaths();
    RG.ignoreStyles();
    stroke(1);
    strokeWeight(1);
    if (pointPaths != null)
    {
      for (int i = 0; i<pointPaths.length; i++)
      {
        if (pointPaths[i] != null) 
        {
          beginShape();
          for (int j = 0; j<pointPaths[i].length; j++)
          {
            PVector p = new PVector(pointPaths[i][j].x, pointPaths[i][j].y);
            p = PVector.mult(p, (vectorScaling/100));
            p = PVector.add(p, getDisplayMachine().scaleToDisplayMachine(getMouseVector()));
            p = getDisplayMachine().scaleToScreen(p);
            stroke(0);
            vertex(p.x, p.y);
          }
          endShape();
        }
      }
    }
  }
}

void showCurrentMachinePosition()
{
  noStroke();
  fill(255,0,255,150);
  PVector pgCoord = getDisplayMachine().scaleToScreen(currentMachinePos);
  ellipse(pgCoord.x, pgCoord.y, 20, 20);

  // also show cartesian position if reported
  fill(255,255,0,150);
  ellipse(currentCartesianMachinePos.x, currentCartesianMachinePos.y, 15, 15);

  noFill();
}

void showGroupBox()
{
  if (displayingGuides)
  {
    if (isBoxSpecified())
    {
      noFill();
      stroke(getFrameColour());
      strokeWeight(1);
      PVector topLeft = getDisplayMachine().scaleToScreen(boxVector1);
      PVector botRight = getDisplayMachine().scaleToScreen(boxVector2);
      rect(topLeft.x, topLeft.y, botRight.x-topLeft.x, botRight.y-topLeft.y);
    }
    else 
    {
      noFill();
      stroke(getFrameColour());
      strokeWeight(1);
  
      if (getBoxVector1() != null)
      {
        PVector topLeft = getDisplayMachine().scaleToScreen(boxVector1);
        line(topLeft.x, topLeft.y, topLeft.x-10, topLeft.y);
        line(topLeft.x, topLeft.y, topLeft.x, topLeft.y-10);
      }
  
      if (getBoxVector2() != null)
      {
        PVector botRight = getDisplayMachine().scaleToScreen(boxVector2);
        line(botRight.x, botRight.y, botRight.x+10, botRight.y);
        line(botRight.x, botRight.y, botRight.x, botRight.y+10);
      }
    }
  }
  
}

void loadImageWithFileChooser()
{
  SwingUtilities.invokeLater(new Runnable() 
  {
    public void run() {
      JFileChooser fc = new JFileChooser();
      fc.setFileFilter(new ImageFileFilter());
      
      fc.setDialogTitle("Choose an image file...");

      int returned = fc.showOpenDialog(frame);
      if (returned == JFileChooser.APPROVE_OPTION) 
      {
        File file = fc.getSelectedFile();
        // see if it's an image
        PImage img = loadImage(file.getPath());
        if (img != null) 
        {
          img = null;
          getDisplayMachine().loadNewImageFromFilename(file.getPath());
          if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
          {
            getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
          }
        }
      }
    }
  });
}

class ImageFileFilter extends javax.swing.filechooser.FileFilter 
{
  public boolean accept(File file) {
      String filename = file.getName();
      filename.toLowerCase();
      if (file.isDirectory() || filename.endsWith(".png") || filename.endsWith(".jpg") || filename.endsWith(".jpeg")) 
        return true;
      else
        return false;
  }
  public String getDescription() {
      return "Image files (PNG or JPG)";
  }
}

void loadVectorWithFileChooser()
{
  SwingUtilities.invokeLater(new Runnable() 
  {
    public void run() {
      JFileChooser fc = new JFileChooser();
      fc.setFileFilter(new VectorFileFilter());
      
      fc.setDialogTitle("Choose a vector file...");

      int returned = fc.showOpenDialog(frame);
      if (returned == JFileChooser.APPROVE_OPTION) 
      {
        File file = fc.getSelectedFile();
        if (file.exists())
        {
          RShape shape = RG.loadShape(file.getPath());
          if (shape != null) 
          {
            setVectorFilename(file.getPath());
            setVectorShape(shape);
          }
          else 
          {
            println("File not found (" + file.getPath() + ")");
          }
        }
      }
    }
  });
}
class VectorFileFilter extends javax.swing.filechooser.FileFilter 
{
  public boolean accept(File file) {
      String filename = file.getName();
      filename.toLowerCase();
      if (file.isDirectory() || filename.endsWith(".svg")) 
        return true;
      else
        return false;
  }
  public String getDescription() {
      return "Vector graphic files (SVG)";
  }
}

void loadNewPropertiesFilenameWithFileChooser()
{
  SwingUtilities.invokeLater(new Runnable() 
  {
    public void run() 
    {
      JFileChooser fc = new JFileChooser();
      fc.setFileFilter(new PropertiesFileFilter());
      
      fc.setDialogTitle("Choose a config file...");

      int returned = fc.showOpenDialog(frame);
      if (returned == JFileChooser.APPROVE_OPTION) 
      {
        File file = fc.getSelectedFile();
        if (file.exists())
        {
          println("New properties file exists.");
          newPropertiesFilename = file.toString();
          println("new propertiesFilename: "+  newPropertiesFilename);
          propertiesFilename = newPropertiesFilename;
          // clear old properties.
          props = null;
          loadFromPropertiesFile();
        }   
      }
    }
  });
}

class PropertiesFileFilter extends javax.swing.filechooser.FileFilter 
{
  public boolean accept(File file) {
      String filename = file.getName();
      filename.toLowerCase();
      if (file.isDirectory() || filename.endsWith(".properties.txt")) 
        return true;
      else
        return false;
  }
  public String getDescription() {
      return "Properties files (*.properties.txt)";
  }
}

void saveNewPropertiesFileWithFileChooser()
{
  SwingUtilities.invokeLater(new Runnable() 
  {
    public void run() 
    {
      JFileChooser fc = new JFileChooser();
      fc.setFileFilter(new PropertiesFileFilter());
      
      fc.setDialogTitle("Enter a config file name...");

      int returned = fc.showSaveDialog(frame);
      if (returned == JFileChooser.APPROVE_OPTION) 
      {
        File file = fc.getSelectedFile();
        newPropertiesFilename = file.toString();
        newPropertiesFilename.toLowerCase();
        if (!newPropertiesFilename.endsWith(".properties.txt"))
          newPropertiesFilename+=".properties.txt";
          
        println("new propertiesFilename: "+  newPropertiesFilename);
        propertiesFilename = newPropertiesFilename;
        savePropertiesFile();
        // clear old properties.
        props = null;
        loadFromPropertiesFile();
      }
    }
  });
}



void setPictureFrameDimensionsToBox()
{
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    Rectangle r = new Rectangle(getDisplayMachine().inSteps(getBoxVector1()), getDisplayMachine().inSteps(getBoxVectorSize()));
    getDisplayMachine().setPictureFrame(r);
  }
}
void setBoxToPictureframeDimensions()
{
  setBoxVector1(getDisplayMachine().inMM(getDisplayMachine().getPictureFrame().getTopLeft()));
  setBoxVector2(getDisplayMachine().inMM(getDisplayMachine().getPictureFrame().getBotRight()));
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    Toggle t = (Toggle) getAllControls().get(MODE_SHOW_IMAGE);
    t.setValue(0);
    t.update();

    t = (Toggle) getAllControls().get(MODE_SHOW_DENSITY_PREVIEW);
    t.setValue(1);
    t.update();
    
  }
}

float getGridSize()
{
  return this.gridSize;
}
void setGridSize(float s)
{
  this.gridSize = s;
}

void setSampleArea(float v)
{
  this.sampleArea = v;
}

void controlEvent(ControlEvent controlEvent) 
{
  if (controlEvent.isTab()) 
  {
    if (controlEvent.tab().name() == getCurrentTab())
    {
      // already here.
      println("Already here.");
    }
    else
    {
      changeTab(currentTab, controlEvent.tab().name());
    }
  }
  else if(controlEvent.isGroup()) 
  {
    print("got an event from "+controlEvent.group().name()+"\t");

    // checkbox uses arrayValue to store the state of 
    // individual checkbox-items. usage:
    for (int i=0; i<controlEvent.group().arrayValue().length; i++) 
    {
      int n = (int)controlEvent.group().arrayValue()[i];
    }
    println();
  }
  
}

void changeTab(String from, String to)
{
  
  // hide old panels
  currentTab = to;
  for (Panel panel : getPanelsForTab(currentTab))
  {
    for (Controller c : panel.getControls())
    {
      c.moveTo(currentTab);
      c.show();
    }
  }
  
}



boolean mouseOverMachine()
{
  boolean result = false;
  if (isMachineClickable())
  {
    if (getDisplayMachine().getOutline().surrounds(getMouseVector())
      && mouseOverControls().isEmpty())
    {
      result = true;
    }
    else
      result = false;
  }
  return result;
}

Set<Controller> mouseOverControls()
{
  Set<Controller> set = new HashSet<Controller>(1);
  for (String key : getAllControls().keySet())
  {
    if (getAllControls().get(key).isInside())
    {
      set.add(getAllControls().get(key));
    }
  }
  return set;
}


boolean isMachineClickable()
{
  if (getCurrentTab() == TAB_NAME_INPUT)
  {
    return true;
  }
  else if (getCurrentTab() == TAB_NAME_PREVIEW)
  {
    return true;
  }
  else if (getCurrentTab() == TAB_NAME_QUEUE)
  {
    return false;
  }
  else if (getCurrentTab() == TAB_NAME_DETAILS)
  {
    return false;
  }
  else
  {
    return false;
  }
}
boolean isPanelClickable()
{
  return true;
}
boolean isQueueClickable()
{
  return true;
}

boolean mouseOverPanel()
{
  boolean result = false;
  for (Panel panel : getPanelsForTab(currentTab))
  {
    if (panel.getOutline().surrounds(getMouseVector()))
      result = true;
  }
  return result;
}

boolean mouseOverQueue()
{
  boolean result = true;
  if (mouseX < leftEdgeOfQueue
    || mouseX > rightEdgeOfQueue
    || mouseY < topEdgeOfQueue
    || mouseY > bottomEdgeOfQueue)
    result = false;
  return result;
}

void changeMachineScaling(int delta)
{
  boolean scalingChanged = true;
  machineScaling += (delta * 0.1);
  if (machineScaling <  MIN_SCALING)
  {
    machineScaling = MIN_SCALING;
    scalingChanged = false;
  }
  else if (machineScaling > MAX_SCALING)
  {
    machineScaling = MAX_SCALING;
    scalingChanged = false;
  }
}

void keyPressed()
{
  if (key == CODED)
  {
    if (keyCode == java.awt.event.KeyEvent.VK_PAGE_UP)
    {
      changeMachineScaling(1);
    }
    else if (keyCode == java.awt.event.KeyEvent.VK_PAGE_DOWN)
    {
      changeMachineScaling(-1);
    }
    else if (keyCode == DOWN)
    {
      getDisplayMachine().getOffset().y = getDisplayMachine().getOffset().y + 10;
    }
    else if (keyCode == UP)
    {
      getDisplayMachine().getOffset().y = getDisplayMachine().getOffset().y - 10;
    }
    else if (keyCode == RIGHT)
    {
      getDisplayMachine().getOffset().x = getDisplayMachine().getOffset().x + 10;
    }
    else if (keyCode == LEFT)
    {
      getDisplayMachine().getOffset().x = getDisplayMachine().getOffset().x - 10;
    }
  }
  else if (key == 'g' || key == 'G')
  {
    Toggle t = (Toggle) getAllControls().get(MODE_SHOW_GUIDES);
    if (displayingGuides)
    {
      minitoggle_mode_showGuides(false);
      t.setValue(0);
    }
    else
    {
      minitoggle_mode_showGuides(true);
      t.setValue(1);
    }
    t.update();
  }
  else if (key == 's' || key == 'S')
    displayingSelectedCentres = (displayingSelectedCentres) ? false : true;
  else if (key == 'i' || key == 'I')
    displayingInfoTextOnInputPage = (displayingInfoTextOnInputPage) ? false : true;
  else if (key == '+')
  {
    currentMachineMaxSpeed = currentMachineMaxSpeed+MACHINE_MAXSPEED_INCREMENT;
    currentMachineMaxSpeed =  Math.round(currentMachineMaxSpeed*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_SETMOTORSPEED+df.format(currentMachineMaxSpeed)+",END");
  }
  else if (key == '-')
  {
    currentMachineMaxSpeed = currentMachineMaxSpeed+(0.0 - MACHINE_MAXSPEED_INCREMENT);
    currentMachineMaxSpeed =  Math.round(currentMachineMaxSpeed*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_SETMOTORSPEED+df.format(currentMachineMaxSpeed)+",END");
  }
  else if (key == '*')
  {
    currentMachineAccel = currentMachineAccel+MACHINE_ACCEL_INCREMENT;
    currentMachineAccel =  Math.round(currentMachineAccel*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_SETMOTORACCEL+df.format(currentMachineAccel)+",END");
  }
  else if (key == '/')
  {
    currentMachineAccel = currentMachineAccel+(0.0 - MACHINE_ACCEL_INCREMENT);
    currentMachineAccel =  Math.round(currentMachineAccel*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_SETMOTORACCEL+df.format(currentMachineAccel)+",END");
  }
  else if (key == ']')
  {
    currentPenWidth = currentPenWidth+penIncrement;
    currentPenWidth =  Math.round(currentPenWidth*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_CHANGEPENWIDTH+df.format(currentPenWidth)+",END");
  }
  else if (key == '[')
  {
    currentPenWidth = currentPenWidth-penIncrement;
    currentPenWidth =  Math.round(currentPenWidth*100.0)/100.0;
    NumberFormat nf = NumberFormat.getNumberInstance(Locale.UK);
    DecimalFormat df = (DecimalFormat)nf;  
    df.applyPattern("###.##");
    realtimeCommandQueue.add(CMD_CHANGEPENWIDTH+df.format(currentPenWidth)+",END");
  }
  else if (key == '#' )
  {
    realtimeCommandQueue.add(CMD_PENUP+"END");
  }
  else if (key == '~')
  {
    realtimeCommandQueue.add(CMD_PENDOWN+"END");
  }
  else if (key == '<' || key == ',')
  {
    if (this.maxSegmentLength > 1)
      this.maxSegmentLength--;
  }
  else if (key == '>' || key == '.')
  {
    this.maxSegmentLength++;
  }
}
void mouseDragged()
{
  if (mouseOverControls().isEmpty())
  {
    if (mouseButton == CENTER)
    {
      machineDragged();
    }
    else if (mouseButton == LEFT)
    {
      if (currentMode.equals(MODE_INPUT_BOX_TOP_LEFT))
      {
        // dragging a selection area
        PVector pos = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
        setBoxVector2(pos);
      }
    }
  }
}
  
void mouseClicked()
{
  if (mouseOverPanel())
  { // changing mode
//    panelClicked();
  }
  else
  {
    if (currentMode.equals(MODE_MOVE_IMAGE))
    {
      PVector imageSize = getDisplayMachine().inMM(getDisplayMachine().getImageFrame().getSize());
      PVector mVect = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
      PVector offset = new PVector(imageSize.x/2.0, imageSize.y/2.0);
      PVector imagePos = new PVector(mVect.x-offset.x, mVect.y-offset.y);
  
      imagePos = getDisplayMachine().inSteps(imagePos);
      getDisplayMachine().getImageFrame().setPosition(imagePos.x, imagePos.y);
  
      if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
        getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
    }
    else if (currentMode.equals(MODE_MOVE_VECTOR))
    {
      PVector mVect = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
      vectorPosition = mVect;
    }
    else if (mouseOverQueue())
    {
      // stopping or starting 
      println("queue clicked.");
      queueClicked();
    }
    else if (mouseOverMachine())
    { 
      // picking coords
      machineClicked();
    }
  }
}

void machineDragged()
{
  if (mouseButton == CENTER)
  {
    PVector currentPos = getMouseVector();
    PVector change = PVector.sub(currentPos, lastMachineDragPosition);
    lastMachineDragPosition = new PVector(currentPos.x, currentPos.y);
    PVector currentPosition = getDisplayMachine().getOutline().getPosition();
    getDisplayMachine().getOffset().add(change);
  }
}

void machineClicked()
{
  if (mouseButton == LEFT)
  {
    leftButtonMachineClick();
  }
}
void mousePressed()
{
//  println("mouse pressed");
//  println("mouse button: "+mouseButton);
//  println("Current mode: " +currentMode);
  if (mouseButton == CENTER)
  {
    middleButtonMachinePress();
    lastMachineDragPosition = getMouseVector();
  }
  else if (mouseButton == LEFT)
  {
    if (MODE_INPUT_BOX_TOP_LEFT.equals(currentMode) && mouseOverMachine())
    {
      minitoggle_mode_showImage(true);
      minitoggle_mode_showDensityPreview(false);
      PVector pos = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
      setBoxVector1(pos);
      if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
      {
        getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
//        minitoggle_mode_showImage(false);
//        minitoggle_mode_showDensityPreview(true);
      }
    }
    else
    {
//      println("Do nothing.");
    }
  }
}

void mouseReleased()
{
  if (mouseButton == LEFT)
  {
    if (MODE_INPUT_BOX_TOP_LEFT.equals(currentMode) && mouseOverMachine())
    {
      PVector pos = getDisplayMachine().scaleToDisplayMachine(getMouseVector());
      setBoxVector2(pos);
      if (isBoxSpecified())
      {
        if (getBoxVector1().x > getBoxVector2().x)
        {
          float temp = getBoxVector1().x;
          getBoxVector1().x = getBoxVector2().x;
          getBoxVector2().x = temp;
        }
        if (getBoxVector1().y > getBoxVector2().y)
        {
          float temp = getBoxVector1().y;
          getBoxVector1().y = getBoxVector2().y;
          getBoxVector2().y = temp;
        }
        if (getDisplayMachine().pixelsCanBeExtracted())
        {
          getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
          minitoggle_mode_showImage(false);
          minitoggle_mode_showDensityPreview(true);
          getAllControls().get(MODE_SHOW_IMAGE).setValue(0);
          getAllControls().get(MODE_SHOW_DENSITY_PREVIEW).setValue(1);
        }
      }
    }
  }
}

void middleButtonMachinePress()
{
  PVector machineDragOffset = PVector.sub(getMouseVector(), getDisplayMachine().getOutline().getPosition());
  this.machineDragOffset = machineDragOffset;
}

void leftButtonMachineClick()
{
  if (currentMode.equals(MODE_BEGIN))
    currentMode = MODE_INPUT_BOX_TOP_LEFT;
  else if (currentMode.equals(MODE_SET_POSITION))
    sendSetPosition();
  else if (currentMode.equals(MODE_DRAW_DIRECT))
    sendMoveToPosition(true);
  else if (currentMode.equals(MODE_DRAW_TO_POSITION))
    sendMoveToPosition(false);
  else if (currentMode.equals(MODE_CHOOSE_CHROMA_KEY_COLOUR))
    setChromaKey(getMouseVector());
  
}

void mouseWheel(int delta) 
{
  changeMachineScaling(delta);
} 

void setChromaKey(PVector p)
{
  color col = getDisplayMachine().getPixelAtScreenCoords(p);
  chromaKeyColour = col;
  if (getDisplayMachine().pixelsCanBeExtracted() && isBoxSpecified())
  {
    getDisplayMachine().extractPixelsFromArea(getBoxVector1(), getBoxVectorSize(), getGridSize(), sampleArea);
  }
}

boolean isPreviewable(String command)
{
  if ((command.startsWith(CMD_CHANGELENGTHDIRECT) 
    || command.startsWith(CMD_CHANGELENGTH)))
  {
    return true;
  }
  else
  {
    return false;
  }
}

/**
  This will comb the command queue and attempt to draw a picture of what it contains.
  Coordinates here are in pixels.
*/
void previewQueue()
{
  
  PVector startPoint = null;
  
  List<String> fullList = new ArrayList<String>();
  if (!commandHistory.isEmpty())
  {
    Integer commandPosition = commandHistory.size()-1;
    String lastCommand = "";
    while (commandPosition>=0)
    {
      lastCommand = commandHistory.get(commandPosition);
      if (isPreviewable(lastCommand))
      {
        fullList.add(lastCommand);
        break;
      }
      commandPosition--;
    }
  }

  for (String command : commandQueue)
  {
    if ((command.startsWith(CMD_CHANGELENGTHDIRECT) || command.startsWith(CMD_CHANGELENGTH)))
    {
      fullList.add(command);
    }
  }
  
  for (String command : fullList)
  {
    String[] splitted = split(command, ",");
    String aLenStr = splitted[1];
    String bLenStr = splitted[2];
    
    
    
    PVector endPoint = new PVector(Integer.parseInt(aLenStr), Integer.parseInt(bLenStr));
    endPoint = getDisplayMachine().asCartesianCoords(endPoint);
    endPoint = getDisplayMachine().inMM(endPoint);
    
    endPoint = getDisplayMachine().scaleToScreen(endPoint);
    
    if (startPoint == null)
    {
      noStroke();
      fill(255,0,255,150);
      startPoint = getDisplayMachine().scaleToScreen(currentMachinePos);
      ellipse(startPoint.x, startPoint.y, 20, 20);
      noFill();
    }
    
    if (command.startsWith(CMD_CHANGELENGTHDIRECT))
      stroke(0);
    else 
      stroke(200,0,0);
    line(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
    startPoint = endPoint;
  }
  

  if (startPoint != null)
  {
    noStroke();
    fill(200,0,0,128);
    ellipse(startPoint.x, startPoint.y, 15,15);
    noFill();
  }
  
}



boolean isHiddenPixel(PVector p)
{
  if ((p.z == MASKED_PIXEL_BRIGHTNESS) || (p.z > pixelExtractBrightThreshold) || (p.z < pixelExtractDarkThreshold))
    return true;
  else
    return false;
}
  


void sizeImageToFitBox()
{
//  PVector mmBoxSize = getDisplayMachine().inSteps(getBoxSize());
//  PVector mmBoxPos = getDisplayMachine().inSteps(getBoxVector1());
//  println("mm box: " + mmBoxSize);
  
  PVector boxSize = getDisplayMachine().inSteps(getBoxSize());
  PVector boxPos = getDisplayMachine().inSteps(getBoxVector1());
  println("image: " + boxSize);
  
  Rectangle r = new Rectangle(boxPos, boxSize);
  getDisplayMachine().setImageFrame(r);
}

void exportQueueToFile()
{
  if (!commandQueue.isEmpty())
  {
    String savePath = selectOutput();  // Opens file chooser
    if (savePath == null) 
    {
      // If a file was not selected
      println("No output file was selected...");
    } 
    else 
    {
      // If a file was selected, print path to folder
      println("Output file: " + savePath);
      String[] rtList = (String[]) realtimeCommandQueue.toArray(new String[0]);
      saveStrings(savePath, rtList);
      String[] list = (String[]) commandQueue.toArray(new String[0]);
      saveStrings(savePath, list);
      println("Completed queue export, " + list.length + " commands exported.");
    }  
  }
}
void importQueueFromFile()
{
  commandQueue.clear();
  String loadPath = selectInput();
  if (loadPath == null)
  {
    // nothing selected
    println("No input file was selected.");
  }
  else
  {
    println("Input file: " + loadPath);
    String commands[] = loadStrings(loadPath);
//    List<String> list = Arrays
    commandQueue.addAll(Arrays.asList(commands));
    println("Completed queue import, " + commandQueue.size() + " commands found.");
  }
}


void queueClicked()
{
  int relativeCoord = (mouseY-topEdgeOfQueue);
  int rowClicked = relativeCoord / queueRowHeight;
  int totalCommands = commandQueue.size()+realtimeCommandQueue.size();
  
  if (rowClicked < 1) // its the header - start or stop queue
  {
    if (commandQueueRunning)
      commandQueueRunning = false;
    else
      commandQueueRunning = true;
  }
  else if (rowClicked > 2 && rowClicked < totalCommands+3) // it's a command from the queue
  {
    int cmdNumber = rowClicked-2;
    if (commandQueueRunning)
    {
      // if its running, then clicking on a command will mark it as a pause point
    }
    else
    {
      // if it's not running, then clicking on a command row will remove it
      if (!realtimeCommandQueue.isEmpty())
      {
        if (cmdNumber <= realtimeCommandQueue.size())
          realtimeCommandQueue.remove(cmdNumber-1);
        else  
        {
          cmdNumber-=(realtimeCommandQueue.size()+1);
          commandQueue.remove(cmdNumber);
        }        
      }
      else
      {
        commandQueue.remove(cmdNumber-1);
      }
    }
  }
}


boolean isRowsSpecified()
{
  if (rowsVector1 != null && rowsVector2 != null)
    return true;
  else
    return false;
}

boolean isBoxSpecified()
{
  if (boxVector1 != null && boxVector2 != null)
  {
    return true;
  }
  else
    return false;
}

void setBoxVector1(PVector vec)
{
  boxVector1 = vec;
}
void setBoxVector2(PVector vec)
{
  boxVector2 = vec;
}
PVector getBoxVector1()
{
  return this.boxVector1;
}
PVector getBoxVector2()
{
  return this.boxVector2;
}
PVector getBoxVectorSize()
{
  return PVector.sub(getBoxVector2(),getBoxVector1());
}

float getSampleArea()
{
  return this.sampleArea;
}


void resetQueue()
{
  currentMode = MODE_BEGIN;
  commandQueue.clear();
  realtimeCommandQueue.clear();
}

void showText(int xPosOrigin, int yPosOrigin)
{
  noStroke();
  fill(0, 0, 0, 80);
  rect(xPosOrigin, yPosOrigin, 220, 550);
  
  
  textSize(12);
  fill(255);
  int tRow = 15;
  int textPositionX = xPosOrigin+4;
  int textPositionY = yPosOrigin+4;
  
  int tRowNo = 1;
  PVector screenCoordsCart = getMouseVector();
 
  text(programTitle, textPositionX, textPositionY+(tRow*tRowNo++));
  tRowNo++;
  text("Cursor position: " + mouseX + ", " + mouseY, textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("MM Per Step: " + getDisplayMachine().getMMPerStep(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Steps Per MM: " + getDisplayMachine().getStepsPerMM() ,textPositionX, textPositionY+(tRow*tRowNo++));

  if (getDisplayMachine().getOutline().surrounds(screenCoordsCart))
  {
    PVector posOnMachineCartesianInMM = getDisplayMachine().scaleToDisplayMachine(screenCoordsCart);
    text("Machine x/y mm: " + posOnMachineCartesianInMM.x+","+posOnMachineCartesianInMM.y, textPositionX, textPositionY+(tRow*tRowNo++));
    
    PVector posOnMachineNativeInMM = getDisplayMachine().convertToNative(posOnMachineCartesianInMM);
    text("Machine a/b mm: " + posOnMachineNativeInMM.x+","+posOnMachineNativeInMM.y, textPositionX, textPositionY+(tRow*tRowNo++));
  
    PVector posOnMachineNativeInSteps = getDisplayMachine().inSteps(posOnMachineNativeInMM);
    text("Machine a/b steps: " + posOnMachineNativeInSteps.x+","+posOnMachineNativeInSteps.y, textPositionX, textPositionY+(tRow*tRowNo++));
  }
  else
  {
    text("Machine x/y mm: --,--", textPositionX, textPositionY+(tRow*tRowNo++));
    text("Machine a/b mm: --,--", textPositionX, textPositionY+(tRow*tRowNo++));
    text("Machine a/b steps: --,--", textPositionX, textPositionY+(tRow*tRowNo++));
  }
  


  drawStatusText(textPositionX, textPositionY+(tRow*tRowNo++));  
    
  text(commandStatus, textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("Mode: " + currentMode, textPositionX, textPositionY+(tRow*tRowNo++));

  // middle side
  text("Grid size: " + getGridSize(), textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("Box width: " + getBoxWidth(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Box height: " + getBoxHeight(), textPositionX, textPositionY+(tRow*tRowNo++));

  text("Box offset left: " + getBoxPosition().x, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Box offset top: " + getBoxPosition().y, textPositionX, textPositionY+(tRow*tRowNo++));
  
  text("Available memory: " + machineAvailMem + " (min: " + machineMinAvailMem +", used: "+ machineUsedMem+")", textPositionX, textPositionY+(tRow*tRowNo++));

  text("Time cmd: " + getCurrentPixelTime() + ", total: " + getTimeSoFar(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Average time per cmd: " + getAveragePixelTime(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Time to go: " + getTimeRemainingMins() + " mins (" + getTimeRemainingSecs() + " secs)", textPositionX, textPositionY+(tRow*tRowNo++));

  text("Commands sent: " + getPixelsCompleted() + ", remaining: " + getPixelsRemaining(), textPositionX, textPositionY+(tRow*tRowNo++));

  text("Estimated complete: " + getEstimatedCompletionTime(), textPositionX, textPositionY+(tRow*tRowNo++));

  text("Pixel sample area: " + sampleArea, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Max line segment length: " + getMaxSegmentLength(), textPositionX, textPositionY+(tRow*tRowNo++));
  text("Zoom: " + machineScaling, textPositionX, textPositionY+(tRow*tRowNo++));

  tRowNo++;
  text("Machine settings:", textPositionX, textPositionY+(tRow*tRowNo++));
  text("Last sent pen width: " + currentPenWidth, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Last sent speed: " + currentMachineMaxSpeed, textPositionX, textPositionY+(tRow*tRowNo++));
  text("Last sent accel: " + currentMachineAccel, textPositionX, textPositionY+(tRow*tRowNo++));

  tRowNo++;
  text("Chroma key colour: ", textPositionX, textPositionY+(tRow*tRowNo));
  fill(chromaKeyColour);
  stroke(255);
  strokeWeight(1);
  rect(textPositionX+120, textPositionY+(tRow*tRowNo)-15, 25, 15);
  noFill();
  noStroke();
  tRowNo++;

}

void drawStatusText(int x, int y)
{
  String drawbotStatus = null;
  
  if (useSerialPortConnection)
  {
    if (isDrawbotConnected())
    {
      if (drawbotReady)
      {
        fill(0, 200, 0);
        if (currentHardware >= HARDWARE_VER_MEGA)
          drawbotStatus = "Polargraph READY! (Mega)";
        else
          drawbotStatus = "Polargraph READY! (Uno)";
      }
      else
      {
        fill(200, 200, 0);
        String busyDoing = lastCommand;
        if ("".equals(busyDoing))
          busyDoing = commandHistory.get(commandHistory.size()-1);
        drawbotStatus = "BUSY: " + busyDoing;
      }  
    }
    else
    {
      fill(255, 0, 0);
      drawbotStatus = "Polargraph is not connected.";
    }  
  }
  else
  {
    fill(255, 0, 0);
    drawbotStatus = "No serial connection.";
  }
  
  text(drawbotStatus, x, y);
  fill(255);
}

void setCommandQueueFont()
{
  textSize(12);
  fill(255);
}  
void showCommandQueue(int xPos, int yPos)
{
  setCommandQueueFont();
  int tRow = 15;
  int textPositionX = xPos;
  int textPositionY = yPos;
  int tRowNo = 1;

  int commandQueuePos = textPositionY+(tRow*tRowNo++);

  topEdgeOfQueue = commandQueuePos-queueRowHeight;
  leftEdgeOfQueue = textPositionX;
  rightEdgeOfQueue = textPositionX+300;
  bottomEdgeOfQueue = height;
  
  drawCommandQueueStatus(textPositionX, commandQueuePos, 14);
  commandQueuePos+=queueRowHeight;
  text("Last command: " + ((commandHistory.isEmpty()) ? "-" : commandHistory.get(commandHistory.size()-1)), textPositionX, commandQueuePos);
  commandQueuePos+=queueRowHeight;
  text("Current command: " + lastCommand, textPositionX, commandQueuePos);
  commandQueuePos+=queueRowHeight;
  
  fill(128,255,255);
  int queueNumber = commandQueue.size()+realtimeCommandQueue.size();
  for (String s : realtimeCommandQueue)
  {
    text((queueNumber--)+". "+ s, textPositionX, commandQueuePos);
    commandQueuePos+=queueRowHeight;
  }
  
  fill(255);
  for (String s : commandQueue)
  {
    text((queueNumber--)+". "+ s, textPositionX, commandQueuePos);
    commandQueuePos+=queueRowHeight;
  }
}

void drawCommandQueueStatus(int x, int y, int tSize)
{
  String queueStatus = null;
  textSize(tSize);
  if (commandQueueRunning)
  {
    queueStatus = "QUEUE RUNNING - click to pause";
    fill(0, 200, 0);
  }
  else
  {
    queueStatus = "QUEUE PAUSED - click to start";
    fill(255, 0, 0);
  }

  text("CommandQueue: " + queueStatus, x, y);
  setCommandQueueFont();
}

long getCurrentPixelTime()
{
  if (pixelTimerRunning)
    return new Date().getTime() - timeLastPixelStarted.getTime();
  else
    return 0L;
}
long getAveragePixelTime()
{
  if (pixelTimerRunning)
  {
    long msElapsed = timeLastPixelStarted.getTime() - timerStart.getTime();
    int pixelsCompleted = getPixelsCompleted();
    if (pixelsCompleted > 0)
      return msElapsed / pixelsCompleted;
    else
      return 0L;
  }
  else
    return 0L;
}
long getTimeSoFar()
{
  if (pixelTimerRunning)
    return new Date().getTime() - timerStart.getTime();
  else
    return 0L;
}
long getTimeRemaining()
{
  if (pixelTimerRunning)
    return getTotalEstimatedTime() - getTimeSoFar();
  else
    return 0L;
}
long getTotalEstimatedTime()
{
  if (pixelTimerRunning)
    return (getAveragePixelTime() * numberOfPixelsTotal);
  else
    return 0L;
}
long getTimeRemainingSecs()
{
  if (pixelTimerRunning)
    return getTimeRemaining() / 1000L;
  else
    return 0L;
}
long getTimeRemainingMins()
{
  if (pixelTimerRunning)
    return getTimeRemainingSecs()/60L;
  else
    return 0L;
}
String getEstimatedCompletionTime()
{
  if (pixelTimerRunning)
  {
    long totalTime = getTotalEstimatedTime()+timerStart.getTime();
    return sdf.format(totalTime);
  }
  else
    return "TIMER NOT RUNNING";
}

int getPixelsCompleted()
{
  if (pixelTimerRunning)
    return numberOfPixelsCompleted-1;
  else
    return 0;
}
int getPixelsRemaining()
{
  if (pixelTimerRunning)
    return numberOfPixelsTotal - getPixelsCompleted();
  else
    return 0;
}


float getBoxWidth()
{
  if (boxVector1 != null && boxVector2 != null)
    return (boxVector2.x-boxVector1.x);
  else
    return 0;
}

float getBoxHeight()
{
  if (boxVector1 != null && boxVector2 != null)
    return (boxVector2.y-boxVector1.y);
  else
    return 0;
}
PVector getBoxSize()
{
  PVector p = PVector.sub(getBoxVector2(), getBoxVector1());
  return p;
}

PVector getBoxPosition()
{
  if (boxVector1 != null)
    return boxVector1;
  else
    return new PVector();
}

void clearBoxVectors()
{
  setBoxVector1(null);
  setBoxVector2(null);
  getDisplayMachine().setExtractedPixels(null);
}

public PVector getHomePoint()
{
  return this.homePointCartesian;
}



//public Machine getMachine()
//{
//  return this.machine;
//}
public DisplayMachine getDisplayMachine()
{
  if (displayMachine == null)
    displayMachine = new DisplayMachine(new Machine(5000, 5000, 800.0, 95.0), machinePosition, machineScaling);
    
  displayMachine.setOffset(machinePosition);
  displayMachine.setScale(machineScaling);
  return displayMachine;
}

Integer getHardwareVersion()
{
  return this.currentHardware;
}

void changeHardwareVersionTo(int newVer)
{
  this.currentHardware = newVer;

  this.panelNames = null;
  this.tabNames = null;
  this.controlNames = null;
  this.controlsForPanels = null;

  this.panelsForTabs = null;
  this.panels = null;

  switch (newVer)
  {
    case HARDWARE_VER_MEGA :
      currentSram = HARDWARE_ATMEGA1280_SRAM;
    default   :  
      currentSram = HARDWARE_ATMEGA328_SRAM;
  }
//  windowResized();
}

void setHardwareVersionFromIncoming(String readyString)
{
  int newHardwareVersion = HARDWARE_VER_UNO;
  if ("READY".equals(readyString))
  {
    newHardwareVersion = HARDWARE_VER_UNO;
  }
  else
  {
    String ver = readyString.substring(6);
    int verInt = HARDWARE_VER_UNO;
    try
    {
      verInt = Integer.parseInt(ver);
    }
    catch (NumberFormatException nfe)
    {
      println("Bad format for hardware version - defaulting to ATMEGA328 (Uno)");
      verInt = HARDWARE_VER_UNO;
    }
    
    if (HARDWARE_VER_MEGA == verInt)
      newHardwareVersion = verInt;
    else
      newHardwareVersion = HARDWARE_VER_UNO;
  }
  
  // now see if it's different to last time.
  if (newHardwareVersion != currentHardware)
  {
    // and make the controller reflect the new hardware.
    changeHardwareVersionTo(newHardwareVersion);
  }
}

void serialEvent(Serial myPort) 
{ 
  // read the serial buffer:
  String incoming = myPort.readStringUntil('\n');
  myPort.clear();
  // if you got any bytes other than the linefeed:
  incoming = trim(incoming);
  println("incoming: " + incoming);
  
  if (incoming.startsWith("READY"))
  {
    drawbotReady = true;
    setHardwareVersionFromIncoming(incoming);
  }
  else if (incoming.startsWith("SYNC"))
    readMachinePosition(incoming);
  else if (incoming.startsWith("CARTESIAN"))
    readCartesianMachinePosition(incoming);
  else if (incoming.startsWith("PGNAME"))
    readMachineName(incoming);
  else if (incoming.startsWith("PGSIZE"))
    readMachineSize(incoming);
  else if (incoming.startsWith("PGMMPERREV"))
    readMmPerRev(incoming);
  else if (incoming.startsWith("PGSTEPSPERREV"))
    readStepsPerRev(incoming);
//  else if (incoming.startsWith("ACK"))
//    respondToAckCommand(incoming);
  else if ("RESEND".equals(incoming))
    resendLastCommand();
  else if ("DRAWING".equals(incoming))
    drawbotReady = false;
  else if (incoming.startsWith("MEMORY"))
    extractMemoryUsage(incoming);

  if (drawbotReady)
    drawbotConnected = true;
}

void extractMemoryUsage(String mem)
{
  String[] splitted = split(mem, ",");
  if (splitted.length == 3)
  {
    machineAvailMem = Integer.parseInt(splitted[1]);
    machineUsedMem = currentSram - machineAvailMem;
    if (machineAvailMem < machineMinAvailMem)
      machineMinAvailMem = machineAvailMem;
  }
}

void readMachinePosition(String sync)
{
  String[] splitted = split(sync, ",");
  if (splitted.length == 4)
  {
    String currentAPos = splitted[1];
    String currentBPos = splitted[2];
    Float a = Float.valueOf(currentAPos).floatValue();
    Float b = Float.valueOf(currentBPos).floatValue();
    currentMachinePos.x = a;
    currentMachinePos.y = b;  
    currentMachinePos = getDisplayMachine().inMM(getDisplayMachine().asCartesianCoords(currentMachinePos));
  }
}
void readCartesianMachinePosition(String sync)
{
  String[] splitted = split(sync, ",");
  if (splitted.length == 4)
  {
    String currentAPos = splitted[1];
    String currentBPos = splitted[2];
    Float a = Float.valueOf(currentAPos).floatValue();
    Float b = Float.valueOf(currentBPos).floatValue();
    currentCartesianMachinePos.x = a;
    currentCartesianMachinePos.y = b;  
  }
}

void readMmPerRev(String in)
{
  String[] splitted = split(in, ",");
  if (splitted.length == 3)
  {
    String mmStr = splitted[1];
    
    float mmPerRev = Float.parseFloat(mmStr);
    getDisplayMachine().setMMPerRev(mmPerRev);
    updateNumberboxValues();
  }
}

void readStepsPerRev(String in)
{
  String[] splitted = split(in, ",");
  if (splitted.length == 3)
  {
    String stepsStr = splitted[1];
    
    Float stepsPerRev = Float.parseFloat(stepsStr);
    getDisplayMachine().setStepsPerRev(stepsPerRev);
    updateNumberboxValues();
  }
}


void readMachineSize(String in)
{
  String[] splitted = split(in, ",");
  if (splitted.length == 4)
  {
    String mWidth = splitted[1];
    String mHeight = splitted[2];
    
    Integer intWidth = Integer.parseInt(mWidth);
    Integer intHeight = Integer.parseInt(mHeight);
    
    float fWidth = getDisplayMachine().inSteps(intWidth);
    float fHeight = getDisplayMachine().inSteps(intHeight);
    
    getDisplayMachine().setSize(int(fWidth+0.5), int(fHeight+0.5));
    updateNumberboxValues();
  }
}

void readMachineName(String sync)
{
  String[] splitted = split(sync, ",");
  if (splitted.length == 3)
  {
    String name = splitted[1];
    
  }
}

//void respondToAckCommand(String ack)
//{
//  String commandOnly = ack.substring(4);
//  if (lastCommand.equals(commandOnly))
//  {
//    // that means the bot got the message!! huspag!!
//    // signal the EXECUTION
//    commandHistory.add(lastCommand);
//    String command = "EXEC";
//    lastCommand = "";
//    println("Dispatching confirmation command: " + command);
//    myPort.write(command);
//  }
//  else
//  {
//    // oh dear, the message got mangled!
//    // try again!!!!
//    if (lastCommand == null || lastCommand.equals(""))
//    {
//      println("Apparently the last command has been badly acknowledged, but there isn't one!!");
//    }
//    else
//    {
//      resendLastCommand();
//    }
//  }
//}

void resendLastCommand()
{
  println("Re-sending command: " + lastCommand);
  myPort.write(lastCommand);
  drawbotReady = false;
}

void dispatchCommandQueue()
{
  if (isDrawbotReady() 
    && (!commandQueue.isEmpty() || !realtimeCommandQueue.isEmpty())
    && commandQueueRunning)
  {
    if (pixelTimerRunning)
    {
      timeLastPixelStarted = new Date();
      numberOfPixelsCompleted++;
    }

    if (!realtimeCommandQueue.isEmpty())
    {
      String command = realtimeCommandQueue.get(0);
      lastCommand = command;
      realtimeCommandQueue.remove(0);
      println("Dispatching PRIORITY command: " + command);
    }
    else
    {
      String command = commandQueue.get(0);
      lastCommand = command;
      commandQueue.remove(0);
      println("Dispatching command: " + command);
    }
    Checksum crc = new CRC32();
    crc.update(lastCommand.getBytes(), 0, lastCommand.length());
    lastCommand = lastCommand+":"+crc.getValue();
    println("Last command:" + lastCommand);
    myPort.write(lastCommand);
    drawbotReady = false;
  }
  else if (commandQueue.isEmpty())
  {
    stopPixelTimer();
  }  
}

void startPixelTimer()
{
  timerStart = new Date();
  timeLastPixelStarted = timerStart;
  pixelTimerRunning = true;
}
void stopPixelTimer()
{
  pixelTimerRunning = false;
}

boolean isDrawbotReady()
{
  return drawbotReady;
}
boolean isDrawbotConnected()
{
  return drawbotConnected;
}

Properties getProperties()
{
  if (props == null)
  {
    FileInputStream propertiesFileStream = null;
    try
    {
      props = new Properties();
      String fileToLoad = sketchPath(propertiesFilename);
      
      File propertiesFile = new File(fileToLoad);
      if (!propertiesFile.exists())
      {
        println("saving.");
        savePropertiesFile();
        println("saved.");
      }
      
      propertiesFileStream = new FileInputStream(propertiesFile);
      props.load(propertiesFileStream);
      println("Successfully loaded properties file " + fileToLoad);
    }
    catch (IOException e)
    {
      println("Couldn't read the properties file - will attempt to create one.");
      println(e.getMessage());
    }
    finally
    {
      try 
      { 
        propertiesFileStream.close();
      }
      catch (Exception e) 
      {
        println("Exception: "+e.getMessage());
      };
    }
  }
  return props;
}

void loadFromPropertiesFile()
{
  getDisplayMachine().loadDefinitionFromProperties(getProperties());
  this.pageColour = getColourProperty("controller.page.colour", color(220));
  this.frameColour = getColourProperty("controller.frame.colour", color(200,0,0));
  this.machineColour = getColourProperty("controller.machine.colour", color(150));
  this.guideColour = getColourProperty("controller.guide.colour", color(255));
  this.backgroundColour = getColourProperty("controller.background.colour", color(100));
  this.densityPreviewColour = getColourProperty("controller.densitypreview.colour", color(0));
  this.chromaKeyColour = getColourProperty("controller.pixel.mask.color", color(0,255,0));

  // pen size
  this.currentPenWidth = getFloatProperty("machine.pen.size", 0.8);

  this.currentMachineMaxSpeed = getFloatProperty("machine.motors.maxSpeed", 600.0);
  this.currentMachineAccel = getFloatProperty("machine.motors.accel", 400.0);
  
  // serial port
  this.serialPortNumber = getIntProperty("controller.machine.serialport", 0);

  // row size
  this.gridSize = getFloatProperty("controller.grid.size", 100.0);
  this.sampleArea = getIntProperty("controller.pixel.samplearea", 2);
  // initial screen size
  this.windowWidth = getIntProperty("controller.window.width", 650);
  this.windowHeight = getIntProperty("controller.window.height", 400);

  this.testPenWidthStartSize = getFloatProperty("controller.testPenWidth.startSize", 0.5);
  this.testPenWidthEndSize = getFloatProperty("controller.testPenWidth.endSize", 2.0);
  this.testPenWidthIncrementSize = getFloatProperty("controller.testPenWidth.incrementSize", 0.5);
  
  this.maxSegmentLength = getIntProperty("controller.maxSegmentLength", 1);
  
  float homePointX = getFloatProperty("controller.homepoint.x", 0.0);
  float homePointY = getFloatProperty("controller.homepoint.y", 0.0);
  
  if (homePointX == 0.0)
  {
    float defaultX = getDisplayMachine().getWidth() / 2.0;    // in steps
    float defaultY = getDisplayMachine().getPage().getTop();  // in steps
//    homePointX = getDisplayMachine().inMM(defaultX);
//    homePointY = getDisplayMachine().inMM(defaultY);
    println("Loading default homepoint.");
  }
  this.homePointCartesian = new PVector(getDisplayMachine().inSteps(homePointX), getDisplayMachine().inSteps(homePointY));
//  println("home point loaded: " + homePointCartesian + ", " + getHomePoint());
  
  setVectorFilename(getStringProperty("controller.vector.filename", null));
  if (getVectorFilename() != null)
  {
    RShape shape = RG.loadShape(getVectorFilename());
    if (shape != null) 
    {
      setVectorShape(shape);
    }
    else 
    {
      println("File not found (" + getVectorFilename() + ")");
    }
  }
  vectorScaling = getFloatProperty("controller.vector.scaling", 100.0);
  getVectorPosition().x = getFloatProperty("controller.vector.position.x", 0.0);
  getVectorPosition().y = getFloatProperty("controller.vector.position.y", 0.0);
  

  
  println("Finished loading configuration from properties file.");
}

void savePropertiesFile()
{
  Properties props = new Properties();
  
  props = getDisplayMachine().loadDefinitionIntoProperties(props);

  props.setProperty("controller.page.colour", hex(this.pageColour, 6));
  props.setProperty("controller.frame.colour", hex(this.frameColour,6));
  props.setProperty("controller.machine.colour", hex(this.machineColour,6));
  props.setProperty("controller.guide.colour", hex(this.guideColour,6));
  props.setProperty("controller.background.colour", hex(this.backgroundColour,6));
  props.setProperty("controller.densitypreview.colour", hex(this.densityPreviewColour,6));

  
  // pen size
  props.setProperty("machine.pen.size", new Float(currentPenWidth).toString());
  // serial port
  props.setProperty("controller.machine.serialport", getSerialPortNumber().toString());

  // row size
  props.setProperty("controller.grid.size", new Float(gridSize).toString());
  props.setProperty("controller.pixel.samplearea", new Float(sampleArea).toString());
  // initial screen size
  props.setProperty("controller.window.width", new Integer(windowWidth).toString());
  props.setProperty("controller.window.height", new Integer(windowHeight).toString());

  props.setProperty("controller.testPenWidth.startSize", new Float(testPenWidthStartSize).toString());
  props.setProperty("controller.testPenWidth.endSize", new Float(testPenWidthEndSize).toString());
  props.setProperty("controller.testPenWidth.incrementSize", new Float(testPenWidthIncrementSize).toString());
  
  props.setProperty("controller.maxSegmentLength", new Integer(getMaxSegmentLength()).toString());
  
  props.setProperty("machine.motors.maxSpeed", new Float(currentMachineMaxSpeed).toString());
  props.setProperty("machine.motors.accel", new Float(currentMachineAccel).toString());
  
  props.setProperty("controller.pixel.mask.color", hex(this.chromaKeyColour, 6));

  PVector hp = null;  
  if (getHomePoint() != null)
  {
    hp = getHomePoint();
  }
  else
    hp = new PVector(2000.0, 1000.0);
    
  hp = getDisplayMachine().inMM(hp);
  
  props.setProperty("controller.homepoint.x", new Float(hp.x).toString());
  props.setProperty("controller.homepoint.y", new Float(hp.y).toString());
  
  if (getVectorFilename() != null)
    props.setProperty("controller.vector.filename", getVectorFilename());
    
  props.setProperty("controller.vector.scaling", new Float(vectorScaling).toString());
  props.setProperty("controller.vector.position.x", new Float(getVectorPosition().x).toString());
  props.setProperty("controller.vector.position.y", new Float(getVectorPosition().y).toString());
 
  FileOutputStream propertiesOutput = null;

  try
  {
    //save the properties to a file
    File propertiesFile = new File(sketchPath(propertiesFilename));
    if (propertiesFile.exists())
    {
      propertiesOutput = new FileOutputStream(propertiesFile);
      Properties oldProps = new Properties();
      FileInputStream propertiesFileStream = new FileInputStream(propertiesFile);
      oldProps.load(propertiesFileStream);
      oldProps.putAll(props);
      oldProps.store(propertiesOutput,"   ***  Polargraph properties file   ***  ");
      println("Saved settings.");
    }
    else
    { // create it
      propertiesFile.createNewFile();
      propertiesOutput = new FileOutputStream(propertiesFile);
      props.store(propertiesOutput,"   ***  Polargraph properties file   ***  ");
      println("Created file.");
    }
  }
  catch (Exception e)
  {
    println("Exception occurred while creating new properties file: " + e.getMessage());
  }
  finally
  {
    if (propertiesOutput != null)
    {
      try
      {
        propertiesOutput.close();
      }
      catch (Exception e2) {println("what now!"+e2.getMessage());}
    }
  }
}

boolean getBooleanProperty(String id, boolean defState) 
{
  return boolean(getProperties().getProperty(id,""+defState));
}
 
int getIntProperty(String id, int defVal) 
{
  return int(getProperties().getProperty(id,""+defVal)); 
}
 
float getFloatProperty(String id, float defVal) 
{
  return float(getProperties().getProperty(id,""+defVal)); 
}
String getStringProperty(String id, String defVal)
{
  return getProperties().getProperty(id, defVal);
}
color getColourProperty(String id, color defVal)
{
  color col = color(180);
  String colStr = getProperties().getProperty(id, "");
  if ("".equals(colStr))
  {
    col = defVal;
  }
  
  if (colStr.length() == 1)
  {
    // single value grey
    colStr = colStr+colStr;
    col = color(unhex(colStr));
  }
  else if (colStr.length() == 3)
  {
    // 3 digit rgb
    String d1 = colStr.substring(0,1);
    String d2 = colStr.substring(1,2);
    String d3 = colStr.substring(2,3);
    d1 = d1+d1;
    d2 = d2+d2;
    d3 = d3+d3;
    
    col = color(unhex(d1), unhex(d2), unhex(d3));
  }
  else if  (colStr.length() == 6)
  {
    // 6 digit rgb
    String d1 = colStr.substring(0,2);
    String d2 = colStr.substring(2,4);
    String d3 = colStr.substring(4,6);
    
    col = color(unhex(d1), unhex(d2), unhex(d3));
  }
  
  return col;
}

Integer getSerialPortNumber()
{
  return this.serialPortNumber;
}
String getStoreFilename()
{
  return this.storeFilename;
}
void setStoreFilename(String filename)
{
  this.storeFilename = filename;
}

boolean getOverwriteExistingStoreFile()
{
  return this.overwriteExistingStoreFile;
}
void setOverwriteExistingStoreFile(boolean over)
{
  this.overwriteExistingStoreFile = over;
}
  
void initProperties()
{
  getProperties();
}

PVector getVectorPosition()
{
  return vectorPosition;
}


