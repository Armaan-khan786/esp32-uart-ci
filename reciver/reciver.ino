#define RXD2 16
#define TXD2 17

String rx = "";
unsigned long startTime;

void setup() {
  Serial.begin(115200);           // USB logs to PC
  Serial2.begin(9600, SERIAL_8N1, RXD2, TXD2);

  Serial.println("UART TEST STARTED");
  startTime = millis();
}

void loop() {
  while (Serial2.available()) {
    char c = Serial2.read();

    if (c == '\n') {
      if (rx == "10101") {
        Serial.println("UART_TEST_PASS");
      } else {
        Serial.println("UART_TEST_FAIL");
      }
      while (1);  // STOP after result
    }
    else if (c == '0' || c == '1') {
      rx += c;
    }
  }

  // Timeout protection
  if (millis() - startTime > 5000) {
    Serial.println("UART_TEST_FAIL");
    while (1);
  }
}