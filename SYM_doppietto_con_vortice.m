clear; clc;

syms x y r theta Vinf GAMMA KAPPA real  % variabili rimboliche

%%% COSTRUZIONE DELLA FUNZIONE DI CORRENTE


% FLUSSO UNIFORME
% u = Vinf, v = 0
psi_uniforme = stream_function(Vinf, 0, x, y, 'cartesiane');

% 2. DOPPIETTO (sostituisce sorgente + pozzo per il cilindro)
% KAPPA = 2 * pi * Vinf * R^2
Vr_doppietto = -KAPPA * cos(theta) / (2*pi*r^2);
Vtheta_doppietto = -KAPPA * sin(theta) / (2*pi*r^2);
psi_doppietto_polare = stream_function(Vr_doppietto, Vtheta_doppietto, r, theta, 'polari');

% VORTICE IRROTAZIONALE
% Vr = 0 , Vtheta = GAMMA/2*pi*r
% GAMMA = circolazione lungo una linea chiusa che circonda l'origine (lungo qualsiasi altra curva sarebbe 0 perché il campo è irrotazionale ovunque)
Vtheta_vortice = GAMMA / (2*pi*r);
psi_vortice_polare = stream_function(0, Vtheta_vortice, r, theta, 'polari');


% passaggio in cartesiane ( sin(theta) = y/r per evitare atan2)
r_cart = sqrt(x^2 + y^2);
psi_doppietto = subs(psi_doppietto_polare, [r, sin(theta)], [r_cart, y/r_cart]);
psi_vortice = subs(psi_vortice_polare, r, r_cart);


% SOVRAPPOSIZIONE
psi_totale = psi_uniforme + psi_doppietto + psi_vortice;
psi_totale_polare = SYM_psi_in_polari(psi_totale, x, y);
Vtheta_totale = diff(-psi_totale_polare, r);
Vr_totale = diff(psi_totale_polare/r, theta);
V_totale = sqrt(Vtheta_totale^2 + Vr_totale^2);



%%% CP

% Cp = 1 - (V/Vinf)
Cp = 1 - (V_totale / Vinf)^2;
% lungo la superficie del corpo, Vr_totale = 0
% quindi V(R, theta) = Vtheta_totale
% V_theta_totale MAX   =>   Cp MIN
t = solve( diff(Vtheta_totale, theta) == 0, theta);
theta_Cpmin_val = double(t(1))



%%% DATI dall'esercizio / valori

Vinf_val = 112.5*1000/3600;           % [m/s]      dato
R = 0.780;                            %            dato
% R^2 = KAPPA_val / 2*pi*Vinf_val
KAPPA_val = 2*pi*Vinf_val*R^2;        % [m^3/s]    calcolato
GAMMA_val = - 138;                    % [m^2/s]    dato



%%% CP: posizone e valore del MINIMO
Cp_min_val = double(subs(Cp, [Vinf, r, theta, KAPPA, GAMMA], [Vinf_val, R, theta_Cpmin_val, KAPPA_val, GAMMA_val]))
fprintf('la posizione del minimo di Cp è a %.3f rad e (Cp)min = %.3f \n', theta_Cpmin_val, Cp_min_val)



%%% PUNTI DI RISTAGNO 

psi_plot = subs(psi_totale, [Vinf, KAPPA, GAMMA], [Vinf_val, KAPPA_val, GAMMA_val]);

[x_monte, y_monte, psi_ristagno] = trova_ristagno(psi_plot, x, y,- R, 0);
[x_valle, y_valle, ~] = trova_ristagno(psi_plot, x, y, +R, 0);

fprintf('ristagno a monte: %.3fm, %.3fm\n', x_monte, y_monte);
fprintf('ristagno a valle: %.3fm, %.3fm\n', x_valle, y_valle);
fprintf('valore della streamline che passa per i punti di ristagno: psi = %.3f\n', psi_ristagno);

% in coordinate polari:
[r_monte, theta_monte] = NUMERICO_coordinate_polari(x_monte,y_monte);
[r_valle, theta_valle] = NUMERICO_coordinate_polari(x_valle,y_valle);
fprintf('ristagno a monte: %.3fm, %.3f rad \n', r_monte, theta_monte);
fprintf('ristagno a valle: %.3fm, %.3f rad \n', r_valle, theta_valle);

% osserviamo che:
% r_ristagno = R
% theta_ristagno | sin(theta_ristagno) = - GAMMA / 4*pi*R*Vinf



%%% ALTRI PUNTI DELL'ESERCIZIO


% GAMMA per cui i punti di ristagno si staccano dalla superficie:
% quando i punti di ristagno si staccano dalla superficie, si trovano entrambi a theta_crit = -pi/2
% quindi, sin(theta_crit) = -1 
% sin(theta_crit) = - GAMMA_crit / 4*pi*r*Vinf = -1
GAMMA_crit_val = 4*pi*R*Vinf_val;
fprintf('circuitazione critica: %.3f m^2/s \n', GAMMA_crit_val)


% Drag per unit span = 0
fprintf('drag per unità di spessore: 0 N/m (flusso simmetrico a destra e sinistra) \n')

% Lift per unit span from KUTTA-JOUKOWSKY'S THM:
rho = 1.225;                        % [ kg / m^3 ]
L = rho * Vinf_val * GAMMA_val;
fprintf('portanza per unità di spessore (kutta-joukowski thm): %.3f N/m \n', L)




%% GRAFICO

[X, Y] = meshgrid(linspace(-10, 10, 500), linspace(-10, 10, 500));
f_psi = matlabFunction(psi_plot, 'Vars', [x, y]);
PSI = f_psi(X, Y);
PSI(~isfinite(PSI)) = NaN;

figure;
hold on;
grid on;
axis equal;
xlabel('x');
ylabel('y');
title('linee di corrente: cilindro con vortice');

contour(X, Y, PSI, 50, 'b', 'LineWidth', 1);
contour(X, Y, PSI, [psi_ristagno psi_ristagno], 'r', 'LineWidth', 2);

plot(x_valle, y_valle, 'ro');
plot(x_monte, y_monte, 'ro');

theta_vals = linspace(0, pi, 100);
for i=1:length(theta_vals)
    Cp_plot(i) = double(subs(Cp, [Vinf, r, theta, KAPPA, GAMMA], [Vinf_val, R, theta_vals(i), KAPPA_val, GAMMA_val]));
end
figure;
hold on;
grid on;
xlabel('theta (rad)');
ylabel('Cp');
title('Cp lungo il profilo');
plot(theta_vals, Cp_plot, 'b', 'LineWidth', 1.5);


