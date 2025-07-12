#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

// Create the PWM driver object
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

// Servo pulse length limits (adjust these for your specific servos)
#define SERVOMIN  150  // Minimum pulse length count (out of 4096)
#define SERVOMAX  600  // Maximum pulse length count (out of 4096)
#define SERVOMID  375  // Middle position pulse length

void setup() {
  Serial.begin(9600);
  Serial.println("PCA9685 Servo Test");

  // Initialize the PWM driver
  pwm.begin();
  pwm.setOscillatorFrequency(27000000);  // Set to 27MHz internal oscillator frequency
  pwm.setPWMFreq(50);  // Servo frequency is typically 50Hz

  delay(10);
  
  // Start servo 0 at middle position
  pwm.setPWM(0, 0, SERVOMID);
  Serial.println("Servo 0 initialized to middle position");
  delay(1000);
}

void loop() {
  Serial.println("Moving servo 0 to minimum position");
  pwm.setPWM(0, 0, SERVOMIN);
  delay(1000);
  
  Serial.println("Moving servo 0 to middle position");
  pwm.setPWM(0, 0, SERVOMID);
  delay(1000);
  
  Serial.println("Moving servo 0 to maximum position");
  pwm.setPWM(0, 0, SERVOMAX);
  delay(1000);
  
  Serial.println("Moving servo 0 back to middle position");
  pwm.setPWM(0, 0, SERVOMID);
  delay(1000);
}
