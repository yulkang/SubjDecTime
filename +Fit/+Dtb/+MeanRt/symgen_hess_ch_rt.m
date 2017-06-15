function symgen_hess_ch_rt

%% Folder to export to
pth = '+Fit/+Dtb/+MeanRt';

%% Cost from RT
syms drift k coh coh0 cost_rt real
syms b tnd td_pred rt_pred rt_obs rt_sem_obs positive
assume(coh - coh0 ~= 0);

%% Cost_RT
drift = k * (coh - coh0);
td_pred = b ./ drift .* tanh(b .* drift);
rt_pred = td_pred + tnd;

cost_rt = log(rt_sem_obs) + (rt_obs - rt_pred) .^ 2 ./ (2 .* rt_sem_obs .^ 2);

%% Choice related variables
syms p_pred n_tot n_ch2
syms cost_ch real
assume(n_ch2 >= 0);
assume(n_ch2 <= n_tot);

%% Cost_Ch
% Range-restricted version to prevent over/underflow
min_p_pred = 1e-9; % To prevent over/underflow
p_pred = min_p_pred + (1 - (2 * min_p_pred)) .* ...
    (1 ./ (1 + exp(-2 .* drift .* b)));

% % Original version
% p_pred = 1 ./ (1 + exp(-2 .* drift .* b));

cost_ch = - ( ...
    + gammaln(n_tot + 1) ...
    - gammaln(n_ch2 + 1) - gammaln(n_tot - n_ch2 + 1) ...
    + n_ch2 .* log(p_pred) ...
    + (n_tot - n_ch2) .* log(1 - p_pred));

%% Combined cost
syms cost real

cost = cost_rt + cost_ch;

%% Gradient
th = [b, k, coh0, tnd];
grad = jacobian(cost, th);

%% Hessian
hess = hessian(cost, th);

%% Generate code
file = fullfile(pth, 'cost_ch_rt.m');
if ~exist(file, 'file') ...
        || inputYN_def(sprintf('%s exists! Overwrite', file), false)
    matlabFunction(cost, grad, hess, ...
        'Optimize', false, ...
        'File', file);
end

