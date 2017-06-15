function y_lim_out = ylim_robust(y, e, varargin)
% YLIM_ROBUST - Set adequate ylim given data after disregarding outliers.
%
% ylim_robust(y, e, ['q', 0.2, 'f', 1, 'def_lim', [-1 1], 'ignore_zero', true]);
%
% y   : Data.
% e   : Error. Give 0 to omit.
% q   : Relative range to include. Give an increasing 2-vector within [0 1].
%       Give a scalar to specify [q 1-q].
% f   : How bigger the y_lim should be compared to the given quantile.
% a   : Absolute range. Omit to include [-inf inf].
% ignore_zero : Whether to ignore zero data.
% def_lim : Default range when no y is finite or nonzero.
%
% y_lim = ylim_robust(...)
%
% : Returns adequate ylim without actually setting ylim.
%
% See also: ylim
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

q = 0.2;
f = 2;
a = [-inf inf];
def_lim = [-1 1];
ignore_zero = true;
fix_min = nan;
fix_max = nan;

varargin2V(varargin);

% Input preprocessing
if ~exist('y', 'var')
    y = bml.plot.get_all_xy;
    y = y(:,2);
end

y = y(:)';

if exist('e', 'var')
    y = [y + e(:)', y - e(:)'];
end
if isscalar(q)
    if q < 0.5
        q = [q, 1-q];
    else
        error('A scalar q should be smaller than 0.5!');
    end
elseif length(q) ~= 2 || q(1) >= q(2) || q(1) < 0 || q(2) > 1
    error('q should be an increasing 2-vector with elements between 0 and 1!');
end
if length(def_lim) ~= 2 || def_lim(1) >= def_lim(2)
    error('def_lim should be an increasing 2-vector!');
end

% Ignore non-finite data
if ignore_zero
    nz   = isfinite(y) & (y~=0);
else
    nz   = isfinite(y);
end

% Ignore outliers outside absolute range, a.
in_a = (y >= a(1)) & (y <= a(2));

% Ignore outliers outside relative range, q.
filt = nz & in_a;

if any(filt)
    y_sort   = sort(y(filt));
    n        = length(y_sort);
    
    y_lim(1) = y_sort(max(1, ceil(n * q(1))));
    y_lim(2) = y_sort(min(n, ceil(n * q(2))));
    
    w        = y_lim(2) - y_lim(1);
    y_lim(1) = y_lim(1) - w/2 * f;
    y_lim(2) = y_lim(2) + w/2 * f;
    
    if y_lim(1) == y_lim(2)
        y_lim = y_lim - diff(def_lim) * [-f, f];
        
    elseif y_lim(1) > y_lim(2)
        y_lim = [y_lim(2), y_lim(1)];
    end
else
    y_lim    = def_lim;
end

if ~isnan(fix_min), y_lim(1) = fix_min; end
if ~isnan(fix_max), y_lim(2) = fix_max; end    

if nargout >= 1
    y_lim_out = y_lim;
else
    ylim(y_lim);
end
end
