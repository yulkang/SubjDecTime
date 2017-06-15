function varargout = strsep2(s, sep)
% Similar to strsep but sep is one (multi)character pattern.
%
% varargout = strsep2(s, sep)
%
% EXAMPLE:
% >> [a,b,c] = strsep2('1+++b++3', '++')
% a = 1
% b = +b
% c = 3
% 
% >> [a,b,c] = strsep2('1++++b++3', '++')
% a = 1
% b =   Empty string: 1-by-0
% c = b
%
% See also: strsep

len = length(sep);
s   = [sep, s, sep];

ix   = strfind(s, sep);
n_ix = length(ix) - 1;

% Remove overlapping separaters
for ii = 2:n_ix
    if ix(ii) < ix(ii-1) + len
        ix(ii) = nan;
    end
end

ix   = ix(~isnan(ix));
n_ix = length(ix) - 1;

% Use the remainder
varargout = cell(1, n_ix);
for ii = 1:n_ix
    varargout{ii} = s((ix(ii) + len):(ix(ii+1) - 1));
end