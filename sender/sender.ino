#define RXD2 16
#define TXD2 17

char pattern[] = "10101";

void setup() {
  Serial.begin(115200);
  Serial2.begin(9600, SERIAL_8N1, RXD2, TXD2);

  Serial.println("ESP32-A Sender Started");
}

void loop() {
  Serial2.write(pattern);     // send 10101
  Serial2.write('\n');        // end marker

  Serial.print("Sent: ");
  Serial.println(pattern);

  delay(2000);
}