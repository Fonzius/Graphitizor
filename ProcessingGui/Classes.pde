class Pad{
  int x, y;
  color c;
  
  Pad(){}
  
  void setX(int x){
    this.x = x;
  }
  
  int getX(){
    return this.x;
  }
  
  void setY(int y){
    this.y = y;
  }
  
  int getY(){
    return this.y;
  }
  void setC(color c){
    this.c = c;
  }
  color getC(){
    return c;
  }
}

class ColorPad extends Pad{ 
 int r;
 
 ColorPad(int x,int y){
   this.x = x;
   this.y = y;
   this.c = color(random(0,255),random(0,255),random(0,255));
   this.r = circleSize;
 }
 
 void show(){
   hColorPad.setSeed(69420);
   hColorPad.setFillColour(this.c);
   hColorPad.ellipse(x,y,r,r);
  }
  
  boolean isIn (int xm,int ym){
    if(dist(xm,ym,this.x,this.y)<=this.r/2)
      return true;
    else
      return false;
  }
}

class PaintablePad extends Pad{
  int padHeight, padWidth;
  int numTotalPixels;
  int[] colorAmount;
  int step;
  int seed;
  color[] instrumentsColor;
  String[] instruments = {"/kick", "/snare", "/hihat", "/clap"};
  
  PaintablePad(int x, int y, int padWidth, int padHeight, int step){
   this.x = x;
   this.y = y;
   this.padHeight = padHeight;
   this.padWidth = padWidth;
   
   this.numTotalPixels = padHeight*padWidth;
   
   this.seed = (int)random(69, 69420);
   
   this.step = step;
   
   this.colorAmount = new int[numColors];
   for(int i = 0; i<numColors; i++)
     this.colorAmount[i] = 0;
     
   this.instrumentsColor = new color[numColors];
   for(int i = 0; i<numColors; i++)
     this.instrumentsColor[i] = colorPad[i].getC();
  }
  
  void show(boolean background){
    if(background == false){
      noFill();
    }
    hPaintablePad.setSeed(this.seed);
    hPaintablePad.rect(this.x, this.y, this.padWidth, this.padHeight);
  }
  
  void updateColorAmount(){
    //Reset previous color counts
    for(int i = 0; i<numColors; i++)
     this.colorAmount[i] = 0;
    
    //count how many pixels there are for each color
    loadPixels();
    int offset, index;
    for(int j = 0; j<this.padHeight; j++){
      offset = (this.y+j)*width + this.x;
      
      for(int i = 0; i<this.padWidth; i++){
        index = offset + i;
        
        for(int k = 0; k<numColors; k++){
          if(pixels[index]==this.instrumentsColor[k]){
            this.colorAmount[k]++;
            break;
          }
        }
      }
    }  
  }
  void sendColorInformation(){
    for(int k = 0; k<numColors; k++){
          float volume = map(this.colorAmount[k], 0, numTotalPixels, 0, 2);
          if(volume>1)
            volume = 1;
          OscMessage msg = new OscMessage(this.instruments[k]);
          msg.add(this.step);
          msg.add(volume);
          
          osc.send(msg, supercollider);
    }
  }
}


class InstrumentPad extends Pad{
  int seed;
  int snappedTo = -1;
  int r;
  
  InstrumentPad(){
    this.x = width - circleSize;
    this.y = 200; 
    seed = (int)random(0,69420);
  }
  InstrumentPad(int x, int y){
    this.x = x;
    this.y = y;
    this.r = circleSize;
    seed = (int)random(0,69420);
  }
  
  void show(){
    hInstrumentPad.setSeed(this.seed);
    hInstrumentPad.ellipse(x,y,r,r);
  }
  
  void isMoved(){
    if(snappedTo!=-1){
      OscMessage msg = new OscMessage("/snapped");
      msg.add(-snappedTo);
      osc.send(msg, supercollider);
      
      selectionPad[snappedTo].empty();
      this.snappedTo = -1;
    }
  }
  boolean isIn (int xm,int ym){
    if(dist(xm,ym,this.x,this.y)<=this.r/2)
      return true;
    else
      return false;
  }
  
  void snap(){
    for(int j = 0; j<numSelectionPad; j++){
      if(dist(selectionPad[j].getX(),selectionPad[j].getY(),this.x,this.y)<=circleSize && !selectionPad[j].isFull()){
        this.x = selectionPad[j].getX();
        this.y = selectionPad[j].getY();
        
        selectionPad[j].fill();
        snappedTo = j;
        
        OscMessage msg = new OscMessage("/snapped");
        msg.add(snappedTo);
        osc.send(msg, supercollider);
        break;
      }
    }
  }
}

class SelectionPad extends Pad{
  boolean full = false;
  int r;
  int seed;
  
  float thunderAngle;
  float thunderDistance;
  int thunderTime = 0;
  int thunderDuration = 20;

  
  SelectionPad(int x, int y){
   this.x = x;
   this.y = y;
   this.r = circleSize;
   this.thunderDistance = dist(x,y,fiveVPad.getX(),fiveVPad.getY());
   this.setAngle();
   this.seed = (int)random(0,69420);
  }
  
  void show(){
    noFill();
    hSelectionPad.setSeed(this.seed);
    hSelectionPad.ellipse(x,y,r,r);
  }
  void fill(){
   this.full = true; 
  }
  
  void empty(){
   this.full = false; 
   //Reset Thunder animation when pad is moved
   this.thunderTime = 0;
  }
  boolean isFull(){
   return full;
  }
  
  void setAngle(){    
    float xD = this.x-fiveVPad.getX();
    float yD = this.y-fiveVPad.getY();
  
    if (xD > 0)
      thunderAngle = atan(yD / xD);
    else if (xD < 0)
      thunderAngle = (atan(yD / xD) + PI);
    else if (xD == 0) {
      if (yD > 0)
        thunderAngle = HALF_PI;
    else
      thunderAngle = - HALF_PI;
    }
  }
  void thunder(){
  
    int tLenght = thunderDuration/2; 
    
    float ax = fiveVPad.getX();
    float ay = fiveVPad.getY();
    
    if(this.thunderTime < tLenght){
      hThunder.beginShape();
        for(int i = 0; i<=thunderTime; i++){
          hThunder.vertex(ax + i*thunderDistance*cos(thunderAngle)/thunderDuration, ay+i*thunderDistance*sin(thunderAngle)/thunderDuration);
        }
      hThunder.endShape();
    }
    
    else if(this.thunderTime >= tLenght && this.thunderTime <= thunderDuration){
      hThunder.beginShape();
        for(int i = thunderTime-tLenght; i<=thunderTime; i++){
          hThunder.vertex(ax + i*thunderDistance*cos(thunderAngle)/thunderDuration, ay+i*thunderDistance*sin(thunderAngle)/thunderDuration);
        }
      hThunder.endShape();
    }
   else if(this.thunderTime > thunderDuration && this.thunderTime <= thunderDuration+tLenght){
     hThunder.beginShape();
       for(int i = thunderTime-tLenght; i<=thunderDuration; i++){
         hThunder.vertex(ax + i*thunderDistance*cos(thunderAngle)/thunderDuration, ay+i*thunderDistance*sin(thunderAngle)/thunderDuration);
       }
     hThunder.endShape();
   }
  
   if(this.thunderTime<thunderDuration+tLenght)
     this.thunderTime++;
     
   else
     this.thunderTime = 0;
  } 
}

class FiveVPad extends Pad{
  int seed;
  int r;
  
  FiveVPad(int x, int y){
    this.x = x;
    this.y = y;
    this.r = circleSize;
    seed = (int)random(0,69420);
  }
  
  void show(){
    hFiveVPad.setSeed(this.seed);
    hFiveVPad.ellipse(x,y,r,r);
  }
}