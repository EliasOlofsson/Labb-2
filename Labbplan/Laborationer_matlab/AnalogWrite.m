% Written by Lucas Strömberg and Johannes Langelaar
% Lucstromberg@gmail.com, JohannesLangelaar@hotmail.com

function AnalogWrite(s,u)
% AnalogWrite(s,u) Sets a control signal u between [-2.5, 2.5] given an
% instance s of the DAQ session for the wheel.

v = -1*u + 2.5;
s.outputSingleScan(v);
end