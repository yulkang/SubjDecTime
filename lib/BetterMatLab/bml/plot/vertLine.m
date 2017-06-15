function h = vertLine(varargin)
% VERTLINE  Draw vertical lines without changing ylim.
%
% vertLine(x1, spec1, ...)
%
% x     : a scalar or vector
% spec  : linespec, color, {linespec, color}, 
%         or {linespec, color, 'other_property1', other_property1, ...}.
%
% See also PLOT, YLIM, HORZLINE

yLim = ylim;
hold on;

if length(varargin) == 1
    varargin{2} = '-';
end

h = zeros(1,floor(length(varargin)/2));

for ii = 1:2:length(varargin)
    x = varargin{ii};
    c = varargin(ii+1);
    
    if ischar(c{1})
        plot([x(:)'; x(:)'], yLim' * ones(1,length(x)), c{1});
    elseif iscell(c{1})
        plot([x(:)'; x(:)'], yLim' * ones(1,length(x)), c{1}{1}, 'color', c{1}{2}, c{1}{3:end});
    elseif isnumeric(c{1})
        plot([x(:)'; x(:)'], yLim' * ones(1,length(x)), 'color', c{1});
    else
        error('spec should be linespec, color, or {linespec, color}!');
    end
end

hold off;
ylim(yLim);
end