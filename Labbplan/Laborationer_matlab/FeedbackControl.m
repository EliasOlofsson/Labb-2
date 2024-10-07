% Written by Lucas Strömberg and Johannes Langelaar
% Lucstromberg@gmail.com, JohannesLangelaar@hotmail.com

function [y,t,vel,u] = FeedbackControl(Fc,r,controlType)
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
%   Fc              controller filter, as LTI object or scalar
%   r               reference signal vector
%
% OUTPUT PARAMETERS:
%   y               angular position vector
%   t               time vector
%   vel             angular velocity vector
%   u               input signal vector
%
% ADDITIONAL PARAMETERS:
% IN:
%   controlType     a string, either 'position' or 'velocity'. 
%                   Default: 'position'
%

s = InitiateWheel;

% If no controlType argument is given, control position
if nargin < 3
    controlType = "position";
end

inputLimit = 2.5; % Limit the input to +-5 V

% Retrieve Low-pass filter and sampling time
[Filter,deltat]=DCservo();
tend = length(r)*deltat;

% Build a state space controller representation
if ~isnumeric(Fc)
    Fc_ss = ss(Fc,'min'); % state space model
    Fd_ss = c2d(Fc_ss, deltat, 'tustin');
    F=Fd_ss.A; G=Fd_ss.B; H=Fd_ss.C; I=Fd_ss.D; % discrete system matrices
    x = 0*G; % x0=0
else % Just a static gain
    F=0; G=0; H=0; I=Fc; x=0;
end

% Build a state space filter representaion
if ~isnumeric(Filter)
    Filt_ss = ss(Filter,'min');
    Filt_d = c2d(ss(Filt_ss), deltat, 'tustin');
    Fi=Filt_d.A; Gi=Filt_d.B; Hi=Filt_d.C; Ii=Filt_d.D; % discrete system matrices
    xi = zeros(size(Gi));
else % Just a static gain
    Fi=0; Gi=0; Hi=0; Ii=Filter; xi=0;
end

% Allocate variables
t = 0:deltat:tend-deltat;
y = nan(size(t));
vel = nan(size(t));
u = nan(size(t));
uf = 0;

% Create a timer with specified sampling time
q = 1;
delete(timerfind);
tajmer = timer('Period',deltat,'ExecutionMode','fixedRate','TasksToExecute',length(t));
tajmer.TimerFcn = @Step;

% Initiate graphics
clear PlotPoints;
PlotPoints(s,t);

% If we already deleted the timer from closing the GUI, this will yield an
% error
try
    start(tajmer);
catch
end

% This loop prevents the program from finishing before all timer calls are
% completed. If the timer is deleted from closing the GUI, we break out
% from the loop
while q <= length(t)
    if isempty(timerfind)
        disp("Program terminated.");
        break;
    end
end
    % Executes every time the timer fires.
    function Step(obj,event)
        y(q) = AnalogRead(s); % Get a position measurement
        
        % Calculate velocity and remove noise by taking a mean. If we
        % haven't enough measurements we set the current velocity to 0
        try
            vel(q) = (y(q) - y(q-4)) / (5*deltat);
            %vel(q) = (y(q) - y(q-1)) / (deltat);
        catch
            vel(q) = 0;
        end
        
        % Compute the error between the reference signal and output
        if strcmp(controlType,"velocity")
            e = r(q)-vel(q);
        else
            e = r(q)-y(q);
        end
        
        
        
        % Compute new input
        x = F*x + G*e;
        u(q) = H*x + I*e;
        
        % Filter the input
        xi = Fi*xi + Gi*u(q);
        uf = Hi*xi + Ii*u(q);
        
        % Limit the filtered input
        uf(find((uf > inputLimit)==1)) = inputLimit;
        uf(find((uf < -inputLimit)==1)) = -inputLimit;
        
        AnalogWrite(s,uf); % Write filtered control signal to motor
        
        % Plot the new point in the GUI
        if strcmp(controlType,"velocity")
            PlotPoints(s,t(q),u(q),y(q),vel(q),nan,r(q));
        else
            PlotPoints(s,t(q),u(q),y(q),vel(q),r(q),nan);
        end
        
        % Increment timestep q. If q has reached its final value, we'll
        % stop the timer
        q = q+1;
        if q > length(t)
            AnalogWrite(s,0);
            stop(tajmer);
            delete(tajmer);
            t = t';
            u = u';
            y = y';
            vel = vel';
        end
    end
end