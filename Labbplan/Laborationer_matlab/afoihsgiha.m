frequency = 0.1;

u = GetSine (frequency) ;
[y , t , ~] = OpenControl (u );

sin_est = EstSine (y , t , frequency );
gain3 = max ( sin_est ) / max (u) ;
delay_samples = finddelay (u , y) ;
Ts = t (2) - t (1) ;
phas3 = delay_samples * Ts * frequency * (180 / pi);

figure ;
plot (t , u , t , est_sine );
title ([ 'Frekvens ', num2str(frequency ) , ' rad /s']) ;
legend ('Signal ', 'Sinus ');
