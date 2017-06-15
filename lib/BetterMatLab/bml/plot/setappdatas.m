function setappdatas(h, varargin)
% setappdatas(h, var1, var2, ...)
% setappdatas(h, {'var1', val1}, {'var2', val2}, ...)

n = length(varargin);
for ii = 1:n
    if isempty(inputname(ii+1))
        setappdata(h, varargin{ii}{1}, varargin{ii}{2});
    else
        setappdata(h, inputname(ii+1), varargin{ii});
    end
end