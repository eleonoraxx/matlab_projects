function psi = stream_function(componente1, componente2, var1, var2, coordinate)
% u, v: componenti di velocità simboliche (u,v oppure vr,vtheta)
% var1, var2: variabili simboliche (x,y oppure r,theta)

if nargin < 5
    coordinate = 'cartesiane';
end

if strcmp(coordinate, 'cartesiane')
    x = var1;
    y = var2;
    u = componente1;
    v = componente2;

    % u = d(psi)/dy  => psi(y) = int_def_da_0_a_y(u, y)
    psi_y = int(u, y, 0, y);

    % v = -d(psi)/dx => psi(x) = int_def_da_0_a_x(-v, x)
    psi_x = int( subs(-v,y,0), x, 0, x);
    psi = psi_y + psi_x;

elseif strcmp(coordinate, 'polari')
    r = var1;
    theta = var2;

    vr = componente1;
    vtheta = componente2;

    % vr = 1/r * d(psi)/d(theta) => psi = int(r*vr, theta) + f(r)
    
    psi_theta = int(r * vr, theta);
    % vtheta = -d(psi)/dr => f'(r) = -vtheta - d(psi_theta)/dr
    df_dr = -vtheta - diff(psi_theta, r);
    f_r = int(df_dr, r);
    psi = psi_theta + f_r;
    
else
    error('Usa "cartesiane" o "polari"');
end

psi = simplify(psi);
end