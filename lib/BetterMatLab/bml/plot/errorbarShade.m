function [hLine, hPatch] = errorbarShade(x, y, e, spec, alpha, specLine, specPatch, varargin)
% [hLine, hPatch] = errorbarShade(x, y, e, spec, [alpha = 0.5], specLine, specPatch, ...)
%
% x : always a vector.
% y : vector or matrix. If matrix, one column per curve.
% e : vector or matrix. If matrix, one or two columns per curve (le, ue)
%
% spec      : either a string (like 'b.-'), a ColorSpec (like [0 0.5 0.5]), 
%             or a matrix of rgb triplets on each row.
% specLine  : {propertyName1, propertyValue1, ...}
%             as in plot(,...).
% specPatch : {propertyName1, propertyValue1, ...}
%             as in patch(,...).
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

if ~exist('alpha', 'var') || isempty(alpha), alpha = 0.25; end
if ~exist('spec', 'var') || isempty(spec), spec  = 'k-'; end
if ~exist('specLine', 'var') || isempty(specLine), specLine = {}; end
if ~exist('specPatch', 'var') || isempty(specPatch), specPatch = {}; end

S = varargin2S(varargin, {
    'ax', gca
    });

specLine = varargin2C(specLine, {
    'LineWidth', 2
    });

x = x(:);

if isvector(y)
    y = y(:);
    if isvector(e)
        e = e(:);
    end
elseif ismatrix(y)
    
    assert(size(y,1) == size(x,1));
    assert(size(y,1) == size(e,1));
    assert((size(e,2) == size(y,2)) || (size(e,2) == size(y,2) * 2));
    
    n = size(y,2);
    if isvector(x)
        x = repmat(x(:), [1, n]);
    end
    
    hLine = cell(1,n);
    hPatch = cell(1,n);
    
    if nargin < 4
        spec = hsv2(n);
    end
    
    for ii = 1:n
        if size(e, 2) == size(y,2) * 2
            ce = e(:, ii * 2 + [-1, 0]);
        else
            ce = e(:, ii);
        end
        
        C = S2C(S);
        [hLine{ii}, hPatch{ii}] = errorbarShade(x(:,ii), y(:,ii), ce, ...
            spec(ii,:), alpha, specLine, specPatch, C{:});
    end
    return;
else
    error('Provide a vector or a matrix!');
end
    
anyNan = any(isnan([x, y, e]), 2);

x = x(~anyNan);
y = y(~anyNan);
e = e(~anyNan, :);

if ischar(spec)
    specColor = spec(spec~='.' & spec~='-' & spec~=':');
else
    specColor = spec;
end

x2 = [x; flipud(x)];
y2 = [y; flipud(y)];

if isvector(e)
    e2 = [e; -flipud(e)];
else
    e2 = [e(:,1); flipud(e(:,2))];
end

if ~isempty(specColor)
    hPatch = patch(S.ax, x2, y2 + e2, specColor, ...
                       'EdgeColor', 'none', ...
                       'FaceColor', specColor, 'FaceAlpha', alpha, specPatch{:}); 
else
    hPatch = patch(S.ax, x2, y2 + e2, '-', ...
                       'EdgeColor', 'none', ...
                       'FaceAlpha', alpha, specPatch{:}); 
end

hold(S.ax, 'on');
for eFac = 0 % -1:1
    if ischar(spec)
        C = [{spec}, specLine{:}];
    else
        C = [{'-'}, varargin2C(specLine, {'Color', spec})];
    end
    for jj = 1:size(e, 2)
        hLine = plot(S.ax, x, y + e(:,jj) * eFac, C{:}); 
        hold(S.ax, 'on');
    end
end
hold(S.ax, 'off');
end