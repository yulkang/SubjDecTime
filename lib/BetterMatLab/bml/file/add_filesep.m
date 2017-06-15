function pth = add_filesep(pth)
% add_filesep  Append filesep at the end if absent.
%
% See also: file, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

if pth(end) ~= filesep, pth = [pth, filesep]; end