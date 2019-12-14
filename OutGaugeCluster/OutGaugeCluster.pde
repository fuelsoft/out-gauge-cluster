import java.io.*;
import java.net.*;
import java.util.*;
import java.nio.*;

float cx, cy, lcx, rcx, by;
float dy;
int radius;
float radiusone;
float radiustwo;
float radiusthree;
float fuelRadius;
PShape signal;
PImage im_tcs, im_abs, im_highbeam, im_parking;

//natural data
int time;
char car[] = new char[4];
int gear;
float speed;
float rpm;
float boost;
float engTemp;
float fuel;
float oilPress;
float oilTemp;
int dashlights;
int showlights;
float throttle;
float brake;
float clutch;

int prevTime = 0;

//derived data
float expectedSpeed = 0;
float[] accel = new float[12];
float aggregatedAccel = 0f;
float[] consumption = new float[30];
float aggregatedCons = 0f;

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
  signal.fill(32, 157, 41);
  signal.noStroke();
  signal.vertex(0, 4);
  signal.vertex(2, 2);
  signal.vertex(0, 0);
  signal.endShape(CLOSE);
  
  im_tcs = loadImage("assets/tcs.png");
  im_abs = loadImage("assets/abs.png");
  im_highbeam = loadImage("assets/high-beam.png");
  im_parking = loadImage("assets/parking.png");

  radius = min(width, height) / 2;
  radiusthree = radius * 0.72;
  radiusone = radius * 0.68;
  fuelRadius = radius * 0.15;
  radiustwo = radius * 1.8;
  
  cx = width / 2;
  cy = height / 2;
  lcx = cx / 2;
  rcx = lcx + cx;
  dy = cy*1.6;
  by = cy / 2;
}

void draw() {  
  
  background(0);
  
  accel = shift(accel);
  accel[accel.length - 1] = speed;
  aggregatedAccel = aggregate(accel)/accel.length;
  
  consumption = shift(consumption);
  consumption[consumption.length - 1] = fuel;
  aggregatedCons = 10000*aggregate(consumption)/consumption.length;
  
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
  if (engTemp > 115) { //temp warn colour
    stroke(255, 0, 0);
  }
  else {
     stroke(63, 200, 255);
  }
  
  //eng temp needle
  strokeWeight(2);
  float et = map(engTemp, 60, 130, 0, 1);
  if (et < 0) et = 0;
  else if (et > 1) et = 1;
  line(lcx, dy, lcx + cos(et*PI + PI) * radiusone/5, dy + sin(et*PI + PI) * radiusone/5);
  
  //eng temp markers
  for (float a = 180; a <= 360; a += (45f/2f)) {
    float angle = radians(a);
    float x = lcx + cos(angle) * fuelRadius;
    float y = dy + sin(angle) * fuelRadius;
    float vx = lcx + cos(angle) * (fuelRadius+5);
    float vy = dy + sin(angle) * (fuelRadius+5);
    line(x, y, vx, vy);
  }

  //eng temp knob
  fill(40);
  noStroke();
  ellipse(lcx, dy, 15, 15);
  /*SMALL GAUGE END*/
  
  /*SMALL GAUGE START*/ //right
  //oil temp colour
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
  }

  //oil temp knob
  fill(40);
  noStroke();
  ellipse(rcx, dy, 15, 15);
  /*SMALL GAUGE END*/
  
  /*SMALL GAUGE START*/ //centre
  //boost pressure colour
  if (boost > 2) { //high boost colour
     stroke(255, 0, 0);
  }
  else if (boost < 0) { //vacuum
     stroke(255, 0, 0); 
  }
  else {
     stroke(63, 200, 255);
  }
  
  //boost pressure needle
  strokeWeight(2);
  float bp = map(boost, 0, 2.06, 0, 1); //boost is in bar
  line(cx, by, cx + cos(bp*PI + PI) * radiusone/3, by + sin(bp*PI + PI) * radiusone/3);
  
  //oil temp markers
  for (float a = 135; a <= 405; a += (45f/4f)) {
    float angle = radians(a);
    float x = cx + cos(angle) * ((radiusone/3)+5);
    float y = by + sin(angle) * ((radiusone/3)+5);
    float vx = cx + cos(angle) * ((radiusone/3)+12);
    float vy = by + sin(angle) * ((radiusone/3)+12);
    line(x, y, vx, vy);
  }

  //boost knob
  fill(40);
  noStroke();
  ellipse(cx, by, 20, 20);
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
  
  //tach micro marks
  strokeWeight(1);
  for (float a = 120; a <= 420; a += 300f/(MAX_RPM/100f)) {
    float angle = radians(a);
    float x = lcx + cos(angle) * radiusthree;
    float y = cy + sin(angle) * radiusthree;
    float vx = lcx + cos(angle) * (radiusthree+10);
    float vy = cy + sin(angle) * (radiusthree+10);
    line(x, y, vx, vy);
  }
  
  //tach macro marks
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
  
  strokeWeight(5);
  line(lcx, cy, lcx + cos(radians(m)) * radiusone, cy + sin(radians(m)) * radiusone); //needle

  //tach knob
  fill(40);
  noStroke();
  ellipse(lcx, cy, 35, 35);
  /*LARGE GAUGE END*/
  
  /*LARGE GAUGE START*/ //right
  float p = map(speed*3.6, 0, MAX_SPEED, 120, 420);
  
  //speedo colour
  stroke(63, 200, 255);
  
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
  
  strokeWeight(5);
  line(rcx, cy, rcx + cos(radians(p)) * radiusone, cy + sin(radians(p)) * radiusone); //needle
  
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
    line((cx - 160), cy*1.85, (cx - 160)+(320*fuel), cy*1.85);
  }
  /*BAR GAUGE END*/
  
  /*BAR GAUGE START*/
  //consumption bar
  strokeWeight(8);
  stroke(40);
  line(cx - 160, cy*1.9, cx + 160, cy*1.9);
  if (aggregatedCons > 0) { //consume
    stroke(63, 200, 255);
    line((cx - 160), cy*1.9, (cx - 160)+(640*aggregatedCons), cy*1.9);
  }
  else { //refill (or recharge on electric vehicles)
    stroke(0, 255, 0);
    line((cx - 160), cy*1.9, (cx - 160), cy*1.9);
  }
  /*BAR GAUGE END*/
  
  /*SIGNAL START*/
  int offset = 32;
  //turn signals
  if((showlights & 0x0040) != 0) {
    shape(signal, cx + 110, by/2, 35, 35); // ->
  }
  if((showlights & 0x0020) != 0) {
    shape(signal, cx - 110, by/2, -35, 35); // <-
  }
  if ((showlights & 0x0002) != 0) { // highbeams
    image(im_highbeam, cx - offset, dy + 40 - offset);
  }
  if ((showlights & 0x0010) != 0) { // traction control
    image(im_tcs, cx + 75 - offset, dy - 20 - offset);
  }
  if ((showlights & 0x0400) != 0) { // antilock breaks
    image(im_abs, cx - 75 - offset, dy - 20 - offset);
  }
  if ((showlights & 0x0004) != 0) { // handbreak breaks
    image(im_parking, cx - offset, dy - 20 - offset);
  }
  /*SIGNAL END*/
}

float[] shift(float[] arr) {
  for (int i = 0; i < arr.length-1; i++) {
    arr[i] = arr[i+1];
  }
  return arr;
}

float aggregate(float[] arr) {
  float a = 0;
   for (int i = 0; i < arr.length-1; i++) {
      a += (arr[i] - arr[i+1]);
   }
   return a;
}

void getPacket() throws IOException{
  println("opening port 5555");
  DatagramSocket socket = new DatagramSocket(5555);
  byte[] buf = new byte[64];
  DatagramPacket packet = new DatagramPacket(buf, buf.length);
  while (true) {
    socket.receive(packet);
    byte[] data = packet.getData();

    for (int i = 0; i < 4; i++) car[i] = (char) data[4 + i];
    gear = (0xFF & data[10]);
    speed = ByteBuffer.wrap(new byte[]{data[12], data[13], data[14], data[15]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    rpm = ByteBuffer.wrap(new byte[]{data[16], data[17], data[18], data[19]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    boost = ByteBuffer.wrap(new byte[]{data[20], data[21], data[22], data[23]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    engTemp = ByteBuffer.wrap(new byte[]{data[24], data[25], data[26], data[27]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    fuel = ByteBuffer.wrap(new byte[]{data[28], data[29], data[30], data[31]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    oilPress = ByteBuffer.wrap(new byte[]{data[32], data[33], data[34], data[35]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    oilTemp = ByteBuffer.wrap(new byte[]{data[36], data[37], data[38], data[39]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
    showlights = ByteBuffer.wrap(new byte[]{data[44], data[45], data[46], data[47]}).order(ByteOrder.LITTLE_ENDIAN).getInt();
    //clutch = ByteBuffer.wrap(new byte[]{data[64], data[65], data[66], data[67]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
  }
}
