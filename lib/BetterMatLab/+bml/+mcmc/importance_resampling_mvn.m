function samp = importance_resampling_mvn(mu, sig, log_q, varargin)
% Importance resampling with multivariate normal approximation
% as in Gelman et al., 2004, Chap. 12.2.
%
% samp = importance_resampling_mvn(mu, sig, log_q, ['opt1', op1, ...])
%
% INPUT
% -----
% mu, sig: parameters of the multivariate normal approximation to the
%          target distribution.
% log_q(th): unnormalized log target probability density.
%
% OPTIONS
% -------
% n_initial_sample: defaults to 2000
% n_final_sample: defaults to 10
% constr: {lb, ub, A, b, Aeq, beq, nonlcon} or fitflow.VectorConstraints
%    as used in FMINCON, FMINCON_COND and IS_CONSTR_MET. Leave empty to omit.
%
% OUTPUT
% ------
% samp(i,j): i-th sample of the j-th estimand.
%
% See also: fmincon, fmincon_cond, is_constr_met, fitflow.VectorConstraints

% 2016 Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'n_initial_sample', 2000
    'n_final_sample', 10
    'constr', {}
    });

% Initial sample
tf_incl = false(S.n_initial_sample, 1);
th = mvnrnd(mu, sig, S.n_initial_sample);

% Keep samples within constraints only.
if ~isempty(S.constr)
    if isa(S.constr, 'fitflow.VectorConstraints')
        Constr = S.constr;
    else
        Constr = fitflow.VectorConstraints(S.constr);
    end
    
    is_met = false(S.n_initial_sample, 1);
    while any(~is_met)
        for ii = find(~is_met(:)')
            is_met(ii) = Constr.is_constr_met(th(ii,:));
        end
        th(~is_met,:) = mvnrnd(mu, sig, nnz(~is_met));
    end
end

% Compute weights
log_g = bml.stat.logmvnpdf(th, mu, sig);
log_w = zeros(S.n_initial_sample, 1);
for ii = 1:S.n_initial_sample
    log_w(ii) = log_q(th(ii,:)) - log_g(ii);
end

% Resample without replacement
for ii = 1:S.n_final_sample
    log_w_left = log_w(~tf_incl);
    w = max(exp(log_w_left - max(log_w_left)), eps); % Prevent underflow.

    ix_left = find(~tf_incl);
    n_left = length(ix_left);
    ix_within_left = randsample(n_left, 1, true, w);
    tf_incl(ix_left(ix_within_left)) = true;
end

% Output
samp = th(tf_incl, :);