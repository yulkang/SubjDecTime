function varargout = getappdatas(h, c)
% varargout = getappdatas(h, c)

n = length(c);
varargout = cell(1,n);
for ii = 1:n
    varargout{ii} = getappdata(h, c{ii});
end