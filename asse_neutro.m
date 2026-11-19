function g = asse_neutro (Ix_tot, Iy_tot, Ixy_tot)
    a = Ixy_tot / ( (Ix_tot*Iy_tot) - Ixy_tot^2) ;
    b = Iy_tot / ( (Ix_tot*Iy_tot) - Ixy_tot^2); 
    g = a/b;
end