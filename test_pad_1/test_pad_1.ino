#define KICK_PIN  5 // +0
#define SNARE_PIN 6 // +1
#define CLAP_PIN 7 // +2
#define HIHAT_PIN 8 // +3
#define HARP_PIN 9 // +4

#define SYNTH_PITCH_PIN A0 //+5

#define MIDI_NOTE_ON  (0x90)
#define MIDI_NOTE_OFF   (0x80)

//WIP: try to use the midi.h library to handle everything, add a manual serial.print('start_letter') to let Supercollider know the start/end of a message.           

bool oldReadKick = false;
bool oldReadSnare = false;
bool oldReadClap = false;
bool oldReadHiHat = false;
bool oldReadHarp = false;
bool synthFlag = false;

bool newReadKick = false;
bool newReadSnare = false;
bool newReadClap = false;
bool newReadHiHat = false;
bool newReadHarp = false;
//bool newReadSynthFlag = false;

int newReadSynth = 0;
int oldReadSynth = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(KICK_PIN,INPUT);
  pinMode(SNARE_PIN,INPUT);
  pinMode(CLAP_PIN,INPUT);
  pinMode(HIHAT_PIN,INPUT);
  pinMode(HARP_PIN,INPUT);
  pinMode(SYNTH_PITCH_PIN,INPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  newReadKick = !digitalRead(KICK_PIN);
  newReadSnare = !digitalRead(SNARE_PIN);
  newReadClap = !digitalRead(CLAP_PIN);
  newReadHiHat = !digitalRead(HIHAT_PIN);
  newReadHarp = !digitalRead(HARP_PIN);


  if((newReadKick != oldReadKick) && newReadKick){ //KICK OFFSET : +0 (channel 0)
    midiMsg(MIDI_NOTE_ON,0x1E,0x7F); //note on, max velocity, 0x1E = 30 (0 midi)
  }else if((newReadKick != oldReadKick) && !newReadKick){
    midiMsg(MIDI_NOTE_OFF,0x1E,0x7F); //note off, max velocity, 0x1E = 30 (0 midi)
  }

  if((newReadSnare != oldReadSnare) && newReadSnare){ //SNARE OFFSET : +1 (channel 1)
    midiMsg(MIDI_NOTE_ON + 1,0x1E,0x7F); //note on, max velocity, 0x1E = 30 (0 midi)
  }else if((newReadSnare != oldReadSnare) && !newReadSnare){
    midiMsg(MIDI_NOTE_OFF + 1,0x1E,0x7F); //note off, max velocity, 0x1E = 30 (0 midi)
  }

  if((newReadClap != oldReadClap) && newReadClap){ //CLAP OFFSET : +2 (channel 2)
    midiMsg(MIDI_NOTE_ON + 2,0x1E,0x7F); //note on, max velocity, 0x1E = 30 (0 midi)
  }else if((newReadClap != oldReadClap) && !newReadClap){
    midiMsg(MIDI_NOTE_OFF + 2,0x1E,0x7F); //note off, max velocity, 0x1E = 30 (0 midi)
  }

  if((newReadHiHat != oldReadHiHat) && newReadHiHat){ //HIHAT OFFSET : +3 (channel 1)
    midiMsg(MIDI_NOTE_ON + 3,0x1E,0x7F); //note on, max velocity, 0x1E = 30 (0 midi)
  }else if((newReadHiHat != oldReadHiHat) && !newReadHiHat){
    midiMsg(MIDI_NOTE_OFF + 3,0x1E,0x7F); //note off, max velocity, 0x1E = 30 (0 midi)
  }
  

  if((newReadHarp != oldReadHarp) && newReadHarp){ //HARP OFFSET : +4 (channel 1)
    midiMsg(MIDI_NOTE_ON + 4,0x1E,0x7F); //note on, max velocity, 0x1E = 30 (0 midi)
  }else if((newReadHarp != oldReadHarp) && !newReadHarp){
    midiMsg(MIDI_NOTE_OFF + 4,0x1E,0x7F); //note off, max velocity, 0x1E = 30 (0 midi)
  }


  oldReadKick = newReadKick;
  oldReadSnare = newReadSnare;
  oldReadClap = newReadClap;
  oldReadHiHat = newReadHiHat;
  oldReadHarp = newReadHarp;

  //ANALOG INPUT
  newReadSynth = analogRead(SYNTH_PITCH_PIN);
  //Serial.println(newReadSynth);
  //delay(500);
  newReadSynth = 255 - ((int)newReadSynth/4); // from 0-1023 to 0-255
  
  if(newReadSynth > 1){
    if(abs(newReadSynth - oldReadSynth) > 1){
      midiMsg(MIDI_NOTE_ON +5, newReadSynth, 0x7F);
      synthFlag = false;
      oldReadSynth = newReadSynth;
    }
  } else if (!synthFlag) {
    midiMsg(MIDI_NOTE_OFF + 5, newReadSynth, 0x7F);
    synthFlag = true;
  }
    
    
  delay(1);
}

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
