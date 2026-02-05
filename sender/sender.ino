#define RXD2 16
#define TXD2 17

char pattern[] = "10101";

void setup() {
  Serial.begin(115200);
  Serial2.begin(115200, SERIAL_8N1, RXD2, TXD2); // MUST MATCH RECEIVER

  Serial.println("ESP32-A Sender Started");
}

void loop() {
  Serial2.print(pattern);   // send 10101
  Serial2.print('\n');      // newline terminator

  Serial.print("Sent: ");
  Serial.println(pattern);

  delay(2000);  // repeat every 2s (safe for CI)
}
