function plot_pulito(psi, var1, var2, psi_stag, x_naso, x_coda, limiti1, limiti2)
% limiti1 = [min_coordinata1, max_coordinata1]
% limiti2 = [min_coordinata2, max_coordinata2]

[X, Y] = meshgrid(linspace( limiti1(1), limiti1(2), 300), linspace( limiti2(1), limiti2(2), 300));

% da una funzione simbolica trasformiamo psi in una FUNZIONE ANONIMA di
% matlab, che cosi matlab fa prima a calcolarla
f_psi = matlabFunction(psi, 'Vars', [var1, var2]);
% applichiao PSI a ciascuna componente della nostra meshgrid, in pratica
% computiamo f(x,y) per ogni (x,y) del nostro piano.
PSI = f_psi(X, Y);

% C è è l'elenco di tutte le coordinate (x,y) a cui è
% associato il valore psi_stag in PSI
C = contourc( X(1,:), Y(:,1), PSI, [psi_stag, psi_stag]);


% 1. Raccogliamo tutti i punti del contorno nel ciclo while
x_corpo = []; 
y_corpo = [];
idx = 1;
while idx < size(C, 2)
    n_punti = C(2, idx);
    x_corpo = [x_corpo, C(1, idx+1 : idx+n_punti)];
    y_corpo = [y_corpo, C(2, idx+1 : idx+n_punti)];
    idx = idx + n_punti + 1;
end

% 2. Filtriamo fuori dal while e chiudiamo l'ovale con convhull
x_min = min(x_naso, x_coda) - 0.05;
x_max = max(x_naso, x_coda) + 0.05;
validi = (x_corpo >= x_min) & (x_corpo <= x_max);
x_chiuso = x_corpo(validi);
y_chiuso = y_corpo(validi);

% trova i punti interni al contorno chiuso e li annulla
if length(x_chiuso) > 5
    k = convhull(x_chiuso, y_chiuso); % Unisce arco sopra e sotto in un solo anello
    maschera = inpolygon(X, Y, x_chiuso(k), y_chiuso(k));
    PSI(maschera) = NaN; 
end

contour(X, Y, PSI, 50, 'color', 'b', 'LineWidth', 1); 
hold on;

if length(x_chiuso) > 5
    plot(x_chiuso(k), y_chiuso(k), 'k', 'LineWidth', 2.5); % Disegna il bordo del corpo
end
end