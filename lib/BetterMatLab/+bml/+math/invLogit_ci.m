function [est_p, ci_p] = invLogit_ci(est_logit, se_logit, mode)
% [est_p, ci_p] = invLogit_ci(est_logit, se_logit, mode='rel'|'abs')
if ~exist('mode', 'var')
    mode = 'rel';
end

est_p = invLogit(est_logit);
ci_p = [invLogit(est_logit - se_logit), invLogit(est_logit + se_logit)];

switch mode
    case 'rel'
        ci_p = ci_p - est_p;
end
