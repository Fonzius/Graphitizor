void drawLines(){
  noFill();
  stroke(0.00,0.00,255.00,150+random(-50,50));
  strokeWeight(4);
  for(int i = 0; i<numFxPad-1; i++){
    for(int j = i+1; j<numFxPad; j++){
      float startX = fxPad[i].getX();
      float startY = fxPad[i].getY();
      float endX = fxPad[j].getX();
      float endY = fxPad[j].getY();
      
      beginShape();
      for(int k = 0; k<numSegments; k++)
        vertex(startX+k*(endX-startX)/numSegments+random(-4,4), startY+k*(endY-startY)/numSegments+random(-4,4));
      endShape();
    }
  } 
}
