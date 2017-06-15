function symgen_hess_ch_rt_drift0

%% Folder to export to
pth = '+Fit/+Dtb/+MeanRt';

order_taylor = 2;

%% Cost from RT only when drift == 0
syms drift drift_taylor k coh coh0 cost_rt real
syms b tnd td_pred rt_pred rt_obs rt_sem_obs positive
% assume(coh - coh0 == 0);

%% Cost_RT
% % When drift is close to 0 (Daniel's version)
% drift = k * (coh - coh0);
% td_pred = (b^2*(48*b*drift + 9))/(27*b*drift + 9);

% % Taylor expansion
% td_pred = taylor(b ./ drift_taylor .* tanh(b .* drift_taylor), ...
%     drift_taylor, order_taylor);
% drift = k * (coh - coh0);
% td_pred = subs(td_pred, drift_taylor, drift);

% When drift == 0
drift = k * (coh - coh0);
td_pred = b .^ 2;

rt_pred = td_pred + tnd;

cost_rt = log(rt_sem_obs) + (rt_obs - rt_pred) .^ 2 ./ (2 .* rt_sem_obs .^ 2);

%% Choice related variables
syms p_pred n_tot n_ch2
syms cost_ch real
assume(n_ch2 >= 0);
assume(n_ch2 <= n_tot);

%% Cost_Ch
% % When drift is close to 0 (Daniel's version)
% p_pred = b * drift + 1/2;

% % Taylor expansion
% p_pred = taylor(1 ./ (1 + exp(-2 .* drift_taylor .* b)), ...
%     drift_taylor, order_taylor);
% p_pred = subs(p_pred, drift_taylor, drift);

% Usual version
% p_pred = 1 ./ (1 + exp(-2 .* drift .* b));

% Range-restricted version to prevent over/underflow
min_p_pred = 1e-9;
p_pred = min_p_pred + (1 - (2 * min_p_pred)) .* ...
    (1 ./ (1 + exp(-2 .* drift .* b)));

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
file = fullfile(pth, 'cost_ch_rt_drift0.m');
if ~exist(file, 'file') ...
        || inputYN_def(sprintf('%s exists! Overwrite', file), false)
    matlabFunction(cost, grad, hess, ...
        'Optimize', false, ...
        'File', file);
end

