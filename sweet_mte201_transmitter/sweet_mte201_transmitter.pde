import controlP5.*;
import processing.serial.*;
/*
 * MTE_201_Potentiometer
 * Arduino code for linear potentiometer
 * Author: Connor Sweet
 *
 * INSTRUCTIONS:
 * 1. Note the COM port of the Arduino attached to the PC. Set 'port' to also communicate with this port.
 * 2. Upload the Arduino code to the Arduino attached to the PC.
 * 3. Run this code. "sweet_mte201_data.txt" will be created inside this directory.
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
  size(1000, 700);
  cp5 = new ControlP5(this);
  PFont font = createFont("arial", 30);
  textFont(font);

  //Setup reset button
  butColor = color(100);
  butColorHighlight = color(255);
  butX = width/2 - butSize - 10;
  butY = width/2 - butSize - 10;

  //Set up measurements and sample tracking
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
  
  //Verify value is not null
  if (val != null)
  {
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
  } else 
    displayVal = lastDisplayVal;
 
  displayAndFlush();
}

//Display information in file and on GUI
void displayAndFlush(){
  output.flush();
  fill(255);
  text("Displacement(mm ±3): " + displayVal, 10, 50);
  text("Mode(mm ±3): " + getMode(list), 10, 100);
  text("Median(mm ±3): " + getMedian(list), 10, 150);
  text("Sample Size: " + counter, 10, 200);
  text("Sample mean: " + sampleMean, 10, 250);
  text("Standard deviation: " + stdDev, 10, 300);
  text("Normal Plot: " + normPlot, 10, 350);
}

//Function determines mode using current data
float getMode(FloatList list){
  if(list.size() > 0){
    list.sort();
    float mode = list.get(0);
    float modeCount = 1;
  
    float currentNum = list.get(0);
    float currentCount = 1;
  
    for(int i = 1; i < list.size(); i++){
      currentNum = list.get(i);
      if(list.get(i-1) == currentNum){
        currentCount ++;
      } else
        currentCount = 1;
      if(currentCount == modeCount)
          mode =  (currentNum + mode) / 2; 
      if(currentCount > modeCount){
        modeCount = currentCount;
        mode = currentNum;
      }
    }
    return mode;
  } else
    return -1;
}

//Function determines median using current data
float getMedian(FloatList list){
 list.sort();
 if(list.size() > 1){
   if(list.size() % 2 == 0)
     return (list.get(((list.size())/2)-1)+list.get((list.size())/2))/2;
   else
     return list.get((list.size()/2)-1);
 }else
   return -1;
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
