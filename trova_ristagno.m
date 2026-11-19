function [coord1_ristagno, coord2_ristagno, psi_ristagno] = trova_ristagno(psi, var1, var2, guess1, guess2)
% ritorna le coordinate dei punti di ristagno ed il valore della stream
% function costituita dai punti in cui V = 0.

componente1 = diff(psi, var1);
componente2 = -diff(psi, var2);

% u=0 e v=0. vpasolve ha bisogno di un "guess" iniziale per 
% sapere dove cercare, specialmente in campi con più punti di ristagno.

sol = vpasolve([componente1 == 0, componente2 == 0], [var1, var2], [guess1, guess2]);
f_check = matlabFunction(componente1 + componente2, 'Vars', [var1, var2]);

% char(var1) prende la variabile simbolica var1 e la tarsforma in una stringa di testo 'var1'. 
% sol (char(var1)) va a pescare nella soluzione la struttura giusta contente la soluzione, legata alla string 'var1'.
% double trasforma il simbolo appena ottenuto in un numero floating point

c1_all = real(double(sol.(char(var1))));
c2_all = real(double(sol.(char(var2))));


% trova la radice più vicina al guess
distanze = sqrt( (c1_all - guess1).^2 + (c2_all - guess2).^2 ) + 0*f_check(c1_all, c2_all);
[~, indice_migliore] = min(distanze);

% estrae l'unica coordinata corretta
coord1_ristagno = round(c1_all(indice_migliore), 6);
coord2_ristagno = round(c2_all(indice_migliore), 6);


psi_ristagno = double(  subs(psi, {var1, var2}, {coord1_ristagno, coord2_ristagno}) );
end