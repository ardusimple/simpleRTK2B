/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file contains the tasks running at 1ms.
% 
% The code includes a dummy example application that blinks two LEDs at a
% frequency proportional to the relative East error between the rover and
% the base.
%
%                           www.ardusimple.com - 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

#include "hardware.h"
#include <math.h>
#include "tasks.h"
#include "stm32l1xx_hal.h"

typedef enum
{
  OK = 0,
  TOO_LEFT,
  TOO_RIGHT
}positionState;

void Events1ms(void)
{
  static GPIO_PinState stateLED = GPIO_PIN_RESET;
  static float counterLED = 0.0f;
  static positionState posState = OK;
  float MAXERROR = 10.0f;
  float trackErrorCm = sensors.gnss.relPos.E;
  counterLED++;
  
  switch (stateLED)
  {
    case 0:   
	  if (counterLED > 100)
	  {
		stateLED = GPIO_PIN_SET;
		counterLED = 0;
	  }
      break;
    case 1:   
	  if (counterLED > fabs(trackErrorCm))
	  {
		stateLED = GPIO_PIN_RESET;
		counterLED = 0;
	  }
      break;
  }
  
  if (fabs(trackErrorCm) <= MAXERROR)
  {
	posState = OK;
  }
  else if (trackErrorCm > MAXERROR)
  {
	posState = TOO_RIGHT;
  }
  else
  {
	posState = TOO_LEFT;
  }
	  
  switch (posState)
  {
  case OK:
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_SET);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_0, GPIO_PIN_SET);
	break;
  case TOO_LEFT:
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_0, stateLED);
	break;
  case TOO_RIGHT:
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, stateLED);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_0, GPIO_PIN_RESET);
	break;
  }
}