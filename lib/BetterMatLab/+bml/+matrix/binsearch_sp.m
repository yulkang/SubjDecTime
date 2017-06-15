function [r, c, cv] = binsearch_sp(sp, q)
% Find the 1st element no smaller than each q(k) in a sparse matrix.
% Useful for sampling from a 2D cumulative distribution sp with 
% q ~ U(0, 1).
%
%   [r, c, cv] = binsearch_sp(sp, q)
%
% is an efficient equivalent to 
%
%   [r, c, cv] = arrayfun(@(cq) find(sp >= cq, 1, 'first'), q)
%
% The following must hold:
%   min(sp(:)) < min(r(:)) and max(sp(:)) > max(r(:)) 
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

assert(iscolumn(q));

[r0, c0, v] = find(sp);

len = length(v);
n = numel(q);

lb = ones(n, 1);
ix = zeros(n, 1) + ceil(len / 2);
ub = zeros(n, 1) + len;

incl = lb < ub;

while any(incl)
    cv = v(ix);
    
    to_inc = cv < q;
    to_dec = cv > q;
    
    lb(to_inc) = min(max(ix(to_inc), lb(to_inc) + 1), len);
    ub(to_dec) = max(min(ix(to_dec), ub(to_dec) - 1), 1);
    ix = ceil((lb + ub) ./ 2);
    
    incl = (lb < ub) & (v(ix) ~= q);
    
%     cv = v(ix); % DEBUG
%     disp(table(q, cv, lb, ix, ub, to_inc, to_dec, incl)); % DEBUG
end

% Guarantee cv >= q
lt_q = v(ix) < q;
ix(lt_q) = ix(lt_q) + 1;

cv = v(ix); % DEBUG

r = r0(ix);
c = c0(ix);