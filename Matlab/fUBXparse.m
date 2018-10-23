function [ rover ] = fUBXparse( msg, rover )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function parses a valid UBX message and saves the information in a
% struct variable
% 
% Input:
%     - msg, contains a valid UBX message (without synchronization
%     characters and checksum)
%     - rover, contains a temporary structure (can be empty or not)
%     
% Output:
%     - rover, updated input variable with the message information
%
%                           www.ardusimple.com - 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define message class characters
UBX_NAV             = hex2dec('1');

% Define message ID characters
UBX_NAV_PVT         = hex2dec('7');
UBX_NAV_RELPOSNED   = hex2dec('3c');
UBX_NAV_HPPOSLLH    = hex2dec('14');
UBX_NAV_STATUS      = hex2dec('3');

if msg(1)==UBX_NAV
    if msg(2) == UBX_NAV_PVT && length(msg)>=92
        i = 5;
        rover.sync=double(typecast(uint8(msg(i:i+3)),'uint32'));
        rover.time.year=msg(i+4)+msg(i+5)*256;
        rover.time.month=msg(i+6);
        rover.time.day=msg(i+7);
        rover.time.hour=msg(i+8);
        rover.time.min=msg(i+9);
        rover.time.sec=msg(i+10);
        rover.pos.fixType=msg(i+20);
        rover.pos.lon=double(typecast(uint8(msg(i+24:i+27)),'int32'))*1e-7;
        rover.pos.lat=double(typecast(uint8(msg(i+28:i+31)),'int32'))*1e-7;
        rover.pos.alt=double(typecast(uint8(msg(i+32:i+35)),'int32'))*1e-3;
        rover.pos.hacc=double(typecast(uint8(msg(i+40:i+43)),'uint32'))*1e-3;
        rover.pos.vacc=double(typecast(uint8(msg(i+44:i+47)),'uint32'))*1e-3;
        rover.pos.gspeed=double(typecast(uint8(msg(i+60:i+63)),'int32'))*1e-3;
        rover.pos.sacc=double(typecast(uint8(msg(i+68:i+71)),'uint32'))*1e-3;
    elseif msg(2) == UBX_NAV_RELPOSNED && length(msg)>=40
        i = 5;
        rover.sync=double(typecast(uint8(msg(i+4:i+7)),'uint32'));
        rover.pos.relposN=(double(typecast(uint8(msg(i+8:i+11)),'int32'))+...
                           1e-2*double(typecast(uint8(msg(i+20)),'int8')))*1e-2;
        rover.pos.relposE=(double(typecast(uint8(msg(i+12:i+15)),'int32'))+...
                           1e-2*double(typecast(uint8(msg(i+21)),'int8')))*1e-2;
        rover.pos.relposD=(double(typecast(uint8(msg(i+16:i+19)),'int32'))+...
                           1e-2*double(typecast(uint8(msg(i+22)),'int8')))*1e-2;
    elseif msg(2) == UBX_NAV_HPPOSLLH && length(msg)>=30
        i = 5;
        rover.sync=double(typecast(uint8(msg(i+4:i+7)),'uint32'));
        rover.hppos.lon=double(typecast(uint8(msg(i+8:i+11)),'int32'))*1e-7+...
                         double(typecast(uint8(msg(i+24)),'int8'))*1e-9;
        rover.hppos.lat=double(typecast(uint8(msg(i+12:i+15)),'int32'))*1e-7+...
                         double(typecast(uint8(msg(i+25)),'int8'))*1e-9;
        rover.hppos.alt=double(typecast(uint8(msg(i+16:i+19)),'int32'))+...
                         double(typecast(uint8(msg(i+26)),'int8'))*1e-1;
        rover.hppos.hacc=double(typecast(uint8(msg(i+28:i+31)),'uint32'))*1e-1;
        rover.hppos.vacc=double(typecast(uint8(msg(i+32:i+35)),'uint32'))*1e-1;
     elseif msg(2) == UBX_NAV_STATUS && length(msg)>=10       
        i = 5;
        rover.sync=double(typecast(uint8(msg(i:i+3)),'uint32'));
        rover.status.fix=msg(i+4);
        rover.status.flags=msg(i+5);
        rover.status.fixStat=msg(i+6);
        rover.time.msss=double(typecast(uint8(msg(i+12:i+15)),'uint32'));
    end
end