
//ANALOGS
#define TEMPO_PIN A0 // +1 145 - 133
#define DRUM_VOLUME_PIN A1// +2 146 - 134
#define INSTRUMENT_VOLUME_PIN A2// +3 147 - 135
#define KEY_PIN A3 // +4 148 - 136
//A4 +5 149 - 137
//A5 +6 150 - 138

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
int newReadInstrumentVolume = 0;
int newReadDrumVolume = 0;
int newReadKey = 0;

int oldReadTempo = 0;
int oldReadInstrumentVolume = 0;
int oldReadDrumVolume = 0;
int oldReadKey = 0;

bool tempoOnFlag = false;
bool instrumentOnFlag = false;
bool drumOnFlag = false;
bool keyOnFlag = false;

int stepThreshold = 1;
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
  pinMode(INSTRUMENT_VOLUME_PIN,INPUT);
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
  // Max velocity fixed for now but the protocol may be changed

  for(int i = 0; i < 12; i++){

    if(i<5
    )
      newReadPin[i] = !digitalRead(i+2);
    //Serial.println(newReadPin[i]);
    //delay(500);
    
    if((newReadPin[i] != oldReadPin[i]) && newReadPin[i]){
      midiMsg(MIDI_NOTE_ON, i ,0x7F);
    }else if((newReadPin[i] != oldReadPin[i]) && !newReadPin[i]){
      midiMsg(MIDI_NOTE_OFF, i ,0x7F);
    }
    
    oldReadPin[i] = newReadPin[i];
    
  }

  //ANALOG READINGS

  //ANALOG INPUT
  newReadTempo = analogRead(TEMPO_PIN);
  newReadDrumVolume = analogRead(DRUM_VOLUME_PIN);
  newReadInstrumentVolume = analogRead(INSTRUMENT_VOLUME_PIN);
  newReadKey = analogRead(KEY_PIN);

  //Conversion from 1023 - 0 to 0 - 255 (the reading is done in pull)
  newReadTempo = 255 - ((int)newReadTempo/4);
  newReadDrumVolume = 255 - ((int)newReadDrumVolume/4);
  newReadInstrumentVolume = 255 - ((int)newReadInstrumentVolume/4);
  newReadKey = 255 - ((int)newReadKey/4);

  //Tempo
  if(newReadTempo > offThreshold){
    if(abs(newReadTempo - oldReadTempo) > stepThreshold){
      midiMsg(MIDI_NOTE_ON +1, newReadTempo, 0x7F);
      tempoOnFlag = true;
      oldReadTempo = newReadTempo;
    }
  } else if (tempoOnFlag) {
    midiMsg(MIDI_NOTE_OFF + 1, newReadTempo, 0x7F);
    tempoOnFlag = false;
  }

  //Drum volume
  if(newReadDrumVolume > offThreshold){
    if(abs(newReadDrumVolume - oldReadDrumVolume) > stepThreshold){
      midiMsg(MIDI_NOTE_ON +2, newReadDrumVolume, 0x7F);
      drumOnFlag = true;
      oldReadDrumVolume = newReadDrumVolume;
    }
  } else if (drumOnFlag) {
    midiMsg(MIDI_NOTE_OFF + 2, newReadDrumVolume, 0x7F);
    drumOnFlag = false;
  }

  //Instrument Volume
  if(newReadInstrumentVolume > offThreshold){
    if(abs(newReadInstrumentVolume - oldReadInstrumentVolume) > stepThreshold){
      midiMsg(MIDI_NOTE_ON +3, newReadInstrumentVolume, 0x7F);
      instrumentOnFlag = true;
      oldReadInstrumentVolume = newReadInstrumentVolume;
    }
  } else if (instrumentOnFlag) {
    midiMsg(MIDI_NOTE_OFF + 3, newReadInstrumentVolume, 0x7F);
    instrumentOnFlag = false;
  }

  //Key
  if(newReadKey > offThreshold){
    if(abs(newReadKey - oldReadKey) > stepThreshold){
      midiMsg(MIDI_NOTE_ON +4, newReadKey, 0x7F);
      keyOnFlag = true;
      oldReadKey = newReadKey;
    }
  } else if (keyOnFlag) {
    midiMsg(MIDI_NOTE_OFF + 4, newReadKey, 0x7F);
    keyOnFlag = false;
  }   
    
  delay(1); //optional
  
}

// --------------------------------------------- //
// -------- FUNCTIONS -------------------------- //

void midiMsg(int cmd, int pitch, int velocity) {
  //Serial.print('z'); // z = midi message start
  Serial.print(cmd); 
  Serial.print('a'); // a = fine command
  Serial.print(pitch);
  Serial.print('b'); // b = fine pitch
  Serial.print(velocity);
  Serial.print('c'); // c = fine velocity e fine midi message
  Serial.println(' ');
}
