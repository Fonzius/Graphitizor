void assignmentWindow(){
  rectMode(CORNER);
 
  h.setBackgroundColour(color(234,215,182));
  fill(255);
  h.setHachurePerturbationAngle(45);
  h.setFillGap(50);
  h.setIsAlternating(false);
  h.rect(5,5,width-5,height-5);

  fiveVPad.show();
  
  for(int j = 0; j<numSelectionPad; j++){
    ellipseMode(CENTER);
    selectionPad[j].show();
    if(selectionPad[j].isFull()){
      selectionPad[j].thunder();
    }
  }
      
  for(int j = 0; j<numInstrumentPad; j++)
    instrumentPad[j].show();
}
