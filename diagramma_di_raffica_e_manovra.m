% DIAGRAMMI DI MANOVRA, RAFFICA E INVILUPPO
% velivolo: PILATUS turbo porter (categoria UTILITY) - normativa CS-23
clear; clc; close all;

% DATI DEL VELIVOLO E COSTANTI
m_vec     = [2800, 1270];       % masse: [W_max, W_min] [kg]
nomi_caso = {'Peso Massimo (2800 kg)', 'Peso Minimo (1270 kg)'};

C = 1.9;                % corda media geometrica [m]
S = 30.15;              % superficie alare [m^2]
CL_max = 1.4;                % CL massimo velivolo completo
CL_min = 1.05;               % CL minimo velivolo completo (volo rovescio)
CL_inf = 5.8;                % pendenza retta di portanza profilo [rad^-1]
allungamento  = 7.96;               % allungamento effettivo
CD_min = 0.08;               % coefficiente di resistenza minimo
Vc_TAS_kmh = 250;                % velocità di crociera TAS @ 2500m [km/h]
rho_2500 = 0.9567;             % densità aria @ 2500m [kg/m^3]
rho_0 = 1.225;              % densità aria @ livello del mare [kg/m^3]
e = 0.9;                % fattore di oswald
g = 9.81;               % accelerazione di gravità [m/s^2]

% fattori di conversione (da tabella normativa)
N2lb      = 0.2248;             % 1 N in lb
m2ft      = 3.281;              % 1 m in ft
kts2ms    = 0.514;              % 1 nodo in m/s
fps2ms    = 1 / m2ft;           % 1 ft/s in m/s 

% parametri aerodinamici indipendenti dal peso (per la raffica)
a_CLalpha = CL_inf / (1 + CL_inf / (e * pi * allungamento));  % [rad^-1]
Ude_C     = 50 * fps2ms;        % raffica a V_C: 50 fps = 15.24 m/s
Ude_D     = 25 * fps2ms;        % raffica a V_D: 25 fps = 7.62 m/s

% RISOLUZIONE (1 = peso massimo, 2 = peso minimo)
for i = 1:2
    m = m_vec(i);
    W = m * g;                  % Peso (N)
    
    fprintf('  RISULTATI: %s\n', upper(nomi_caso{i}));

    % STEP 1: fattori di carico massimi e minimi (normativa)
    n_pos = 4.4;
    n_neg = -0.4 * n_pos;  % -1.76
    
    % STEP 2: velocità di crociera di progetto V_C
    Vc_TAS = Vc_TAS_kmh / 3.6;                      % m/s
    Vc_EAS = Vc_TAS * sqrt(rho_2500 / rho_0);       % m/s
    
    % conversione carico alare in unità imperiali (lb/ft^2)
    W_lb   = m * 2.205;                             % lb
    S_ft2  = S * (m2ft^2);                          % ft^2
    carico_alare_imperiale = W_lb / S_ft2;          % lb/ft^2
    
    if carico_alare_imperiale <= 20
        k_Vc = 33;
    else
        k_Vc = 33 - (33 - 28.6) * (carico_alare_imperiale - 20) / (100 - 20);
    end

    Vc_lim_kts = k_Vc * sqrt( carico_alare_imperiale);               % nodi
    Vc_lim_ms  = Vc_lim_kts * kts2ms;               % m/s

    V_C = max(Vc_EAS, Vc_lim_ms);
    
    % STEP 3: velocità di stallo (V_st+ e V_st-)
    V_st_pos = sqrt(2*W / (rho_0 * S * CL_max)); % m/s
    V_st_neg = sqrt(2*W / (rho_0 * S * CL_min)); % m/s
    
    % STEP 4: parabole con n = f(V_EAS)
    coeff_pos =  0.5 * rho_0 * (S / W) * CL_max;    % n+ = coeff_pos * V_st_pos^2
    coeff_neg = -0.5 * rho_0 * (S / W) * CL_min;    % n- = coeff_neg * V_st_neg^2
    
    % STEP 5: velocità di manovra (V_A+ e V_A-) e limiti 
    VA_guess_pos = sqrt(n_pos / coeff_pos);
    VA_guess_neg = sqrt(abs(n_neg / coeff_neg));
    
    VA_lim_pos   = V_st_pos * sqrt(abs(n_pos));
    VA_lim_neg   = V_st_neg * sqrt(abs(n_neg));
    
    % V_st*sqrt(|n|) <= V_A <= V_C
    V_A_pos = min(max(VA_guess_pos, VA_lim_pos), V_C);
    V_A_neg = min(max(VA_guess_neg, VA_lim_neg), V_C);
    
    % STEP 6: velocità di picchiata V_D 
    VD_calc = sqrt((2 * W) / (rho_0 * S * CD_min)); % m/s
    
    if carico_alare_imperiale <= 20
        k_Vd = 1.50;
    else
        k_Vd = 1.50 - (1.50 - 1.35) * (WS_imp - 20) / (100 - 20);
    end
    Vc_min_app_kts = 17 * sqrt(n_pos * carico_alare_imperiale);     % nodi
    VD_lim_ms      = k_Vd * Vc_min_app_kts * kts2ms; % m/s
    
    V_D = max(VD_calc, VD_lim_ms);
    
    % CALCOLO DIAGRAMMA DI RAFFICA 
    % Attenzione: mu_g usa la densità in quota (rho_2500)
    mu_g = (2 * W / S) / (rho_2500 * C * a_CLalpha * g);
    k_g  = (0.88 * mu_g) / (5.3 + mu_g);
    
    % fattori di carico a raffica (rho_0 perché V è in EAS)
    dn_RC = (k_g * rho_0 * Ude_C * a_CLalpha * V_C) / (2 * (W / S));
    dn_RD = (k_g * rho_0 * Ude_D * a_CLalpha * V_D) / (2 * (W / S));
    
    n_RC_pos = 1 + dn_RC;
    n_RC_neg = 1 - dn_RC;
    n_RD_pos = 1 + dn_RD;
    n_RD_neg = 1 - dn_RD;
    


    % STAMPA RIEPILOGO A SCHERMO
    fprintf('Carico alare W/S      = %.2f lb/ft^2\n',  carico_alare_imperiale);
    fprintf('Parabole: n+ = +%.6f * V^2  |  n- = %.6f * V^2\n', coeff_pos, coeff_neg);
    fprintf('Parametri raffica: C_La = %.2f rad^-1, mu_g = %.2f, k_g = %.3f\n\n', a_CLalpha, mu_g, k_g);
    
    Punti = {'St+'; 'St-'; 'A+'; 'A-'; 'C+'; 'C-'; 'D+'; 'D-'; 'R_C+'; 'R_C-'; 'R_D+'; 'R_D-'};
    V_tab = [V_st_pos; V_st_neg; V_A_pos; V_A_neg; V_C; V_C; V_D; V_D; V_C; V_C; V_D; V_D];
    n_tab = [1; -1; n_pos; n_neg; n_pos; n_neg; n_pos; -1; n_RC_pos; n_RC_neg; n_RD_pos; n_RD_neg];
    disp(table(Punti, round(V_tab, 2), round(n_tab, 3), 'VariableNames', {'Punto', 'V_EAS_ms', 'n'}));




    % STEP 7: DISEGNO DEI DIAGRAMMI (MANOVRA, RAFFICA E INVILUPPO)
    % Vettore velocità per costruire i profili superiori e inferiori
    V_pos_vec = linspace(V_st_pos, V_D, 500);
    V_neg_vec = linspace(V_st_neg, V_D, 500);
    
    % Profilo Manovra superiore e inferiore
    n_man_sup = min(coeff_pos * V_pos_vec.^2, n_pos);
    n_man_inf = zeros(size(V_neg_vec));
    for k = 1:length(V_neg_vec)
        vk = V_neg_vec(k);
        if vk <= V_A_neg
            n_man_inf(k) = coeff_neg * vk^2;
        elseif vk <= V_C
            n_man_inf(k) = n_neg;
        else
            n_man_inf(k) = n_neg + (-1 - n_neg) * (vk - V_C) / (V_D - V_C);
        end
    end
    
    % Profilo Raffica superiore e inferiore
    n_raf_sup = zeros(size(V_pos_vec));
    for k = 1:length(V_pos_vec)
        vk = V_pos_vec(k);
        if vk <= V_C
            r_line = 1 + (n_RC_pos - 1) * (vk / V_C);
            n_raf_sup(k) = min(coeff_pos * vk^2, r_line);
        else
            n_raf_sup(k) = n_RC_pos + (n_RD_pos - n_RC_pos) * (vk - V_C) / (V_D - V_C);
        end
    end
    
    % Per il ramo inferiore di raffica partiamo da V_st_pos (come da Fig. 9-10 del PDF)
    V_raf_inf_vec = linspace(V_st_pos, V_D, 500);
    n_raf_inf = zeros(size(V_raf_inf_vec));
    for k = 1:length(V_raf_inf_vec)
        vk = V_raf_inf_vec(k);
        if vk <= V_C
            n_raf_inf(k) = 1 + (n_RC_neg - 1) * (vk / V_C);
        else
            n_raf_inf(k) = n_RC_neg + (n_RD_neg - n_RC_neg) * (vk - V_C) / (V_D - V_C);
        end
    end
    
    % Costruzione Poligono di Inviluppo (Unione Manovra U Raffica)
    n_inv_sup = max(n_man_sup, n_raf_sup);
    
    % Ramo inferiore per V tra V_st_pos e V_st_neg (dove la manovra vale 0 e la raffica scende sotto 0)
    V_step_vec = linspace(V_st_pos, V_st_neg, 100);
    n_raf_step = 1 + (n_RC_neg - 1) * (V_step_vec / V_C);
    n_inv_step = min(0, n_raf_step);
    
    % Ramo inferiore per V >= V_st_neg
    n_raf_inf_sub = interp1(V_raf_inf_vec, n_raf_inf, V_neg_vec);
    n_inv_inf     = min(n_man_inf, n_raf_inf_sub);
    
    % Coordinate chiuse per fill() dell'inviluppo e dei diagrammi
    V_poly_inv = [V_pos_vec, fliplr(V_neg_vec), fliplr(V_step_vec)];
    n_poly_inv = [n_inv_sup, fliplr(n_inv_inf), fliplr(n_inv_step)];
    
    V_poly_man = [V_st_pos, V_pos_vec, V_D, fliplr(V_neg_vec), V_st_neg, V_st_pos];
    n_poly_man = [0, n_man_sup, -1, fliplr(n_man_inf), 0, 0];
    
    V_poly_raf = [V_st_pos, V_pos_vec, V_D, fliplr(V_raf_inf_vec)];
    n_poly_raf = [0, n_raf_sup, n_RD_neg, fliplr(n_raf_inf)];

    % Plot Figura
    figure('Name', nomi_caso{i}, 'Color', 'w', 'Position', [100 + (i-1)*650, 100, 620, 500]);
    hold on; grid on; box on;
    
    % 1. Area di Inviluppo (Giallo)
    h_inv = fill(V_poly_inv, n_poly_inv, [1 1 0.1], 'EdgeColor', 'none', 'DisplayName', 'Diagramma di inviluppo');
    
    % 2. Parabole di stallo tratteggiate
    V_par = linspace(0, 80, 200);
    plot(V_par, coeff_pos * V_par.^2, 'b--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
    plot(V_par, coeff_neg * V_par.^2, 'r--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
    
    % 3. Rette di costruzione della raffica da (0,1)
    plot([0, V_C], [1, n_RC_pos], 'b:', 'LineWidth', 1.0, 'HandleVisibility', 'off');
    plot([0, V_D], [1, n_RD_pos], 'b:', 'LineWidth', 1.0, 'HandleVisibility', 'off');
    plot([0, V_C], [1, n_RC_neg], 'b:', 'LineWidth', 1.0, 'HandleVisibility', 'off');
    plot([0, V_D], [1, n_RD_neg], 'b:', 'LineWidth', 1.0, 'HandleVisibility', 'off');
    
    % 4. Linee limite tratteggiate e asse n = 0
    yline(0, 'k-', 'LineWidth', 1.0, 'HandleVisibility', 'off');
    plot([0, V_D], [n_pos, n_pos], 'k--', 'HandleVisibility', 'off');
    plot([0, V_D], [n_neg, n_neg], 'k--', 'HandleVisibility', 'off');
    plot([V_st_pos, V_st_pos], [0, n_pos], 'k--', 'HandleVisibility', 'off');
    plot([V_st_neg, V_st_neg], [0, n_neg], 'k--', 'HandleVisibility', 'off');
    
    % 5. Contorno Diagramma di Manovra (Rosso) e Raffica (Blu)
    h_man = plot(V_poly_man, n_poly_man, 'r-', 'LineWidth', 2.2, 'DisplayName', 'Diagramma di manovra');
    h_raf = plot(V_poly_raf, n_poly_raf, 'b-', 'LineWidth', 2.2, 'DisplayName', 'Diagramma di raffica');
    
    % 6. Punti notevoli ed etichette
    plot(V_tab, n_tab, 'go', 'MarkerFaceColor', 'g', 'MarkerSize', 4, 'HandleVisibility', 'off');
    text(V_st_pos-6, 1.2, 'St+', 'FontWeight', 'bold');
    text(V_st_neg-6, -1.2, 'St-', 'FontWeight', 'bold');
    text(V_A_pos-4, n_pos+0.25, 'A+', 'FontWeight', 'bold');
    text(V_A_neg-4, n_neg-0.25, 'A-', 'FontWeight', 'bold');
    text(V_C, n_pos-0.25, 'C+', 'FontWeight', 'bold');
    text(V_C, n_neg+0.25, 'C-', 'FontWeight', 'bold');
    text(V_D-3, n_pos+0.25, 'D+', 'FontWeight', 'bold');
    text(V_D+1.5, -1, 'D-', 'FontWeight', 'bold');
    text(V_C+1, n_RC_pos+0.15, 'R\_C+', 'FontWeight', 'bold', 'Color', 'b');
    text(V_C+1, n_RC_neg-0.15, 'R\_C-', 'FontWeight', 'bold', 'Color', 'b');
    text(V_D+1.5, n_RD_pos, 'R\_D+', 'FontWeight', 'bold', 'Color', 'b');
    text(V_D+1.5, n_RD_neg, 'R\_D-', 'FontWeight', 'bold', 'Color', 'b');
    
    xlabel('V_{EAS} (m/s)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Fattore di carico n', 'FontSize', 11, 'FontWeight', 'bold');
    title(['Diagramma di Manovra, Raffica e Inviluppo - ', nomi_caso{i}], 'FontSize', 12);
    legend([h_man, h_raf, h_inv], 'Location', 'northeast');
    xlim([0, 145]);
    ylim([-3.2, 5.5]);
end