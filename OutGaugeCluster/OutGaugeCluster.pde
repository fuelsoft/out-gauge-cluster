import java.io.*;
import java.net.*;
import java.util.*;
import java.nio.*;

float cx, cy, lcx, rcx;
float dy;
float radiusone;
float radiustwo;
float radiusthree;
float fuelRadius;

float rpm = 0;
float fuel = 1;
float engTemp = 0;
int prevTime = 0;
float speed = 0;
int showlights = 0;
float oilTemp = 0;
int gear = 1;

float acc = 0;

PShape signal;

/*CHANGE THESE*/
final int MAX_RPM = 5800;
final int MAX_SPEED = 190; //in km/h

void setup() {
  size(1280, 640);
  
  try {
    thread("getPacket");
  } catch (Exception e) {
    println("Exception in setting up packet reception");
    exit();
  }
  
  signal = createShape();
  signal.beginShape(TRIANGLE_STRIP);
  signal.fill(63, 200, 255);
  signal.noStroke();
  signal.vertex(0, 4);
  signal.vertex(2, 2);
  signal.vertex(0, 0);
  signal.endShape(CLOSE);

  int radius = min(width, height) / 2;
  radiusthree = radius * 0.72;
  radiusone = radius * 0.68;
  fuelRadius = radius * 0.15;
  radiustwo = radius * 1.8;
  
  cx = width / 2;
  cy = height / 2;
  lcx = cx / 2;
  rcx = lcx + cx;
  dy = cy*1.6;
}

void draw() {  
  
  background(0);
  
  /*VERTICAL INDICATOR START*/ //center
  for (float a = 0; a < 160; a += 20) {
    int widthOffset = 10;
    if(gear == (7-a/20)) { //this is the selected gear
      if (a == 120) {
        stroke(63, 255, 63);
      }
      else {
        stroke(255, 0, 0);
      }
      strokeWeight(3);
      widthOffset = 15;
      
    }
    else {
      strokeWeight(2);
      stroke(63, 200, 255);
    }
    line(cx-widthOffset, cy+a-20, cx+widthOffset, cy+a-20);
  }
  /*VERTICAL INDICATOR END*/
  
  /*SMALL GAUGE START*/ //left
  //eng temp colour
  if (engTemp > 0.8) { //temp warn colour
    stroke(255, 0, 0);
  }
  else {
     stroke(63, 200, 255);
  }
  
  //eng temp needle
  strokeWeight(2);
  line(lcx, dy, lcx + cos(engTemp*PI + PI) * radiusone/5, dy + sin(engTemp*PI + PI) * radiusone/5);
  
  //eng temp markers
  for (float a = 180; a <= 360; a += (45f/2f)) {
    float angle = radians(a);
    float x = lcx + cos(angle) * fuelRadius;
    float y = dy + sin(angle) * fuelRadius;
    float vx = lcx + cos(angle) * (fuelRadius+5);
    float vy = dy + sin(angle) * (fuelRadius+5);
    line(x, y, vx, vy);
    //vertex(x, y);
  }

  //eng temp knob
  fill(40);
  noStroke();
  ellipse(lcx, dy, 15, 15);
  /*SMALL GAUGE END*/
  
  ///*SMALL GAUGE START*/ //center
  ////acc colour
  //if (acc > 1) { //temp warn colour
  //  stroke(255, 0, 0);
  //}
  //else {
  //   stroke(63, 200, 255);
  //}
  
  ////acc needle
  //float scalar = (1/2f);
  //strokeWeight(2);
  //line(cx, dy, cx + cos(acc * PI * (scalar) + 3*PI/2) * radiusone/5, dy + sin(acc * PI * (scalar) + 3*PI/2) * radiusone/5);
  
  ////acc markers
  //for (float a = 180; a <= 360; a += (45f/2f)) {
  //  float angle = radians(a);
  //  float x = cx + cos(angle) * fuelRadius;
  //  float y = dy + sin(angle) * fuelRadius;
  //  float vx = cx + cos(angle) * (fuelRadius+5);
  //  float vy = dy + sin(angle) * (fuelRadius+5);
  //  line(x, y, vx, vy);
  //}

  ////acc knob
  //fill(40);
  //noStroke();
  //ellipse(cx, dy, 15, 15);
  ///*SMALL GAUGE END*/
  
  /*SMALL GAUGE START*/ //right
  //eng temp colour
  if (oilTemp > 140) { //temp warn colour
    stroke(255, 0, 0);
  }
  else {
     stroke(63, 200, 255);
  }
  
  //oil temp needle
  strokeWeight(2);
  float ot = map(oilTemp, 80, 150, 0, 1);
  if (ot < 0) ot = 0;
  else if (ot > 1) ot = 1;
  line(rcx, dy, rcx + cos(ot*PI + PI) * radiusone/5, dy + sin(ot*PI + PI) * radiusone/5);
  
  //oil temp markers
  for (float a = 180; a <= 360; a += (45f/2f)) {
    float angle = radians(a);
    float x = rcx + cos(angle) * fuelRadius;
    float y = dy + sin(angle) * fuelRadius;
    float vx = rcx + cos(angle) * (fuelRadius+5);
    float vy = dy + sin(angle) * (fuelRadius+5);
    line(x, y, vx, vy);
    //vertex(x, y);
  }

  //oil temp knob
  fill(40);
  noStroke();
  ellipse(rcx, dy, 15, 15);
  /*SMALL GAUGE END*/
  
  /*LARGE GAUGE START*/ //left
  float m = map(rpm, 0, MAX_RPM, 120, 420);
  
  //tach colour
  if (rpm < MAX_RPM*0.8) {
    stroke(63, 200, 255);
  }
  else if (rpm < MAX_RPM*0.95) {
    stroke(63+(map(rpm, MAX_RPM*0.8, MAX_RPM*0.95, 0, 1)*192), 200-(map(rpm, MAX_RPM*0.8, MAX_RPM*0.95, 0, 1)*127), 255-(map(rpm, MAX_RPM*0.8, MAX_RPM*0.95, 0, 1)*255));
  }
  else {
    stroke(255, 0, 0);
  }
  strokeWeight(5);
  line(lcx, cy, lcx + cos(radians(m)) * radiusone, cy + sin(radians(m)) * radiusone); //needle
  
  //tach macro marks
  strokeWeight(1);
  for (float a = 120; a <= 420; a += 300f/(MAX_RPM/100f)) {
    float angle = radians(a);
    float x = lcx + cos(angle) * radiusthree;
    float y = cy + sin(angle) * radiusthree;
    float vx = lcx + cos(angle) * (radiusthree+10);
    float vy = cy + sin(angle) * (radiusthree+10);
    line(x, y, vx, vy);
  }
  
  //tach micro marks
  strokeWeight(2);
  for (float a = 120; a <= 420; a += 300f/(MAX_RPM/1000f)) {
    float angle = radians(a);
    float x = lcx + cos(angle) * radiusthree;
    float y = cy + sin(angle) * radiusthree;
    float vx = lcx + cos(angle) * (radiusthree+20);
    float vy = cy + sin(angle) * (radiusthree+20);
    line(x, y, vx, vy);
  }
  
  //tach top and bottom markers
  strokeWeight(5);
  line(lcx + cos(radians(420)) * radiusthree, cy + sin(radians(420)) * radiusthree, lcx + cos(radians(420)) * (radiusthree+25), cy + sin(radians(420)) * (radiusthree+25));
  line(lcx + cos(radians(120)) * radiusthree, cy + sin(radians(120)) * radiusthree, lcx + cos(radians(120)) * (radiusthree+25), cy + sin(radians(120)) * (radiusthree+25));

  //tach knob
  fill(40);
  noStroke();
  ellipse(lcx, cy, 35, 35);
  /*LARGE GAUGE END*/
  
  /*LARGE GAUGE START*/ //right
  float p = map(speed*3.6, 0, MAX_SPEED, 120, 420);
  
  //speedo colour
  stroke(63, 200, 255);
  strokeWeight(5);
  line(rcx, cy, rcx + cos(radians(p)) * radiusone, cy + sin(radians(p)) * radiusone); //needle
  
  //speedo macro marks
  strokeWeight(1);
  for (float a = 120; a <= 420; a += 300f/(MAX_SPEED)) {
    float angle = radians(a);
    float x = rcx + cos(angle) * radiusthree;
    float y = cy + sin(angle) * radiusthree;
    float vx = rcx + cos(angle) * (radiusthree+10);
    float vy = cy + sin(angle) * (radiusthree+10);
    line(x, y, vx, vy);
  }
  
  //speedo micro marks
  strokeWeight(2);
  for (float a = 120; a <= 420; a += 300f/(MAX_SPEED/10f)) {
    float angle = radians(a);
    float x = rcx + cos(angle) * radiusthree;
    float y = cy + sin(angle) * radiusthree;
    float vx = rcx + cos(angle) * (radiusthree+20);
    float vy = cy + sin(angle) * (radiusthree+20);
    line(x, y, vx, vy);
  }
  
  //speedo top and bottom markers
  strokeWeight(5);
  line(rcx + cos(radians(420)) * radiusthree, cy + sin(radians(420)) * radiusthree, rcx + cos(radians(420)) * (radiusthree+25), cy + sin(radians(420)) * (radiusthree+25));
  line(rcx + cos(radians(120)) * radiusthree, cy + sin(radians(120)) * radiusthree, rcx + cos(radians(120)) * (radiusthree+25), cy + sin(radians(120)) * (radiusthree+25));

  //speedo knob
  fill(40);
  noStroke();
  ellipse(rcx, cy, 35, 35);
  /*LARGE GAUGE END*/

  /*BAR GAUGE START*/
  //fuel bar
  strokeWeight(8);
  stroke(40);
  line(cx - 160, cy*1.85, cx + 160, cy*1.85); //fuel background
  if (fuel > 0.0f) {
    if (fuel < 0.15) { //fuel warn colour
      stroke(255, 0, 0);
    }
    else { //fuel OK colour
       stroke(63, 200, 255);
    }
    line(cx - 160, cy*1.85, (cx - 160)+(320*fuel), cy*1.85);
  }
  /*BAR GAUGE END*/
  
  /*SIGNAL START*/
  //turn signals
  if((showlights & 0x0040) != 0) {
  shape(signal, cx+10, dy*1.055, 25, 25); // ->
  }
  if((showlights & 0x0020) != 0) {
  shape(signal, cx-10, dy*1.055, -25, 25); // <-
  }
  /*SIGNAL END*/
  
}

void getPacket() throws IOException{
  println("opening port 5555");
  DatagramSocket socket = new DatagramSocket(5555);
  byte[] buf = new byte[64];
  DatagramPacket packet = new DatagramPacket(buf, buf.length);
  while (true) {
    socket.receive(packet);
    byte[] data = packet.getData();
    rpm = ByteBuffer.wrap(new byte[]{data[16], data[17], data[18], data[19]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    speed = ByteBuffer.wrap(new byte[]{data[12], data[13], data[14], data[15]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    fuel = ByteBuffer.wrap(new byte[]{data[28], data[29], data[30], data[31]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    engTemp = ByteBuffer.wrap(new byte[]{data[24], data[25], data[26], data[27]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    showlights = ByteBuffer.wrap(new byte[]{data[44], data[45], data[46], data[47]}).order(ByteOrder.LITTLE_ENDIAN).getInt();
    oilTemp = ByteBuffer.wrap(new byte[]{data[36], data[37], data[38], data[39]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    gear = (0xFF & data[10]);
  }
}