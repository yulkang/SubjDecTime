function varargin2var(vararginCell)
nVar = length(vararginCell)/2;
for iVar = 1:nVar
	assignin('caller', vararginCell{iVar*2-1}, vararginCell{iVar*2});
end
return;