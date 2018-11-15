import controlP5.*;
import processing.serial.*;
//Author: Connor Sweet
/*
INSTRUCTIONS:
1. Note the COM port of the Arduino attached to the PC. Set 'port' to also communicate with this port.
2. Upload the Arduino code to the Arduino attached to the PC.
3. Run this code. "data.txt" will be created inside this directory.
*/

Serial port;
PrintWriter output;
ControlP5 cp5;
int bColor = 100;
Textfield text;

String displayVal = "";
String lastDisplayVal = "";

void setup() 
{
   port = new Serial( this, Serial.list()[0], 9600 ); //CONFIG SERIAL LIST PORT FOR YOUR LAPTOP
   output = createWriter( "sweet_mte201_data.txt" );
   size(600,600);
   cp5 = new ControlP5(this);
   PFont font = createFont("arial", 30);
   textFont(font);
}

void draw() 
{
  background(bColor);
  
    //if (port.available() > 0 ) {
         String val = port.readString();
         if (val != null)
         {
              output.println(val);
              displayVal = val;
              lastDisplayVal = displayVal;
         } else 
         {
           displayVal = lastDisplayVal;
         } 
    //}
    text("Displacement is equal to: " + displayVal, 50, 300);
}

//terminate process when key is pressed
void keyPressed() 
{ 
    output.flush();
    output.close();
    exit();
}
