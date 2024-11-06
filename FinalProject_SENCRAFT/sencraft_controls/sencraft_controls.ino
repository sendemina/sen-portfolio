/*
    Arduino and ADXL345 Accelerometer Tutorial
     by Dejan, https://howtomechatronics.com
*/

#include <Wire.h>  // Wire library - used for I2C communication

int ADXL345 = 0x53; // The ADXL345 sensor I2C address

float X_out, Y_out, Z_out;  // Outputs
int X_out_mapped, Y_out_mapped, Z_out_mapped;

const int selPin = 3;
const int vertPin = A0;
const int horzPin = A1;

int selVal, vertVal, horzVal;
int selVal_mapped, vertVal_mapped, horzVal_mapped;

enum state { x, y, z, s, v, h };
//enum state { x, y, v, h };

state currentState;

void setup() 
{
  pinMode(selPin, INPUT);
  pinMode(vertPin, INPUT);
  pinMode(horzPin, INPUT);

  Serial.begin(9600); // Initiate serial communication for printing the results on the Serial monitor
  Wire.begin(); // Initiate the Wire library
  // Set ADXL345 in measuring mode
  Wire.beginTransmission(ADXL345); // Start communicating with the device 
  Wire.write(0x2D); // Access/ talk to POWER_CTL Register - 0x2D
  // Enable measurement
  Wire.write(8); // (8dec -> 0000 1000 binary) Bit D3 High for measuring enable 
  Wire.endTransmission();
  delay(10);
}

void loop() 
{
  selVal = digitalRead(selPin);
  vertVal = analogRead(vertPin);
  horzVal = analogRead(horzPin);

  // === Read acceleromter data === //
  Wire.beginTransmission(ADXL345);
  Wire.write(0x32); // Start with register 0x32 (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(ADXL345, 6, true); // Read 6 registers total, each axis value is stored in 2 registers
  X_out = ( Wire.read()| Wire.read() << 8); // X-axis value
  X_out = X_out/256; //For a range of +-2g, we need to divide the raw values by 256, according to the datasheet
  Y_out = ( Wire.read()| Wire.read() << 8); // Y-axis value
  Y_out = Y_out/256;
  Z_out = ( Wire.read()| Wire.read() << 8); // Z-axis value
  Z_out = Z_out/256;
  delay(500);
  
  //X_out_mapped = (x_out - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;

  X_out_mapped = int(constrain(map(X_out*100, -105, 105, 6, 255), 6, 255));
  Y_out_mapped = int(constrain(map(Y_out*100, -105, 105, 6, 255), 6, 255));
  //Z_out_mapped = int(constrain(map(Z_out*100, -105, 105, 6, 255), 6, 255));

  vertVal_mapped = map(vertVal, 0, 660, 6, 255);
  horzVal_mapped = map(horzVal, 0, 660, 6, 255);


  serialWrite();
  //printDebug();

}

void serialWrite()
{
  currentState = x;
  Serial.write(currentState);
  Serial.write(X_out_mapped);

  currentState = y;
  Serial.write(currentState);
  Serial.write(Y_out_mapped);

  // currentState = z;
  // Serial.write(currentState);
  // Serial.write(Z_out_mapped);
  
//  currentState = s;
//  Serial.write(currentState);
//  Serial.write(1);

  currentState = v;
  Serial.write(currentState);
  Serial.write(vertVal_mapped);

  currentState = h;
  Serial.write(currentState);
  Serial.write(horzVal_mapped);
}

void printDebug()
{
   Serial.print("Xa= ");
   //Serial.println(X_out);
   Serial.print(X_out_mapped);

   Serial.print("   Ya= ");
   //Serial.print(Y_out);
   Serial.print(Y_out_mapped);

   Serial.print("   Za= ");
   //Serial.println(Z_out);
   Serial.print(Z_out_mapped);

   Serial.print("   s= ");
   Serial.print(selVal);

   Serial.print("   vert= ");
   //Serial.print(vertVal);
   Serial.print(vertVal_mapped);

   Serial.print("   horz= ");
   //Serial.println(horzVal);
   Serial.println(horzVal_mapped);
}
