% Written by Lucas Strömberg and Johannes Langelaar
% Lucstromberg@gmail.com, JohannesLangelaar@hotmail.com

function r = GetStep(amp,Tstep,Tend)
%
% r = GetStep(amp)
% r = GetStep(amp,Tstep,Tend)
%
% Returns a step vector with given an amplitude, that starts with 5 s of
% zeros and ends at t = 15 s.
%
% INPUT PARAMETERS:
%   amp             The amplitude of the step
%
% OUTPUT PARAMETERS:
%   r               Data vector of the step
%
% ADDITIONAL PARAMETERS:
% IN:
%   Tstep              Amount of zeros before the step in seconds (default = 5 s)
%   Tend                End time of the step in seconds (default = 15 s)
%

if nargin < 3
    Tstep = 5;
    Tend = 15;
end

if Tend <= 2*Tstep
    disp("Longer end time required.");
else
    [~, Tsamp] = DCservo();
    z = zeros(1,ceil(Tstep/Tsamp))';
    o = amp*ones(1,(ceil(Tend/Tsamp)+1)-(ceil(Tstep/Tsamp)))';
    r = [z; o];
end
end