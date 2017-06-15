function c = ds_count(tmp, querry, op, cols, w_col)
% c = ds_count(tmp, querry, [op='incl'|'excl', f={fieldnames}, w_col=count_column]);
%
% EXAMPLE:
% >> C1 = {'a', 'b'; 1 2; 1 3};
% >> C2 = {'a', 'b', 'c'; 1 2 1; 1 2 2; 1 3 1; 1 3 2; 1 3 3};
% >> ds1 = cell2ds(C1)
% ds1 = 
%     a          b      
%     [1]        [2]    
%     [1]        [3]    
% 
% >> ds2 = cell2ds(C2)
% ds2 = 
%     a          b          c      
%     [1]        [2]        [1]    
%     [1]        [2]        [2]    
%     [1]        [3]        [1]    
%     [1]        [3]        [2]    
%     [1]        [3]        [3]    
% 
% >> ds_count(ds1, ds2)
% ans = 
%      2
%      3

if nargin < 3
    cols = tmp.Properties.VarNames;
    
else
    assert(nargin >= 4, 'field names are required if op is given!');
    
    switch op
        case 'excl'
            cols = setdiff(tmp.Properties.VarNames, cols);
    end
end

n_t  = length(tmp);
n_q  = length(querry);
c    = zeros(n_t, 1);

for ii = 1:n_t
    
    tf = true(n_q, 1);
    
    for jj = 1:length(cols)
        tf = tf & arrayfun( ...
            @(d) isequal(d, tmp.(cols{jj})(ii)), querry.(cols{jj}));
    end
    
    if nargin >= 5
        c(ii) = sum(querry.(w_col)(tf));
    else
        c(ii) = nnz(tf);
    end
end