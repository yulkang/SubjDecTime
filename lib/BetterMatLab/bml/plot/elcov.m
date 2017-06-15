function [el, ev, mx, my] = elcov(x, y, sc)
% Find an ellipse representing covariance.
%
% x, y : vector
% sc   : 'std', 'sem', a scalar, or a function handle of a form @(x, y) for scaling sqrt(cov).
% el   : 100 x (x,y) matrix representing the ellipse.
% ev   : scaled eigenvectors.
% mx,my: mean x and y.
%
% See http://stackoverflow.com/questions/3417028/ellipse-around-the-data-in-matlab


if nargin < 3
    sc = @(x, y) 1;
elseif isnumeric(sc) && isscalar(sc)
    sc = @(x, y) sc;
elseif ischar(sc)
    switch sc
        case 'std'
            sc = @(x, y) 1;
        case 'sem'
            sc = @(x, y) 1/sqrt(length(x));
        otherwise
            error('Unsupported scale!');
    end
else
    assert(isa(sc, 'function_handle'), ...
        'scale must be a string, a scalar numeric, or a function handle!');
end

incl = ~any(isnan([x, y]), 2);

x    = x(incl);
y    = y(incl);

ev  = evec(x, y) * sc(x, y);
mx  = mean(x);
my  = mean(y);

th  = linspace(0, 2*pi, 100)';
el  = [cos(th), sin(th)] * ev';
el  = bsxfun(@plus, mean([x, y]), el);        
end


function ev = evec(x, y)
% Scaled eigenvectors of the covariance matrix.
%
% From http://stackoverflow.com/questions/3417028/ellipse-around-the-data-in-matlab

if isempty(x)
    ev = nan(2,2);
    return;
end

c = cov(x, y);
[ev, d] = eig(c);

[d, ord] = sort(diag(d), 'descend');
ev = ev(:,ord);
ev = bsxfun(@times, ev, sqrt(d(:)'));
end
