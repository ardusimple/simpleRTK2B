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
        rover.pos.alt=double(typecast(uint8(msg(i+36:i+39)),'int32'))*1e-3;
        rover.pos.hacc=double(typecast(uint8(msg(i+40:i+43)),'uint32'))*1e-3;
        rover.pos.vacc=double(typecast(uint8(msg(i+44:i+47)),'uint32'))*1e-3;
    elseif msg(2) == UBX_NAV_RELPOSNED && length(msg)>=40
        i = 5;
        rover.sync=double(typecast(uint8(msg(i+4:i+7)),'uint32'));
        rover.pos.relposN=double(typecast(uint8(msg(i+8:i+11)),'int32'))*1e-2;
        rover.pos.relposE=double(typecast(uint8(msg(i+12:i+15)),'int32'))*1e-2;
        rover.pos.relposD=double(typecast(uint8(msg(i+16:i+19)),'int32'))*1e-2;
    end
end