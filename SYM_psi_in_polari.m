function [psi_polare, r, theta] = SYM_psi_in_polari(psi, x, y)
    syms r theta real
    assume (r>0);
    assume (theta >= 0 & theta < 2*pi);
    psi_temp = subs(psi, atan2(x,y), theta);
    psi_polare = subs(psi_temp, [x ,y], [r*cos(theta), r*sin(theta)]);
    psi_polare = simplify(psi_polare, 'Steps', 50);

end