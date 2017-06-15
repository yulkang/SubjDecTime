function pd = cdWhich(fun)
% CD to the function's directory.
%
% Example:
% >> which linspace
% /Applications/MATLAB_R2012a.app/toolbox/matlab/elmat/linspace.m
% >> cdWhich linspace
% >> cd
% /Applications/MATLAB_R2012a.app/toolbox/matlab/elmat

try
    pwd = cd(fileparts(which(fun)));
    
catch err_cd
    warning(err_msg(err_cd));
end
    
if nargout > 0
    pd = pwd;
end
