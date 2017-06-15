function ds = dsQ(ds, op, q, v)
% ds = dsQ(ds, op, q, v)
%
% op: 'tf', 'ix', 'set', 'set1', 'get', 'get1'
% q:  Name-value pairs
% v:  column indices (get) or name-value pairs (set).

if isempty(op)
    op = 'tf';
end

switch op
    case 'tf'
        n   = length(ds);
        res = true(n,1);
        
        for ii = 1:2:length(q);
            col = row2cell(ds.(q{ii}), true);
            
            res = res & cellfun(@(v) isequal(v, q{ii+1}), col);
        end
        ds = res;
        
    case 'ix' % Gives numerical indices.
        ds = find(dsQ(ds, 'tf', q));
        
    case {'set', 'set1'}
        tf = dsQ(ds, 'tf', q);
        
        if op(end) == '1'
            assert(nnz(tf) == 1);
        end
        
        ds = ds_set(ds, tf, v);
        
    case 'get'
        tf = dsQ(ds, 'tf', q);
        
        if op(end) == '1'
            assert(nnz(tf) == 1);
        end
        
        if nargin < 4 || isempty(v) || (ischar(v) && strcmp(v,':'))
            ds = ds(tf,:);
        elseif ischar(v)
            ds = ds.(v)(tf);
        elseif iscell(v) || isnumeric(v)
            ds = ds(tf,v);
        end        
end