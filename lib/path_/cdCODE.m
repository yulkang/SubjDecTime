function pd = cdCODE(pth)
% pd = cdCODE(pth)

if nargout > 0
    pd  = pwd;
end
if nargin == 0, pth = ''; end
cd(DIR_([':CODE/', pth]));