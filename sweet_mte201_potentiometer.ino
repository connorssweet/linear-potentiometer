/*
 * MTE_201_Potentiometer
 * Arduino code for linear potentiometer
 * Author: Connor Sweet
 */
const float LENGTH_TOTAL = 0.102; //Total length of potentiometer in metres
const float LENGTH_OUTLIER = 0.005;
const float VOLTAGE_TOTAL = 5; //Total voltage drop across potentionmeter in volts

const int WIPER_PIN = 14; //A0 pin for wiper

//Actual lengths for each length measure pin
const float LENGTH_1_ACTUAL = 0.02-LENGTH_OUTLIER, LENGTH_2_ACTUAL = 0.04-LENGTH_OUTLIER, LENGTH_3_ACTUAL = 0.06-LENGTH_OUTLIER, LENGTH_4_ACTUAL = 0.08-LENGTH_OUTLIER, LENGTH_5_ACTUAL = 0.1-LENGTH_OUTLIER;
//A1-A5 pins for set lengths on resistant strip, for calibration
const int LENGTH_1_PIN = 15, LENGTH_2_PIN = 16, LENGTH_3_PIN = 17, LENGTH_4_PIN = 18, LENGTH_5_PIN = 19;

void setup() {
  pinMode(WIPER_PIN, INPUT);
  pinMode(LENGTH_1_PIN, INPUT);
  pinMode(LENGTH_2_PIN, INPUT);
  pinMode(LENGTH_3_PIN, INPUT);
  pinMode(LENGTH_4_PIN, INPUT);
  pinMode(LENGTH_5_PIN, INPUT);
  Serial.begin(9600);
  analogReference(DEFAULT);
}

void loop() {
  float wiperLength = getDistance(WIPER_PIN);
  float coeff = getCoefficient(wiperLength);
  wiperLength *= coeff;
  Serial.println((String)(round(wiperLength+LENGTH_OUTLIER)));
  delay(100);
}

//Returns length in mm based on analog reading. Param: analog read port
float getDistance(int port){
  return ((float(analogRead(port)) / 1023 * 5) * LENGTH_TOTAL / VOLTAGE_TOTAL)*1000;
}

//Determines coefficient to calibrate measurements
float getCoefficient(float wiperLength){
  //Obtain measured lengths for each known point in mm
  float length1 = getDistance(LENGTH_1_PIN);
  float length2 = getDistance(LENGTH_2_PIN);
  float length3 = getDistance(LENGTH_3_PIN);
  float length4 = getDistance(LENGTH_4_PIN);
  float length5 = getDistance(LENGTH_5_PIN);

  //Obtain differences between the wiper length and the obtained lengths in mm
  float diff1 = abs(wiperLength - length1);
  float diff2 = abs(wiperLength - length2);
  float diff3 = abs(wiperLength - length3);
  float diff4 = abs(wiperLength - length4);
  float diff5 = abs(wiperLength - length5);

  //Determine the most likely interval the wiper rests in
  float mostLikelyInterval = min(min(min(diff1,diff2),min(diff3,diff4)),diff5);

  //Return coefficient based on most likely interval
  if(mostLikelyInterval == diff1)
      return LENGTH_1_ACTUAL*1000 / length1;
  else if (mostLikelyInterval == diff2)
      return LENGTH_2_ACTUAL*1000 / length2;
  else if (mostLikelyInterval == diff3)
      return LENGTH_3_ACTUAL*1000 / length3;
  else if (mostLikelyInterval == diff4)
      return LENGTH_4_ACTUAL*1000 / length4;
  else
      return LENGTH_5_ACTUAL*1000 / length5;
}


