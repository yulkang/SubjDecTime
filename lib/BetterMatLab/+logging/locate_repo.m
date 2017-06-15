function repo_dir = locate_repo(in_dir)
% locate_repo  Locate the repo that in_dir belongs to.
%
% repo_dir = locate_repo(in_dir)
%
% See also logging, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

if (nargin >= 1) && ~isempty(in_dir)
    if exist(in_dir, 'dir')
        new_dir = in_dir;
    elseif exist(in_dir, 'file')
        new_dir = fileparts(in_dir);
    else
        new_dir = fileparts(which(in_dir));
    end
    
    prev_dir = cd(new_dir);
else
    prev_dir = pwd;
end

if ~logging.is_versioned
    repo_dir = '';    
else
    % Find the first dir with '.git' whle cd-ing up.
    pd = '';
    while ~exist('./.git', 'dir') && ~strcmp(pd, pwd)
        pd = cd('..');
    end
    
    repo_dir = pwd;
end
cd(prev_dir);
end