function res = data_pth(src, subpth, full_pkg_name)
% res = data_pth(src, subpth, full_pkg_name)
%
% EXAMPLE: Ext.finder(logging.data_pth(cd)) shows Data folder corresponding to pwd.

if nargin < 1, src = cd; end
if nargin < 2, subpth = {}; end
if nargin < 3, full_pkg_name = false; end

src_full = which(src);
if isempty(src_full), src_full = src; end

[pth, nam] = fileparts(src_full);

if isempty(strfind(src_full, [filesep, '+']))
    % Non-package
    src_dir = fullfile_fast(pth, nam);
else
    % Package folder name
    if full_pkg_name
        src_dir = fullfile_fast(pth, src);
    else
        % Package folder name
        src_dir = src_full;
    end
end
    
res_dir = strrep(src_dir, DIR_('CODE'), DIR_('DATA'));
res = fullfile_fast(res_dir, subpth{:});
