import org.gicentre.handy.*;
import oscP5.*;
import netP5.*;

void setup(){
  size(1000,800);
  
  background(255);
  rectMode(CORNER);
  ellipseMode(CENTER);
  strokeJoin(ROUND);
  
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
        
         temp = dist(xm, ym, instrumentPad[j].getX(), instrumentPad[j].getY());
        
         if( temp < distance){
           distance = temp;
           currentlyMoving = j;
        }
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
}
