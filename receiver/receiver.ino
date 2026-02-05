#define RXD2 16
#define TXD2 17

String rx = "";
unsigned long startTime;

void setup() {
  Serial.begin(115200);   // USB to PC (CI reads this)
  Serial2.begin(115200, SERIAL_8N1, RXD2, TXD2); // MUST MATCH SENDER

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

    // Accept only valid toggle bits
    if (c == '0' || c == '1') {
      rx += c;

      // Safety: limit length
      if (rx.length() > 5) {
        Serial.println("UART_TEST_FAIL");
        while (1);
      }
    }
  }

  // CI-safe timeout (longer)
  if (millis() - startTime > 8000) {
    Serial.println("UART_TEST_FAIL");
    while (1);
  }
}
