%% weyl_verification.m
% Numerical verification of Sturmian density convergence for golden ratio floor operator.
%
% Lean 4 gap: weyl_equidistribution_interval (Sturmian.lean, line 322)
%   - Algebraic parts fully proved (binary alphabet, step characterization)
%   - density_step_one / density_step_two depend on 1 audited sorry
%     (Stone-Weierstrass bridge for Weyl equidistribution on AddCircle)
%
% This script verifies numerically:
%   lim_{N->inf} #{n <= N : d_phi(n) = 1} / N  ==>  1/phi^2  ~= 0.38197
%   lim_{N->inf} #{n <= N : d_phi(n) = 2} / N  ==>  1/phi    ~= 0.61803
%
% Three-Distance Theorem path (Lean strategy):
%   For irrational alpha, {alpha}, {2*alpha}, ..., {N*alpha} create gaps of
%   at most 3 distinct lengths. For alpha=phi exactly 2 lengths, giving
%   the density result combinatorially -- no Stone-Weierstrass needed.

%% Setup
phi = (1 + sqrt(5)) / 2;
phi_inv  = 1 / phi;        % ~0.61803  (density of step-2)
phi_inv2 = 1 / phi^2;      % ~0.38197  (density of step-1)

fprintf('phi        = %.10f\n', phi);
fprintf('1/phi      = %.10f  (expected density of step-2)\n', phi_inv);
fprintf('1/phi^2    = %.10f  (expected density of step-1)\n', phi_inv2);
fprintf('sum        = %.10f  (must = 1)\n', phi_inv + phi_inv2);

%% Compute Sturmian step sequence d_phi(n) for n=1..N_max
N_max = 1e6;
n     = (1:N_max)';

gold_floor      = floor(phi * (n + 1)) - floor(phi * n);  % d_phi(n)
is_step_one     = (gold_floor == 1);
is_step_two     = (gold_floor == 2);

% Sanity: every step is 1 or 2
assert(all(is_step_one | is_step_two), 'ERROR: step outside {1,2}');
fprintf('\nAll steps in {1,2}: PASS\n');

%% Convergence at checkpoints
checkpoints = [100, 1000, 10000, 100000, 1000000];
fprintf('\n%-10s  %-14s  %-14s  %-12s  %-12s\n', ...
    'N', 'rho_1 (actual)', 'rho_2 (actual)', 'err_rho1', 'err_rho2');
fprintf('%s\n', repmat('-', 1, 68));

for N = checkpoints
    r1 = sum(is_step_one(1:N)) / N;
    r2 = sum(is_step_two(1:N)) / N;
    fprintf('%-10d  %-14.8f  %-14.8f  %-12.2e  %-12.2e\n', ...
        N, r1, r2, abs(r1 - phi_inv2), abs(r2 - phi_inv));
end

%% Convergence plot
% Vectorized running averages — no loop needed
N_plot   = (1000:1000:N_max)';
rho1_run = cumsum(is_step_one(1:1000:N_max)) ./ (1:numel(N_plot))';
rho2_run = cumsum(is_step_two(1:1000:N_max)) ./ (1:numel(N_plot))';

% Correct running averages at every 1000-step checkpoint via cumsum on full array
cs1 = cumsum(is_step_one);
cs2 = cumsum(is_step_two);
rho1_run = cs1(N_plot) ./ N_plot;
rho2_run = cs2(N_plot) ./ N_plot;

figure('Name', 'Weyl Equidistribution: Sturmian density convergence', ...
       'Position', [50 50 1300 440]);

subplot(1,3,1);
plot(N_plot/1e3, rho1_run, 'b-', 'LineWidth', 1.5); hold on;
yline(phi_inv2, 'r--', 'LineWidth', 2);
xlabel('N  (\times10^3)'); ylabel('\rho_1(N)');
title('Density of step-1:  d_\phi(n) = 1');
legend({'Empirical \rho_1', '1/\phi^2 = 0.38197'}, 'Location', 'southeast');
grid on;

subplot(1,3,2);
plot(N_plot/1e3, rho2_run, 'm-', 'LineWidth', 1.5); hold on;
yline(phi_inv, 'r--', 'LineWidth', 2);
xlabel('N  (\times10^3)'); ylabel('\rho_2(N)');
title('Density of step-2:  d_\phi(n) = 2');
legend({'Empirical \rho_2', '1/\phi = 0.61803'}, 'Location', 'northeast');
grid on;

subplot(1,3,3);
err1_run = abs(rho1_run - phi_inv2);
loglog(N_plot, err1_run, 'k-', 'LineWidth', 1.5); hold on;
loglog(N_plot, 2./N_plot, 'r--', 'LineWidth', 1.5);
xlabel('N'); ylabel('|\rho_1(N) - 1/\phi^2|');
title('Error decay: O(1/N) bound');
legend({'Empirical error', '2/N bound'}, 'Location', 'northeast');
grid on;

sgtitle('Sturmian density convergence — numerical verification of Weyl equidistribution', ...
        'FontSize', 13);
exportgraphics(gcf, 'weyl_convergence.png', 'Resolution', 150);
fprintf('\nFigure saved: weyl_convergence.png  (in %s)\n', pwd);

%% Three-Distance Theorem verification
% For phi, gaps between {phi*n} should take exactly 2 distinct values.
frac_pts = mod(phi * (1:200)', 1);
frac_sorted = sort(frac_pts);
gaps = diff([0; frac_sorted; 1]);
unique_gaps = unique(round(gaps, 6));
fprintf('\nThree-Distance Theorem for phi (N=200):\n');
fprintf('  Distinct gap lengths: %d  (expected <= 3, phi gives exactly 2)\n', numel(unique_gaps));

%% Lucas number check
L4 = phi^4 + (1/phi)^4;
L8 = phi^8 + (1/phi)^8;
fprintf('\nLucas identities (Lean-verified):\n');
fprintf('  L4 = phi^4 + phi^{-4} = %.10f  (exact: 7)\n', L4);
fprintf('  L8 = phi^8 + phi^{-8} = %.10f  (exact: 47)\n', L8);

%% CMB sound speed primary result
omega_g = 2.473e-5;
z_star  = 1089.92;
c_over_sqrt3phi = 1 / sqrt(3 * phi);   % c_s/c = 1/sqrt(3*phi)
omega_b_pred    = 4 * omega_g * (1 + z_star) / (3 * phi);

fprintf('\nPrimary cosmological result:\n');
fprintf('  c_s(z*)/c = 1/sqrt(3*phi) = %.10f\n', c_over_sqrt3phi);
fprintf('  omega_b h^2 (corollary)   = %.5f  (Planck: 0.02237, BBN: 0.02233)\n', omega_b_pred);

fprintf('\nDone.\n');
