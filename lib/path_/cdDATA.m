function pd = cdDATA(pth)
% pd = cdDATA(pth)

if nargout > 0
    pd  = pwd;
end
cd(DIR_([':DATA/', pth]));