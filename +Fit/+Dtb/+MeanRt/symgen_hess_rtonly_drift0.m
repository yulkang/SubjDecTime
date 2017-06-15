function symgen_hess_rtonly_drift0

%% Folder to export to
pth = '+Fit/+Dtb/+MeanRt';

%% Cost from RT only when drift == 0
syms drift k coh coh0 cost_rt real
syms b tnd td_pred rt_pred rt_obs rt_sem_obs positive
assume(coh - coh0 == 0);

%% Cost_RT
% drift = k * (coh - coh0);
td_pred = b .^ 2;
rt_pred = td_pred + tnd;
cost_rt = log(rt_sem_obs) ...
    + (rt_obs - rt_pred) .^ 2 ./ (2 .* rt_sem_obs .^ 2);

%% Combined cost
syms cost real

cost = cost_rt;

%% Gradient
th = [b, k, coh0, tnd];
grad = jacobian(cost, th);

%% Hessian
hess = hessian(cost, th);

%% Generate code
file = fullfile(pth, 'cost_rtonly_drift0.m');
if ~exist(file, 'file') ...
        || inputYN_def(sprintf('%s exists! Overwrite', file), false)
    matlabFunction(cost, grad, hess, ...
        'Optimize', false, ...
        'File', file);
end

