function pth = addgenpath(d,addopt,verbose)
% Add paths recursively
%
% addgenpath(d=pwd,addopt={},verbose = true)
%
% addopt: '-begin' (default), '-end', '-frozen'
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

if nargin < 1 || isempty(d)
    d = pwd;
end
if nargin < 2 || isempty(addopt)
    addopt = {}; 
end

pth = genpath2(d);
addpath(pth, addopt{:});

if nargin < 3 || verbose
    if isempty(pth)
        fprintf('No subdirectories to add to path.\n');
    else
        fprintf('Added subdirectories to path:\n');
        
        npth = nnz(pth == pathsep);
        [pths{1:npth}] = strsep(pth, pathsep);
        fprintf('  %s\n', pths{:});
    end
end
end
