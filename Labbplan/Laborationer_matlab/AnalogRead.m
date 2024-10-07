% Written by Lucas Strömberg and Johannes Langelaar
% Lucstromberg@gmail.com, JohannesLangelaar@hotmail.com

function pos = AnalogRead(s)
%AnalogRead(s) Reads an angular position of the wheel, given an instance of
%the DAQ session for the wheel.

% side: -1 means left, 1 means right
% revs: total number of revolutions [-inf,inf]
persistent lastVoltage revs xi Fi Gi Hi Ii

% Read voltage and shift so that the zero is at the top
voltage = s.inputSingleScan();
voltage = voltage - 1.1; % Now, voltage: [-2.5, 2.5]

% Instantiate lastVoltage and lowpass filter 
if isempty(lastVoltage)
    lastVoltage = voltage;
    
    Filter = tf(10,[1 10]);
    [~,deltat] = DCservo();
    Filt_ss = ss(Filter,'min');
    Filt_d = c2d(ss(Filt_ss), deltat, 'tustin');
    Fi=Filt_d.A; Gi=Filt_d.B; Hi=Filt_d.C; Ii=Filt_d.D; % discrete system matrices
    xi = zeros(size(Gi));
end

% Below we convert voltage to radians. This is executed by counting the
% positive/negative revolutions

pos = ((voltage)/2.5)*pi;

% Instantiate revs depending if whether we begin at the positive or
% negative "side" of the wheel
if isempty(revs)
    if pos >= 0
        revs = 0;
    else
        revs = -1;
    end
end

if pos < 0
    pos = pos + 2*pi;
end

if sign(lastVoltage) < sign(voltage) && abs(voltage) < 1 % clockwise revolution
    revs = revs+1;
elseif sign(lastVoltage) > sign(voltage) && abs(voltage) < 1 % counter-clockwise revolution
    revs = revs-1;
end
pos = (revs*2*pi + pos); % Now, pos: [-inf, inf] rads


% Filter high-frequency noise of the measurement
xi = Fi*xi + Gi*pos;
pos = Hi*xi + Ii*pos;

lastVoltage = voltage;
end