function copyfile2(src, dst, verbose, varargin)
% Same as copyfile except this creates destination folder if absent
%
% copyfile2(src, dst, verbose = false, ...)

if nargin < 3, verbose = false; end

% try
%     copyfile(src, dst, varargin{:});
%     if verbose, fprintf('Copied %s to %s\n', src, dst); end
% catch 
    dst_dir = fileparts(dst);
    succ = mkdir2(dst_dir);
    if succ && verbose, fprintf('Made a folder: %s\n', dst_dir); end
        
    copyfile(src, dst, varargin{:});
    if verbose, fprintf('Copied %s to %s\n', src, dst); end
% end