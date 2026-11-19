clc
clearvars

M0 = 0.3;
T_isa = 288.15;
z = 4000;
R_ = 8.314; 'J/mol*K';
Mmol = 0.02896; 'Kg';
vettore_OPR = 10:10:100; 
vettore_TIT = 1200:100:1800;
[OPR, TIT] = meshgrid(vettore_OPR, vettore_TIT);
en = 0.99;
ed = 0.85;
eta_t = 0.90;
mb = 4.5;
gamma = 1.4;
h = 0.0065;
g = 9.81;
Hi = 43000000;

R = R_./Mmol;



T0 = T_isa - h.*z;
a = sqrt(gamma.*R.*T0);
u = a.*M0;



coeff_z = g./(h.*R);

p_isa = 10^5;
p0 = p_isa.*(1 - (0.0065.*z./T_isa) )^coeff_z ;
cp = R.*gamma./(gamma-1);
p0_tot = p0 .* (1 + (gamma-1)./2 .* M0.^2).^(gamma./(gamma-1));

T0_tot = T0 .* (1 + (gamma-1)./2 .* M0.^2);

T2_tot = T0_tot .* OPR.^((gamma-1)./gamma);

p1_tot = ed .* p0_tot;
p3_tot = OPR .* p1_tot;

T4_tot = TIT - T2_tot + T0_tot;
p4_tot = p3_tot .* ( ( T4_tot ./ TIT ) .^ (gamma .* eta_t ./ (gamma-1) ) );
we = sqrt( T4_tot .* (1 - (p0./(p4_tot.*en)).^( (gamma-1) ./gamma ) ) .*2 .*cp );

f = cp.*(TIT - T2_tot) ./ (Hi - cp.*TIT);

'spinta specifica';
'S = spinta = (m+mb).*we - m.*u + Ae(pe-p0)';
'ugello adattato S = (m+mb)*we - m*u ';
'Ia = spinta specifica = S./m = (1 + f)*we - m*u';
Ia = we.*(1+f) - u;


% qs = mb/S = mb/m *Ia = f/Ia
qs = f./Ia;


% =========================================================

figure

% Ia = f(OPR) , TIT costante
subplot(2,2,1);
hold on;
grid on;
xlabel('Rapporto di Compressione (OPR)');
ylabel('Spinta Specifica (Ia) [N*s/kg]');
title('Spinta Specifica vs OPR (curve a TIT costante)');

legenda_TIT = cell(length(vettore_TIT), 1);

for i = 1:length(vettore_TIT)
    plot(vettore_OPR, Ia(i, :));
    legenda_TIT{i} = ['TIT = ', num2str(vettore_TIT(i)), ' K'];
end

legend(legenda_TIT, 'Location', 'bestoutside');


% q_s = f(OPR) , TIT costante
subplot(2,2,2);
hold on;
xlabel('Rapporto di Compressione (OPR)');
ylabel('Consumo Specifico (qs) [kg/(N*s)]');
title('Consumo Specifico vs OPR (curve a TIT costante)');

grid on;
for i = 1:length(vettore_TIT)
    plot(vettore_OPR, qs(i, :));
end

legend(legenda_TIT, 'Location', 'bestoutside');


% Ia = f(TIT) , OPR costante
subplot(2,2,3);
hold on;
grid on;
xlabel('Temperatura Ingresso Turbina (TIT) [K]');
ylabel('Spinta Specifica (Ia) [N*s/kg]');
title('Spinta Specifica vs TIT (curve a OPR costante)');

legenda_OPR = cell(length(vettore_OPR), 1);

for j = 1:length(vettore_OPR)
    plot(vettore_TIT, Ia(:, j));
    legenda_OPR{j} = ['OPR = ', num2str(vettore_OPR(j))];
end

legend(legenda_OPR, 'Location', 'bestoutside');


% q_s = f(TIT), OPR costante
subplot(2,2,4)
hold on;
grid on;
xlabel('Temperatura Ingresso Turbina (TIT) [K]');
ylabel('Consumo Specifico (qs) [kg/(N*s)]');
title('Consumo Specifico vs TIT (curve a OPR costante)')

for j = 1:length(vettore_OPR)
    plot(vettore_TIT, qs(:, j));
end

legend(legenda_OPR, 'Location', 'bestoutside');





