%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file contains the main function, which basically initializes the
% hardware and runs timed tasks.
%
% This code is an example and only runs timed tasks at 1ms.
%
%                           www.ardusimple.com - 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#include "tasks.h"
#include "hardware.h"
#include <stdlib.h>
#include "main.h"

void timedLoop(void)
{
  static int curTime = 0;
  static int prevTime = 0;
  int intTime = 1; //1ms = 0.001s
  static int cnt1ms=0;
  if (abs(curTime - prevTime) > intTime)
  {
    cnt1ms++;
    curTime = 0;
    prevTime = curTime;
  }

  if (cnt1ms>=1)
  {
	Events1ms();
	cnt1ms=0;
  }
  
  curTime ++;
}

void mainLoop(void)
{
  while (1)
  {
    if(sysTick == 1)
    {
      timedLoop();
      sysTick = 0;
    }
  }
}

int main(void)
{
  initHardware();
  mainLoop();
  return(0);  
}