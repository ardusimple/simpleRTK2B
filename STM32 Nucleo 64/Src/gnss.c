%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file contains the functions needed to read the UBX protocol
% message and parse it to usable variables.
% 
% This code is an example and can be modified to parse whatever message
% needed. In this case, a few variables from the UBX_NAV_PVT and
% UBX_NAV_RELPOSNED messages are extracted.
%
%                           www.ardusimple.com - 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#include <math.h>
#include "hardware.h"
#include "tasks.h"
#include "gnss.h"

uint8_t rxString[MAX_GNSS];
int rxindex = 0;
uint8_t rxBufferGNSS = 0;
tGNSSrx GNSSrx;

void handleGNSS(void)
{
  uint8_t msgbuf[MAX_GNSS];
  int32_t msgcnt;
  msgcnt=readUBXpkt(msgbuf);
		
  if(msgcnt>0)
  {
	EventsCommGNSS(msgbuf,msgcnt);
  }
  else if(msgcnt==-1)
  {
	initGNSSrx();
  }
}

void EventsCommGNSS(uint8_t *msgbuf, int32_t cnt)
{
 sensors.gnss.parseUBX(msgbuf,cnt);
}

int readUBXpkt(byte *retbuf)
{
  int i=0;
  if(GNSSrx.ctr<MAX_GNSS)
  {
    if(addUBXpktByte(rxBufferGNSS,&(GNSSrx))>0)
    {
      GNSSrx.state=SM_UBX_BEFORE;
      for(i=0;i<GNSSrx.ctr;i++) retbuf[i]=GNSSrx.buf[i];
      GNSSrx.ctr=0;
      if(checkUBX(retbuf,i)==0)
      {
        return(i-2);
      }
      else
      {
        return(0);
      }
    }
  }
  if(GNSSrx.ctr>=MAX_GNSS)
  {
    GNSSrx.ctr=0;
    GNSSrx.state=SM_UBX_BEFORE;
  }
  return(0);
}

void initGNSSrx(void)
{
  GNSSrx.state = SM_UBX_BEFORE;
  GNSSrx.ctr = 0;
}

int addUBXpktByte(byte ch, tGNSSrx *pr)
{
	switch(pr->state)
	{
	case SM_UBX_BEFORE:
		if(ch==UBX_SYN_CHAR1) pr->state=SM_UBX_SYN2;     //SYNCHAR1
		break;
	case SM_UBX_SYN2:
		if(ch==UBX_SYN_CHAR2) pr->state=SM_UBX_CLASS;     //SYNCHAR2
		else pr->state=SM_UBX_BEFORE;
		break;
	case SM_UBX_CLASS:
		pr->buf[pr->ctr++]=ch;          //CLASS                          
		pr->state=SM_UBX_ID;
		break;
	case SM_UBX_ID:
		pr->buf[pr->ctr++]=ch;          //ID
		pr->state=SM_UBX_PAYLEN1;
		break;
	case SM_UBX_PAYLEN1:
		pr->buf[pr->ctr++]=ch;          //PAYLOAD LENGTH1
		pr->state=SM_UBX_PAYLEN2;	
		break;
	case SM_UBX_PAYLEN2:
		pr->buf[pr->ctr++]=ch;          //PAYLOAD LENGTH2
		pr->state=SM_UBX_PAYLOAD;
		break;
	case SM_UBX_PAYLOAD:
		pr->buf[pr->ctr++]=ch;          //PAYLOAD
		if(pr->ctr >= (bytesToShort((byte *)&(pr->buf[2])) + 4)) pr->state=SM_UBX_CHK1;
		else if(pr->ctr >= (UART_BUF_SIZE-10)) pr->state=SM_UBX_ERR;
		break;
	case SM_UBX_CHK1:
		pr->buf[pr->ctr++]=ch;
		pr->state=SM_UBX_CHK2;			//CHECKSUM1
		break;
	case SM_UBX_CHK2:
		pr->buf[pr->ctr++]=ch;
		pr->state=SM_UBX_END;			//CHECKSUM1
		break;
	case SM_UBX_ERR:
		pr->state=SM_UBX_BEFORE;
		break;
	default:
		pr->state=SM_UBX_ERR;
		break;
	}
	if(pr->state==SM_UBX_ERR || pr->state==SM_UBX_BEFORE)
	{
		return(-1);
	}
	else if(pr->state==SM_UBX_END)
	{
		pr->state=SM_UBX_BEFORE;
		return(pr->ctr);
	}
	else return(0);
}

int checkUBX(byte *buf, int cnt)
{
	byte cha=0, chb=0;

	crcUBX(buf,cnt-2,&cha,&chb);
	if((cha == buf[cnt-2]) && (chb == buf[cnt-1])) return(0);
	return(-1);
}

void crcUBX(byte *buf, int cnt, byte *pcha, byte *pchb)
{
	int i=0;

	*pcha=0;
	*pchb=0;
	for(i=0 ; i<cnt ; i++)
	{
		(*pcha) = (byte)((*pcha) + buf[i]);
		(*pchb) = (byte)((*pchb) + (*pcha));
	}
}

bool CGNSS::parseUBX(byte *buf, int cnt)
{
  bool ok = false;

  if(buf[0]==UBX_NAV)
  {
    if(buf[1]==UBX_NAV_PVT && cnt>=92)
    {
	  iTOW = bytesToLong(&(buf[4]));
	  UTCyear = bytesToShort(&(buf[8]));;
      UTCmonth = (int)buf[10];
      UTCday = (int)buf[11];
      UTChour = (int)buf[12];
      UTCminute = (int)buf[13];
      UTCsecond = (int)buf[14];
	  fixType = (int)buf[24];
	  hAcc = bytesToLong(&(buf[44]));
	  vAcc = bytesToLong(&(buf[48]));
      pos.lon = bytesToLong(&(buf[28]))*1.0e-7;
	  pos.lat = bytesToLong(&(buf[32]))*1.0e-7;
	  pos.alt = bytesToLong(&(buf[36]))*1.0e-7;
    }
    else if(buf[1]==UBX_NAV_RELPOSNED && cnt>=40)
    {
	  relPos.N = bytesToLong(&(buf[12]))+0.01f*(float)buf[24];
	  relPos.E = bytesToLong(&(buf[16]))+0.01f*(float)buf[25];
	  relPos.D = bytesToLong(&(buf[20]))+0.01f*(float)buf[26];
    }
  }	
  return ok;
}

int32_t bytesToLong(uint8_t *b)
{
	int8_t i;
	mlong x;
	for(i=0 ; i<4 ; i++)
	{
		x.b[i] = b[i];
	}	
	return(x.i);
}

int16_t bytesToShort(uint8_t *b)
{
	mshort x;
	x.b[1] = b[1];
	x.b[0] = b[0];
	return(x.i);
}