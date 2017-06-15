function str = cellfprintf(varargin)
% str = cellfprintf(varargin)
%
% Same as cellprintf, but also prints to prompt.

str = cellprintf(varargin{:});

disp(str);
end