int numColors = 4;
int numSteps = 8;
int numSelectionPad = 6;
int numInstrumentPad = 3;

String mode = "sequencer";
PImage sequencerScreenBackup;

OscP5 osc;
NetAddress supercollider;

color mouseColor = color(255,255,255);

int oldmx;
int oldmy;

int circleSize = 100;

SelectionPad[] selectionPad;
InstrumentPad[] instrumentPad;
FiveVPad fiveVPad;
ColorPad[] colorPad;
PaintablePad[] paintPad;

HandyRenderer hBackground;
HandyRenderer hPencil;
HandyRenderer hColorPad;
HandyRenderer hPaintablePad;
HandyRenderer hInstrumentPad;
HandyRenderer hSelectionPad;
HandyRenderer hThunder;
HandyRenderer hFiveVPad;

int currentlyMoving = -1;
float mouseDistanceX = 0.00;
float mouseDistanceY = 0.00;

float maxDistance = dist(0,0,width,height);
