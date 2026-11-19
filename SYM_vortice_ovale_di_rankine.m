clear; clc;

syms vx0 sx0 px0 vy0 y0 x y r theta Vinf LAMBDA GAMMA real  % variabili rimboliche


% FLUSSO UNIFORME
% u = Vinf, v = 0
psi_uniforme = stream_function(Vinf, 0, x, y, 'cartesiane');

% SORGENTE
% Vr = LAMBDA/(2*pi*r), Vtheta = 0
% LAMBDA = portata volumetrica per unità di lunghezza radiale
Vr_sorgente = LAMBDA / (2*pi*r);
psi_sorgente_polare = stream_function(Vr_sorgente, 0, r, theta, 'polari');

% POZZO
% Vr = LAMBDA/(2*pi*r), Vtheta = 0
% LAMBDA = portata volumetrica per unità di lunghezza radiale
Vr_pozzo = - LAMBDA / (2*pi*r);
psi_pozzo_polare = stream_function(Vr_pozzo, 0, r, theta, 'polari');

% VORTICE IRROTAZIONALE
% Vr = 0 , Vtheta = GAMMA/2*pi*r
% GAMMA = circolazione lungo una linea chiusa che circonda l'origine (lungo qualsiasi altra curva sarebbe 0 perché il campo è irrotazionale ovunque)
Vtheta_vortice = GAMMA / (2*pi*r);
psi_vortice_polare = stream_function(0, Vtheta_vortice, r, theta, 'polari');


% r = sqrt(x^2+y^2), theta = atan2(y,x)
psi_sorgente = subs(psi_sorgente_polare, [r, theta], [sqrt( (x-sx0)^2 + (y-y0)^2), atan2( y-y0 , x-sx0 )]);
psi_pozzo = subs(psi_pozzo_polare, [r, theta], [sqrt( (x-px0)^2 + (y - y0)^2), atan2( y-y0 , x-px0 )]);
psi_vortice = subs(psi_vortice_polare, [r, theta], [sqrt( (x-vx0)^2 + (y - vy0)^2), atan2(y-vy0 , x-vx0 )]);


% SOVRAPPOSIZIONE
psi_totale = psi_uniforme + psi_sorgente + psi_pozzo + psi_vortice;
disp('stream function totale:');
disp(psi_totale);



% PLOTTING

Vinf_val = 10; 

LAMBDA_val = 2*pi;
sx0_val = 0;
px0_val = 2;
y0_val = 3;

GAMMA_val = 3;
vx0_val = 1;
vy0_val = 3;


psi_plot = subs(psi_totale, [Vinf, LAMBDA, GAMMA, sx0, px0, y0, vx0, vy0], [Vinf_val, LAMBDA_val, GAMMA_val, sx0_val, px0_val, y0_val, vx0_val, vy0_val]);

% 2 PUNTI DI RISTAGNO 
[x_monte, y_monte, psi_ristagno] = trova_ristagno(psi_plot, x, y, sx0_val - 2, y0_val);
[x_valle, y_valle, ~] = trova_ristagno(psi_plot, x, y, px0_val +2, y0_val);

fprintf('ristagno a monte: (%.3f, %.3f)\n', x_monte, y_monte);
fprintf('ristagno a valle: (%.3f, %.3f)\n', x_valle, y_valle);
fprintf('valore della streamline che passa per i punti di ristagno: psi = %.3f\n', psi_ristagno);


% GRAFICO

[X, Y] = meshgrid(linspace(-4, 6, 500), linspace(-2, 6, 500));
f_psi = matlabFunction(psi_plot, 'Vars', [x, y]);
PSI = f_psi(X, Y);
PSI(~isfinite(PSI)) = NaN;

figure;
hold on;
grid on;
axis equal;
xlabel('x');
ylabel('y');
title('linee di corrente: ovale di rankine con vortice');

contour(X, Y, PSI, 50, 'b', 'LineWidth', 1);
contour(X, Y, PSI, [psi_ristagno psi_ristagno], 'r', 'LineWidth', 2);

plot(sx0_val, y0_val, 'go', 'MarkerSize', 6, 'MarkerFaceColor', 'g');
plot(px0_val, y0_val, 'go', 'MarkerSize', 6, 'MarkerFaceColor', 'g');
plot(vx0_val, vy0_val, 'mo', 'MarkerSize', 6, 'MarkerFaceColor', 'm');
plot(x_valle, y_valle, 'ro');
plot(x_monte, y_monte, 'ro');



