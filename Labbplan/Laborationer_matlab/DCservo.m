% Written by Lucas Strömberg and Johannes Langelaar
% Lucstromberg@gmail.com, JohannesLangelaar@hotmail.com

function [filter, deltat] = DCservo()
%DCservo Returns Lowpass filter and sampling time

% low pass filter
wb = 1; % choose an appropriate bandwidth
K = 1;
filter = K*tf(wb,[1 wb]);

% sampling time
deltat=3/40;
end

