% Öppna figuren om den är sparad som en .fig-fil
openfig('test.fig'); 

% Hämta alla linjer i figuren
h = findobj(gca,'Type','line'); % Hämta alla linjeobjekt i grafen

% Eftersom vi vill ha den blå linjen (vi antar att den är den första),
% kan vi anropa den första linjen i listan. Om du vet att den blå linjen 
% har ett specifikt index, kan du justera detta.

% Hämta X- och Y-data från den blå linjen (vi antar att det är den första)
x_data = get(h(2), 'XData'); % Tid (x)
y_data = get(h(2), 'YData'); % Utsignal (y)

% Kontrollera dimensionerna och säkerställ att y_data är en kolumnvektor
if size(y_data, 1) < size(y_data, 2)
    y_data = y_data';  % Transponera y_data till kolumnvektor om det behövs
end

% Skapa en enkel tidsserie (utan ingångssignal)
data = iddata(y_data, [], 0.1); % Skapa iddata för tidsserie

% Visa datan för att säkerställa att den är korrekt
disp(data)

% Vid denna punkt kan du fortsätta med att använda denna data
% för systemidentifiering eller vad du önskar.

%%
% Skapa ingångssignalen (konstant 1V)
u_data = ones(length(y_data), 1); % En vektor med konstant värde 1 av samma längd som y_data

% Skapa iddata med både ingångssignal och utsignal
data = iddata(y_data, u_data, 0.1); % 0.1 är provtagningsperioden

% Nu kan du fortsätta med systemidentifieringen
sys = tfest(data, 2); % Identifiera en andra ordningens överföringsfunktion (justera efter behov)

% Visa den identifierade överföringsfunktionen
disp(sys);

% Nu kan du simulera systemet och applicera din Lead-Lag-regulator

%%
% Simulera stegsvar eller andra typer av analyser
compare(data, sys);  % Jämför den faktiska datan med din identifierade modell

%%
% Definiera Lead- och Lag-komponenterna
% Definiera Lead- och Lag-komponenterna
lead_numerator = 0.7947 * [1.25 1]; % Täljaren för lead-delen
lead_denominator = [0.3125 1];      % Nämnaren för lead-delen

lag_numerator = [6.25 1];  % Täljaren för lag-delen
lag_denominator = [6.25 1]; % Lag-filtret korrigerad nämnare

% Skapa överföringsfunktionerna
lead_tf = tf(lead_numerator, lead_denominator);
lag_tf = tf(lag_numerator, lag_denominator);

% Total överföringsfunktion
F_total = lead_tf * lag_tf;

% Skapa det återkopplade systemet med regulatorn
T = feedback(F_total * sys, 1); % Stängd slinga med enhetsåterkoppling

% Simulera stegsvar
step(T);

%%