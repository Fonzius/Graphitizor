
void mousePressed(MouseEvent e){
  int xm = e.getX();
  int ym = e.getY();
  
  float distance;
  float temp;
  
  if(fxMode==true){
    tempPads = fxPad;
    numTempPads = numFxPad;
  }
  else{
    tempPads = instrumentPad;
    numTempPads = numInstrumentPad;
  }
 
  distance = maxDistance;

  for(int j = 0; j<numTempPads; j++){
    if(tempPads[j].isIn(xm,ym)){
      
      temp = dist(xm, ym, tempPads[j].getX(), tempPads[j].getY());
      
      if( temp < distance){
         distance = temp;
         currentlyMoving = j;
      }
    }
  }
  if(currentlyMoving!=-1){
    mouseDistanceX = tempPads[currentlyMoving].getX()-xm;
    mouseDistanceY = tempPads[currentlyMoving].getY()-ym;
    tempPads[currentlyMoving].isMoved();
  }
}

void mouseReleased(){
  if(fxMode == false && currentlyMoving>=0 && currentlyMoving<=numInstrumentPad)
    instrumentPad[currentlyMoving].snap();
 
  currentlyMoving = -1;
  mouseDistanceX = 0;
  mouseDistanceY = 0;
  
  
}

void mouseDragged(MouseEvent e) 
{
  if(currentlyMoving != -1){
    int xm = e.getX();
    int ym = e.getY();
    
    tempPads[currentlyMoving].setX(xm+mouseDistanceX);
    tempPads[currentlyMoving].setY(ym+mouseDistanceY);
    tempPads[currentlyMoving].setC1((int) 255*xm/width);
    tempPads[currentlyMoving].setC2((int) 255*ym/height); 
  }
}

void keyPressed(){
  if(key == CODED){
    if(keyCode == UP){
      if(fxMode == true){
        fxMode = false;
      }
      else{
        fxMode = true;
      }
    }
  }
}

void oscEvent(OscMessage msg){
  if(msg.checkAddrPattern("/harpVolume")){
    println("ysysys");
    hThunder.setStrokeColour(color(0,0,255-msg.get(0).intValue()));
  }
}
