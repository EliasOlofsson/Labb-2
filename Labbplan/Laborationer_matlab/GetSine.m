function [x,t]=GetSine(w,amp,T,Tinit,Ts)
%
% x=GetSine(w)
% [x,t]=GetSine(w,amp,T,Tinit,Ts)
%
% Returns a sine wave signal: x(t) = C*sin(w*t)
% Amplitude and durance is adapted for the DC motor process when
% run in mode 'Control signal'.
%
% INPUT PARAMETER:
%   w           angular frequency of the sine wave signal
%
% OUTPUT PARAMETER:
%   x           sine wave signal
%
% ADDITIONAL PARAMETERS:
% IN:
%   amp     amplitude of the sine wave signal (default amp = min(2.5,max(w,0.1)))
%   T       durance of x (default T >= 30, and such that x(end) = 0)
%   Tinit   durance of initial phase, where x = 0 (default Tinit = 0.5)
%   Ts      sampling period (default Ts = 0.025)
% OUT:
%   t       time vector
%
% HN 2007-11-01
if nargin<5
    [~, Ts] = DCservo();
end
if nargin<4
    Tinit=0.5;
end
if nargin<3
    T=(0.5+round(30*w/pi))*pi/w;
end
if nargin<2
    amp=min(2.5,max(w,0.1));
end

t1=0:Ts:T;
x1=amp*cos(w*t1);
x=[zeros(1,floor(Tinit/Ts)) x1]';
x(end)=0;
t2=-floor(Tinit/Ts)*Ts:Ts:-Ts;
t=[t2 t1];