function pth_above = pth_above_pkg(full_pth)
% pth_above_pkg  Give path just above (nested) package or class folders.
%
% pth_above = pth_above_pkg(full_pth)
%
% EXAMPLE:
% >> pth_above_pkg('Code/project/@class1/class1.m')
% ans = 
% Code/project
%
% >> pth_above_pkg('Code/project/+pkg1/+pkg2/fun.m')
% ans = 
% Code/project
%
% See also: package, PsyLib
%
% 2014 (c) Yul Kang. See help PsyLib for the license.

if ~exist(full_pth, 'dir')
    full_pth = fileparts(full_pth);
end

loc_ptrn = union( ...
    strfind(full_pth, [filesep, '@']), ...
    strfind(full_pth, [filesep, '+']));

if isempty(loc_ptrn), pth_above = full_pth; return; end

loc_sep = strfind(full_pth, filesep);

loc_above = max(setdiff(loc_sep, loc_ptrn));
loc_next  = loc_sep(find(loc_sep == loc_above) + 1);

pth_above = full_pth(1:(loc_next-1));