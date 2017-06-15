function copy_which(src0, dst0)
% Copy which(src) into which(dst)'s folder.
%
% copy_which(src0, dst0)
%
% src0, dst0: char or function_handle
%
% If which(dst) returns empty (when dst is not recognized), uses it as
% the destination folder as is.
%
% If dst is unspecified or empty, uses pwd.
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

% src
if ~ischar(src0), src0 = char(src0); end

src = which(src0);
[~, src_name, src_ext] = fileparts(src);

% dst
if ~exist('dst0', 'var') || isempty(dst0)
    dst_path = pwd;
else
    if ~ischar(dst0), dst0 = char(dst0); end
    
    dst = which(dst0);
    if isempty(dst)
        dst_path = dst;
    else
        dst_path = fileparts(dst);
    end
end

% dst_full
dst_full = fullfile(dst_path, [src_name, src_ext]);

% copy
mkdir2(dst_path);
copyfile(src, dst_full);
fprintf('Copied %s to %s\n', src, dst_full);
