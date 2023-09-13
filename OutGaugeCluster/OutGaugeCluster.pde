import java.io.*;
import java.net.*;
import java.util.*;
import java.nio.*;

char gearnames[] = {'R', 'N', '1', '2', '3', '4', '5', '6'};

float cx, cy, lcx, rcx, by;
float dy;
int radius;
float radiusone;
float radiustwo;
float radiusthree;
float fuelRadius;

PFont labelFont;

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

void setup() {
	size(1000, 400);
	try {
		thread("getPacket");
	} catch (Exception e) {
		println("Failed to create network connection!");
		exit();
	}
	
	// font_default = createFont("./assets/LiberationMono-Regular.ttf", 20);
	labelFont = createFont("./assets/BravePhoenixCompactItalic-gxYEq.otf", 72);
}

void draw() {  
	background(0x00, 0xFF, 0x00);

	int col1 = 100;
	int col2 = 380;
	int col3 = 600;

	int row1 = 120;
	int row2 = row1 + 80;
	int row3 = row2 + 80;

	textFont(labelFont);

	text("RPM: " + Integer.toString((int) max(rpm, 0)), col1, row1);
	text("KM/H: "  + Integer.toString((int) (speed * 3.6f)), col1, row2);

	text("PSI: " + Float.toString(((int) (boost * 14.5f * 10)) / 10.0f), col3, row1);
	text("GEAR: " + gearnames[gear], col3, row2);

	text(Float.toString(((int) (fuel * 1000)) / 10.0f) + '%', col1, row3);
	text(Float.toString(((int) (engTemp * 10)) / 10.0f) + " °C", col2, row3);
	text(Float.toString(((int) (oilTemp * 10)) / 10.0f) + " °C", 660, row3);
}

void getPacket() throws IOException{
	println("opening port 5555");
	DatagramSocket socket = new DatagramSocket(5555);
	byte[] buf = new byte[64];
	DatagramPacket packet = new DatagramPacket(buf, buf.length);
	while (true) {
		socket.receive(packet);
		byte[] data = packet.getData();

		// for (int i = 0; i < 4; i++) car[i] = (char) data[4 + i];
		gear = (0xFF & data[10]);
		speed = ByteBuffer.wrap(new byte[]{data[12], data[13], data[14], data[15]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
		rpm = ByteBuffer.wrap(new byte[]{data[16], data[17], data[18], data[19]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
		boost = ByteBuffer.wrap(new byte[]{data[20], data[21], data[22], data[23]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
		engTemp = ByteBuffer.wrap(new byte[]{data[24], data[25], data[26], data[27]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
		fuel = ByteBuffer.wrap(new byte[]{data[28], data[29], data[30], data[31]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
		// oilPress = ByteBuffer.wrap(new byte[]{data[32], data[33], data[34], data[35]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
		oilTemp = ByteBuffer.wrap(new byte[]{data[36], data[37], data[38], data[39]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
		showlights = ByteBuffer.wrap(new byte[]{data[44], data[45], data[46], data[47]}).order(ByteOrder.LITTLE_ENDIAN).getInt();
		//clutch = ByteBuffer.wrap(new byte[]{data[64], data[65], data[66], data[67]}).order(ByteOrder.LITTLE_ENDIAN).getFloat();
	}
}
