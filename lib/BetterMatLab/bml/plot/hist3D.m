function varargout = hist3D(X, hist3_opt, imagesc_opt, varargin)
% hist3D  draws hist3 as a imagesc plot for each unique value of each column in X.
%
% [n, c, h] = hist3D(X, hist3_opt, imagesc_opt, ['opt1', opt1, ...])
%
% X(:,1) is considered as x, and X(:,2) as y.
% 
% Options     Default values  Explanation
% 'fmt_x',    '%1.0f', ... % Format for XTickLabel
% 'fmt_y',    '%1.0f', ... % Format for YTickLabel
% 'pool_rep', true, ...    % Whether to pool x and y values.

% Default values
if ~exist('hist3_opt', 'var'),  hist3_opt = {}; end
if ~exist('imagesc_opt', 'var'), imagesc_opt = {}; end

S = varargin2S(varargin, { ...
    'fmt_x',    '%1.0f', ... % Format for XTickLabel
    'fmt_y',    '%1.0f', ... % Format for YTickLabel
    'pool_rep', false, ...    % Whether to pool x and y values.
    'to_plot',  nargout == 0, ...
    });

% Pool repertoire of x and y if requested.
if S.pool_rep
    rep_args = {repmat({unique(X(:))}, [1 2])};
else
    rep_args = {};
end

% Discretize each column of X
[D, rep, n_rep] = discretize(X, 'unique_col', rep_args{:});

% Edges should be repertoire of values in each column.
% When n_rep(1) == 1, hist3's bug causes error. So use minimum of 2 bins.
hist3_opt = [{'Edges', {1:max(n_rep(1),2), 1:max(n_rep(2),2)}}, hist3_opt];

% Feed into hist3c
[varargout{1:nargout}] = hist3c(D, hist3_opt, imagesc_opt, varargin{:});

% Add X/YTickLabel
if S.to_plot
    set(gca, ...
        'XTick',        (1:n_rep(1)) + 0.5, ...
        'XTickLabel',   csprintf(S.fmt_x, rep{1}), ...
        'YTick',        (1:n_rep(2)) + 0.5, ...
        'YTickLabel',   csprintf(S.fmt_y, rep{2}), ...
        'TickLength',   [0 0] ...
        );
end
end