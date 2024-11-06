/* Seasons by Sen Demina

Instuctions:
- click on the paint brush => new sky canvas
- click on the paint bucket => shift the hue
- click on the arrow => return to the original sky
- click on the door => it will open
- click on next season => the season will change
- during autumn and winter, move the mouse => create wind
*/

import processing.sound.*;
 
static enum season { SPRING, AUTUMN, WINTER }
season currentSeason;

boolean originalSky = true;
boolean openDoor = false;
float redTint = random(100, 255), 
      blueTint = random(100, 255), 
      greenTint = random(100, 255);
      
PImage apple;
PImage blossom;
PImage hills;
PImage hills_autumn;
PImage hills_winter;
PImage house;
PImage house_winter;
PImage granny;

PImage brush;
PImage bucket;
PImage arrow;
PImage nextSeason;
PImage note_on;
PImage note_off;

PFont font;

int timeOfOpenedDoor;
float grannyPos = 660;

SmokePuff[] smokePuffs = new SmokePuff[20];
Raindrop[] raindrops = new Raindrop[500];
Snowflake[] snowflakes = new Snowflake[600];

SoundFile meadow;
SoundFile rain;
SoundFile chimes;
SoundFile door;

BrownNoise wind;

void setup()
{
  size(1080, 720);
  
  meadow = new SoundFile(this, "meadow.mp3");
  meadow.amp(0.3);
  
  rain = new SoundFile(this, "rain.mp3");
  rain.amp(0.1);
  
  chimes = new SoundFile(this, "wind_chimes.mp3");
  chimes.amp(0.2);
  
  door = new SoundFile(this, "door.mp3");
  door.amp(0.2);
  
  wind = new BrownNoise(this);

  apple = loadImage("apple.png");
  blossom = loadImage("blossom.png");
  hills = loadImage("hills.png");  
  hills_autumn = loadImage("hills_autumn.png"); 
  hills_winter = loadImage("hills_winter.png"); 
  house = loadImage("house.png"); 
  house_winter = loadImage("house_winter.png"); 
  granny = loadImage("granny.png");
  
  brush = loadImage("brush.png"); 
  bucket = loadImage("bucket.png"); 
  arrow = loadImage("arrow.png");
  nextSeason = loadImage("season.png");
  note_on = loadImage("note_on.png");
  note_off = loadImage("note_off.png");
  
  font = createFont("lemon.ttf", 16);
  textFont(font);
  
  for (int i = 0; i < smokePuffs.length - 1; i++)
  {
    smokePuffs[i] = new SmokePuff(800, 280 + i*20);
  }
  
  for (int i = 0; i < raindrops.length - 1; i++)
  {
    raindrops[i] = new Raindrop(random(-width, 2*width), random(-height, 0), random(10, 30));
  }
  
  for (int i = 0; i < snowflakes.length - 1; i++)
  {
    snowflakes[i] = new Snowflake(random(-width, 2*width), random(-height, 0));
  }
  currentSeason = season.SPRING;
  meadow.loop();
}

void draw()
{
  //====DEBUGGING======
  //println(frameRate);
  //println(mouseX, mouseY);
  //println(millis());
  //println(timeOfOpenedDoor);
  
  noStroke();
  
  if (originalSky)
  {  
    background(255);
    fill(210, 240, 250, 80);
    noStroke();
    gradientSky();
    
    // SUN 
    for (int i = 1; i <= width/2; i+= 50) 
    {     
      fill(250, 50);
      ellipse(70, 50, i, i);
    }
    
    //clouds
    fill(250, 250, 255);
    ellipse(300 - frameCount/15, 200, 200, 200);
    ellipse(500 - frameCount/15, 300, 400, 400);
    ellipse(300 - frameCount/15, 500, 300, 300);
    ellipse(800 - frameCount/15, 500, 500, 500);
    
    //smoke
    for (int i = 0; i < smokePuffs.length - 1; i++)
    {
      smokePuffs[i].drawSmokePuff();
    }
  }
  else
  {
    paintClouds();
  }
  
  if(currentSeason == season.SPRING)
  {
    // HOUSE   
    image(house, 0, 0);
    drawDoor();
  
    // HILLS
    image(hills, 0, 0);
    
    // blosssoms
    image(blossom, 880, 180, 100, 100);
    image(blossom, 940, 220, 100, 100);
    image(blossom, 950, 160, 100, 100);
  }
  else if(currentSeason == season.AUTUMN)
  { 
    image(house, 0, 0); 
    drawDoor();
    image(hills_autumn, 0, 0);
    // apples
    image(apple, 880, 180, 100, 100);
    image(apple, 940, 220, 100, 100);
    image(apple, 950, 160, 100, 100);
    for (int i = 0; i < raindrops.length - 1; i++)
    {
      raindrops[i].drawRaindrop();
    }
  }
  else if(currentSeason == season.WINTER)
  {
    image(house_winter, 0, 0);
    drawDoor();
    image(hills_winter, 0, 0);
    for (int i = 0; i < snowflakes.length - 1; i++)
    {
      snowflakes[i].drawSnowflake();
    }
  } 
  
  // UI
  if(currentSeason == season.AUTUMN || currentSeason == season.WINTER)
    { tint(255, 126); }
  image(brush, 0, height - 80, 80, 80);
  if (originalSky) { tint(255, 126); }
  image(bucket, 80, height - 80, 80, 80);
  tint(255, 255);
  if (originalSky) { tint(255, 126); }
  image(arrow, 160, height - 80, 80, 80);
  tint(255, 255);
  if (meadow.isPlaying() || chimes.isPlaying())
  { image(note_on, 140, 10, 80, 80); }
  else
  { image(note_off, 140, 10, 80, 80); }
  
  // Next Season
  image(nextSeason, 0, -30, 150, 150);
  
  wind.amp(constrain((mouseX-pmouseX), 0.01, 0.03));
}

class SmokePuff
{
  float xPos;
  float yPos;
  float size = 10;
  float tone = 50;
  
  SmokePuff(float _xPos, float _yPos)
  {
    xPos =_xPos;
    yPos = _yPos;
  }
  
  void drawSmokePuff()
  {
    if (yPos <= 0) yPos = 280;
    tone = 255 - yPos/3;
    size = (280 - yPos)/2;
    //println(xPos, yPos);
    fill(tone, tone - 10, tone - 20);
    if (frameCount % 5 == 0)
    {
      xPos = (int)random(750 + yPos/5, 850 - yPos/5);
      yPos -= 2;
    }
    noStroke();
    circle(xPos, yPos, size);
  }
}

class Snowflake
{
  float xPos;
  float yPos;
  float size;
  
  Snowflake(float _xPos, float _yPos)
  {
    xPos =_xPos;
    yPos = _yPos;
    size = random(10, 20);
  }
  
  void drawSnowflake()
  {
    if (yPos >= height) yPos = 0;
    //println(xPos, yPos);
    fill(250, 240, 230);
    if (frameCount % 5 == 0)
    {
      xPos += (mouseX - pmouseX) + (int)random(-10, 10);
      yPos += 0.5*size;
    }
    noStroke();
    circle(xPos, yPos, size);
  }
}

class Raindrop
{
  float xPos;
  float yPos;
  float lastXPos;
  float len;
  
  Raindrop(float _xPos, float _yPos, float _len)
  {
    xPos =_xPos;
    yPos = _yPos;
    len = _len;
  }
  
  void drawRaindrop()
  {
    if (yPos >= height) yPos = 0;
    //println(xPos, yPos);
      lastXPos = xPos;
    yPos += len/5;
    xPos += 0.2*(mouseX - pmouseX);
    strokeWeight(2);
    stroke(100, 150, 200);
    line(xPos, yPos, lastXPos, yPos - len);
  }
}

void mouseClicked()
{
  //DOOR
  if(mouseX>680 && mouseX<750 && mouseY>350 && mouseY<450)
  {
    openDoor = true;
    grannyPos = 660;
    timeOfOpenedDoor = millis();
  }
  //PAINTBRUSH
  else if(mouseX>0 && mouseX<80 && 
          mouseY>height-80 && mouseY<height)
  {
    if(currentSeason == season.SPRING)
    {
      background(210, 240, 250);
      originalSky = false;
    }
  }
  //BUCKET
  else if(mouseX>80 && mouseX<160 && 
          mouseY>height-80 && mouseY<height)
  {
    if (!originalSky)
    {
      redTint = random(0, 255); 
      blueTint = random(0, 255);
      greenTint = random(0, 255);  
      fill(redTint, blueTint, greenTint, 50);
      gradientSky();
    }
  }
  //RESET ARROW
  else if(mouseX>160 && mouseX<220 && 
          mouseY>height-80 && mouseY<height)
  {
    originalSky = true;
    openDoor = false;
  }
  //SEASON CHANGER
  else if(mouseX>10 && mouseX<140 && 
          mouseY>10 && mouseY<80)
  {
    originalSky = true;
    if (currentSeason == season.SPRING) 
    {
      currentSeason = season.AUTUMN;
      meadow.stop();
      rain.loop();
      wind.play();

    }
    else if (currentSeason == season.AUTUMN) 
    {
      currentSeason = season.WINTER;
      meadow.stop();
      rain.stop();
      wind.stop();
      chimes.loop();
    }
    else if  (currentSeason == season.WINTER) 
    {
      currentSeason = season.SPRING;
      chimes.stop();
      meadow.loop();
    }
    
    openDoor = false;
  }
  //MUSIC
  else if(mouseX>140 && mouseX<240 && 
          mouseY>10 && mouseY<80)
  {
    if (meadow.isPlaying() || chimes.isPlaying()) 
    { 
       meadow.stop();
       chimes.stop();
    }
    else if (currentSeason == season.WINTER) { chimes.loop(); }
    else if (currentSeason == season.SPRING) { meadow.loop(); }
  }
}


void gradientSky()
{
  noStroke();
  for (int i = 1; i <= 10; i++)
  {
    rect(0, 0, width, height/i);
  }
}


void paintClouds()
{
  stroke(250, 250, 255);
  float mouseSpeed = abs(mouseX - pmouseX);
  strokeWeight(mouseSpeed);
  line(pmouseX, pmouseY, mouseX, mouseY);
}


void drawDoor()
{ 
  if(openDoor)
  {
    noStroke();
    fill(100, 100, 150);
    ellipse(710, 390, 30, 50);
    fill(110, 150, 150);
    strokeWeight(10);
    stroke(230, 130, 60);
    ellipse(690, 390, 10, 50);
    noStroke();
    fill(150, 70, 50);
    ellipse(695, 390, 10, 50);

    //Character
    if (currentSeason == season.AUTUMN)
    {
      if (grannyPos >= 580)
      {
        grannyPos -= 1;
      }
      image(granny, grannyPos, 350, 100, 100);
      fill(150, 70, 50);
      textSize(16);
      if(millis() - timeOfOpenedDoor > 1000)
      {
        text("At last the apples have ripened!", 450, 350, 200, 100);
      }
    }
    else if (currentSeason == season.SPRING)
    {
      if (grannyPos >= 580)
      {
        grannyPos -= 1;
      }
      image(granny, grannyPos, 350, 100, 100);
      fill(150, 70, 50);
      textSize(16);
      if(millis() - timeOfOpenedDoor > 1000+10)
      {
        text("What lovely apple blossoms!", 450, 350, 200, 100);
      }
    }
    else if (currentSeason == season.WINTER)
    {
      if(millis() - timeOfOpenedDoor > 1000)
      {
        text("I'd rather stay inside...", 450, 350, 200, 100);
        if(millis() - timeOfOpenedDoor > 2000)
        {
          openDoor = false;
          if(!door.isPlaying()) { door.play(); }
        }
      }
    }
  }
  else
  {
    fill(110, 150, 150);
    strokeWeight(10);
    stroke(230, 130, 60);
    ellipse(710, 390, 30, 50);
  }
}
