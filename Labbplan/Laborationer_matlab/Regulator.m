

V_c = 1.6;
Phi_m = 55;

[amp, fas] = bode(G, V_c);

%Phi_max = Phi_m - (180 + arg(G(iw)));

beta = 0.25;
K = sqrt(beta)/amp;
Tau_d = (1)/(V_c*sqrt(beta));
Tau_i = 10/V_c;

F_lead_theo = (K*(Tau_d * s + 1)) / (beta * Tau_d * s + 1);
F_lag_theo = (Tau_i * s + 1) / (Tau_i * s);

%F_lead_calc = 0.253*((1.14*s+1)/(0.37*1.14*s+1));
%F_lag_calc = (6.94*s+1)/(6.94*s);

%F_total_calc = F_lead_calc * F_lag_calc;

F_total_theo = F_lead_theo * F_lag_theo;

r = GetStep(1); 
[y, t] = FeedbackControl(F_total_theo, r);
figure;
plot(t, y, t, r);
title('Stegsvar för det slutna systemet');
xlabel('Tid (s)');
ylabel('Utsignal');
grid on;