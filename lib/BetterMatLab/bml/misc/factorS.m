function [res, n, factVar, factVal] = factorS(S)
% factorS Combine factors in a struct into a cell array
%
% [res, n, factVar, factVal] = factorS(Struct)
%
% See also: factorize

factVar = fieldnames(S);
factVal = struct2cell(S);
[res n] = factorize(factVal);