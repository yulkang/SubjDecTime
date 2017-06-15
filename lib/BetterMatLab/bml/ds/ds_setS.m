function ds = ds_setS(ds, ix, v, varargin)
% ds = ds_setS(ds, ix, v, varargin)
%
% ix: logical or numeric index or a function handle that gets ds.
% v: either a struct or a cell array of name-value pairs.
%
% OPTIONS
% -------
% 'existing2cell',true % Enforce existing non-cell columns into a cell, as needed
% 'scalar2cell',  true % Sets everything in a cell, except a cell column vector if cell2cell is false.
% 'cell2cell',    false % Sets everything in a cell, even a cell.
% 'struct2cell',  true
% 'object2cell',  true
% 'mat2cell',     true
% 'char2cell',    true
% 'unpackFields', true
% 'unpackFieldsArg', {}
% 
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'existing2cell',true % Enforce existing non-cell columns into a cell, as needed
    'scalar2cell',  true % Sets everything in a cell, except a cell column vector if cell2cell is false.
    'cell2cell',    false % Sets everything in a cell, even a cell.
    'struct2cell',  true
    'object2cell',  true
    'mat2cell',     true
    'char2cell',    true
    'unpackFields', true
    'unpackFieldsArg', {}
    });

if ischar(ix) && isequal(ix, ':'), ix = 1:length(ds); end
if isa(ix, 'function_handle'), ix = ix(ds); end
if iscell(v), v = varargin2S(v); end
if isa(v, 'dataset')
    v = ds2struct(v, 'cellfields', true);
    
%     if islogical(ix), ix = find(ix); end
%     for ii = 1:length(v)
%         ds = ds_setS(ds, ix(ii), ds2struct(v(ii,:), 'cellfields', true); 
%     end
end
if S.unpackFields
    v = unpackFields(v, S.unpackFieldsArg{:}); 
end

% Could convert table to struct, field-by-field. Implement if necessary.
assert(isstruct(v), 'Give a struct, dataset, or cell array of name-value pairs!');
    
fs = fieldnames(v);
nc = length(fs);
nr = numIx(ix);

for ii = 1:nc
    f = fs{ii};
    
    if S.existing2cell
        % Enforce a cell column vector
        if isdscolumn(ds, f) && (~iscell(ds.(f)) || size(ds.(f),2) > 1)
            ds.(f) = row2cell(ds.(f));
        end
    end
    
    if isempty(v.(f)) || ...
            (S.object2cell && isobject(v.(f)))
        
        ds.(f)(ix,1) = {v.(f)};
        
    elseif S.scalar2cell
        if ~S.cell2cell && iscell(v.(f)) && iscolumn(v.(f)) && (size(v.(f),1) == numIx(ix))
            % If cell2cell == false,
            % a column cell vector of matching height is saved as is.
            % Might harm consistency in saving cells. 
            % Give cells by default to prevent this.
            ds.(f)(ix,1) = v.(f);
        elseif (size(v.(f),1) == numIx(ix))
            ds.(f)(ix,1) = row2cell(v.(f));
        else
            ds.(f)(ix,1) = {v.(f)};
        end
        
    elseif (S.mat2cell && size(v.(f),2) > 1) ...
            || (S.struct2cell && isstruct(v.(f)))
        % If matrix, char, or struct,
        ds.(f)(ix,1) = row2cell(v.(f));
        
    elseif S.char2cell && ischar(v.(f))
        ds.(f)(ix,1) = cellstr(v.(f));
        
    elseif size(v.(f),2) > 1
        % If saving a matrix as is,
        if size(v.(f),1) == 1
            ds.(f)(ix,1:size(v.(f),2)) = repmat(v.(f), [nr, 1]);
        else
            ds.(f)(ix,1:size(v.(f),2)) = v.(f);
        end
        
    else
        % Otherwise (scalar or column vector)
        ds.(f)(ix,1) = v.(f);
    end
end