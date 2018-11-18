import controlP5.*;
import processing.serial.*;
//Author: Connor Sweet
/*
INSTRUCTIONS:
 1. Note the COM port of the Arduino attached to the PC. Set 'port' to also communicate with this port.
 2. Upload the Arduino code to the Arduino attached to the PC.
 3. Run this code. "sweet_mte201_data.txt" will be created inside this directory.
 */

//Varaibles for IO
Serial port;
PrintWriter output;

//Variables for GUI
ControlP5 cp5;
Textfield text;

//Variables related to reset button
int butX, butY, butSize = 90;
color butColor, butColorHighlight;
boolean butOver = false;

//Variables for measurement displayed
String displayVal = "", lastDisplayVal = "";

//Variables for stats functions
FloatList list;
int counter;
float sampleMean, stdDev, normPlot;

//Instantiates variables and establishes connection to serial
void setup() 
{
  //Configure serial list index to listen to Arduino port
  port = new Serial( this, Serial.list()[0], 9600 );
  
  //Setup writer
  output = createWriter( "sweet_mte201_data.txt" );
  
  //Setup GUI
  size(1000, 500);
  cp5 = new ControlP5(this);
  PFont font = createFont("arial", 30);
  textFont(font);

  //Setup reset button
  butColor = color(100);
  butColorHighlight = color(255);
  butX = width/2 - butSize - 10;
  butY = width/2 - butSize - 10;

  //Set up measurement ssand sample tracking
  list = new FloatList();
  counter = 0;
  normPlot = 0;
}

void draw() 
{
  background(0);
  
  //Draw reset button
  updateButton();
  stroke(255);
  rect(butX, butY, butSize, butSize);

  //Get newest value
  String val = port.readString();
  
  //Veify value is not null
  if (val != null)
  {
    //Verify value obtained from serial is valid - check if decimal exists
    if(val.toString().contains(".")){
      char[] arr = val.toString().trim().toCharArray();
      //Verify number format transmitted correctly over serial
      if(arr.length > 3 && arr[arr.length-3] == '.' && arr[0] != '.'){
        output.println(val);
        displayVal = val;
        lastDisplayVal = displayVal;
        
        //Append value and calculate related values if valid
        if (val != "" && !Float.isNaN(float(val))) {
          print("Value obtained: " + val);
          list.append(float(val));
          counter++;
          //get sample mean, standard deviation, normal
          sampleMean = getSampleMean();
          stdDev = getStandardDeviation(sampleMean);
          normPlot = getNormal(sampleMean, stdDev);
        }      
      //if value is not valid, then display previous value
      } else 
          displayVal = lastDisplayVal;
      //if value has no decimal, then display previous value
     } else 
       displayVal = lastDisplayVal;
  }
  
  displayAndFlush();
}

//Display information in file and on GUI
void displayAndFlush(){
  output.flush();
  fill(255);
  text("Current displacement(mm) is equal to: " + displayVal, 50, 200);
  text("Sample Size: " + counter, 50, 150);
  text("Sample mean: " + sampleMean, 50, 250);
  text("Standard deviation: " + stdDev, 50, 300);
  text("Normal Plot: " + normPlot, 50, 350);
}

//Function determines sample mean using current data
float getSampleMean() {
  float sum = 0;
  for (int i = 0; i < list.size(); i++)
    sum += list.get(i);
  float sm = sum/counter;
  //Returns -1 if sample mean is invalid
  if(Float.isNaN(sm))
    return -1;
  else
    return sm;
}

//Function determines standard deviation using current data
float getStandardDeviation(float sampleMean) {
  float sum = 0;
  for (int i = 0; i < list.size(); i++)
    sum += pow(list.get(i)-sampleMean, 2);
  float sd = sqrt(sum/(counter-1));
  //Returns -1 if standard deviation is invalid
  if(Float.isNaN(sd))
    return -1;
  else
    return sd;
}

//Function determines normal value using current data
float getNormal(float sampleMean, float stdDev){
  return (randomGaussian() * stdDev) + sampleMean;
}


//Update function to update button
void updateButton() {
  if(mouseX >= butX && mouseX <= butX+butSize && mouseY >= butY && mouseY <= butY+butSize)
    fill(butColorHighlight);
  else 
    fill(butColor);
}

//Resets if mouse is pressed over reset button
void mousePressed() {
  if (mouseX >= butX && mouseX <= butX+butSize && mouseY >= butY && mouseY <= butY+butSize){
    print(list);
    list.clear();
    counter = 0;
  }
}

//Terminate process when any key is pressed
void keyPressed() 
{
  output.close();
  exit();
}
