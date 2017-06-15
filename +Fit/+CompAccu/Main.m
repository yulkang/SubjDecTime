classdef Main < Fit.Common.CommonWorkspace
properties 
    res_accu % results from binofit (phat, pci)
    res_logit
end
%% Batch / Main
methods
    function [S_batch, Ss, n] = get_S_batch(~, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            'parad', {'VD_wSDT', 'VD_woSDT'}
            });
        [Ss, n] = factorizeS(S_batch);
    end
    function batch(W0, varargin)
        [~, Ss, n] = W0.get_S_batch(varargin{:});
        
        for ii = 1:n
            S = Ss(ii);
            C = S2C(S);
            W = feval(class(W0), C{:});
            W.main(C{:});
        end
    end
    function main(W, varargin)
        W.init(varargin{:});
        W.fit;
        W.plot_and_save_all;
    end
    function plot_and_save_all(W)        
        W.save_res;
    end
end
%% Compare across subjects
methods
    function ds = compare_subjs(W0, varargin)
        [ds, file_batch] = W0.get_res_subjs(varargin{:});
        
        mkdir2(fileparts(file_batch));
        fprintf('Saving to %s.csv\n', file_batch);
        export(ds, 'File', [file_batch '.csv'], 'Delimiter', ',');

        fprintf('Saving to %s.txt\n', file_batch);
        diary([file_batch '.txt']);
        
        W0.summarize_var('b0', ds.b(:,1));
        W0.summarize_var('b1', ds.b(:,2));
        W0.summarize_var('Rsq', ds.rsq);
        W0.summarize_var('pval', ds.p, '%1.2g');
        
        diary('off');
        fprintf('Done.');
    end
    function [ds, file_batch] = get_res_subjs(W0, varargin)
        [ds, file_batch, ~, n_batch] = W0.get_ds_batch(varargin{:});
        
        for i_batch = n_batch:-1:1
            file = ds.file{i_batch};
            fprintf('Loading %s\n', file);
            L = load(file, 'res');
            
            res = copyFields(struct, L.res);
            res.b = res.b';
            res.bint = hVec(res.bint');
            
            ds = ds_set(ds, i_batch, res);
        end
        ds.b = cell2mat2(ds.b);
        ds.bint = cell2mat2(ds.bint);
    end
    function [ds, file_batch, Ss, n_batch, S_batch] = get_ds_batch(W0, ...
            varargin)
        
        [S_batch, Ss, n_batch] = W0.get_S_batch(varargin{:});
        if n_batch == 0
            ds = dataset;
            file_batch = '';
            Ss = [];
            return;
        end
        
        ds = dataset;
        for i_batch = n_batch:-1:1
            S = Ss(i_batch);
            C = S2C(S);

            W = feval(class(W0));
            bml.oop.varargin2props(W, C, true);
            
            file = W.get_file;
            S0_file = W.get_S0_file;
            
            ds = ds_set(ds, i_batch, S0_file);
            ds.file{i_batch,1} = file;
        end
        
        S0_files = struct;
        for fs = fieldnames(S0_file)'
            S0_files.(fs{1}) = ds.(fs{1});
        end
        file_batch = fullfile('Data', class(W0), ...
            bml.str.Serializer.convert(S0_files));
    end
    function summarize_var(~, nam, v, fmt)
        if ~exist('fmt', 'var')
            fmt = '%1.2f';
        end
        fprintf(['%s: ' fmt '-' fmt ' (median ' fmt ')\n'], ...
            nam, min(v), max(v), median(v));
    end
end
%% Init
methods
    function W = Main(varargin)
        W.data_file_type = 'orig';
        W.parad = 'VD_woSDT';
        if nargin > 0
            W.init(varargin{:});
        end
    end
end
%% Calculation
methods
    function fit(W)
        W.fit_accu;
        W.fit_logit;
    end
    function res_accu = fit_accu(W)
        accu = W.Data.accu(W.Data.cond ~= 0);
        
        n_all_cond = nnz(~isnan(accu));
        n_ch1_all_cond = nnz(accu == 1);

        [phat_all_cond, pci_all_cond] = binofit(n_ch1_all_cond, n_all_cond);
        res_accu = ...
            packStruct(n_all_cond, n_ch1_all_cond, phat_all_cond, pci_all_cond);
        
        W.res_accu = res_accu;
    end
    function res_logit = fit_logit(W)
        conds = W.Data.conds(:);
        obs_ch = W.Data.obs_ch(:);
        obs_n = W.Data.obs_n(:);
        obs_y = [obs_ch .* obs_n, obs_n];
        
        res_logit = bml.stat.glmwrap(conds, obs_y, 'binomial');
        res_logit = copyFields(res_logit, ...
            packStruct(conds, obs_ch, obs_n));
        
        W.res_logit = res_logit;
    end
end
%% Plot
methods
    function plot(W)
    end
end
%% Save
methods
    function save_res(W)
        file = W.get_file;
        mkdir2(fileparts(file));
        fprintf('Saving to %s\n', file);
        
        res_accu = W.res_accu; %#ok<NASGU>
        res_logit = W.res_logit; %#ok<NASGU>
        save(file, 'W', 'res_accu', 'res_logit', 'file');
    end
end
end