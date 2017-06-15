classdef PermuteParam < Fit.PerturbPred.PerturbPred
%% Settings
properties    
    ths_to_permute = {'k', 'b', 'bias_cond'};
    to_exclude_own_param = true;
    ix_subjs_sum_llk = 1:4;
end
%% Init
methods
    function W = PermuteParam(varargin)
        W.subjs = Data.Consts.subjs;
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function main(W0)
        if isempty(W0.Ws)
            W0.init;
        end
        
        %%
        n_subj = numel(W0.Ws);
        perms_all = flip(perms(1:n_subj), 2);
        n_perm = size(perms_all, 1);
        
        th0s = double(W0.ds_params);
        ths_to_permute = W0.ths_to_permute;
        n_ths_to_permute = numel(ths_to_permute);
        
        llk = zeros(n_subj^n_ths_to_permute, n_subj);    
        llk0 = zeros(1, n_subj);
        
        %%
        for i_subj = n_subj:-1:1
            fprintf('Starting subj %d\n', i_subj);
            W = W0.Ws{i_subj};
            
            for i_th = 1:n_ths_to_permute
                th1 = ths_to_permute{i_th};
                W.th.(th1) = th0s(i_subj, i_th);
            end
            llk0(i_subj) = W0.get_llk_ch(W);
            
            factors = cell(1, n_ths_to_permute);            
            for i_th = 1:n_ths_to_permute
                factors{i_th} = num2cell(1:n_subj);
            end
            [subj_perm, n_perm_th] = factorize(factors);
            subj_perm = cell2mat(subj_perm);
            
            if W0.to_exclude_own_param
                incl = ~any(subj_perm == i_subj, 2);
                subj_perm = subj_perm(incl, :);
                n_perm_th = nnz(incl);
            end
            
            %%
            for i_perm = 1:n_perm_th
                for i_th = 1:n_ths_to_permute
                    th1 = ths_to_permute{i_th};
                    subj_th = subj_perm(i_perm, i_th);
                    th_v = th0s(subj_th, i_th);
                    
                    W.th.(th1) = th_v;
                end
                llk(i_perm, i_subj) = W0.get_llk_ch(W);
            end
            
            fprintf('Finished.\n');
        end
        llk = llk(1:n_perm_th,:);
        
        %% Individual-level p-value
        W0.p_perm = mean(bsxfun(@ge, llk, llk0));
        W0.llk = llk;
        W0.llk0 = llk0;
        
        %% Group-level p-value
        if n_subj <= 4
            factors = cell(1, n_subj);
            for i_subj = 1:n_subj
                factors{i_subj} = 1:n_perm_th;
            end
            subj_perm = cell(1, n_subj);
            [subj_perm{1:n_subj}] = ndgrid(factors{:});

            for i_subj = 1:n_subj
                subj_perm{i_subj} = subj_perm{i_subj}(:);
            end
            subj_perm = cell2mat(subj_perm);
        else
            rng(0);
            n_perm = 1e5;
            subj_perm = ceil(rand(n_perm, n_subj) * n_perm_th);
        end
        
        llk_sum_perm = zeros(size(subj_perm));
        for i_subj = 1:n_subj
            llk_sum_perm(:,i_subj) = llk(subj_perm(:,i_subj), i_subj);
        end
        
        %%
        n_perm = size(llk_sum_perm, 1);
        
        llk_sum = sum(llk_sum_perm(:, W0.ix_subjs_sum_llk), 2);
        llk_sum0 = sum(W0.llk0, 2);
        
        W0.p_perm_sum = mean(llk_sum >= llk_sum0);
        
        disp(W0.p_perm);
        disp(W0.p_perm_sum);
        fprintf('p_sum=%1.5g among %1.7g combinations\n', ...
            W0.p_perm_sum, n_perm);
    end
end
end