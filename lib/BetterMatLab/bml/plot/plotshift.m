function h = plotshift(x, y, opt, varargin)
% h = plotshift(x, y, opt, varargin)
%
% OPTIONS:
% 'x_shift',  0
% 'y_shift',  0.1
% 'scale',    'rel'

if nargin < 3, opt = {}; end
S = varargin2S(opt, {
    'x_shift',  0
    'y_shift',  0.1
    'scale',    'rel'
    });

switch S.scale
    case 'abs'
        x_shift = S.x_shift;
        y_shift = S.y_shift;
    case 'rel'
        x_shift = S.x_shift * (max(x(:)) - min(x(:)));
        y_shift = S.y_shift * (max(y(:)) - min(y(:)));
end

if isvector(x), x = x(:); end
if isvector(y), y = y(:); end

n   = max(size(x,2), size(y,2));
fac = 0:(n-1);

x = bsxfun(@plus, x, x_shift * fac);
y = bsxfun(@plus, y, y_shift * fac);

if nargout > 0
    h = plot(x, y, varargin{:});
end

