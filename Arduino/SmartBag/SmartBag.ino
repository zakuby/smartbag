/*
 *  Created by Muhammad Yaqub
*/
#include <TimeLib.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <SPI.h>
#include <MFRC522.h>
#include <Wire.h>
#include <FirebaseArduino.h>
#include "SoftwareSerial.h"

// Firebase Setup
#define FIREBASE_HOST "smartbag-b64b8.firebaseio.com"
#define FIREBASE_AUTH "idX9y5iDKOfRwrMVKghhHgAm1ykPywDYw9MjPsOa"

//RFID Reader Pin
#define SS_PIN D4  //D2
#define RST_PIN D3 //D1

// Wifi
const char* ssid     = "Theex-HQ";
//"Theex-HQ"; "FeelsBadMan"; "Lilian";
const char* password = "JuraganPeceLyeye";
//"JuraganPeceLyeye"; "jangkrik39A"; "qwertyui";

// NTP Servers:
static const char ntpServerName[] = "us.pool.ntp.org";
//static const char ntpServerName[] = "time.nist.gov";
time_t prevDisplay = 0; // when the digital clock was displayed
const int timeZone = 7;     // +7 GMT Waktu Indonesia Barat

WiFiUDP Udp;
unsigned int localPort = 8888;  // local port to listen for UDP packets

time_t getNtpTime();
void digitalClockDisplay();
void printDigits(int digits);
void sendNTPpacket(IPAddress &address);

// MPU6050 Slave Device Address
const uint8_t MPU6050SlaveAddress = 0x68;

// Select SDA and SCL pins for I2C communication
const uint8_t scl = D1;
const uint8_t sda = D2;

// sensitivity scale factor respective to full scale setting provided in datasheet
const uint16_t AccelScaleFactor = 16384;
const uint16_t GyroScaleFactor = 131;

// MPU6050 few configuration register addresses
const uint8_t MPU6050_REGISTER_SMPLRT_DIV   =  0x19;
const uint8_t MPU6050_REGISTER_USER_CTRL    =  0x6A;
const uint8_t MPU6050_REGISTER_PWR_MGMT_1   =  0x6B;
const uint8_t MPU6050_REGISTER_PWR_MGMT_2   =  0x6C;
const uint8_t MPU6050_REGISTER_CONFIG       =  0x1A;
const uint8_t MPU6050_REGISTER_GYRO_CONFIG  =  0x1B;
const uint8_t MPU6050_REGISTER_ACCEL_CONFIG =  0x1C;
const uint8_t MPU6050_REGISTER_FIFO_EN      =  0x23;
const uint8_t MPU6050_REGISTER_INT_ENABLE   =  0x38;
const uint8_t MPU6050_REGISTER_ACCEL_XOUT_H =  0x3B;
const uint8_t MPU6050_REGISTER_SIGNAL_PATH_RESET  = 0x68;

int16_t AccelX, AccelY, AccelZ, Temperature, GyroX, GyroY, GyroZ;
int notag = 0;
bool inventoryIn;



MFRC522 mfrc522(SS_PIN, RST_PIN);   // Create MFRC522 instance.

void WiFiEvent(WiFiEvent_t event) {
  Serial.printf("[WiFi-event] event: %d\n", event);

  switch (event) {
    case WIFI_EVENT_STAMODE_GOT_IP:
      Serial.println("WiFi connected");
      Serial.println("IP address: ");
      Serial.println(WiFi.localIP());
      
      break;
    case WIFI_EVENT_STAMODE_DISCONNECTED:
      Serial.println("WiFi lost connection");
      break;
  }
}

void setup() 
{
  
  Serial.begin(9600);   // Initiate a serial communication
  while (!Serial) ; // Needed for Leonardo only
  
  SPI.begin();      // Initiate  SPI bus
  mfrc522.PCD_Init();   // Initiate MFRC522
  Serial.println();
  Serial.println("RFID Reader OK.");
  
  Wire.begin(sda, scl);
  MPU6050_Init();
  // delete old config
  WiFi.disconnect(true);

  delay(100);

  WiFi.onEvent(WiFiEvent);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("Starting UDP");
  Udp.begin(localPort);
  Serial.print("Local port: ");
  Serial.println(Udp.localPort());
  Serial.println("waiting for sync");
  setSyncProvider(getNtpTime);
  setSyncInterval(300);
  
  Serial.println();
  Serial.println();
  Serial.println("Wait for WiFi... ");
  delay(100);

  pinMode(D0,OUTPUT);
  pinMode(D8,OUTPUT);
  Serial.println();
  Serial.println("LED OK.");
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.stream("/");
  Serial.println();
  Serial.println("Firebase Stream OK.");
}
void loop() 
{
  digitalWrite(D0, LOW);
  digitalWrite(D8, LOW);
  if (timeStatus() != timeNotSet) {
    if (now() != prevDisplay) { //update the display only if time has changed
      prevDisplay = now();
      digitalClockDisplay();
    }
  }
  
  readAccel();
  delay(500);
  scanRFID();

} 
double AxPrev, AyPrev, AzPrev, AxNext, AyNext, AzNext, rangeAz;
int counterAccel = 0;
int counterIdle = 0;

void readAccel(){
  double Ax, Ay, Az;
  Read_RawValue(MPU6050SlaveAddress, MPU6050_REGISTER_ACCEL_XOUT_H);

  //divide each with their sensitivity scale factor
  Ax = (double)AccelX / AccelScaleFactor;
  Ay = (double)AccelY / AccelScaleFactor;
  Az = (double)AccelZ / AccelScaleFactor;
  if (counterAccel == 0){
    AxPrev = Ax;
    AzPrev = Az;
    AyPrev = Ay;
    counterAccel = 1;
  }else if(counterAccel == 1){
    AxNext = Ax;
    AzNext = Az;
    AyPrev = Ay;
    counterAccel = 0;
    counterIdle = counterIdle + 1;
    rangeAz = AzPrev - AzNext;
    Serial.print("Az Range : ");Serial.println(AzPrev - AzNext);
    if (rangeAz >= 0.12 || rangeAz <= -0.12){
      Serial.print("Tas Diangkat");
      counterIdle = 0;
        if (Firebase.getInt("tasMove") != 1){
          Firebase.set("tasMove", 1);
        }
    }else if (counterIdle == 10 && rangeAz <= 0.03 && rangeAz >= -0.03){
        if (Firebase.getInt("tasMove") != 0){
          Firebase.set("tasMove", 0);
        }
    }
  }
}

void scanRFID(){
  // Look for new cards
  if ( ! mfrc522.PICC_IsNewCardPresent()) 
  {
    return;
  }
  // Select one of the cards
  if ( ! mfrc522.PICC_ReadCardSerial()) 
  {
    return;
  }

  getUIDtag();
  
}

//Show UID on serial monitor
void getUIDtag(){
  Serial.println();
  Serial.print(" UID tag :");
  String content= "";
  byte letter;
  for (byte i = 0; i < mfrc522.uid.size; i++) 
  {
     Serial.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
     Serial.print(mfrc522.uid.uidByte[i], HEX);
     content.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " "));
     content.concat(String(mfrc522.uid.uidByte[i], HEX));
  }
  content.toUpperCase();
  Serial.println();
  sendUIDtoFirebase(content);
}

void sendUIDtoFirebase(String content){
  String UIDTime = String(day()) + "-" + String(month()) + "-" + String(year()) + " " + String(hour()) + ":" + String(minute()) + ":" + String(second());
  if (Firebase.getInt("inventory/"+content.substring(1)+"/status") == 0)
  {
    Firebase.set("inventory/"+content.substring(1)+"/status", 1);
    Firebase.setString("inventory/"+content.substring(1)+"/in/time", UIDTime);
    Serial.println("Inventory In, Status Data uploaded");
    inventoryIn = true;
  }else{
    Firebase.set("inventory/"+content.substring(1)+"/status", 0);
    Firebase.setString("inventory/"+content.substring(1)+"/out/time", UIDTime);
    Serial.println("Inventory Out, Status Data uploaded");
    inventoryIn = false;
  }
  statusLED();
  notag = 1;
  Serial.println();
}

void statusLED(){
  if(inventoryIn){
    digitalWrite(D8, HIGH); //Lampu Hijau Menyala
    delay(2000);
  }else{
    digitalWrite(D0, HIGH); //Lampu Merah Menyala
    delay(2000);
  }
}

void I2C_Write(uint8_t deviceAddress, uint8_t regAddress, uint8_t data) {
  Wire.beginTransmission(deviceAddress);
  Wire.write(regAddress);
  Wire.write(data);
  Wire.endTransmission();
}

// read all 14 register
void Read_RawValue(uint8_t deviceAddress, uint8_t regAddress) {
  Wire.beginTransmission(deviceAddress);
  Wire.write(regAddress);
  Wire.endTransmission();
  Wire.requestFrom(deviceAddress, (uint8_t)14);
  AccelX = (((int16_t)Wire.read() << 8) | Wire.read());
  AccelY = (((int16_t)Wire.read() << 8) | Wire.read());
  AccelZ = (((int16_t)Wire.read() << 8) | Wire.read());
  Temperature = (((int16_t)Wire.read() << 8) | Wire.read());
  GyroX = (((int16_t)Wire.read() << 8) | Wire.read());
  GyroY = (((int16_t)Wire.read() << 8) | Wire.read());
  GyroZ = (((int16_t)Wire.read() << 8) | Wire.read());
}

//configure MPU6050
void MPU6050_Init() {
  delay(150);
  Serial.println("MPU6050 OK.");
  I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_SMPLRT_DIV, 0x07);
  I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_PWR_MGMT_1, 0x01);
  I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_PWR_MGMT_2, 0x00);
  I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_CONFIG, 0x00);
  I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_GYRO_CONFIG, 0x00);//set +/-250 degree/second full scale
  I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_ACCEL_CONFIG, 0x00);// set +/- 2g full scale
  I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_FIFO_EN, 0x00);
  I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_INT_ENABLE, 0x01);
  I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_SIGNAL_PATH_RESET, 0x00);
  I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_USER_CTRL, 0x00);
}


void printDigits(int digits)
{
  // utility for digital clock display: prints preceding colon and leading 0
  Serial.print(":");
  if (digits < 10)
    Serial.print('0');
  Serial.print(digits);
}



void digitalClockDisplay()
{
  // digital clock display of the time
  Serial.print(hour());
  printDigits(minute());
  printDigits(second());
  Serial.print(" ");
  Serial.print(day());
  Serial.print(".");
  Serial.print(month());
  Serial.print(".");
  Serial.print(year());
  Serial.println();
}
/*-------- NTP code ----------*/

const int NTP_PACKET_SIZE = 48; // NTP time is in the first 48 bytes of message
byte packetBuffer[NTP_PACKET_SIZE]; //buffer to hold incoming & outgoing packets

time_t getNtpTime()
{
  IPAddress ntpServerIP; // NTP server's ip address

  while (Udp.parsePacket() > 0) ; // discard any previously received packets
  Serial.println("Transmit NTP Request");
  // get a random server from the pool
  WiFi.hostByName(ntpServerName, ntpServerIP);
  Serial.print(ntpServerName);
  Serial.print(": ");
  Serial.println(ntpServerIP);
  sendNTPpacket(ntpServerIP);
  uint32_t beginWait = millis();
  while (millis() - beginWait < 1500) {
    int size = Udp.parsePacket();
    if (size >= NTP_PACKET_SIZE) {
      Serial.println("Receive NTP Response");
      Udp.read(packetBuffer, NTP_PACKET_SIZE);  // read packet into the buffer
      unsigned long secsSince1900;
      // convert four bytes starting at location 40 to a long integer
      secsSince1900 =  (unsigned long)packetBuffer[40] << 24;
      secsSince1900 |= (unsigned long)packetBuffer[41] << 16;
      secsSince1900 |= (unsigned long)packetBuffer[42] << 8;
      secsSince1900 |= (unsigned long)packetBuffer[43];
      return secsSince1900 - 2208988800UL + timeZone * SECS_PER_HOUR;
    }
  }
  Serial.println("No NTP Response :-(");
  return 0; // return 0 if unable to get the time
}

// send an NTP request to the time server at the given address
void sendNTPpacket(IPAddress &address)
{
  // set all bytes in the buffer to 0
  memset(packetBuffer, 0, NTP_PACKET_SIZE);
  // Initialize values needed to form NTP request
  // (see URL above for details on the packets)
  packetBuffer[0] = 0b11100011;   // LI, Version, Mode
  packetBuffer[1] = 0;     // Stratum, or type of clock
  packetBuffer[2] = 6;     // Polling Interval
  packetBuffer[3] = 0xEC;  // Peer Clock Precision
  // 8 bytes of zero for Root Delay & Root Dispersion
  packetBuffer[12] = 49;
  packetBuffer[13] = 0x4E;
  packetBuffer[14] = 49;
  packetBuffer[15] = 52;
  // all NTP fields have been given values, now
  // you can send a packet requesting a timestamp:
  Udp.beginPacket(address, 123); //NTP requests are to port 123
  Udp.write(packetBuffer, NTP_PACKET_SIZE);
  Udp.endPacket();
}
