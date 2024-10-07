% Written by Lucas Strömberg and Johannes Langelaar
% Lucstromberg@gmail.com, JohannesLangelaar@hotmail.com

function [y,t,vel] = OpenControl(u)
% [y,t,vel] = OpenControl(u)
%
% OpenControl Runs open control on the system and returns the angular
% position, time, angular velocity and input vectors, given an open-loop input
% signal to the system.
% 
% INPUT PARAMETERS:
%   u               input signal as a vector
%
% OUTPUT PARAMETERS:
%   y               angular position vector
%   t               time vector
%   vel             angular velocity vector
%

s = InitiateWheel;

inputLimit = 2.5; % Limit the input to +-5 V

% Retrieve low-pass filter and sampling time
[Filter,deltat]=DCservo();

% Build a state space filter representaion
if ~isnumeric(Filter)
    Filt_ss = ss(Filter,'min');
    Filt_d = c2d(ss(Filt_ss), deltat, 'tustin');
    Fi=Filt_d.A; Gi=Filt_d.B; Hi=Filt_d.C; Ii=Filt_d.D; % discrete system matrices
    xi = zeros(size(Gi));
else % Just a static gain
    Fi=0; Gi=0; Hi=0; Ii=Filter; xi=0;
end

% Filter the input
uf = zeros(size(u));
for q=1:length(u)
    xi = Fi*xi + Gi*u(q);
    uf(q) = Hi*xi + Ii*u(q);
end

% Limit the filtered input
uf(find((uf > inputLimit)==1)) = inputLimit;
uf(find((uf < -inputLimit)==1)) = -inputLimit;

% Allocate variables
y = nan(size(u));
vel = nan(size(u));
t = 0:deltat:deltat*(length(u)-1);
t = t';

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
        AnalogWrite(s,uf(q)); % Write control signal to wheel
        y(q) = AnalogRead(s); % Get a position measurement
        
        % Calculate velocity and remove noise by taking a mean. If we
        % haven't enough measurements we set the current velocity to 0
        try
            vel(q) = (y(q) - y(q-4)) / (5*deltat);
        catch
        end
        
        % Plot the new point in the GUI
        PlotPoints(s,t(q),u(q),y(q),vel(q),nan,nan);
        
        % Increment timestep q. If q has reached its final value, we'll
        % stop the timer
        q = q+1;
        if q > length(t)
            AnalogWrite(s,0);
            stop(tajmer);
            delete(tajmer);
            assignin('base','y',y);
        end
    end
end
