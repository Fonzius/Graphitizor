void fxWindow(){
  background(255);
    
  drawLines();
   
  noStroke();
  for(int j = 0; j<numFxPad; j++)
    fxPad[j].show();
}
