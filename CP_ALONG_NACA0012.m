clear; clc; close all;

% >>> CHANGE ANGLE OF ATTACK HERE FOR YOUR EXAM <<<
AoA_deg = 0; % Angle of Attack in degrees (Try 0, 4, 8, -4, etc.)
% -------------------------------------------------

alpha = deg2rad(AoA_deg);
N = 400;
beta = linspace(0, pi, N);
x = 0.5 * (1 - cos(beta)); 
t = 0.12;

% Geometry & Slope
yt = 5 * t * (0.2969*sqrt(x) - 0.1260*x - 0.3516*x.^2 + 0.2843*x.^3 - 0.1015*x.^4);
dyt_dx = 5 * t * (0.14845./sqrt(x + 1e-6) - 0.1260 - 0.7032*x + 0.8529*x.^2 - 0.4060*x.^3);

% Velocity & Cp Calculation with Riegels Leading-Edge Correction
% Base velocity component from thickness
u_thick = 1 + 0.88 * (yt ./ (x + 0.03)) - 0.12 * x.^1.5;

% Circulation component due to Angle of Attack (Thin Airfoil Theory)
u_alpha = sin(alpha) * sqrt((1 - x) ./ (x + 0.008));

% Surface velocities (Riegels rule prevents LE singularity and shifts stagnation point)
V_upper = (u_thick * cos(alpha) + u_alpha) ./ sqrt(1 + dyt_dx.^2);
V_lower = (u_thick * cos(alpha) - u_alpha) ./ sqrt(1 + dyt_dx.^2);

Cp_upper = 1 - V_upper.^2;
Cp_lower = 1 - V_lower.^2;

% Integrate Cp to find Lift Coefficient (Cl = integral of Cp_l - Cp_u)
Cl = trapz(x, (Cp_lower - Cp_upper)) * cos(alpha);

% Locate Stagnation Point (where Cp is maximum / closest to 1)
if AoA_deg >= 0
    [Cp_stag, idx_stag] = max(Cp_lower);
    stag_surf = 'Lower Surface';
else
    [Cp_stag, idx_stag] = max(Cp_upper);
    stag_surf = 'Upper Surface';
end
x_stag = x(idx_stag);

% Plotting
figure('Color', 'w', 'Position', [100, 100, 850, 620]);

subplot(4,1,1:3); hold on; grid on; box on;
% Shade area between curves to represent Lift (Cl)
fill([x, fliplr(x)], [Cp_upper, fliplr(Cp_lower)], [0.9 0.95 1], ...
    'EdgeColor', 'none', 'DisplayName', sprintf('Enclosed Area = C_l (\\approx %.2f)', Cl));

plot(x, Cp_upper, 'b-', 'LineWidth', 2.5, 'DisplayName', 'Upper Surface (Suction / Expansion)');
plot(x, Cp_lower, 'r-', 'LineWidth', 2.5, 'DisplayName', 'Lower Surface (Pressure)');
yline(0, 'k-.', 'LineWidth', 1, 'DisplayName', 'C_p = 0');

% Plot Stagnation Point
plot(x_stag, Cp_stag, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'g', ...
    'DisplayName', sprintf('Stagnation Point (x/c = %.3f, %s)', x_stag, stag_surf));

% Plot Suction Peak
[Cp_min, idx_min] = min(Cp_upper);
plot(x(idx_min), Cp_min, 'ks', 'MarkerSize', 8, 'MarkerFaceColor', 'm', ...
    'DisplayName', sprintf('Suction Peak (C_p = %.2f at x/c = %.3f)', Cp_min, x(idx_min)));

set(gca, 'YDir', 'reverse');
ylim([min(Cp_upper)-0.3, 1.2]); xlim([-0.02, 1.02]);
ylabel('C_p [Inverted Axis]', 'FontWeight', 'bold');
title(sprintf('NACA 0012 C_p Distribution at \\alpha = %.1f^\\circ  (C_l \\approx %.2f)', AoA_deg, Cl), 'FontSize', 12);
legend('Location', 'southeast');

% Airfoil Plot with AoA rotation visual
subplot(4,1,4); hold on; grid on; box on;
fill([x, fliplr(x)], [yt, fliplr(-yt)], [0.85 0.85 0.85], 'EdgeColor', 'k', 'LineWidth', 1.5);
y_stag = ifelse(AoA_deg >= 0, -yt(idx_stag), yt(idx_stag));
plot(x_stag, y_stag, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 7);
axis equal; xlim([-0.02, 1.02]); ylim([-0.15, 0.15]);
xlabel('x/c', 'FontWeight', 'bold'); ylabel('y/c', 'FontWeight', 'bold');
title(sprintf('Stagnation Point Location on Airfoil (x/c = %.3f)', x_stag));

function out = ifelse(cond, true_val, false_val)
if cond, out = true_val; else, out = false_val; end
end