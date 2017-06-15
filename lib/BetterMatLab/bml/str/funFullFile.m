function res = funFullFile(frm, varargin)
% Same as funPrintf except that '/' is combined by fullfile.
%
% EXAMPLE:
%
% >> funFullFile('D%TT/%%', 'D', '20130725', 'T', '162105')
% ans = 20130725T162105/%
%
% >> funFullFile('D%TT/%%_%/', 'D', '20130725', 'T', '162105')
% ans = 20130725T162105/%_/
% 
% See also FUNPRINTF.


src = funPrintfChop(frm, '/');

for ii = 1:length(src)
    src{ii} = funPrintf(src{ii}, varargin{:});
end

res = fullfile(src{:});