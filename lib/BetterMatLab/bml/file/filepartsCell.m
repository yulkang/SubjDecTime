function [pathCell, name, ext] = filepartsCell(src)
% [pathCell, name, ext] = filepartsCell(src)
%
% See also: file, PsyLib
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

% if src(1)==filesep
%     src = src(2:end);
% end

[pth, name, ext] = fileparts(src);

if isempty(pth)
    pathCell = {};
else
    pth     = [pth, filesep];
    pthIx   = [1, find(pth==filesep)+1];

    nPath   = length(pthIx)-1;
    pathCell = cell(1,nPath);
    for ii = 1:nPath
        pathCell{ii} = pth(pthIx(ii):(pthIx(ii+1)-2));
    end
    
    if pth(1) == filesep
        pathCell{1} = [filesep, pathCell{1}];
    end
end