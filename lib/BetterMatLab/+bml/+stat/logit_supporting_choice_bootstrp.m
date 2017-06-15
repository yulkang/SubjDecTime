function [lev, ci, lev_samp] = logit_supporting_choice_bootstrp(X, ch, varargin)
% [lev, ci, lev_samp] = logit_supporting_choice_bootstrp(X, ch, varargin)
%
% lev(1,k) : leverage of X(:,k).
% ci(1,k)  : 15.87-th percentile (equivalent to one SE below estimate).
% ci(2,k)  : 84.13-th percentile (equivalent to one SE above estimate).
% lev_samp(s,k) : leverage of X(:,k) from s-th bootstrap sample.
%
% OPTIONS
% -------
% 'column_included', 1:K % Defaults to all columns except the bias.
%                        % Give 0 for the bias term
% 'n_samp', 1000 % # bootstrap samples.
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'column_included', 1:size(X,2) % Defaults to all columns except the bias.
                                   % Give 0 for the bias term
    'n_samp', 1000 % # bootstrap samples.
    });

% Check X
n_tr = size(X, 1);

% Check ch
assert(isvector(ch) && length(ch) == n_tr);
assert(islogical(ch));

% Bootstrap
lev_samp = bootstrp(S.n_samp, @bootfun, X, ch);

lev = median(lev_samp);
ci = prctile(lev_samp, [15.87, 84.13]); % similar to 1 Stdev.

% % Old algorithm: wrong, because beta is not independent of X.
% for i_param = 1:n_param
%     cx = X(:, i_param) .* sign(ch - 0.5);
%     mean_cx = nanmean(cx);
% 
%     lev(i_param) = mean_cx * b0(i_param);
% 
%     se(i_param) = sqrt(bml.math.var_prod_rv_summary( ...
%         [mean_cx, lev(i_param)], [nanvar(cx), se0(i_param).^2]));
% end

function lev = bootfun(X, ch)
    b = glmfit(X, ch, 'binomial');
    b = hVec(b(S.column_included + 1));
    
    X_for_ch = bsxfun(@times, X(:, S.column_included), sign(ch - 0.5));
    lev = bsxfun(@times, b, X_for_ch);
    
    lev = mean(lev);
end
end