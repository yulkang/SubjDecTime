function varargout = hist3c(X, hist3_opt, imagesc_opt, varargin)
% hist3c  draws hist3 as a imagesc plot.
%
% [n, c, h] = hist3c(X, hist3_opt, imagesc_opt, varargin)
%
% Options       Default values
% 'scale',      1

% Default values
if ~exist('hist3_opt', 'var'),  hist3_opt = {}; end
if ~exist('imagesc_opt', 'var'), imagesc_opt = {}; end

S = varargin2S(varargin, { ...
    'scale', 1, ...
    'to_plot', nargout == 0, ...
    });

% Count
[n, c] = hist3(X, hist3_opt{:});

% Draw
if isempty(c)
    h = nan;
else
    if S.to_plot
        h = imagesc(c{1}, c{2}, n' * S.scale);
        axis xy;
        if ~isempty(imagesc_opt)
            set(h, imagesc_opt{:});
        end
    else
        h = nan;
    end
end

% Output
if nargout >= 1, varargout{1} = n; end
if nargout >= 2, varargout{2} = c; end
if nargout >= 3, varargout{3} = h; end
