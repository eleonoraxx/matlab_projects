function f = baricentro_e_momenti(A, X, Y)
% f = [ XG, YG, IX_tot, IY_tot, IXY_tot, Ix_tot, Iy_tot, Ixy_tot, theta, I_lambda, I_eta ]
    for i = 1:length(X)
        SX(i) = A(i)*Y(i);
        IX(i) = A(i)* ( Y(i) ^2);
        SY(i) = A(i)* X(i);
        IY(i) = A(i)* ( X(i) ^2);
        IXY(i) = A(i) * X(i) * Y(i);
    end

    SX_tot = sum(SX);
    SY_tot = sum(SY);
    A_tot = sum(A);

    XG = SY_tot/A_tot;
    YG = SX_tot/A_tot;

    IX_tot = sum(IX);
    IY_tot = sum(IY);
    IXY_tot = sum(IXY);


    for i = 1:length(X)
        Ix(i) = A(i)* ( (Y(i) - YG)^2);
        Iy(i) = A(i)* ( ( X(i) - XG)^2);
        Ixy(i) = A(i) * ( X(i) - XG ) * ( Y(i) - YG);
    end


    Ix_tot = sum(Ix);
    Iy_tot = sum(Iy);
    Ixy_tot = sum(Ixy);

    theta = 0.5*atan(- 2*Ixy_tot / (Ix_tot - Iy_tot));
    
    K1 = 0.5*( Ix_tot + Iy_tot );
    K2 = 0.5*sqrt( (Ix_tot - Iy_tot)^2  + 4 * Ixy_tot^2 ) ;

    if theta > 0
        I_lambda = K1 + K2;
        I_eta = K1 - K2;
    else 
        I_lambda = K1 - K2;
        I_eta = K1 + K2;
    end
    
    f = [ XG, YG, IX_tot, IY_tot, IXY_tot, Ix_tot, Iy_tot, Ixy_tot, theta, I_lambda, I_eta ];
end
