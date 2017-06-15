function tf = is_git_path(pth)
% True if /.git appears in the path.
tf = ~isempty(strfind(pth, [filesep, '.git']));
end