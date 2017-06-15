function varargout = hist3D(varargin)
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
[varargout{1:nargout}] = hist3D(varargin{:});