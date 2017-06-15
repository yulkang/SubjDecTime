% function init_path
restoredefaultpath;
addpath(genpath('lib'));

import bml.override.*
% import bml.file.edit
% import bml.file.help

dbstop if error

try
    opengl hardwarebasic
catch err
    warning(err_msg(err));
end
set(0, 'DefaultFigureWindowStyle', 'docked');
varargin = {};