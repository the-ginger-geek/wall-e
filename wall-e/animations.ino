/**
 * Wall-e Animation Presets
 * 
 * @file      animations.ino
 * @brief     Servo motor animations for various Wall-E movements
 * @author    Simon Bluett
 * @copyright MIT license
 * @version   2.9
 * @date      7th August 2020
 * 
 * Preset animations for all the servo motors can be defined here.
 * The animations consist of a set of position instructions for each
 * servo motor, along with a specified time for how long that position
 * should be held until the next animation instruction is executed.
 *
 * To add your own animation, follow these steps:
 * 1. Add a new 'case' statement with the number you want to associate with your animation.
 * 2. Follow the same format as below to add new movement instructions
 *    queue.push({time, head rotation, neck top, neck bottom, eye right, eye left, arm left, arm right})
 *    > The time needs to be a number in milliseconds
 *    > Each servo position value needs to be an integer (whole) number between 0-100
 *    > 0 = LOW servo position, 100 = HIGH servo position as specified in the wall-e_calibration sketch
 *    > If you want the servo to be disabled/not updated by a specific instruction, use -1
 * 3. Make sure that your 'case' statement ends with the "break;" command 
 */

#ifndef ANIMATIONS_INO
#define ANIMATIONS_INO

void playAnimation(int animationNo) {

	switch (animationNo) {

		case 0:
			// --- Reset Servo positions ---
			//          time,head,necT,necB,eyeR,eyeL,armL,armR
			queue.push({1000,  50,  10,  0,   0,   0,  40,  40});
			break;

		case 1:
			// --- Bootup Eye Sequence ---
			//          time,head,necT,necB,eyeR,eyeL,armL,armR
			queue.push({2000,  50,  45,  90,  40,  40,  40,  40});
			queue.push({ 700,  50,  45,  90,  40,   0,  40,  40});
			queue.push({ 700,  50,  45,  90,   0,   0,  40,  40});
			queue.push({ 700,  50,  45,  90,   0,  40,  40,  40});
			queue.push({ 700,  50,  45,  90,  40,  40,  40,  40});
			queue.push({ 400,  50,  45,  90,   0,   0,  40,  40});
			queue.push({ 400,  50,  45,  90,  40,  40,  40,  40});
			queue.push({2000,  50,   0,  60,  40,  40,  40,  40});
			queue.push({1000,  50,   0,  60,   0,   0,  40,  40});
			break;

		case 2:
			// --- Inquisitive motion sequence ---
			//          time,head,necT,necB,eyeR,eyeL,armL,armR
			queue.push({3000,  48,  40,   0,  35,  45,  60,  59});
			queue.push({1500,  48,  40,  20, 100,   0,  80,  80});
			queue.push({3000,   0,  40,  40, 100,   0,  80,  80});
			queue.push({1500,  48,  60, 100,  40,  40, 100, 100});
			queue.push({1500,  48,  40,  30,  45,  35,   0,   0});
			queue.push({1500,  34,  34,  10,  14, 100,   0,   0});
			queue.push({1500,  48,  60,  20,  35,  45,  60,  59});
			queue.push({3000, 100,  20,  50,  40,  40,  60, 100});
			queue.push({1500,  48,  15,   0,   0,   0,   0,   0});
			queue.push({1000,  50,  10,   0,   0,   0,  40,  40});
			break;

		case 3:
			// --- Happy Expression ---
			//          time,head,necT,necB,eyeR,eyeL,armL,armR
			queue.push({ 500,  50,  20,  30,  80,  80,  20,  20});
			queue.push({ 800,  40,  30,  40, 100, 100,  10,  10});
			queue.push({ 600,  60,  30,  40, 100, 100,  90,  90});
			queue.push({ 800,  50,  20,  30,  80,  80,  20,  20});
			queue.push({ 600,  45,  25,  35, 100, 100,  80,  80});
			queue.push({ 600,  55,  25,  35, 100, 100,  10,  10});
			queue.push({1200,  50,  20,  30,  80,  80,  40,  40});
			break;

		case 4:
			// --- Sad Expression ---
			//          time,head,necT,necB,eyeR,eyeL,armL,armR
			queue.push({1500,  50,  60,  20,  10,  10,  60,  60});
			queue.push({2000,  45,  70,  10,   0,   0,  70,  70});
			queue.push({1800,  40,  80,   5,   5,   5,  80,  80});
			queue.push({2500,  35,  85,   0,   0,   0,  85,  85});
			queue.push({1500,  40,  80,   5,   5,   5,  80,  80});
			queue.push({2000,  45,  70,  10,  10,  10,  70,  70});
			queue.push({1500,  50,  60,  20,  20,  20,  60,  60});
			break;

		case 5:
			// --- Surprise Expression ---
			//          time,head,necT,necB,eyeR,eyeL,armL,armR
			queue.push({ 200,  50,  10,  60, 100, 100,  40,  40});
			queue.push({ 300,  40,   0,  80, 100, 100,  10,  10});
			queue.push({ 400,  60,   5,  70, 100, 100,  90,  90});
			queue.push({ 500,  50,  15,  50, 100, 100,  20,  80});
			queue.push({ 600,  45,  10,  60, 100, 100,  80,  20});
			queue.push({ 400,  55,   5,  65, 100, 100,  30,  70});
			queue.push({1000,  50,  10,  50,  80,  80,  40,  40});
			break;

		case 6:
			// --- Dance Movement ---
			//          time,head,necT,necB,eyeR,eyeL,armL,armR
			queue.push({ 800,  30,  30,  40,  60,  60,  90,  10});
			queue.push({ 800,  70,  20,  50,  80,  80,  10,  90});
			queue.push({ 600,  50,  40,  30,  40,  40,  80,  20});
			queue.push({ 600,  50,  10,  60, 100, 100,  20,  80});
			queue.push({ 800,  20,  30,  40,  60,  60,  90,  10});
			queue.push({ 800,  80,  20,  50,  80,  80,  10,  90});
			queue.push({ 600,  50,  35,  35,  70,  70,  50,  50});
			queue.push({ 800,  40,  25,  45,  90,  90,  80,  20});
			queue.push({ 800,  60,  25,  45,  90,  90,  20,  80});
			queue.push({1000,  50,  30,  40,  80,  80,  40,  40});
			break;

		case 7:
			// --- Sleep Animation ---
			//          time,head,necT,necB,eyeR,eyeL,armL,armR
			queue.push({2000,  50,  40,  30,  60,  60,  50,  50});
			queue.push({2500,  48,  60,  20,  40,  40,  60,  60});
			queue.push({3000,  45,  75,  10,  20,  20,  70,  70});
			queue.push({3500,  42,  85,   5,  10,  10,  80,  80});
			queue.push({4000,  40,  90,   0,   0,   0,  85,  85});
			queue.push({1000,  40,  90,   0,   0,   0,  85,  85});
			break;

		case 8:
			// --- Wake Up Animation ---
			//          time,head,necT,necB,eyeR,eyeL,armL,armR
			queue.push({2000,  40,  90,   0,   0,   0,  85,  85});
			queue.push({1500,  42,  80,   5,  10,  10,  80,  80});
			queue.push({1200,  45,  70,  10,  20,  20,  70,  70});
			queue.push({1000,  48,  50,  20,  40,  40,  60,  60});
			queue.push({ 800,  50,  30,  40,  60,  60,  50,  50});
			queue.push({ 600,  52,  20,  50,  80,  80,  40,  40});
			queue.push({ 500,  48,  15,  60, 100, 100,  30,  30});
			queue.push({ 400,  52,  10,  65, 100, 100,  20,  20});
			queue.push({1000,  50,  10,  60,  80,  80,  40,  40});
			break;

		default:
			Serial.println(F("Invalid animation requested"));
			break;
	}


}

#endif /* ANIMATIONS_INO */