function tf = is_versioned(pth)
% is_versioned  Return if the (current) folder is under Git version control.
%
% tf = is_versioned([pth = cd])
%
% See also logging, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

import Ext.git

if ~exist('pth', 'var')
    pd = cd;
else
    pd = cd(pth);
end

allOutput = git('status');
tf = ~any(strfind(allOutput, 'fatal: Not a git repository') == 1);

cd(pd);
end