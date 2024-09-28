%GETSINE
% x=GetSine(w)
% [x,t]=GetSine(w,amp,T,Tinit,Ts)
%
% Returns a sine wave signal: x(t) = C*sin(w*t)
% Amplitude and durance is adapted for the DC motor process when
% run in mode ’Control signal’.
%
% INPUT PARAMETER:
% w angular frequency of the sine wave signal
%
% OUTPUT PARAMETER:
% x sine wave signal
%
% ADDITIONAL PARAMETERS:
% IN:
% amp amplitude of the sine wave signal (default amp = min(2.5,max(w,0.1)))
% T durance of x (default T >= 30, and such that x(end) = 0)
% Tinit durance of initial phase, where x = 0 (default Tinit = 0.5)
% Ts sampling period (default Ts = 0.025)
% OUT:
% t time vector
%ESTSINE
% sin_est=EstSine(x,t,w)
%
% Estimates a sine wave signal from a given data sequence:
% sin_est(t) = A*sin(w*t) + B*cos(w*t), where A & B are
% chosen to minimize |x(t) - sin_est(t)|^2.
%
% INPUT PARAMETERS:
% x observed/measured data sequence, vector
% t time vector, corresponding to x(t)
% w angular frequency for sine signal, scalar
%
% OUTPUT PARAMETER:
% sin_est estimated sine wave signal, vector (corresponds
% to the time vector t)
%GETSTEP
% r = GetStep(amp)
% r = GetStep(amp,Tstep,Tend)
%
% Returns a step vector with given an amplitude, that starts with 5 s of
% zeros and ends at t = 15 s.
%
% INPUT PARAMETERS:
% amp The amplitude of the step
%
% OUTPUT PARAMETERS:
% r Data vector of the step
%
% ADDITIONAL PARAMETERS:
% IN:
% Tstep Amount of zeros before the step in seconds (default = 5 s)
% Tend End time of the step in seconds (default = 15 s)
%OPENCONTROL
% [y,t,vel] = OpenControl(u)
%
% OpenControl Runs open control on the system and returns the angular
% position, time, angular velocity and input vectors, given an open-loop input
% signal to the system.
%
% INPUT PARAMETERS:
% u input signal as a vector
%
% OUTPUT PARAMETERS:
% y angular position vector
% t time vector
% vel angular velocity vector
%
%FEEDBACKCONTROL
% [y,t,vel,u] = FeedbackControl(Fc,r)
% [y,t,vel,u] = FeedbackControl(Fc,r,controlType)
%
% FeedbackControl Runs feedback control on the system and returns the
% angular position and time vectors, given a controller and reference
% signal.
%
% Tests the closed loop system Gc = Go/(1+Go) with Go = Fc*G.
% G is the system, and you only define the filter Fc.
% For proportional control, Fc can be a scalar.
%
% INPUT PARAMETERS:
% Fc controller filter, as LTI object or scalar
% r reference signal vector
% q
% OUTPUT PARAMETERS:
% y angular position vector
% t time vector
% vel angular velocity vector
% u input signal vector
%
% ADDITIONAL PARAMETERS:
% IN:
% controlType a string, either ’position’ or ’velocity’.
% Default: ’position’
%