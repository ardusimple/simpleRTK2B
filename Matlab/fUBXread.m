function [ rover, output ] = fUBXread( buf, count, rover, output )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function reads a standard UBX protocol message.
% If the message is valid, it parses the information in the output variable
% 
% Input:
%     - buf, contains the message to be read
%     - count, contains the length of the message
%     - rover, contains a temporary structure of the message variables
%     - output, contains the cumulative structure of the message variables
%     
% Output:
%     - output, contains the cumulative message variables in a structure
%     - rover, contains the message variables in a structure
%
%                           www.ardusimple.com - 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define state machine states
ST_BEFOREPKT        = 0;
ST_INPKT            = 2;
ST_PKTDONE          = 4;
ST_PKTERR           = -1;
ST_UBX_INPKTID1     = 21;
ST_UBX_INPKTID2     = 22;
ST_UBX_INPKTID3     = 23;
ST_UBX_INPKTLEN1    = 25;
ST_UBX_INPKTLEN2    = 26;
ST_UBX_INCHK1       = 28;
ST_UBX_INCHK2       = 29;


% Define UBX protocol synchronization characters
UBXSYNC1 = hex2dec('B5');
UBXSYNC2 = hex2dec('62');

i = 1;
while i <= count
    switch rover.parser.state
        % Waiting for first synchronization character
        case ST_BEFOREPKT
            if buf(i) == UBXSYNC1
                rover.parser.state = ST_UBX_INPKTID1;
            end
            i = i+1;
        % Waiting for second synchronization character
        case ST_UBX_INPKTID1
            if buf(i) == UBXSYNC2
                rover.parser.state = ST_UBX_INPKTID2;
            else
                rover.parser.state = ST_BEFOREPKT;
            end
            i = i+1;
        % Message class byte
        case ST_UBX_INPKTID2
            rover.parser.k = 1;
            msg = 0;
            msg(rover.parser.k) = buf(i);
            rover.parser.state = ST_UBX_INPKTID3;
            i = i+1;
        % ID class byte
        case ST_UBX_INPKTID3
            rover.parser.k = rover.parser.k+1;
            msg(rover.parser.k) = buf(i);
            rover.parser.state = ST_UBX_INPKTLEN1;
            i = i+1;
        % First lenght byte
        case ST_UBX_INPKTLEN1
            rover.parser.k = rover.parser.k+1;
            msg(rover.parser.k) = buf(i);
            rover.parser.state = ST_UBX_INPKTLEN2;
            i = i+1;
        % Second length byte
        case ST_UBX_INPKTLEN2
            rover.parser.k = rover.parser.k+1;
            msg(rover.parser.k) = buf(i);
            rover.parser.payloadLen = msg(3)+msg(4)*256;
            rover.parser.state = ST_INPKT;
            i = i+1;
        % Read payload information until defined length
        case ST_INPKT
            rover.parser.k = rover.parser.k+1;
            msg(rover.parser.k) = buf(i);
            if rover.parser.k >= rover.parser.payloadLen+4
                rover.parser.state = ST_UBX_INCHK1;
            elseif rover.parser.k >= 256
                rover.parser.state = ST_PKTERR;
            end
            i = i+1;
        % Read first checksum byte
        case ST_UBX_INCHK1
            rover.parser.k = rover.parser.k+1;
            msg(rover.parser.k) = buf(i);
            rover.parser.state = ST_UBX_INCHK2;
            i = i+1;
        % Read second checksum byte
        case ST_UBX_INCHK2
            rover.parser.k = rover.parser.k+1;
            msg(rover.parser.k) = buf(i);
            rover.parser.state = ST_PKTDONE;
        % Packet finished, parse message if checksum is correct
        case ST_PKTDONE
            CK_A = 0;
            CK_B = 0;
            for j = 1:1:rover.parser.k-2
                CK_A = CK_A + msg(j);
                CK_B = CK_B + CK_A;
            end
            CK_A = mod(CK_A,256);
            CK_B = mod(CK_B,256);
            if CK_A == msg(rover.parser.k-1) && CK_B == msg(rover.parser.k)
               rover = fUBXparse(msg, rover);
               indexOutput = size(output,2);
               % Use the sync value to see if the incoming message is
               % from a new time and the output index must be increased or
               % if it is just from a different message class or id
               if rover.sync ~= output(size(output,2)).sync
                    indexOutput = size(output,2)+1;
               end
               output(indexOutput) = rover;
            end
            rover.parser.state = ST_BEFOREPKT;
            i = i+1;
        % Packet error state
        case ST_PKTERR
            rover.parser.state = ST_BEFOREPKT;
        otherwise
            rover.parser.state = ST_PKTERR;
    end
end

end