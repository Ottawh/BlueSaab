/*
 BlueSaab v5.0b

 A CD changer emulator for older SAAB cars with RN52 Bluetooth module by Microchip Technology Inc.
 
 Credits:

 Hardware design:           Seth Evans (http://bluesaab.blogspot.com)
 Initial code:              Seth Evans and Emil Fors
 CAN code:                  Igor Real (http://secuduino.blogspot.com)
 Information on SAAB I-Bus: Tomi Liljemark (http://pikkupossu.1g.fi/tomi/projects/i-bus/i-bus.html)
 RN52 handling:             based on code by Tim Otto (https://github.com/timotto/RN52lib)
 Additions/bug fixes:       Karlis Veilands, Girts Linde and Sam Thompson
*/


#include <Arduino.h>
#include <avr/wdt.h>
#include "CDC.h"
#include "RN52handler.h"
#include "Timer.h"
#include "SidResource.h"

#define DEBUGMODE 0

CDChandler CDC;
Timer time;

int freeRam ()
{
    extern int __heap_start, *__brkval;
    int v;
    return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval);
}

void setup() {
    wdt_disable(); // Allow delay loops greater than 15ms during setup.
    Serial.begin(9600);
    Serial.println(F("\"BlueSaab\""));
#if (DEBUGMODE==1)
    Serial.print(F("Free SRAM: "));
    Serial.print(freeRam());
    Serial.println(F(" bytes"));
    Serial.println(F("Press H for Help"));
#endif
    Serial.println(F("Software version: v5.1b"));
    BT.initialize();
    CDC.openCanBus();
    wdt_enable(WDTO_500MS); // give the loop time to do more serial diagnostic logging.
}

void loop() {
    time.update();
    CDC.handleCdcStatus();
    sidResource.update();
    BT.update();
    BT.monitor_serial_input();
    wdt_reset();
}
