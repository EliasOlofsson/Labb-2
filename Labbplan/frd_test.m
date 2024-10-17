frekvenser = [0.2, 0.5, 1.0, 1.44, 2.0, 3.0, 4.0, 5.0, 6.0, 8.0]; 
magnitud = [7.197, 3.147, 1.367, 0.766, 0.414, 0.261, 0.108, 0.074, 0.039, 0.020]; 
fas = [-106, -122, -137, -142, -155, -172, -180, -180, -180.4817, -180]; 

sys = frd(magnitud.*exp(1j*deg2rad(fas)), frekvenser);

margin(sys);

[Gm, Pm, Wgm, Wpm] = margin(sys);
Gm_dB = 20 * log10(Gm); % Convert gain margin to dB
fprintf('Gain Margin: %.2f dB\n', Gm_dB);
fprintf('Phase Margin: %.2f degrees\n', Pm);

