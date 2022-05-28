//Scans all the pixels and then sends all the information via OSC to supercollider
void sendPixelInformation(){
  for(int i = 0; i<numSteps; i++){
   paintPad[i].updateColorAmount();
   paintPad[i].sendColorInformation();
  }
}

void setupHandyRenderers(){
  hPencil = HandyPresets.createWaterAndInk(this);
  hPencil.setIsHandy(true);
  hPencil.setOverrideStrokeColour(true);
  hPencil.setStrokeWeight(10);

  
  hColorPad = new HandyRenderer(this);
  hColorPad.setIsAlternating(true);
  hColorPad.setFillGap(3);
  hColorPad.setSeed(69420);
  hColorPad.setOverrideFillColour(true);
  hColorPad.setRoughness(2);
  
  hPaintablePad = new HandyRenderer(this);
  hPaintablePad.setRoughness(1);
  hPaintablePad.setStrokeWeight(2);
  hPaintablePad.setOverrideStrokeColour(true);
  hPaintablePad.setStrokeColour(color(0,0,0));
  hPaintablePad.setOverrideFillColour(true);
  hPaintablePad.setFillColour(color(255,255,255));
  
  hBackground = new HandyRenderer(this);
  hBackground.setStrokeWeight(3);
  hBackground.setRoughness(3);
  hBackground.setBackgroundColour(color(234,215,182));
  hBackground.setFillGap(50);
  hBackground.setIsAlternating(false);
  
  hInstrumentPad = new HandyRenderer(this);
  hInstrumentPad.setOverrideStrokeColour(true);
  hInstrumentPad.setBackgroundColour(color(167,200,76));
  hInstrumentPad.setOverrideFillColour(true);
  hInstrumentPad.setFillColour(color(255,0,0));
  hInstrumentPad.setFillGap(5);
  hInstrumentPad.setStrokeWeight(3);
  hInstrumentPad.setHachurePerturbationAngle(15);
  hInstrumentPad.setRoughness(1);
  hInstrumentPad.setIsAlternating(true);
  hInstrumentPad.setStrokeColour(color(0));
  
  hSelectionPad = new HandyRenderer(this);
  hSelectionPad.setOverrideStrokeColour(true);
  hSelectionPad.setStrokeColour(color(255,255,255));
  hSelectionPad.setRoughness(1);
  hSelectionPad.setStrokeWeight(5);
  
  hThunder = HandyPresets.createPencil(this);
  hThunder.setRoughness(5);
  hThunder.setStrokeWeight(5);
  hThunder.setStrokeColour(color(0,0,255));
  
  hFiveVPad = new HandyRenderer(this);
  hFiveVPad.setOverrideStrokeColour(true);
  hFiveVPad.setStrokeColour(color(0,0,0));
  hFiveVPad.setStrokeWeight(3);
  hFiveVPad.setOverrideFillColour(true);
  hFiveVPad.setFillColour(color(255,200,100));
  hFiveVPad.setFillGap(5);
  hFiveVPad.setHachurePerturbationAngle(85);
  hFiveVPad.setIsAlternating(true);
  hFiveVPad.setRoughness(1);
  hFiveVPad.setBackgroundColour(color(167,200,76));
}

void setupClassObjects(){
  
  selectionPad = new SelectionPad[numSelectionPad];
  instrumentPad = new InstrumentPad[numInstrumentPad];
  
  fiveVPad = new FiveVPad(circleSize/2+5, height/2);
  
  float selectionRadius = width/3;
  float angleIncrement = PI/(numSelectionPad-1);
  //Manually initialize all the assignable pads slots
  for(int j = 0; j < numSelectionPad; j++)
   selectionPad[j] = new SelectionPad((int)(circleSize+selectionRadius*cos(PI/2-j*angleIncrement)),(int)(height/2+selectionRadius*sin(PI/2-j*angleIncrement)));
  
  
  for(int j = 0; j<numInstrumentPad; j++)
   instrumentPad[j] = new InstrumentPad((int)(width-circleSize), (int)(height/2 + random(-200,200)));

  //Initialize class objects
  colorPad = new ColorPad[numColors];
  for(int j = 0; j<numColors; j++)
    colorPad[j] = new ColorPad(j*width/4+circleSize, circleSize + 10);
    
  paintPad = new PaintablePad[numSteps];
  for(int i = 0; i<numSteps;i++){
    paintPad[i] = new PaintablePad(i*width/8,height/2,width/8,height/4,i);
    paintPad[i].show(true);
  } 
}

void firstSequencerSetup(){
  background(255);
  hBackground.rect(5,5,width-5,height-5);
  for(int j = 0; j<numColors; j++)
    colorPad[j].show();
  for(int i = 0; i<numSteps;i++)
    paintPad[i].show(true);
    
  saveSequencerScreen();
}
void sequencer(){
  for(int j = 0; j<numColors; j++)
    colorPad[j].show();
  for(int i = 0; i<numSteps;i++)
    paintPad[i].show(false);
}

void saveSequencerScreen(){
  sequencerScreenBackup = get();
}

void loadSequencerScreen(){
  set(0,0,sequencerScreenBackup);
}

void assignment(){
  background(255);
  //Fill just to overwrite the noFill()
  fill(255);
  hBackground.setSeed(440);
  hBackground.rect(5,5,width-5,height-5);

  fiveVPad.show();
  
  for(int j = 0; j<numSelectionPad; j++){
    selectionPad[j].show();
    if(selectionPad[j].isFull()){
      selectionPad[j].thunder();
    }
  }
  fill(255);
      
  for(int j = 0; j<numInstrumentPad; j++)
    instrumentPad[j].show();
}
