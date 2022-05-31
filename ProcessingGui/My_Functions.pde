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
  hColorPad.setRoughness(1);
  hColorPad.setStrokeWeight(2);
  
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
  hInstrumentPad.setOverrideFillColour(true);
  hInstrumentPad.setStrokeWeight(3);
  hInstrumentPad.setRoughness(1);
  hInstrumentPad.setStrokeColour(color(0));
  
  hSelectionPad = new HandyRenderer(this);
  hSelectionPad.setOverrideStrokeColour(true);
  hSelectionPad.setStrokeColour(color(255,255,255));
  hSelectionPad.setRoughness(1);
  hSelectionPad.setStrokeWeight(5);
  
  hThunder = HandyPresets.createPencil(this);
  hThunder.setRoughness(5);
  hThunder.setStrokeWeight(5);
  hThunder.setStrokeColour(color(0,0,255,100));
  
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
  
  fiveVPad = new FiveVPad(width/2, height-circleSize);
  
  float selectionRadius = width/3;
  float angleIncrement = (5*PI)/(6*(numSelectionPad-1));
  //Manually initialize all the assignable pads slots
  for(int j = 0; j < numSelectionPad; j++)
   selectionPad[j] = new SelectionPad((int)(fiveVPad.getX()+selectionRadius*cos((13*PI/12)+j*angleIncrement)),(int)(fiveVPad.getY()+selectionRadius*sin((13*PI/12)+j*angleIncrement)), selectionColor[j]);
  
  for(int j = 0; j<numInstrumentPad; j++)
   instrumentPad[j] = new InstrumentPad(circleSize+j*(width-circleSize)/numInstrumentPad, circleSize, instrumentColor[j], j);

  //Initialize class objects
  colorPad = new ColorPad[numColors];
  for(int j = 0; j<numColors; j++)
    colorPad[j] = new ColorPad(j*width/4+circleSize, circleSize + 10, drumsColor[j]);
    
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
    
  for(int i = 0; i<numSteps;i++){
    paintPad[i] = new PaintablePad(i*width/numSteps,height/2,width/numSteps,height/4,i);
    paintPad[i].show(true);
  } 
    
  saveSequencerScreen();
  sendPixelInformation();
}
void sequencer(){
  for(int j = 0; j<numColors; j++)
    colorPad[j].show();
    
  for(int i = 0; i<numSteps;i++){
    paintPad[i].show(false);
  }
  
  fill(0);
  textFont(font);
  text("Kick", colorPad[0].getX(), colorPad[0].getY()+2*circleSize/3);
  text("Snare", colorPad[1].getX(), colorPad[1].getY()+2*circleSize/3);
  text("Hihat", colorPad[2].getX(), colorPad[2].getY()+2*circleSize/3);
  text("Clap", colorPad[3].getX(), colorPad[3].getY()+2*circleSize/3);
  
  text("<- Assignment View", 330, height-40);
  
  textFont(fontina);
  text("e -> Eraser \n R -> Reset Canvas", width-200, height-160);
  text("1-5 -> Change Brush Size", 270, height-170);

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
      
  for(int j = 0; j<numInstrumentPad; j++){
    instrumentPad[j].show();
    fill(0);
    textFont(fontina);
    text(instrumentPadName[j],instrumentPad[j].getX(), instrumentPad[j].getY());
  }
  
  textFont(font);
  text("Sequencer View ->", width-330, height-40);
}

void updateThunderDuration(float durationRaw){
 int duration = (int)(20/log(1+durationRaw));
 for(int i = 0; i<numSelectionPad; i++)
   selectionPad[i].setThunderDuration(duration);
}
