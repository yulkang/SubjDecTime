function [train, test] = crossvaltf(meth, n_sim, group, varargin)
% [train, test] = crossvalind(method, n_sim, group, varargin)
%
% method
% 'KfoldConsec': Kfold using consecutive parts.
% 'HoldOut'
% % Other methods are under construction.
%
% train(TR, SIM) : true if TR is included in the training set
%                  on the SIM-th simulation.
% test(TR, SIM) : true if TR is included in the test set
%                 on the SIM-th simulation.

if isnumeric(group) && isscalar(group)
    n_tr = group;
else
    n_tr = size(group, 1);
end

train = false(n_tr, n_sim);
test = false(n_tr, n_sim);

if isempty(group)
    group = ones(n_tr, 1);
else
    [~,~,group] = unique(group, 'rows');
end

switch meth
    case 'Kfold'
        error('Not implemented yet!');
        
    case 'KfoldMod'
        % According to mod(1:n_in_group, n_sim). Not random.
        n_group = max(group);
        rel_in_group = zeros(n_tr, 1);
        for i_group = 1:n_group
            in_group = group == i_group;
            n_in_group = nnz(in_group);
            rel_in_group(in_group) = mod((1:n_in_group)' - 1, n_sim) + 1;
        end
        for i_sim = 1:n_sim
            test(:,i_sim) = rel_in_group == i_sim;
            train(:,i_sim) = ~test(:,i_sim);
        end        
        
    case 'KfoldConsec'
        n_group = max(group);
        rel_in_group = zeros(n_tr, 1);
        for i_group = 1:n_group
            in_group = group == i_group;
            n_in_group = nnz(in_group);
            rel_in_group(in_group) = (1:n_in_group)' / n_in_group;
        end
        for i_sim = 1:n_sim
            rel_st = (i_sim - 1) / n_sim;
            rel_en = i_sim / n_sim;
            
            test(:,i_sim) = (rel_in_group > rel_st) ...
                          & (rel_in_group <= rel_en);
            train(:,i_sim) = ~test(:,i_sim);
        end
        
    case 'HoldOut'
        for i_sim = 1:n_sim
            [train(:, i_sim), test(:, i_sim)] = crossvalind('HoldOut', ...
                group, varargin{:});
        end
        
    otherwise
        error('Not implemented yet!');
end