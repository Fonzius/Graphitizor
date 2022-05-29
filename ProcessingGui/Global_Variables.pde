int numColors = 4;
int numSteps = 8;
int numSelectionPad = 3;
int numInstrumentPad = 6;

String mode = "sequencer";
PImage sequencerScreenBackup;
PImage canvasControls;
PImage snare;
PFont font;
PFont fontina;


OscP5 osc;
NetAddress supercollider;

color mouseColor = color(255,255,255);

int oldmx;
int oldmy;

int circleSize = 120;

SelectionPad[] selectionPad;
InstrumentPad[] instrumentPad;
FiveVPad fiveVPad;
ColorPad[] colorPad;
PaintablePad[] paintPad;

HandyRenderer hBackground;
HandyRenderer hPencil;
HandyRenderer hColorPad;
HandyRenderer hPaintablePad;
HandyRenderer hPaintablePadAccent;
HandyRenderer hInstrumentPad;
HandyRenderer hSelectionPad;
HandyRenderer hThunder;
HandyRenderer hFiveVPad;

int currentlyMoving = -1;
float mouseDistanceX = 0.00;
float mouseDistanceY = 0.00;

float maxDistance = dist(0,0,width,height);

String[] instrumentPadName = {"Saw \n Bass","Violin","Rhodes","Pad","Pluck","Sine"};
color[] instrumentColor = {color(33,226,255), color(33,226,255), color(255,150,11), color(255,150,11), color(249,183,255),color(249,183,255)};
color[] selectionColor = {color(33,226,255), color(255,150,11), color(249,183,255)};
color[] drumsColor ={color(223,3,247), color(47,228,255), color(255,255,47), color(215,100,0)};
