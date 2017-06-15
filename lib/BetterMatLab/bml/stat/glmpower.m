function [po, res] = glmpower(b, X, link, varargin)
% [po, res] = glmpower(b, x, link, varargin)
%
% b     : 1 x nb vector of parameter estimates
% x     : N x nb vector of the independent variables
%
% po(coef): proportion of rejected null hypotheses
%
% res   : n_sim x 1 struct array
% .b
% .dev
% .stats
% .y    : n_dat x 1 array of the simulated dependent variable.
% .b_sim : n_sim x nb array of the simulated independent variables.
%
% For the old version, see glmpower_old.
%
% See also: glmsim, logistic_effect_size, glmpower_old

% 2017 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'alpha', 0.05
    'n_sim', 1e3
    });

if nargin < 3 || isempty(link), link = 'logit'; end
assert(strcmp(link, 'logit'), ...
    'Link functions other than logit are not supported yet!');

[~,~,~,~,p_sim,res] = bml.stat.glmsim(b, X, link, ...
    'nSim', S.n_sim);

po = mean(p_sim' < S.alpha);
end