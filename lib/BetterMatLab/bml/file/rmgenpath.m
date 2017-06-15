function pth = rmgenpath(d,verbose)
% Remove paths recursively
%
% pth = rmgenpath(d=pwd,verbose=true)
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

if nargin < 1 || isempty(d)
    d = pwd;
elseif exist(fullfile(pwd, d), 'dir')
    d = fullfile(pwd, d);
end

pth = genpath2(d);
rmpath(pth);

if nargin < 2 || verbose
    if isempty(pth)
        fprintf('No subdirectories to remove from path.\n');
    else
        fprintf('Removed subdirectories from path:\n');
        
        npth = nnz(pth == pathsep);
        [pths{1:npth}] = strsep(pth, pathsep);
        fprintf('  %s\n', pths{:});
    end
end
