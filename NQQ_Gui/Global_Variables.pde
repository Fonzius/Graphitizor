HandyRenderer h;
HandyRenderer hThunder;

OscP5 osc;
NetAddress supercollider;

int numSegments = 25;
int numFxPad = 8;
int numSelectionPad = 6;
int numInstrumentPad = 3;
int numTempPads;

Pad[] fxPad;
Pad[] tempPads;
SelectionPad[] selectionPad;
InstrumentPad[] instrumentPad;
FiveVPad fiveVPad;

float circleSize = 100.00;

int radius = 0;

int currentlyMoving = -1;
float mouseDistanceX = 0.00;
float mouseDistanceY = 0.00;

boolean fxMode = false;

float maxDistance = dist(0,0,width,height);
