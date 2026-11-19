clear; clc;

syms x y r theta Vinf LAMBDA GAMMA real  % variabili rimboliche


% FLUSSO UNIFORME
% u = Vinf, v = 0
psi_uniforme = stream_function(Vinf, 0, x, y, 'cartesiane');

% SORGENTE
% Vr = LAMBDA/(2*pi*r), Vtheta = 0
% LAMBDA = portata volumetrica per unità di lunghezza radiale
Vr_sorgente = LAMBDA / (2*pi*r);
psi_sorgente_polare = stream_function(Vr_sorgente, 0, r, theta, 'polari');

% VORTICE IRROTAZIONALE
% Vr = 0 , Vtheta = GAMMA/2*pi*r
% GAMMA = circolazione lungo una linea chiusa che circonda l'origine (lungo qualsiasi altra curva sarebbe 0 perché il campo è irrotazionale ovunque)
Vtheta_vortice = GAMMA / (2*pi*r);
psi_vortice_polare = stream_function(0, -Vtheta_vortice, r, theta, 'polari');


% r = sqrt(x^2+y^2), theta = atan2(y,x)
psi_sorgente = subs(psi_sorgente_polare, [r, theta], [sqrt(x^2 + y^2), atan2(y,x)]);
psi_vortice = subs(psi_vortice_polare, [r, theta], [sqrt(x^2 + y^2), atan2(y,x)]);


% SOVRAPPOSIZIONE
psi_totale = psi_uniforme + psi_sorgente + psi_vortice;
disp('stream function totale:');
disp(psi_totale);



% PLOT

Vinf_val = 1; 
LAMBDA_val = 2*pi;
GAMMA_val = 3;

psi_plot = subs(psi_totale, [Vinf, LAMBDA, GAMMA], [Vinf_val, LAMBDA_val, GAMMA_val]);


figure;
hold on;

fcontour(psi_plot, [-5 5 -5 5], 'LevelList', -5:0.5:5, 'LineWidth', 1.5);
plot(0, 0, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

title('linee di corrente');
xlabel('x');
ylabel('y');
grid on;
axis equal;