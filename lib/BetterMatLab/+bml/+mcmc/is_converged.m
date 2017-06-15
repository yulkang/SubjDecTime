function [tf, tf_all, rhat] = is_converged(samp, thres)
% Test of convergence given multiple chains (Gelman and Rubin 1992).
%
% [tf, tf_all, rhat] = is_converged(samp, [thres=1.1])
%
% samp : either a matrix or a 3-dimensional array.
% tf : a scalar logical. all(tf_all)
% tf_all(k): true if k-th estimand converged.
% 
% When samp is a matrix (for one scalar estimand):
%     samp(i, j): i-th sample of j-th chain.
%     tf: a scalar. True if converged, i.e., r < thres.
%     rhat: estimate of potential scale reduction 
%           when the chain is run to infinity.
%
% When samp is a 3-dimensional array (for multiple scalar estimands):
%     samp(i, k, j): i-th sample of k-th estimand from j-th chain.
%     tf(1, k): True if converged, i.e., rhat(1, k) < thres.
%     rhat(1, k): rhat for the k-th estimand.

% 2016 Yul Kang. hk2699 at columbia dot edu.

if ~exist('thres', 'var')
    thres = 1.1; % as in Gelman et al., 2004.
end

if ismatrix(samp)
    samp = permute(samp, [1, 3, 2]);
end

n = size(samp, 1);

within = mean(var(samp), 3);
between = n * var(mean(samp), 0, 3);

varhat = (n - 1) ./ n .* within + 1 ./ n .* between;
rhat = sqrt(varhat ./ within);

tf_all = rhat < thres;
tf = all(tf_all);
end