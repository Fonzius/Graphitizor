
//ANALOGS
#define TEMPO_PIN A0 // +1 145 - 133
#define DRUM_VOLUME_PIN A1 // +2 146 - 134
#define FIRST_VOLUME_PIN A2 // +3 147 - 135
#define SECOND_VOLUME_PIN A3 //A4 +5 149 - 137
#define THIRD_VOLUME_PIN A4 //A5 +6 150 - 138
#define KEY_PIN A5 // +4 148 - 136


//MIDI
#define MIDI_NOTE_ON  (0x90) // = 144
#define MIDI_NOTE_OFF   (0x80) // = 132

//WIP: try to use the midi.h library to handle everything, add a manual serial.print('start_letter') to let Supercollider know the start/end of a message.           

//Old reads flag
bool oldReadPin[12];

//New reads flag
bool newReadPin[12];

//Analog readings
int newReadTempo = 0;
int newReadFirstVolume = 0;
int newReadSecondVolume = 0;
int newReadThirdVolume = 0;
int newReadDrumVolume = 0;
int newReadKey = 0;

int oldReadTempo = 0;
int oldReadFirstVolume = 0;
int oldReadSecondVolume = 0;
int oldReadThirdVolume = 0;
int oldReadDrumVolume = 0;
int oldReadKey = 0;

bool tempoOnFlag = false;
bool firstOnFlag = false;
bool secondOnFlag = false;
bool thirdOnFlag = false;
bool drumOnFlag = false;
bool keyOnFlag = false;

int stepThreshold = 10;
int offThreshold = 1;

// -------------------------------------------------------- //
// --------------------- SETUP ---------------------------- //

void setup() {
  
  Serial.begin(115200);

  //INSTRUMENT
  for (int i = 2; i < 14; i++){
    pinMode(i,INPUT);
  }

  //ANALOGS
  pinMode(TEMPO_PIN,INPUT);
  pinMode(DRUM_VOLUME_PIN,INPUT);
  pinMode(FIRST_VOLUME_PIN,INPUT);
  pinMode(SECOND_VOLUME_PIN,INPUT);
  pinMode(THIRD_VOLUME_PIN,INPUT);
  pinMode(KEY_PIN,INPUT);


//Flag array initialization
  for(int i=0; i<12; i++){
    oldReadPin[i] = false;
    newReadPin[i] = false;
  }
  
}

// ------------------------------------------------ //
// --------------------- LOOP --------------------- //

void loop() {

  //  DIGITAL READINGS
  // Pullup reading, here negated to be used as usual
  // Everything on channel 0: [144 NOTE_ON - 132 NOTE_OFF]
  // Use the pitch message of the midi protocol to indicate the pin

  for(int i = 0; i < 12; i++){
    
    newReadPin[i] = !digitalRead(i+2);
    //Serial.println(newReadPin[i]);
    //delay(500);
    
    if((newReadPin[i] != oldReadPin[i]) && newReadPin[i]){
      delay(1);
      newReadPin[i] = !digitalRead(i+2);
      if((newReadPin[i] != oldReadPin[i]) && newReadPin[i])
        midiMsg(MIDI_NOTE_ON, i);
    }else if((newReadPin[i] != oldReadPin[i]) && !newReadPin[i]){
      delay(1);
      newReadPin[i] = !digitalRead(i+2);
      if((newReadPin[i] != oldReadPin[i]) && !newReadPin[i])
        midiMsg(MIDI_NOTE_OFF, i);
    }
    
    oldReadPin[i] = newReadPin[i];
    
  }

  //ANALOG READINGS

  //ANALOG INPUT
  newReadTempo = analogRead(TEMPO_PIN);
  newReadDrumVolume = analogRead(DRUM_VOLUME_PIN);
  newReadFirstVolume = analogRead(FIRST_VOLUME_PIN);
  newReadSecondVolume = analogRead(SECOND_VOLUME_PIN);
  newReadThirdVolume = analogRead(THIRD_VOLUME_PIN);
  newReadKey = analogRead(KEY_PIN);

  //Conversion from 1023 - 0 to 0 - 255 (the reading is done in pull)
  newReadTempo = 255 - ((int)newReadTempo/4);
  newReadDrumVolume = 255 - ((int)newReadDrumVolume/4);
  newReadFirstVolume = 255 - ((int)newReadFirstVolume/4);
  newReadSecondVolume = 255 - ((int)newReadSecondVolume/4);
  newReadThirdVolume = 255 - ((int)newReadThirdVolume/4);
  newReadKey = 255 - ((int)newReadKey/4);


  //Tempo
  if(newReadTempo > offThreshold){
    if(abs(newReadTempo - oldReadTempo) > stepThreshold){
      delay(5);
      if(abs(newReadTempo - oldReadTempo) > stepThreshold){
        midiMsg(MIDI_NOTE_ON +1, newReadTempo);
        tempoOnFlag = true;
        oldReadTempo = newReadTempo;
      }
    }
  } else if (tempoOnFlag) {
    midiMsg(MIDI_NOTE_OFF + 1, newReadTempo);
    tempoOnFlag = false;
  }

  //Drum volume
  if(newReadDrumVolume > offThreshold){
    if(abs(newReadDrumVolume - oldReadDrumVolume) > stepThreshold){
      delay(5);
      if(abs(newReadDrumVolume - oldReadDrumVolume) > stepThreshold){
        midiMsg(MIDI_NOTE_ON +2, newReadDrumVolume);
        drumOnFlag = true;
        oldReadDrumVolume = newReadDrumVolume;
      }
    }
  } else if (drumOnFlag) {
    midiMsg(MIDI_NOTE_OFF + 2, newReadDrumVolume);
    drumOnFlag = false;
  }

  //First Volume
  if(newReadFirstVolume > offThreshold){
    if(abs(newReadFirstVolume - oldReadFirstVolume) > stepThreshold){
      delay(5);
      if(abs(newReadFirstVolume - oldReadFirstVolume) > stepThreshold){
        midiMsg(MIDI_NOTE_ON +3, newReadFirstVolume);
        firstOnFlag = true;
        oldReadFirstVolume = newReadFirstVolume;
      }
    }
  } else if (firstOnFlag) {
    midiMsg(MIDI_NOTE_OFF + 3, newReadFirstVolume);
    firstOnFlag = false;
  }
  
  //Second Volume
  if(newReadSecondVolume > offThreshold){
    if(abs(newReadSecondVolume - oldReadSecondVolume) > stepThreshold){
      delay(5);
      if(abs(newReadSecondVolume - oldReadSecondVolume) > stepThreshold){
        midiMsg(MIDI_NOTE_ON +4, newReadSecondVolume);
        secondOnFlag = true;
        oldReadSecondVolume = newReadSecondVolume;
       }
    }
  } else if (secondOnFlag) {
    midiMsg(MIDI_NOTE_OFF + 4, newReadSecondVolume);
    secondOnFlag = false;
  }
  
  //Third Volume
  if(newReadThirdVolume > offThreshold){
    if(abs(newReadThirdVolume - oldReadThirdVolume) > stepThreshold){
      delay(5);
      if(abs(newReadThirdVolume - oldReadThirdVolume) > stepThreshold){
        midiMsg(MIDI_NOTE_ON +5, newReadThirdVolume);
        thirdOnFlag = true;
        oldReadThirdVolume = newReadThirdVolume;
      }
    }
  } else if (thirdOnFlag) {
    midiMsg(MIDI_NOTE_OFF + 5, newReadThirdVolume);
    thirdOnFlag = false;
  }

  //Key
  if(newReadKey > offThreshold){
    if(abs(newReadKey - oldReadKey) > stepThreshold){
      delay(5);
      if(abs(newReadKey - oldReadKey) > stepThreshold){
        midiMsg(MIDI_NOTE_ON +6, newReadKey);
        keyOnFlag = true;
        oldReadKey = newReadKey;
      }
    }
  } else if (keyOnFlag) {
    midiMsg(MIDI_NOTE_OFF + 6, newReadKey);
    keyOnFlag = false;
  }   
    
  delay(1); //optional
  
}

// --------------------------------------------- //
// -------- FUNCTIONS -------------------------- //

void midiMsg(int cmd, int pitch) {

  Serial.print(cmd); 
  Serial.print('a'); // a = end of command
  Serial.print(pitch);
  Serial.print('b'); // b = end of pitch
  Serial.println(' ');

}
