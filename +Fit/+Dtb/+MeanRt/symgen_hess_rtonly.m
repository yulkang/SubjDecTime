function f = symgen_hess_rtonly

%% Folder to export to
pth = '+Fit/+Dtb/+MeanRt';

%% Cost from RT only
syms drift k coh coh0 cost real
syms b tnd td_pred rt_pred rt_obs rt_sem_obs positive
assume(coh - coh0 ~= 0);

%% Cost
drift = k * (coh - coh0);
td_pred = b ./ drift .* tanh(b .* drift);
rt_pred = td_pred + tnd;
cost = log(rt_sem_obs) + (rt_obs - rt_pred) .^ 2 ./ (2 .* rt_sem_obs .^ 2);

%% Gradient
th = [b, k, coh0, tnd];
grad = jacobian(cost, th);

%% Hessian
hess = hessian(cost, th);

%% Generate code
file = fullfile(pth, 'cost_rtonly.m');
if ~exist(file, 'file') ...
        || inputYN_def(sprintf('%s exists! Overwrite', file), false)
    f = matlabFunction(cost, grad, hess, ...
        'Optimize', false, ...
        'File', file);
else
    f = matlabFunction(cost, grad, hess, ...
        'Optimize', false);    
end
end