#include <StaticThreadController.h>
#include <Thread.h>
#include <ThreadController.h>

#define TEMP_INTERVAL 2
#define DEBUG true

int targetTemp = 25;



ThreadController controller = ThreadController();

void setup() {
  Serial.begin(9600);
  setupRotary();
  setupSevseg();
  Thread tempThread = setupTemp();
  Thread extruderThread = setupExtruder();
  controller.add(&tempThread);
  controller.add(&extruderThread);
}

void loop() {
  loopRotary();
  loopSevseg();
  controller.run();
}



////////////////// ROTARY /////////////////

#define ROTARY_A 52
#define ROTARY_B 50
#define ROTARY_BUTTON 48
#define ROTARY_DELAY 2000

int rotaryValue = 25;
int rotaryState;
int rotaryLastState;
int lastChange = 0;

void setupRotary() {
  pinMode (ROTARY_A, INPUT);
  pinMode (ROTARY_B, INPUT);
  pinMode(ROTARY_BUTTON, INPUT);

  digitalWrite(ROTARY_BUTTON, HIGH);

  rotaryLastState = digitalRead(ROTARY_A);  
}

void loopRotary() {
  lastChange++;
  rotaryState = digitalRead(ROTARY_A); // Reads the "current" state of the outputA
  if (rotaryState != rotaryLastState){     
    if (digitalRead(ROTARY_B) != rotaryState) { 
      rotaryValue ++;
    } else {
      rotaryValue --;
    }

    targetTemp = rotaryValue;

    rotaryDisplayTarget();
  } 
  rotaryLastState = rotaryState;
  
  if(digitalRead(ROTARY_BUTTON) == 0) {
    rotaryDisplayTarget();  
  }
}

void rotaryDisplayTarget() {
  lastChange = 0;
  if(DEBUG) {
    Serial.print("Rotary: ");
    Serial.println(targetTemp);
  }

  sevsegPrint(targetTemp);
}



////////////////// SEVSEG /////////////////

#include "SevSeg.h"
SevSeg sevseg;

int sevSegLast = 0;

void setupSevseg() {
  byte numDigits = 3;
  byte digitPins[] = {23, 24, 25};
  byte segmentPins[] = {32, 28, 36, 38, 40, 30, 34};
  bool resistorsOnSegments = false; // 'false' means resistors are on digit pins
  byte hardwareConfig = COMMON_CATHODE; // See README.md for options
  bool updateWithDelays = false; // Default. Recommended
  bool leadingZeros = false; // Use 'true' if you'd like to keep the leading zeros
  
  sevseg.begin(hardwareConfig, numDigits, digitPins, segmentPins, resistorsOnSegments, updateWithDelays, leadingZeros);
  sevseg.setBrightness(90);
}

void loopSevseg() {
  sevseg.refreshDisplay();
  sevseg.setNumber(sevSegLast);
}

void sevsegPrint(int value) {
  sevSegLast = value;
}


////////////////// TEMP /////////////////

#define THERMISTORPIN A0
#define THERMISTORNOMINAL 100000
#define TEMPERATURENOMINAL 25   
#define NUMSAMPLES 3
#define BCOEFFICIENT 3950
#define SERIESRESISTOR 10000

#define RELAY_PIN 8
#define LED_PIN 53

uint16_t samples[NUMSAMPLES];

Thread setupTemp() {
  analogReference(EXTERNAL);

  pinMode(RELAY_PIN, OUTPUT);    // Output mode to drive relay
  digitalWrite(RELAY_PIN, LOW);  // make sure it is off to start

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  Thread myThread = Thread();
  myThread.setInterval(2000);
  myThread.onRun(loopTemp);
  return myThread;
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

  if(DEBUG) {
    Serial.print("Temp  : ");
    Serial.println((int)steinhart);
  }
  
  if(lastChange > ROTARY_DELAY) {
    int temp = (int)steinhart;
    sevsegPrint(temp);
    lastChange = 0;
  }

  if(steinhart <= 0) {
    digitalWrite(RELAY_PIN, LOW);
    digitalWrite(LED_PIN, LOW);
    if(DEBUG) { Serial.println("Temp measurement error"); }
  } else if(steinhart < targetTemp - 5) {
    digitalWrite(RELAY_PIN, HIGH);
    digitalWrite(LED_PIN, HIGH);
    if(DEBUG) { Serial.println("on"); }
  } else {
    digitalWrite(RELAY_PIN, LOW);
    digitalWrite(LED_PIN, LOW);
    if(DEBUG) { Serial.println("off"); }
  }
}


////////////// EXTRUDER //////////////

#define MOTOR_DIR 2
#define MOTOR_STP 3
#define MOTOR_MS3 4
#define MOTOR_MS2 5
#define MOTOR_MS1 6
#define MOTOR_EN  7


int x;
int y;
int state;

Thread setupExtruder() {
  pinMode(MOTOR_STP, OUTPUT);
  pinMode(MOTOR_DIR, OUTPUT);
  pinMode(MOTOR_MS1, OUTPUT);
  pinMode(MOTOR_MS2, OUTPUT);
  pinMode(MOTOR_MS3, OUTPUT);
  pinMode(MOTOR_EN, OUTPUT);
  resetBEDPins();

  extruderSmallStepPrepare();

  Thread myThread = Thread();
  myThread.setInterval(10);
  myThread.onRun(loopExtruder);
  return myThread;
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
  extruderSmallStep();
}

void extruderSmallStepPrepare() {
  digitalWrite(MOTOR_DIR, LOW); //Pull direction pin low to move "forward"
  digitalWrite(MOTOR_MS1, HIGH); //Pull MS1,MS2, and MS3 high to set logic to 1/16th microstep resolution
  digitalWrite(MOTOR_MS2, HIGH);
  digitalWrite(MOTOR_MS3, HIGH);

  digitalWrite(MOTOR_EN, LOW);
}

void extruderSmallStep() {
  digitalWrite(MOTOR_STP,HIGH); //Trigger one step forward
  delay(1);
  digitalWrite(MOTOR_STP,LOW); //Pull step pin low so it can be triggered again
}

