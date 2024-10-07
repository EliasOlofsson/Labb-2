% Written by Lucas Strömberg and Johannes Langelaar
% Lucstromberg@gmail.com, JohannesLangelaar@hotmail.com

% NI card is: USB-6009
% First, install NI-DAQmx driver for Windows 10
% Secondly, install MATLAB's Data Acquisition Toolbox
% Third, install NI-DAQmx Support from Data Acquisition Toolbox
% Output port to motor: AO1 (Analog Output 1)
% Input port from sensor: AI0 (Analog Input 0)

function s = InitiateWheel()
%InitiateWheel() Gets an instance of the DAQ session for the wheel and sets
%the position to 0 when the device is found

% While we haven't found the device, try to do so
deviceFound = false;
disp("Waiting for USB...");
while ~deviceFound
    try
        % To prevent earlier sessions from intervening from our attempts to
        % create a connection, we must reset all DAQ sessions.
        daqreset; 
        
        device = daq.getDevices;
        id = device.ID;
        outputPort = 'ao1';
        inputPort = 'ai0';
        
        s = daq.createSession('ni');
        
        s.addAnalogInputChannel(id,inputPort,'Voltage');
        s.addAnalogOutputChannel(id,outputPort,'Voltage');
        deviceFound = true;
        disp("Device found!");
    catch
    end
end

clear AnalogRead; % Clear all persistent variables

% Set the wheel to it's top position by slowly moving the wheel clockwise
% until "input" is within a small threshold of the zero-position
AnalogWrite(s,1);

input = -1;
while abs(input) >= 0.03
    % We don't use AnalogRead() here since we don't want to instantiate any
    % persistent variables yet
    input = s.inputSingleScan() - 1.1; % Reposition the "zero" of the input voltage
end
AnalogWrite(s,0); % Stop the wheel
end