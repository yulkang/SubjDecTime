function res = intNonuni(x, y, op)
% INTNONUNI   Integral with nonuniform intervals of integrand.
%
% res = intNonuni(x, y, [op='mean'])
%
% op
%   right   : take right value in each interval as height
%   left    : take left value in each interval as height
%   mean    : mean of the above two.

if ~exist('op', 'var'), op = 'mean'; end

switch op
    case 'left'
        res = sum(diff(x) .* y(2:end));
    case 'right'
        res = sum(diff(x) .* y(1:(end-1)));
    case 'mean'
        res = (intNonuni(x,y,'left') + intNonuni(x,y,'right')) / 2;
end
        