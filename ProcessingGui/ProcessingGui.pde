import org.gicentre.handy.*;
import oscP5.*;
import netP5.*;

void setup(){
  size(1000,800);
  
  font = createFont("Rocky Age.ttf", 50);
  fontina = createFont("Rocky Age.ttf", 30);

  textAlign(CENTER,CENTER);

  background(255);
  rectMode(CORNER);
  ellipseMode(CENTER);
  strokeJoin(ROUND);
  imageMode(CENTER);
  
  //Setup OSC communication with Supercollider
  osc = new OscP5(this, 12000);
  supercollider = new NetAddress("127.0.0.1", 57120);
  
  //Setup all render styles
  setupHandyRenderers();
  //Object declarations
  setupClassObjects();
    
  //Initialize the standard mouse color
  mouseColor = colorPad[0].getC();
  
  firstSequencerSetup();
}


void draw(){
  
  if(mode == "sequencer")
    sequencer();
  else if(mode == "assignment")
    assignment();
}

//Mousereleased instead of clicked because it was messing up if dragged on the pad, you'd have to be perfectly still while clicking
void mouseReleased(MouseEvent e){
  if(mode == "sequencer"){
    //Looks for what color the mouse is on and changes the mousecolor accordingly
    for(int j = 0; j<numColors; j++)
      if(colorPad[j].isIn(e.getX(),e.getY()))
         mouseColor = colorPad[j].getC();     
    sendPixelInformation();
  }
  else if(mode == "assignment"){
    if(currentlyMoving>=0 && currentlyMoving<=numInstrumentPad)
      instrumentPad[currentlyMoving].snap();
 
    currentlyMoving = -1;
    mouseDistanceX = 0;
    mouseDistanceY = 0;
  }
}

void mousePressed(MouseEvent e){
  //For the Sequencer
  oldmx = e.getX();
  oldmy = e.getY();
  
  if(mode == "assignment"){
    //Looks for the nearest pad to move and then moves it keeping the relative distance to the mouse intact
    int xm = oldmx;
    int ym = oldmy;
   
    float distance;
    float temp;
    distance = maxDistance;
     
     for(int j = 0; j<numInstrumentPad; j++){
       if(instrumentPad[j].isIn(xm,ym)){
         if(e.getCount()==1){
           temp = dist(xm, ym, instrumentPad[j].getX(), instrumentPad[j].getY());
          
           if( temp < distance){
             distance = temp;
             currentlyMoving = j;
           }
         }
         else
           instrumentPad[j].reset();
      }
    }
    if(currentlyMoving!=-1){
      mouseDistanceX = instrumentPad[currentlyMoving].getX()-xm;
      mouseDistanceY = instrumentPad[currentlyMoving].getY()-ym;
      instrumentPad[currentlyMoving].isMoved();
    }
  }
}

void mouseDragged(MouseEvent e){
  int currentmx = e.getX();
  int currentmy = e.getY();
  
  if(mode == "sequencer"){
    boolean inSeq = false;
    for(int j = 0; j<numColors; j++)
      if(currentmy>2*height/4 && currentmy<3*height/4){
        inSeq = true;
        break;
      }
    if(inSeq == true){
     hPencil.setStrokeColour(mouseColor);
     hPencil.line(oldmx, oldmy, e.getX(), e.getY());
    }
    oldmx = currentmx;
    oldmy = currentmy;
  }
  else if(mode == "assignment"){ 
    if(currentlyMoving != -1){
      instrumentPad[currentlyMoving].setX((int)(currentmx+mouseDistanceX));
      instrumentPad[currentlyMoving].setY((int)(currentmy+mouseDistanceY));
    }
  }
}

void keyPressed(){
  if(key == CODED){
    if(keyCode == LEFT){
      if(mode == "sequencer"){
        saveSequencerScreen();
        mode = "assignment";
      }
    }
    else if(keyCode == RIGHT){
      if(mode == "assignment"){
        loadSequencerScreen();
        mode = "sequencer";
      }
    }
  }
  else if(key == '1')
    hPencil.setStrokeWeight(10);
  else if(key == '2')
    hPencil.setStrokeWeight(15);
  else if(key == '3')
    hPencil.setStrokeWeight(20);
  else if(key == '4')
    hPencil.setStrokeWeight(30);
  else if(key == '5')
    hPencil.setStrokeWeight(50);
  else if(key == 'e')
    mouseColor = color(255,255,255);
  else if(key == 'r' && mode == "sequencer"){
    fill(255);
    firstSequencerSetup();
  }
  else if(key == '-' && numSteps > 1){
    numSteps--;
    
    OscMessage msg = new OscMessage("/seqLenght");
    msg.add(numSteps);
    osc.send(msg, supercollider);
    
    firstSequencerSetup();
  }
  else if(key == '+' && numSteps <8){
    numSteps++;

    OscMessage msg = new OscMessage("/seqLenght");
    msg.add(numSteps);
    osc.send(msg, supercollider);
    
    firstSequencerSetup();

  }
}

void oscEvent(OscMessage msg){
 if(msg.checkAddrPattern("/volumeHigh")){
   selectionPad[2].setIntensity(msg.get(0).intValue());
 }
 if(msg.checkAddrPattern("/volumeLow")){
   selectionPad[0].setIntensity(msg.get(0).intValue());
 }
 if(msg.checkAddrPattern("/volumeMed")){
   selectionPad[1].setIntensity(msg.get(0).intValue());
 }
}
