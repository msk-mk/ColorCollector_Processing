import processing.video.*;  
  
Capture cam;  
PImage result;  
  
boolean colorSelected = false;  
color paintColor;  
  
float paintH;  
float paintS;   
float paintB;   

float hueThreshold = 10;
float satThreshold = 20;  
float briThreshold = 10;  

PImage flameImg;  
boolean showFlame = false;  
int currentFlame = -1;  
int flameTime; 
  
void setup() {  
  size(1280, 480);
  
  String[] cameras = Capture.list();   
  if (cameras == null) {  
    cam = new Capture(this, 640, 480);  
  } else if (cameras.length == 0) {  
    println("There are no cameras available for capture.");  
    exit();  
  } else {  
    println("Available cameras:");  
    printArray(cameras);  
    cam = new Capture(this, 640, 480, cameras[0], 30);  
  }  
  result = createImage(640, 480, RGB);  
  
  flameTime = millis();  
  flameImg = createFlame(0); 

  cam.start();  
  
  for (int x=0; x<cam.width; x++){
    for (int y=0; y<cam.height; y++){
      result.set(x, y, color(255));    
    }
  }
}  
  
void draw() {  
  if (cam.available() == true) {
    cam.read();  
  }  
  image(cam, 0, 0, cam.width, cam.height);  
  
  if (colorSelected) {
    for (int x=0; x<cam.width; x++){
      for (int y=0; y<cam.height; y++){  
        color c = cam.get(x, y);    
        if (isSimilarColor(c)) {  
          result.set(x, y, paintColor);  
        }  
      }  
    }  
  }  
  
  image(result, cam.width, 0, result.width, result.height);  
  
  int phase = ((millis() - flameTime) / 3000) % 3;  
  
  if (phase != currentFlame) {  
    flameImg = createFlame(phase);  
    currentFlame = phase;  
  } 
  if (showFlame) {  
    image(flameImg, cam.width, 0, flameImg.width, flameImg.height);  
  }  
}  
  
void mousePressed() {  
  if (mouseX < cam.width) {  
    paintColor = averageColor(cam, mouseX, mouseY);   
    setPaintColor(paintColor);    
    colorSelected = true; 
  }  
}  
  
void setPaintColor(color c) {  
  paintH = hue(c);  
  paintS = saturation(c);  
  paintB = brightness(c);  
}  
 
boolean isSimilarColor(color c) {  
  float h = hue(c);  
  float s = saturation(c);  
  float br = brightness(c); 
  
  if (min(abs(h-paintH),360-abs(h-paintH)) > hueThreshold) return false;  
  if (abs(s - paintS) > satThreshold) return false;  
  if (abs(br - paintB) > briThreshold) return false;  
  
  return true;  
}  

color averageColor(PImage img, int cx, int cy) {  
  int rSum = 0;  
  int gSum = 0;  
  int bSum = 0;  
  int count = 0;  
  
  for (int x = max(0, cx-4); x <= min(img.width-1, cx+4); x++) {  
    for (int y = max(0, cy-4); y <= min(img.height-1, cy+4); y++) {  
      color c = img.get(x, y);  
  
      int r = int(red(c));  
      int g = int(green(c));  
      int b = int(blue(c));  
  
      rSum += r;  
      gSum += g;  
      bSum += b;  
      count++;  
    }  
  }  
  
  int r = rSum / count;  
  int g = gSum / count;  
  int b = bSum / count;  
  
  return color(r, g, b);  
}  

void keyPressed() {  
  if (key == 'c' || key == 'C') {  
    showFlame = !showFlame;  
  }  
}  

PImage createFlame(int phase) {  

  int w = 640;
  int h = 480;
  PGraphics pattern = createGraphics(w, h);  
  
  pattern.beginDraw();  
  pattern.background(0);     
  pattern.noStroke();  
  pattern.fill(255);  
  
  if (phase == 0) {  
    drawFlamePattern(pattern, w/3.8, h/6, 1.2);  
    drawFlamePattern(pattern, w/12, h/3.5, 0.7);  
    drawFlamePattern(pattern, w/2.5, h/2.7, 0.85);   
  } else if (phase == 1){  
    drawFlamePattern(pattern, w/2.6, h/4, 1.0);  
    drawFlamePattern(pattern, w/4.5, h/2.5, 0.7);  
    drawFlamePattern(pattern, w/8, h/6, 1.2);  
  }  
  else {
    drawFlamePattern(pattern, w/3.3, h/3, 1.2);  
    drawFlamePattern(pattern, w/9, h/6, 0.9);  
    drawFlamePattern(pattern, w/2.5, h/8, 0.65);  
  }
  
  pattern.endDraw();  
  
  PImage img = createImage(640, 480, ARGB);  

  for (int x = 0; x < w; x++) {  
    for (int y = 0; y < h; y++) {  
      color c = pattern.get(x, y);  
  
      if (brightness(c) > 1) {  
        img.set(x, y, color(0, 0, 0, 0));  
      } else {  
        img.set(x, y, color(0, 0, 0, 255));  
      }  
    }  
  }  
  
  return img;  
}  

void drawFlamePattern(PGraphics pg, float cx, float cy , float sca) {  
  pg.pushMatrix();  
  
  pg.translate(cx, cy);  
  pg.scale(sca);
  pg.noStroke();   
  pg.fill(255);   
  
  pg.circle(0,0,5);

  pg.rotate(18*PI/180);
  for(int i=0; i<10; i++){
    pg.rotate(2*18*PI/180);
    pg.translate(0,60);
    pg.circle(0,0,8);
    pg.translate(0,-60);
  }
  for(int i=0; i<10; i++){
    pg.rotate(2*18*PI/180);
    pg.triangle(0, 20, 4, 60, -4, 60);
  }
  pg.rotate(-18*PI/180);

  pg.rotate(36*PI/180);
  for(int i=0; i<10; i++){
    pg.rotate(2*18*PI/180);
    pg.translate(0,50);
    pg.circle(0,0,6);
    pg.translate(0,-50);
  }
  for(int i=0; i<10; i++){
    pg.rotate(2*18*PI/180);
    pg.triangle(0, 25, 3, 50, -3, 50);
  }
  pg.rotate(-36*PI/180);

  for(int i=0; i<10; i++){
    pg.rotate(2*18*PI/180);
    pg.translate(0,20);
    pg.circle(0,0,6);
    pg.translate(0,-20);
  }

  for(int i=0; i<10; i++){
    pg.rotate(2*18*PI/180);
    pg.triangle(0, 6, 3, 20, -3, 20);
  }
  
  pg.popMatrix();  
}  
