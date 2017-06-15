function [ds, nPerRep] = factorDS(ds, src, varargin)
% [ds nPerRep] = factorDS(ds, src, ...)
%
% ds:  Dataset to modify. Give dataset, the constructor, to create a new one.
% src: Either a cell vector of name-value pair (below) or an equivalent struct.
%
% EXAMPLE:
%
% >> [ds nPerRep] = factorDS(dataset, {'a', 1:3, 'b', [10 20]})
% ds = 
%     a    b 
%     1    10
%     1    20
%     2    10
%     2    20
%     3    10
%     3    20
% nPerRep =
%     6
%
% See also: factorize

S = varargin2S(varargin, {
    'ignoreEmpty', false
    'keepCell', false
    });

if isstruct(src)
    f = fieldnames(src);
    v = struct2cell(src);
elseif iscell(src)
    f = src(1:2:end);
    v = src(2:2:end);
end

if S.ignoreEmpty
    toIgnore = cellfun(@isempty, v);
    f = f(~toIgnore);
    v = v(~toIgnore);
end

[r, nPerRep] = factorize(v);

for ii = 1:length(f)
    if S.keepCell
        ds.(f{ii}) = r(:,ii);
    else
        ds.(f{ii}) = cell2mat(r(:,ii));
    end
end
end