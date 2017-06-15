function res = capCat(varargin)
% CAPCAT Concatenate strings, capitalizing the first letters.
%
% res = capCat(string1, string2, ...)
%
% Example:
% >> capCat('a', 'bb', '23', 'Cde', 'FG', 'hij')
% ans =
% ABb23CdeFGHij

res = '';
for ii = 1:length(varargin)
    if 'a' <= varargin{ii}(1) && varargin{ii}(1) <= 'z'
        varargin{ii}(1) = upper(varargin{ii}(1));
    end
    res = [res, varargin{ii}];
end
end