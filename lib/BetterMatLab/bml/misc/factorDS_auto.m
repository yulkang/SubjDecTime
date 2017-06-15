function [ds, nPerRep] = factorDS_auto(src, varargin)
% [ds nPerRep] = factorDS_auto(src, ...)
%
% src: Either a cell vector of name-value pair (below) or an equivalent struct.
%
% EXAMPLE:
%
% >> [ds nPerRep] = factorDS_auto(dataset, {'a', 1:3, 'b', [10 20]})
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
% 'ignoreEmpty', false
% 'keepCell', 'auto' % 'never', 'always', 'auto'
%     'auto': gives a matrix 
%             if all entries are nonempty numeric row vectors.
% 
% See also: factorize

S = varargin2S(varargin, {
    'ignoreEmpty', false
    'keepCell', 'auto' % 'never', 'always', 'auto'
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
ds = dataset;

for ii = 1:length(f)
    switch S.keepCell
        case 'always'
            keep_cell = true;
        case 'never'
            keep_cell = false;
        case 'auto'
            keep_cell = any(~cellfun(@isnumeric, r(:,ii))) ...
                     || isempty(r(1,ii)) ...
                     || ~isrow(r(1,ii)) ...
                     || any(~cellfun(@(v) ...
                        isequal(size(v), size(r(1,ii))), r(:,ii)));
    end
    if keep_cell
        ds.(f{ii}) = r(:,ii);
    else
        ds.(f{ii}) = cell2mat(r(:,ii));
    end
end
end