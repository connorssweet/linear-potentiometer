//Analog reading input to obtain voltage drop
int x = 14; //A0

void setup() {
  // put your setup code here, to run once:
  pinMode(x, INPUT);
  Serial.begin(9600);
  analogReference(DEFAULT);
}

void loop() {
  // put your main code here, to run repeatedly:
  int vRead = analogRead(x);
  
  Serial.println(vRead);
  
  delay(2000);

}
