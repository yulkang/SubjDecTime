classdef HistoryComparer
    
methods
    function [d_orig, dif_orig, d_cv, dif_cv] = ...
            step_per_time_orig_vs_cv(W, res)
        %%
        res_orig = res;
        [d_orig, ~, dif_orig] = W.step_per_time(res_orig);
        
        n_cv = numel(res.CrossvalFl.ress);
        for ii = n_cv:-1:1
            res_cv{ii} = res.CrossvalFl.ress{ii};       
            [d_cv{ii}, ~, dif_cv{ii}] = W.step_per_time(res_cv);
        end
    end
    function [d_his_summary, d_his, dif_his] = step_per_time(W, res, varargin)
        S = varargin2S(varargin, {
            'summary', @(v) median(abs(v))
            });
        
        %% See t_elapsed vs history
        his = res.history;
        col_names = his.Properties.VarNames;
        [non_th_names, non_th_col] = ...
            setdiff(col_names, res.th_names, 'stable');
        th_col = ~non_th_col;
        
        mat = ds2mat(his);
        mat = diff(mat, 1, 1);
        
        step_summary = S.summary(mat);
        
        d_his = mat2dataset(mat, 'VarNames', col_names);
        d_his_summary = ds2struct( ...
            mat2dataset(step_summary, 'VarNames', col_names));
        
        %%
        mat_dif_his = (ds2mat(his(end,:)) ...
                    - ds2mat(his(1,:)));
        dif_his = ds2struct( ...
            mat2dataset(mat_dif_his, 'VarNames', col_names));
    end
end
end