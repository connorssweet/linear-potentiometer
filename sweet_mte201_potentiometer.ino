//Author: Connor Sweet
//Analog reading input to obtain voltage drop
int readPot = 14; //A0
float lTotal = 0.0125; //total length of potentiometer in metres
float vTotal = 0.00016; //total voltage drop across potentionmeter in V.
//float cal = 1400; // off by 1cm
float cal = 1600;
void setup() {
  // put your setup code here, to run once:
  pinMode(readPot, INPUT);
  Serial.begin(9600);
  analogReference(DEFAULT);
}

void loop() {
  // put your main code here, to run repeatedly:
  int vRead = analogRead(readPot);
  
  Serial.println(vRead);
  //delay(5000);
  float vFound = (float)vRead / 1023 * 3.3;
  Serial.println(vFound);
  float lFound = (vFound * lTotal / vTotal) / cal;
  
  Serial.println("Estimated length: " + (String)(lFound*1000) + "mm");
  
  delay(2000);

}
