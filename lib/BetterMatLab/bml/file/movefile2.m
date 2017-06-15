function movefile2(src, dst, verbose)
% Same as movefile except this creates destination folder if absent
%
% movefile2(src, dst, verbose = false)

if nargin < 3, verbose = false; end

% try
%     movefile(src, dst);
%     if verbose, fprintf('Moved %s to %s\n', src, dst); end
% catch 
    dst_dir = fileparts(dst);
    succ = mkdir2(dst_dir);
    if succ && verbose, fprintf('Made a folder: %s\n', dst_dir); end
        
    movefile(src, dst);
    if verbose, fprintf('Moved %s to %s\n', src, dst); end
% end