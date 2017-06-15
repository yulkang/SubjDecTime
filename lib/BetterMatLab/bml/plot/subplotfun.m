function [h, res] = subplotfun(bat, commonargs, varargin)
% h = subplotfun(bat, commonargs, varargin)
%
% bat:
% {{fun, r, c, nR, nC, args, nam, nout}, {...}, ...}
%
% commonargs: cell array of arguments common to all functions.
% fun: either a function handle or a string. Required. All others are optional.
% r, c, nR, nC: Specifies location and span of subplots. 
%               Use 1,1,1,1 to avoid adding subplots if the function doesn't use plot.
% args: cell array of arguments specific to the function.
% nam: name for the output.
% nout: number of outputs to get from the function.
%
% [res.(nam){1:nout}] = fun(h, commonargs, arg, ...);
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

if nargin < 2, commonargs = {}; end

bat = bat2batmat(bat);

nR = max([bat{:,2}] + [bat{:,4}] - 1);
nC = max([bat{:,3}] + [bat{:,5}] - 1);

h = subplotRCs(nR, nC);
n = size(bat, 1);

res = struct;
for ii = 1:n
    [fun, r, c, nR, nC, args, nam, nout] = dealDef(bat(ii,:), ...
        {[], 1, 1, 1, 1, {}, sprintf('fun%02d', ii)}, true);

    if ischar(fun)
        fun = evalin('caller', ['@', fun]); 
    end
    
    ch = h(r - 1 + (1:nR), c - 1 + (1:nC));
    
    [res.(nam){1:nout}] = fun(ch, commonargs{:}, args{:});
end
