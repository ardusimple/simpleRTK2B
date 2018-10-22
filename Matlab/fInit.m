function [ rover, output ] = fInit(  )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function inititalizes two variables with an empty structure.
% 
% Input:
%     - None
%     
% Output:
%     - output, containing an inititalized empty struct
%     - rover, containing an inititalized empty struct
%
%                           www.ardusimple.com - 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% iTOW
    rover.sync              = 0;    
% Time
    rover.time.year         = 0;
    rover.time.month        = 0;
    rover.time.day          = 0;
    rover.time.hour         = 0;
    rover.time.min          = 0;
    rover.time.sec          = 0;    
% Position
    rover.pos.fixType       = 0;
    rover.pos.lon           = 0;
    rover.pos.lat           = 0;
    rover.pos.alt           = 0;
    rover.pos.relposN       = 0;
    rover.pos.relposE       = 0;
    rover.pos.relposD       = 0;
    rover.pos.hacc          = 0;
    rover.pos.vacc          = 0;
    rover.pos.gspeed        = 0;
    rover.pos.sacc          = 0;
% Internal
    rover.parser.state      = 0;
    rover.parser.payloadLen = 0;
    rover.parser.k          = 0;
    
    output = rover;
end