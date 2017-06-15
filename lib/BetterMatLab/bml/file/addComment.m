function [dst success] = addComment(src, comment, verbose)
% ADDCOMMENT    Adds comment to file name, preceded by '_'.
%
% [dst success] = addComment(src, comment, verbose=true)

if nargin < 3, verbose = true; end

[pth file ext] = fileparts(src);
dst = fullfile(pth, [file '_' comment ext]);
    
if exist(src, 'file')    
    if verbose, fprintf('Renamed %s to %s\n\n', src, dst); end
    movefile(src, dst);
    success = true;
else
    if verbose, fprintf('%s doesn''t exist!\n\n', src); end
    success = false;
end
end


