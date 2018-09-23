#ifndef __HARDWARE_H
#define __HARDWARE_H

#include <stdint.h>
#include "basic_types.h"
#include "gnss.h"
#include "stm32l1xx_hal.h"

#define USART_GNSS 0x02

extern int sysTick;
extern UART_HandleTypeDef huart2;
void initHardware(void);

class CSensors
{
public:
      CSensors() {}
      CGNSS gnss;
};

extern CSensors sensors;

#endif