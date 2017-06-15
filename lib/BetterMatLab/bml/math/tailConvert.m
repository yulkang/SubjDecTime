function p = tailConvert(p, op, varargin)
% p = tailConvert(p, op='2to1', varargin)
%
% '2to1'
% : Assume the test is stat > 0 and the sign of p is the same as stat.

if nargin < 2
    op = '2to1'; % needs sign
end

switch op
    case '2to1' % Assume the test is stat > 0 and the sign of p is the same as stat.
        if p > 0
            p = p / 2;
        else
            p = 1 - p / 2;
        end
    case '1to2'
        error('Not implemented yet!');
end