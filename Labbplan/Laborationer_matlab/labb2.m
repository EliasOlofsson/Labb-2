```matlab
% Steg 1: Mätning och estimering av sinusvågor för flera frekvenser
frequencies = [0.2, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0, 8.0]; % Testade frekvenser
gain = zeros(1, length(frequencies));
phase = zeros(1, length(frequencies));
Ts = 0; % Tidssteg, sätt detta korrekt baserat på era mätningar

for i = 1:length(frequencies)
    frequency = frequencies(i);
    
    % Generera sinussignal vid given frekvens
    u = GetSine(frequency);  % Generera sinusvåg med GetSine
    
    % Öppna systemet och få ut signal och tid
    [y, t, ~] = OpenControl(u);  % Använd OpenControl för att köra systemet
    
    % Estimera sinusvågen från utsignalen
    sin_est = EstSine(y, t, frequency);  % Använd EstSine för att estimera vågen
    
    % Beräkna förstärkning
    gain(i) = max(sin_est) / max(u);
    
    % Beräkna fördröjning med finddelay
    delay_samples = finddelay(u, y);
    if i == 1
        Ts = t(2) - t(1); % Tidssteget är skillnaden mellan två tidpunkter
    end
    
    % Fasberäkning
    phase(i) = delay_samples * Ts * frequency * (180 / pi); % Omvandlar till grader
    
    % Plotta sinusvåg och dess estimering
    figure;
    plot(t, y, t, sin_est);
    title(['Frekvens ', num2str(frequency), ' rad/s']);
    legend('Signal', 'Estimerad sinus');
    
    % Skriv ut förstärkning och fas
    disp(['Gain vid ', num2str(frequency), ' rad/s: ', num2str(gain(i))]);
    disp(['Phase vid ', num2str(frequency), ' rad/s: ', num2str(phase(i)), ' grader']);
end

% Steg 2: Skapa en frekvensresponsmodell med frd
w = frequencies; % Frekvenserna
z = gain .* exp(1i .* phase * pi / 180); % Eulers formel för att skapa komplexa siffror
G = frd(z, w); % Skapa frekvensresponsdata

% Plotta Bodediagram för G
figure;
bode(G); % Plotta Bodediagrammet med frd-objektet G
title('Bode Diagram för det uppmätta systemet');

% Steg 3: Designa Lead-filter
omega_c = 1.44; % Skärfrekvens
phi_m = 55; % Fasmarginal
beta = (1 - sind(phi_m)) / (1 + sind(phi_m)); % Beräkna beta
Td = 1 / (omega_c * sqrt(beta)); % Differentiationstid

% Lead-kompensering
s = tf('s');
F_lead = (Td * s + 1) / (beta * Td * s + 1);
disp(['Lead-filter: ', num2str(F_lead)]);

% Steg 4: Designa Lag-filter
Ti = 10 / omega_c; % Tidskonstant för lag-filter
gamma = 0.1; % Precisionen för slutvärdesteoremet
F_lag = (Ti * s + 1) / (gamma * Ti * s + 1);
disp(['Lag-filter: ', num2str(F_lag)]);

% Steg 5: Samla total regulator och testa med step response
K = omega_c / gamma; % Förstärkning
F_total = K * F_lead * F_lag;

% Stegsvar för det slutna systemet
r = GetStep(1); % Generera stegsvar
[y, t] = FeedbackControl(F_total, r);
figure;
plot(t, y);
title('Stegsvar för det slutna systemet');
xlabel('Tid (s)');
ylabel('Utsignal');
grid on;

% Om ni vill justera för olika wc, fasmarginal etc.
disp(['Total regulator: ', num2str(F_total)]);
```