import org.gicentre.handy.*;
import oscP5.*;
import netP5.*;

void setup(){
  h = new HandyRenderer(this);
  hThunder = HandyPresets.createPencil(this);
  
  hThunder.setRoughness(5);
  hThunder.setStrokeColour(color(0,0,255));
  
  //Setup OSC Communication with SC
  OscProperties properties = new OscProperties();
  properties.setListeningPort(57120);
  
  osc = new OscP5(this, properties);
  supercollider = new NetAddress("127.0.0.1", 57123);
  

  
  
  
  
  size(1000,800);
  ellipseMode(CENTER);
  
  fxPad = new Pad[numFxPad];
  selectionPad = new SelectionPad[numSelectionPad];
  instrumentPad = new InstrumentPad[numInstrumentPad];
  
  fiveVPad = new FiveVPad(circleSize/2+5, (float)height/2);
  
  for(int j = 0; j<numFxPad; j++)
    fxPad[j] = new Pad();
  
  float selectionRadius = width/3;
  float angleIncrement = PI/(numSelectionPad-1);
  //Manually initialize all the assignable pads slots
  for(int j = 0; j < numSelectionPad; j++)
   selectionPad[j] = new SelectionPad(circleSize+selectionRadius*cos(PI/2-j*angleIncrement),height/2+selectionRadius*sin(PI/2-j*angleIncrement));
  
  
   for(int j = 0; j<numInstrumentPad; j++)
    instrumentPad[j] = new InstrumentPad((float)width-circleSize, (float) height/2 + random(-200,200));
}


void draw() {
  //Synth Effect Mode, the pads control the parameters of the synth
  if(fxMode==true){
    fxWindow();
  }
  //Control Assignation Mode: the pads assign the sounds to the arduino pads
  else{
    assignmentWindow();
  }
}
