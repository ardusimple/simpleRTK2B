%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script reads a .ubx file and saves the data in a struct variable
% easy to work with. It reads only UBX protocol, other protocols are
% ignored
% 
% Input:
%     - Path to the .ubx file
%     
% Output:
%     - output, containing the data extracetd from the .ubx file
%
%                           www.ardusimple.com - 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the path to the .ubx file
filePath = 'C:\Users\Josep\Desktop\20180902_field_tests\COM10_180902_163856_car_3d_modelling.ubx';

% Disconnect and delete previous open ports
instrreset;

% Open the .ubx file you want to read
s = fopen(filePath,'r');

% Initialize an empty struct
[rover, output] = fInit();

% Read the file and store the data in the output variable
[buf,count] = fread(s);
[~, output] = fUBXread(buf,count,rover,output);

% Close the .ubx file
fclose(s);

% Remove first row (doesn't contain information) and clear temporary variables
output(1)=[];
clear filePath ans buf s rover count