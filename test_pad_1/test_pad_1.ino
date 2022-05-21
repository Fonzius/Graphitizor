#define KICK_PIN  5 // +0
#define SNARE_PIN 6 // +1
#define CLAP_PIN 7 // +2
#define HIHAT_PIN 8 // +3

#define MIDI_NOTE_ON  (0x90)
#define MIDI_NOTE_OFF   (0x80)

//WIP: try to use the midi.h library to handle everything, add a manual serial.print('start_letter') to let Supercollider know the start/end of a message.

bool oldReadKick = false;
bool oldReadSnare = false;
bool oldReadClap = false;
bool oldReadHiHat = false;

bool newReadKick = false;
bool newReadSnare = false;
bool newReadClap = false;
bool newReadHiHat = false;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  pinMode(5,INPUT);
  pinMode(6,INPUT);
  pinMode(7,INPUT);
  pinMode(8,INPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  newReadKick = digitalRead(KICK_PIN);
  newReadSnare = digitalRead(SNARE_PIN);
  newReadClap = digitalRead(CLAP_PIN);
  newReadHiHat = digitalRead(HIHAT_PIN);
  
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

  oldReadKick = newReadKick;
  oldReadSnare = newReadSnare;
  oldReadClap = newReadClap;
  oldReadHiHat = newReadHiHat;
 
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
