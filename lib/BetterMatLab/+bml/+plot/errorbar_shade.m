function [hLine, hPatch] = errorbar_shade(x, y, e, varargin)
% [hLine, hPatch] = errorbar_shade(x, y, e, ...)
% [hLine, hPatch] = errorbar_shade(x, y, le, ue, ...)
%
% x : always a vector.
% y : vector or matrix. If matrix, one column per curve.
% e, le, ue : vector or matrix.
%
% 'color', 'k' % Patch's color.
% 'alpha', 0.5
% 'plot_args', {} % To color the line differently, set 'Color' here.
% 'patch_args', {}
%
% See also: plot, patch, errorbar
%
% 2013-2015 (c) Yul Kang. hk2699 at columbia dot edu.

%% Disambiguate e or le & ue
if ~isempty(varargin)
    if isnumeric(varargin{1})
        if isempty(varargin{1})
            le = e;
            ue = e;
        else
            le = e;
            ue = varargin{1};
        end
        varargin = varargin(2:end);
    else
        le = e;
        ue = e;
    end
else
    le = e;
    ue = e;
end

%% Specs
S = varargin2S(varargin, {
    'color', 'k' % Patch's color.
    'alpha', 0.25
    'plot_args', {} % To color the line differently, set 'Color' here.
    'patch_args', {}
    });
S.plot_args = bml.plot.varargin2plot(S.plot_args, {
    'Color', S.color
    'LineWidth', 2
    });
S.patch_args = varargin2C(S.patch_args, {
    'EdgeColor', 'none'
    'FaceColor', S.color
    'FaceAlpha', S.alpha
    });

%% Check and expand x, y, e
assert(isvector(x));
x = x(:);

if isvector(y)
    assert(isvector(le));
    assert(isvector(ue));
    y = y(:);
    le = le(:);
    ue = ue(:);
    
elseif ismatrix(y)
    assert(size(y,1) == size(x,1));
    assert(isequal(size(y), size(le)));
    assert(isequal(size(y), size(ue)));
    
    n = size(y,2);
    x = repmat(x(:), [1, n]);
    
    hLine = gobjects(1, n);
    hPatch = gobjects(1, n);
    for ii = 1:n        
        [hLine(ii), hPatch(ii)] = bml.plot.errorbar_shade( ...
            x(:,ii), y(:,ii), le(:, ii), ue(:, ii), varargin{:});
        hold on;
    end
    return;
else
    error('y must be a vector or a matrix!');
end

%% Filter out NaN
anyNan = any(isnan([x, y, le, ue]), 2);

x = x(~anyNan);
y = y(~anyNan);
le = le(~anyNan);
ue = ue(~anyNan);

%% Draw patch
x2 = [x; flipud(x)];
y2 = [y; flipud(y)];
e2 = [-le; flipud(ue)];

hPatch = patch(x2, y2 + e2, S.color, S.patch_args{:}); 
hold on;

%% Draw line
hLine = plot(x, y, S.plot_args{:}); 
hold off;
end