```matlab
% Steg 1: M�tning och estimering av sinusv�gor f�r flera frekvenser
frequencies = [0.2, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0, 8.0]; % Testade frekvenser
gain = zeros(1, length(frequencies));
phase = zeros(1, length(frequencies));
Ts = 0; % Tidssteg, s�tt detta korrekt baserat p� era m�tningar

for i = 1:length(frequencies)
    frequency = frequencies(i);
    
    % Generera sinussignal vid given frekvens
    u = GetSine(frequency);  % Generera sinusv�g med GetSine
    
    % �ppna systemet och f� ut signal och tid
    [y, t, ~] = OpenControl(u);  % Anv�nd OpenControl f�r att k�ra systemet
    
    % Estimera sinusv�gen fr�n utsignalen
    sin_est = EstSine(y, t, frequency);  % Anv�nd EstSine f�r att estimera v�gen
    
    % Ber�kna f�rst�rkning
    gain(i) = max(sin_est) / max(u);
    
    % Ber�kna f�rdr�jning med finddelay
    delay_samples = finddelay(u, y);
    if i == 1
        Ts = t(2) - t(1); % Tidssteget �r skillnaden mellan tv� tidpunkter
    end
    
    % Fasber�kning
    phase(i) = delay_samples * Ts * frequency * (180 / pi); % Omvandlar till grader
    
    % Plotta sinusv�g och dess estimering
    figure;
    plot(t, y, t, sin_est);
    title(['Frekvens ', num2str(frequency), ' rad/s']);
    legend('Signal', 'Estimerad sinus');
    
    % Skriv ut f�rst�rkning och fas
    disp(['Gain vid ', num2str(frequency), ' rad/s: ', num2str(gain(i))]);
    disp(['Phase vid ', num2str(frequency), ' rad/s: ', num2str(phase(i)), ' grader']);
end

% Steg 2: Skapa en frekvensresponsmodell med frd
w = frequencies; % Frekvenserna
z = gain .* exp(1i .* phase * pi / 180); % Eulers formel f�r att skapa komplexa siffror
G = frd(z, w); % Skapa frekvensresponsdata

% Plotta Bodediagram f�r G
figure;
bode(G); % Plotta Bodediagrammet med frd-objektet G
title('Bode Diagram f�r det uppm�tta systemet');

% Steg 3: Designa Lead-filter
omega_c = 1.44; % Sk�rfrekvens
phi_m = 55; % Fasmarginal
beta = (1 - sind(phi_m)) / (1 + sind(phi_m)); % Ber�kna beta
Td = 1 / (omega_c * sqrt(beta)); % Differentiationstid

% Lead-kompensering
s = tf('s');
F_lead = (Td * s + 1) / (beta * Td * s + 1);
disp(['Lead-filter: ', num2str(F_lead)]);

% Steg 4: Designa Lag-filter
Ti = 10 / omega_c; % Tidskonstant f�r lag-filter
gamma = 0.1; % Precisionen f�r slutv�rdesteoremet
F_lag = (Ti * s + 1) / (gamma * Ti * s + 1);
disp(['Lag-filter: ', num2str(F_lag)]);

% Steg 5: Samla total regulator och testa med step response
K = omega_c / gamma; % F�rst�rkning
F_total = K * F_lead * F_lag;

% Stegsvar f�r det slutna systemet
r = GetStep(1); % Generera stegsvar
[y, t] = FeedbackControl(F_total, r);
figure;
plot(t, y);
title('Stegsvar f�r det slutna systemet');
xlabel('Tid (s)');
ylabel('Utsignal');
grid on;

% Om ni vill justera f�r olika wc, fasmarginal etc.
disp(['Total regulator: ', num2str(F_total)]);
```