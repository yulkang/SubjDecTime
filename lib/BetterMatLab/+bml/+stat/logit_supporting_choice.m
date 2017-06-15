function [lev, lev_all, res] = logit_supporting_choice(X, ch, varargin)
% [lev, lev_all, res] = logit_supporting_choice(X, ch, varargin)
%
% X(tr,k)  : independent variables for logistic regression.
% ch(tr,1) : dependent variable. Must be logical.
%
% lev(1,k)       : mean leverage of X(:,k).
% lev_all(tr,k)  : trial-by-trial leverage of X(tr,k)
%
% res : contains above outputs and se_* as fields. Also includes:
% .X_for_ch(tr,k) : If align_sign_to_ch = true,
%                   X with sign flipped in rows with ch = false.
%                   Otherwise, identical to X.
%
% OPTIONS
% -------
% 'column_included', 1:K % Defaults to all columns except the bias.
%                        % Give 0 for the bias term
% 'align_sign_to_ch', true % Flips sign in trials with ch = false
%
% See also: logit_supporting_choice_bootstrp
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'column_included', 1:size(X,2) % Defaults to all columns except the bias.
                                   % Give 0 for the bias term
    'align_sign_to_ch', true % Flips sign in trials with ch = false
    });

% Check X
n_tr = size(X, 1);

% Check ch
assert(isvector(ch) && length(ch) == n_tr);
assert(islogical(ch));

res = glmwrap(X, ch, 'binomial');
b   = res.b;
se  = res.se;

b   = hVec(b(S.column_included + 1));
se_b  = hVec(se(S.column_included + 1));

b0 = b(1);
se_b0 = se(1);

% Estimates
if S.align_sign_to_ch
    X_for_ch = bsxfun(@times, X(:, S.column_included), sign(ch - 0.5));
else
    X_for_ch = X;
end
lev_all = bsxfun(@times, b, X_for_ch);
lev = nanmean(lev_all);

% Total leverage - can be used as offsets in nested models.
% Since constants are 1, b0 can be used as is.
B_all = b0 + lev_all;
B = b0 + lev;

% SE - note that X_for_ch is observed and has no SE.
se_lev_all = sqrt(bsxfun(@times, se_b.^2, X_for_ch.^2));
se_lev = sqrt(nansem(X_for_ch).^2 .* b.^2 ...
            + nanmean(X_for_ch).^2 + se_b.^2); 

se_B_all = sqrt(se_b0.^2 + se_lev_all.^2);
se_B     = sqrt(se_b0.^2 + se_lev.^2);

% Output
res = packStruct( ...
    X_for_ch, ...
    lev, lev_all, ...
    se_lev, se_lev_all, ...
    B, B_all, ...
    se_B, se_B_all);
end