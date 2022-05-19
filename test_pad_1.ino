#define KICK_PIN  5
#define MIDI_NOTE_ON  (0x90)
#define MIDI_NOTE_OFF   (0x80)

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(5,INPUT);
  //pinMode(6,input);
  //pinMode(7,input);
  //pinMode(8,input);

}

void loop() {
  // put your main code here, to run repeatedly:
  if(digitalRead(KICK_PIN)){
    midiMsg(MIDI_NOTE_ON,0x1E,0x7F); //note on, max velocity, 0x1E = 30 (0 midi)
  }else{
    midiMsg(MIDI_NOTE_OFF,0x1E,0x7F); //note off, max velocity, 0x1E = 30 (0 midi)
  }
  delay(1000);
}

void midiMsg(int cmd, int pitch, int velocity) {
  Serial.print('z'); // z = midi message start
  Serial.print(cmd); //prova anche write se non va
  Serial.print('a'); // a = fine command
  Serial.print(pitch);
  Serial.print('b'); // b = fine pitch
  Serial.print(velocity);
  Serial.print('c'); // c = fine velocity e fine midi message
}
