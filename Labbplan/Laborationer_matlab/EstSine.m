function sin_est=EstSine(x,t,w,Transient,Ts)
%
% sin_est=EstSine(x,t,w)
%
% Estimates a sine wave signal from a given data sequence:
% sin_est(t) = A*sin(w*t) + B*cos(w*t), where A & B are 
% chosen to minimize |x(t) - sin_est(t)|^2.
%
% INPUT PARAMETERS:
%   x           observed/measured data sequence, vector
%   t           time vector, corresponding to x(t)
%   w           angular frequency for sine signal, scalar
%
% OUTPUT PARAMETER:
%   sin_est     estimated sine wave signal, vector (corresponds 
%               to the time vector t)
%

% HN 2007-10-14, rev. HN 2008-11-25

Ts=1/40; % Sampling period

Transient=8; % Transient phase, not used in estimation.

N1=ceil(Transient/Ts);
xe=x(N1:end);te=t(N1:end); % Data vector used for estimation.
xe=xe(:);te=te(:);  % Convert to column vectors.
N=length(xe);   % Number of data points.

Phi=[ones(N,1) te sin(w*te) cos(w*te)]; % Phi-matrix ...

theta=Phi\xe;  % minimize wrt A & B above, plus constant offset and
               % linear drift, i.e. |xe(t) - (A*sin(w*t) +
               % B*cos(w*t) + k*t + m)|^2 is minimized. The
               % parameter vector is theta = [m k A B]'.

sin_est=theta(3)*sin(w*t)+theta(4)*cos(w*t);
% plot(t,[sin_est(:) x(:)-theta(2)*t(:)-theta(1)])
