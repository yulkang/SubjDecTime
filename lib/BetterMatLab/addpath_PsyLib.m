function addpath_PsyLib
pth = fullfile(fileparts(mfilename('fullpath')), 'PsyLib');
addpath(genpath(pth));
end