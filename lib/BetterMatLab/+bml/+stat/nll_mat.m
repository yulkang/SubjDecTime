function [nll, nll_sep] = nll_mat(pred_mat, obs_mat, varargin)
% pred_mat(bin, cond)
% obs_mat(bin, cond)
%
% nll = sum(nll_sep)
% nll_sep(cond)

% Yul Kang 2016. hk2699 at columbia dot edu.

assert(isequal(size(pred_mat), size(obs_mat)));
n_cond = size(pred_mat, 2);
nll_sep = zeros(1, n_cond);
for cond = 1:n_cond
    nll_sep(cond) = bml.stat.nll_bin(pred_mat(:,cond), obs_mat(:,cond), ...
        varargin{:});
end
nll = sum(nll_sep);
