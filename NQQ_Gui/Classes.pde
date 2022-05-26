class Pad{
  float x, y;
  int c1,c2;
  float r;
  
  Pad(){
    this.x = random(circleSize, width-circleSize);
    this.y = random(circleSize, height-circleSize);;
    this.r = circleSize;
    this.c1 = 255*(int)this.x/width;
    this.c2 = 255*(int)this.y/height;
  };
  
  Pad(float x, float y){
   this.x = x;
   this.y = y;
   this.r = circleSize;
   this.c1 = 255*(int)this.x/width;
   this.c2 = 255*(int)this.y/height;
  }
  
  void setX(float x){
    this.x = x;
  }
  
  float getX(){
    return this.x;
  }
  
  void setY(float y){
    this.y = y;
  }
  
  float getY(){
    return this.y;
  }
  
  void setR(int r){
    this.r = r;
  }
  
  float getR(){
    return this.r;
  }
  
  void setC1(int c1){
    this.c1 = c1;
  }
  
  void setC2(int c2){
    this.c2 = c2;
  }
  
  void isMoved(){};
  
  boolean isIn (int xm,int ym){
    if(dist(xm,ym,this.x,this.y)<=this.r/2)
      return true;
    else
      return false;
  }
  
  void show(){
    fill(c1,c2,200);
    circle(x,y,r);
  }
}

class SelectionPad extends Pad{
  boolean full = false;
  
  float thunderAngle;
  float thunderDistance;
  int thunderTime = 0;
  int thunderDuration = 20;

  
  SelectionPad(float x, float y){
   this.x = x;
   this.y = y;
   this.r = circleSize;
   this.thunderDistance = dist(x,y,fiveVPad.getX(),fiveVPad.getY());
   this.setAngle();
  }
  
  void show(){
    noFill();
    stroke(255);
    h.setRoughness(0);
    strokeWeight(5);
    h.ellipse(x,y,r,r);
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

class InstrumentPad extends Pad{
  int seed;
  int snappedTo = -1;
  
  InstrumentPad(){
    this.x = width - circleSize;
    this.y = 200; 
    seed = (int)random(0,69420);
  }
  InstrumentPad(float x, float y){
    this.x = x;
    this.y = y;
    this.r = circleSize;
    seed = (int)random(0,69420);
  }
  
  void show(){
    stroke(0);
    h.setHachurePerturbationAngle(15);
    h.setFillGap(5);
    h.setSeed(this.seed);
    h.setRoughness(1);
    h.setBackgroundColour(color(167,200,76));
    fill(color(255,0,0));
    strokeWeight(3);
    h.setIsAlternating(true);
    h.setStrokeColour(color(255));
    h.ellipse(x,y,r,r);
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

class FiveVPad extends Pad{
  int seed;
  
  FiveVPad(float x, float y){
    this.x = x;
    this.y = y;
    this.r = circleSize;
    seed = (int)random(0,69420);
  }
  
  void show(){
    stroke(0);
    h.setHachurePerturbationAngle(85);
    h.setFillGap(5);
    h.setSeed(this.seed);
    h.setRoughness(1);
    h.setBackgroundColour(color(167,200,76));
    fill(color(255,200,100));
    strokeWeight(3);
    h.setIsAlternating(true);
    h.setStrokeColour(color(255));
    h.ellipse(x,y,r,r);
  }
  
}
