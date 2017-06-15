function ds = cell2ds(C, get_colname, get_rowname)
% function ds = cell2ds(C, get_colname=true, get_rowname=false)
%
% Give get_rowname == 2 to have a column of the rowname.

if ~exist('get_colname', 'var'), get_colname = true; end
if ~exist('get_rowname', 'var'), get_rowname = false; end

if get_rowname == 2
    C = [C(:,1), C];
end

if get_colname && get_rowname
    ds = dataset([{C(2:end,2:end)}, C(1,2:end)], 'ObsNames', C(2:end,1)');
    
elseif get_colname && ~get_rowname
    ds = dataset([{C(2:end,:)}, C(1,:)]);
    
elseif ~get_colname && get_rowname
    ds = dataset([{C(:,2:end)}, csprintf('Var%d', 1:(size(C,2)-1))], ...
        'ObsNames', C(:,1)');
    
else
    ds = dataset([{C}, csprintf('Var%d', 1:size(C,2))]);   
end
