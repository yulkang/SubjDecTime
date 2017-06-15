function br = get_branch(in_dir)
% get_branch  Returns Git branch name.
%
% See also logging, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

import Ext.git;

if nargin >= 1
    pd = cd(in_dir);
else
    pd = pwd;
end

out = git('status');

if ismember(1, strmatch('On branch ', out))
    C = textscan(out, 'On branch %s');
    br = C{1}{1};
else
    cd(pd);
    error('Unexpected output from git status!');
end
cd(pd);