int targetTemp = 25;

void setup() {
  setupRotary();
  setupSevseg();
  setupExtruder();
  setupTemp();
}

int count = 0;

void loop() {
  count++;
  loopRotary();
  loopSevseg();
  loopExtruder();
  if(count >= 100) {
    count = 0;
    loopTemp();
  }
}



////////////////// ROTARY /////////////////

#define ROTARY_A 52
#define ROTARY_B 50

int rotaryValue = 25;
int rotaryState;
int rotaryLastState;

void setupRotary() {
  pinMode (ROTARY_A, INPUT);
  pinMode (ROTARY_B, INPUT);
       
  Serial.begin (9600);
  rotaryLastState = digitalRead(ROTARY_A);  
}

void loopRotary() {
  rotaryState = digitalRead(ROTARY_A); // Reads the "current" state of the outputA
  if (rotaryState != rotaryLastState){     
    if (digitalRead(ROTARY_B) != rotaryState) { 
      rotaryValue ++;
    } else {
      rotaryValue --;
    }
    Serial.print("Rotary Value: ");
    Serial.println(rotaryValue);

    sevsegPrint(rotaryValue);
    targetTemp = rotaryValue;
  } 
  rotaryLastState = rotaryState;
}



////////////////// SEVSEG /////////////////

#include "SevSeg.h"
SevSeg sevseg;

int sevSegLast = 0;

void setupSevseg() {
  byte numDigits = 3;
  byte digitPins[] = {23, 24, 25};
  byte segmentPins[] = {40, 36, 30, 32, 34, 38, 28};
  bool resistorsOnSegments = false; // 'false' means resistors are on digit pins
  byte hardwareConfig = COMMON_CATHODE; // See README.md for options
  bool updateWithDelays = false; // Default. Recommended
  bool leadingZeros = false; // Use 'true' if you'd like to keep the leading zeros
  
  sevseg.begin(hardwareConfig, numDigits, digitPins, segmentPins, resistorsOnSegments, updateWithDelays, leadingZeros);
  sevseg.setBrightness(90);
}

void loopSevseg() {
  sevseg.setNumber(sevSegLast);
  sevseg.refreshDisplay();
}

void sevsegPrint(int value) {
  sevSegLast = value;
}


////////////////// TEMP /////////////////

#define THERMISTORPIN A0
#define THERMISTORNOMINAL 100000
#define TEMPERATURENOMINAL 25   
#define NUMSAMPLES 5
#define BCOEFFICIENT 3950
#define SERIESRESISTOR 10000

#define RELAY_PIN 8

uint16_t samples[NUMSAMPLES];

void setupTemp() {
  analogReference(EXTERNAL);

  pinMode(RELAY_PIN, OUTPUT);    // Output mode to drive relay
  digitalWrite(RELAY_PIN, LOW);  // make sure it is off to start
}
  
void loopTemp() {
  uint8_t i;
  float average;
  
  // take N samples in a row, with a slight delay
  for (i=0; i< NUMSAMPLES; i++) {
    samples[i] = analogRead(THERMISTORPIN);
    delay(1);
  }
  
  // average all the samples out
  average = 0;
  for (i=0; i< NUMSAMPLES; i++) {
      average += samples[i];
  }
  average /= NUMSAMPLES;
  
  average = 1023 / average - 1;
  average = SERIESRESISTOR / average;
  
  float steinhart;
  steinhart = average / THERMISTORNOMINAL;     // (R/Ro)
  steinhart = log(steinhart);                  // ln(R/Ro)
  steinhart /= BCOEFFICIENT;                   // 1/B * ln(R/Ro)
  steinhart += 1.0 / (TEMPERATURENOMINAL + 273.15); // + (1/To)
  steinhart = 1.0 / steinhart;                 // Invert
  steinhart -= 273.15;                         // convert to C
  
  Serial.print("Temperature: ");
  Serial.println((int)steinhart);

  sevsegPrint((int)steinhart);

  if(steinhart < targetTemp - 5) {
      digitalWrite(RELAY_PIN, HIGH);
      Serial.println("on");
  } else {
      digitalWrite(RELAY_PIN, LOW);
      Serial.println("off");
  }
}


////////////// EXTRUDER //////////////

#define MOTOR_STP 3
#define MOTOR_DIR 2
#define MOTOR_MS1 6
#define MOTOR_MS2 5
#define MOTOR_MS3 4
#define MOTOR_EN  7


int x;
int y;
int state;

void setupExtruder() {
  pinMode(MOTOR_STP, OUTPUT);
  pinMode(MOTOR_DIR, OUTPUT);
  pinMode(MOTOR_MS1, OUTPUT);
  pinMode(MOTOR_MS2, OUTPUT);
  pinMode(MOTOR_MS3, OUTPUT);
  pinMode(MOTOR_EN, OUTPUT);
  resetBEDPins();
}

void resetBEDPins()
{
  digitalWrite(MOTOR_STP, LOW);
  digitalWrite(MOTOR_DIR, LOW);
  digitalWrite(MOTOR_MS1, LOW);
  digitalWrite(MOTOR_MS2, LOW);
  digitalWrite(MOTOR_MS3, LOW);
  digitalWrite(MOTOR_EN, HIGH);
}

void loopExtruder() {
  digitalWrite(MOTOR_EN, LOW);
  //extruderStepForward(1);
  extruderSmallStep();
}

void extruderStepForward(int steps) {
  Serial.println(steps);
  digitalWrite(MOTOR_DIR, LOW); //Pull direction pin low to move "forward"
  for(x= 0; x<steps; x++)  //Loop the forward stepping enough times for motion to be visible
  {
    digitalWrite(MOTOR_STP,HIGH); //Trigger one step forward
    delay(1);
    digitalWrite(MOTOR_STP,LOW); //Pull step pin low so it can be triggered again
    delay(1);
  }  
}


void extruderSmallStep() {
  digitalWrite(MOTOR_DIR, LOW); //Pull direction pin low to move "forward"
  digitalWrite(MOTOR_MS1, HIGH); //Pull MS1,MS2, and MS3 high to set logic to 1/16th microstep resolution
  digitalWrite(MOTOR_MS2, HIGH);
  digitalWrite(MOTOR_MS3, HIGH);
  for(x= 1; x<2; x++)  //Loop the forward stepping enough times for motion to be visible
  {
    digitalWrite(MOTOR_STP,HIGH); //Trigger one step forward
    delay(1);
    digitalWrite(MOTOR_STP,LOW); //Pull step pin low so it can be triggered again
    delay(1);
  }
}

