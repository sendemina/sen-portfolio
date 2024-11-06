/*
  SENCRAFT by Sen Demina
  Music by Julien Massaux
*/

import processing.sound.*;
import processing.serial.*;
import java.util.ArrayList;

Serial myPort; 
int val = 0;

enum inputState { Xa, Ya, Za, Sel, Vert, Horz };
inputState currentInput;
 
int valX, valY, valZ, valS, valV, valH;

float nextRotX;
int rotToY;
boolean rotToPosX;
float rotX, rotY;

PVector pmove;
PVector move;
int moveToX, moveToY;

float incr = 0.03;

float walkSpeed = 5;
int cubeSize = 50;
int X = 50;
int Y = 50;
Cube[][] cubes = new Cube[X][Y];
Cube lastPos;

int lastX, lastY;

boolean treeXP, treeXN, treeYP, treeYN;

float elevation;
float xOff, yOff;
SoundFile sencraft; 

boolean started;
boolean colliding;

void setup()
{
  //size(1000, 600, P3D);
  size(1600, 990, P3D);
  soundtrack();
  setupSerial();
  
  move = new PVector(0, 0, 0);
  pmove = new PVector(0, 0, 0);
  //moveTo = new PVector(0, 0, 0);
  
  for(int i = 0; i < X; i++)
  {
    for(int j = 0; j < Y; j++)
    {
      cubes[i][j] = new Cube(i, j, 0);
    }
  }
  lastPos = cubes[0][0];
  calculateElevation();
  shapeMode(CENTER); 
  
  lightSpecular(128, 128, 128);
  //rotY = PI;
  noCursor();
}

void soundtrack()
{
  sencraft = new SoundFile(this, "sencraft_draft.mp3"); 
  sencraft.amp(0.1);
  sencraft.loop();
}

void setupSerial()
{
  //String portName = Serial.list()[0]; //for windows
  String portName = Serial.list()[5];   //for mac
  //myPort = new Serial(this, portName, 9600);
}

void handleSerialInput()
{
  if(myPort.available() > 0) 
  {                     
    val = myPort.read();
    
    switch(val)
    {
      case 0:
        currentInput = inputState.Xa;
        //println("state is now X "+millis());
        break;
      case 1:
        currentInput = inputState.Ya;
        //println("state is now Y "+millis());
        break;
      case 2:
        currentInput = inputState.Za;
        //println("state is now Z "+millis());
        break;
      case 3:
        currentInput = inputState.Sel;
        //println("state is now S "+millis());
        break;
      case 4:
        currentInput = inputState.Vert;
        //println("state is now V "+millis());
        break;
      case 5:
        currentInput = inputState.Horz;
        //println("state is now H "+millis());
        break;
      default:
        handleInputAxes();
        //println(val);
    }
  }
  //else { println("port unavailable"); }
}

void handleInputAxes()
{
  //println(currentInput);
  switch(currentInput)
  {
    case Xa:
      valX = val;
      if(valX > 140) { rotToY = -1; }
      else if (valX < 120) { rotToY = 1; }
      else { rotToY = 0; }
      //nextRotY = -(PI/3+valX/255.0*2*PI);
      //if(nextRotY - rotY > 0) { rotToPosY = true; }
      //else { rotToPosY = false; }
      //rotY = -(PI/3+valX/255.0*2*PI);
      break;
    case Ya:
      valY = val;
      //if(valX > 132) { rotToX = 1; }
      //else if (valX < 128) { rotToX = -1; }
      //else { rotToX = 0; }
      nextRotX = -(PI/2-valY/255.0*PI);
      if(nextRotX - rotX > 0) { rotToPosX = true; }
      else { rotToPosX = false; }
      //rotX = PI/2-valY/180.0*PI;
      break;
    case Za:
      valZ = val;
      break;
    case Sel: 
      println("sel=" + val);
      break;
    case Vert:
      valV = val;
      if(val > 145) { moveToY = 1; }
      else if(val < 125) { moveToY = -1; }
      else { moveToY = 0; }
      break;
    case Horz:
      valH = val;
      if(val > 145) { moveToX = 1; }
      else if(val < 125) { moveToX = -1; }
      else { moveToX = 0; }
      break;
    default:
      println("state error");
  }
  
  //println("x="+valX+" y="+valY+" z="+valZ);
  //println("x="+rotX+" y="+rotY+" z="+valZ);
  //println("vert="+valV+" horz="+valH);
  //println("vert="+move.y+" horz="+move.x);
}

void rotateTowards()
{
  //if(abs(nextRotY - rotY) > incr)
  //{
  //  if(rotToPosY) { rotY += incr; }
  //  else { rotY -= incr; }
  //}
  
  if(abs(nextRotX - rotX) > incr*2)
  {
    if(rotToPosX) { rotX += incr; }
    else { rotX -= incr; }
  }
  rotY += rotToY * incr;
}

void moveTowards()
{
  move.add(new PVector(-sin(rotY)*walkSpeed*moveToY, 0, cos(rotY)*walkSpeed*moveToY));
  move.add(new PVector(-sin(rotY-PI/2)*walkSpeed*moveToX, 0, cos(rotY-PI/2)*walkSpeed*moveToX));
}

void keyboardControls()
{
  rotX = -mouseY*PI/200;
  rotY = mouseX*PI/200;
  
  if(keyPressed)
  {  
    started = true;
    if(key == 'w') { move.add(new PVector(-sin(rotY)*walkSpeed, 0, cos(rotY)*walkSpeed)); }
    if(key == 's') { move.add(new PVector(sin(rotY)*walkSpeed, 0, -cos(rotY)*walkSpeed)); }
    if(key == 'a') { move.add(new PVector(-sin(rotY-PI/2)*walkSpeed, 0, cos(rotY-PI/2)*walkSpeed)); }
    if(key == 'd') { move.add(new PVector(-sin(rotY+PI/2)*walkSpeed, 0, cos(rotY+PI/2)*walkSpeed)); }
    //if(keyCode==SHIFT) { elevation += cubeSize*1.5; }
  }
}


void handleCollision()
{  
  //println(lastPos.x_pos + " " + lastPos.y_pos);
  if(colliding) 
  { 
    //move.x = lastPos.x_pos;
    //move.z = lastPos.y_pos;
    move.add(new PVector(-sin(rotY)*10, 0, cos(rotY)*walkSpeed*10));
  }
//  //println(-int(ceil(move.x/cubeSize)) + " " + -int(ceil(move.z/cubeSize)));
//  if(-int(ceil(move.x/cubeSize)) != pmove.x || -int(ceil(move.z/cubeSize)) != pmove.z) 
//  {
//    pmove.x = -move.x/cubeSize;
//    pmove.z = -move.z/cubeSize;
//    //println("new pos at " + millis());
//  }
  
//  print(pmove.x + " " + pmove.z + " | ");
//  //  //pmove = move;
    //println(-move.x/cubeSize + " " + -move.z/cubeSize);
  
//  //println(treeXP + " " + treeXN + " " + treeYP + " " + treeYN);
//  if(treeXP||treeXN) { move.x = pmove.x; }
//  if(treeYP||treeYN) { move.z = pmove.z; }
  
//  treeXP = false;
//  treeXN = false;
//  treeYP = false;
//  treeYN = false;
}

void draw()
{
  background(100, 150, 200);
  noFill();
  strokeWeight(1);
  
  //println(millis());
  if(millis() >= 15000) { started = true; }
  if(!started)
  {
    println("turn");
    pushMatrix();
    fill(200);
    translate(width/2, height/2, 450);
    background(30, 50, 100);
    textSize(50);
    strokeWeight(5);
    text("Turn around", -200, -50, 700, 100);
    popMatrix();
  }
  
  handleFalling();
  
  //UI
  pushMatrix();
  stroke(200);
  translate(width/2, height/2, 450);
  circle(0, 0, 2); 
  popMatrix();
  
  
  translate(width/2, height/2+cubeSize, height*0.9);
  rotateX(rotX);
  rotateY(rotY);
  //sphere(20);
  
  
  pushMatrix();

  keyboardControls();
  
  //=====ARDUINO CONTROLS===
  //handleSerialInput();
  //rotateTowards();
  //moveTowards();
  
  handleCollision();
  
  //stroke(100, 100, 200);
  //lights();
  spotLight(200, 150, 100, 0, cubeSize, -100, sin(rotY)*3, 0, -cos(rotY)*3, PI/2, 100);
  ambientLight(50, 50, 200);
  noStroke();
  
  //println(elevation);
  translate(move.x, elevation, move.z);
  //elevation = 0;
  for(int i = 0; i < X; i++)
  {
    pushMatrix();
    for(int j = 0; j < Y; j++)
    {
      pushMatrix();
      translate(0, cubes[i][j].elevation, 0);
      cubes[i][j].drawCube();
      cubes[i][j].x_pos = move.x+cubeSize*i;
      cubes[i][j].y_pos = move.z+cubeSize*j;
      cubes[i][j].drawCube();
      popMatrix();
      
      translate(0, 0, cubeSize);
      //println(cubes[i][j].isAtOrigin());
      if(cubes[i][j].isAtOrigin())
      {
        if(cubes[i][j].hasTree) { colliding = true; }
        else { colliding = false; }
        //println(colliding);
        //if(cubes[i][j] != lastPos && !colliding)
        //{
        //  lastPos = cubes[i][j];
        //  println("new lastPos is " + lastPos.x_pos + " " + lastPos.y_pos);
        //}
        
        elevation = 200-cubes[i][j].elevation;
        //ArrayList treesNearby = cubes[i][j].cubesHaveTrees();
        //for(int k = 0; k < treesNearby.size(); k++)
        //{
        //  Cube cube = (Cube)treesNearby.get(k); 
        //  //println("tree at [" + cube.x + "][" + cube.y + "]");
        //  if(i == cube.x - 1) { treeXP = true; }
        //  else { treeXP = false; }
        //  if(i == cube.x + 1) { treeXN = true; }
        //  else { treeXN = false; }
        //  if(j == cube.y - 1) { treeYP = true; }
        //  else { treeYP = false; }
        //  if(j == cube.y + 1) { treeYN = true; }
        //  else { treeYN = false; }
        //}
      }
      //else elevation-=0.1;
      //println(elevation);
    }
    popMatrix();
    translate(cubeSize, 0, 0);
  } 
  popMatrix();
}

class Cube
{
  int x, y;
  float x_pos, y_pos;
  int elevation;
  boolean hasTree;
  Tree tree;
  
  Cube(int _x, int _y, int _elevation)
  {
    x = _x;
    y = _y;
    x_pos = x*cubeSize;
    y_pos = y*cubeSize;
    
    elevation = _elevation;
    if(int(random(30))==0 && !isAtOrigin()) { hasTree = true; }
    if(hasTree)
    {
      //println("cube["+x+"]["+y+"] has tree");
      tree = new Tree(this, int(random(8, 20)));
    }
  }
  
  void drawCube()
  {
    fill(100, 200, 100);
    box(cubeSize);
    if(hasTree) { tree.drawTree(); }
  }
  
  boolean isAtOrigin()
  {
    if(x_pos >= -cubeSize/2 && x_pos <= cubeSize/2 
      && y_pos >= -cubeSize/2 && y_pos <= cubeSize/2)
    {
      //println("at origin");
      return true;
    }
    else 
    { 
      //println("NOOOOOOOOOT at origin");
      return false; 
    }
  }
  
  ArrayList<Cube> cubesHaveTrees()
  {
    ArrayList<Cube> cubesWithTrees = new ArrayList<Cube>();
    if(x > 0 && x < X-1 && y > 0 && y < Y-1)
    {
      for(int i = -1; i < 2; i++)
      {
        for(int j = -1; j < 2; j++)
        {
          int xpos = x+i;
          int ypos = y+j;
          if(cubes[xpos][ypos].hasTree) 
          { 
            cubesWithTrees.add(cubes[xpos][ypos]);
            //println("tree near at " + xpos + " " + ypos);
          }
        }
      }
    }
    return cubesWithTrees;
  }
}

class Tree
{
  Cube cube;
  int tall;
  
  Tree(Cube _cube, int _tall)
  {
    cube = _cube;
    tall = _tall;
    //println("made tree");
  }
  
  void drawTree()
  {
    fill(100, 100, 50);
    pushMatrix();
    for(int i = 0; i < tall; i++)
    {
      translate(0, -cubeSize, 0);
      box(cubeSize);
    }
    fill(100, 200, 100);
    sphere(150);
    popMatrix();
  }
}

void calculateElevation()
{
  xOff = 0; 
  for(int i = 0; i < X; i++)
  {
    yOff = 0;
    for (int j = 0; j < Y; j++)
    {
      cubes[i][j].elevation = int(map(noise(xOff, yOff), 0, 1, 0, 10))*cubeSize;
      //elevation[i][j] = int(random(-2, 2))*cubeSize;
      //println("elevation["+i+"]"+"["+j+"]"+" = "+cubes[i][j].elevation);               
      yOff += 0.01;
    }
    xOff += 0.01;
  }
  //println("elevation calculated");
}

void handleFalling()
{
  if (move.x < 0 || move.x > X || move.y < 0 || move.y > Y)
  {
    elevation -= 20;
  }
  if(elevation < -2000)
  {
    pushMatrix();
    fill(200);
    translate(width/2, height/2, 0);
    background(30, 50, 100);
    textSize(50);
    strokeWeight(5);
    text("Goodbye ,  blocky world", -200, -50, 700, 100);
    popMatrix();
  }
}
