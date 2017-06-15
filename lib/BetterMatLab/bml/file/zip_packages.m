function zip_packages(filesToZip, zipFile, verbose, root_dir)
% zip_packages(filesToZip, zipFile, [verbose=true], [respect_nonpackage_dir=true])
%
% See also: dep2zip, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

if ~exist('verbose', 'var'), verbose = true; end
if ~exist('root_dir', 'var'), root_dir = ''; end

need_new_dir = true;
dir_num      = 0;

while need_new_dir
    dir_num = dir_num + 1;
    tmp_dir = fullfile(fileparts(zipFile), sprintf('zip_rel_%d', dir_num));
    
    need_new_dir = exist(tmp_dir, 'dir');
end

mkdir(tmp_dir);

[~, filesToZip] = copyPackageFiles(filesToZip, tmp_dir, root_dir);

% May remove copying when ~anyPackage in copyPackageFiles to save time.

zip(zipFile, '*', tmp_dir);
rmdir(tmp_dir, 's');

if verbose
    fprintf('Zipped %d files to %s.\n', length(filesToZip), zipFile);
end
end


function [anyPackage, filesToZip] = copyPackageFiles(filesToZip, tmp_dir, root_dir)
if ~exist('root_dir', 'var'), root_dir = ''; end
anyPackage = false;

n = length(filesToZip);
for ii = 1:n
    [pth nam ext] = fileparts(filesToZip{ii});
    
    if ~isempty(root_dir)
        cLoc = strfind(pth, root_dir) + length(root_dir) - 1;
    else
        if isunix
            cLoc = min([strfind(pth, '/+'), strfind(pth, '/@')]);
        else
            cLoc = min(cLoc, [strfind(pth, '\+'), strfind(pth, '\@')]);
        end
    end
    cLoc = min(cLoc);
    
    if ~isempty(cLoc)
        anyPackage = true;
        newLoc = fullfile(pth((cLoc+1):end), [nam ext]);        
    else
        newLoc = fullfile([nam ext]);
    end
    
    newPth = fileparts(newLoc);
    if ~isempty(newPth) && ~exist(fullfile(tmp_dir, newPth), 'dir')
        mkdir(fullfile(tmp_dir, newPth));
    end
    copyfile(filesToZip{ii}, fullfile(tmp_dir, newLoc));
    filesToZip{ii} = newLoc;
end
end
