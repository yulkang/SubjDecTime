function res = glmpower_old(b, x, link, varargin)
% res = glmpower_old(b, x, link, varargin)
%
% b     : 1 x nb vector of parameter estimates
% x     : N x nb vector of the independent variables
% res   : n_sim x 1 struct array
% .b
% .dev
% .stats
% .y    : n_dat x 1 array of the simulated dependent variable.
% .b_sim : n_sim x nb array of the simulated independent variables.

S = varargin2S(varargin, {
    'n_dat', size(x, 1)
    'n_sim', 1000
    'seed',  'shuffle'
    'y',     [] % Needed when y_resamp is not 'sim'.
    ... x_resamp, y_resamp: 
    ...     Whether to resample x and y. 
    ...     'no'      : repeat in order.
    ...     'shuffle' : shuffle order then repeat.
    ...     'yes'     : sample with replacement.
    ...     'sim'     : for y only. Simulate assuming that the model is correct.
    ...
    ...     'no' or 'shuffle' preserves balanced design.
    'x_resamp', 'no'    
    'y_resamp', 'yes'
    'covb',  []
    'se',    zeros(size(b)) % If given, uses normrnd to simulate variability in beta.
    });

if nargin < 3 || isempty(link), link = 'logit'; end

rng(S.seed);
nb = length(b);

% Covariance matrix defaults to diagonal.
if isempty(S.covb)
    S.covb = diag(S.se) .^ 2;
end
C = S2C(S);
        
switch link
    case 'logit'
        b_sim = mvnrnd(repmat(b(:)', [S.n_sim, 1]), S.covb);
        
        
        res = arrayfun(@(ii) wrap(@() glmsim_old(b_sim(ii,:)', x, link, C{:}), 1:4), ...
            (1:S.n_sim)', 'UniformOutput', false);
        
        res = reshape([res{:}]', 4, [])';
        res = struct('b', res(:,1), 'dev', res(:,2), 'stats', res(:,3), ...
            'y', res(:,4), 'b_sim', b_sim(:));
        
    otherwise
        error('Not implemented yet!');
end