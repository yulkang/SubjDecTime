function pathCell = filepartsCell2(src)
% pathCell = filepartsCell(src)
%
% pathCell{1} : file name.
% pathCell{2} : extension.
% pathCell{3:end}: path.
%
% See also: file, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

if src(1)==filesep
    src = src(2:end);
end

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
end

pathCell = [{name, ext}, pathCell(:)'];