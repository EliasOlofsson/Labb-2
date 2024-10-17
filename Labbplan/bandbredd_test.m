
frekvenser = [0.2, 0.5, 1.0, 1.44, 2.0, 3.0, 4.0, 5.0, 6.0, 8.0]; % frekvenser i rad/s
magnitud = [7.197, 3.147, 1.367, 0.766, 0.414, 0.261, 0.108, 0.074, 0.039, 0.020]; % magnitud i dB
fas = [-106, -122, -137, -142, -155, -172, -180, -180, -180.4817, -180]; % fas i grader


magnitud_linjar = 10.^(magnitud / 20);


sys = frd(magnitud_linjar.*exp(1j*deg2rad(fas)), frekvenser);

margin(sys);


max_magnitud_dB = max(magnitud);
dB_niva = max_magnitud_dB - 3;


index_ovre = find(magnitud < dB_niva, 1); 
index_nedre = index_ovre - 1; 


if ~isempty(index_ovre) && index_ovre > 1
    frekvens_bandbredd = interp1(magnitud([index_nedre, index_ovre]), ...
                                 frekvenser([index_nedre, index_ovre]), dB_niva);
    fprintf('Interpolerad bandbredd är cirka %.4f rad/s\n', frekvens_bandbredd);
else
    fprintf('Kunde inte hitta -3 dB-punkten inom det givna frekvensområdet.\n');
end
