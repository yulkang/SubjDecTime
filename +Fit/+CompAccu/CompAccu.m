classdef CompAccu < Fit.Common.CommonWorkspace
%% Settings
properties
    subjs = Data.Consts.subjs;
    parads = {'VD_woSDT', 'VD_wSDT'};
end
%% Internal
properties 
    tbl = table; % (tr, variables) % table across all subjects
    Ws = {}; % {subj, parad}
end
%% Results
properties
    b0 = []; % (boot, subj) : beta of interaction
    b_all = []; % (regressor, subj, boot) : all betas
end
%% Results
properties
    n_boot = 1e4;
    
    res_glmfit = struct;
    
    ds_txt = dataset;
end
methods
    function W = CompAccu(varargin)
        W.parad = 'VD_wSDT';
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function main(W0)
        W0.get_tbl;
        W0.fit_indiv;

        % For across-subject test. But coefficient sizes vary a lot, so
        % mean is not a good summary.
%         W0.bootstrap;
%         W0.summarize;
    end
    function get_tbl(W0)
        n_subj = numel(W0.subjs);
        n_parad = numel(W0.parads);
        
        ch = cell(n_subj, n_parad);
        cond = cell(n_subj, n_parad);
        wSdt = cell(n_subj, n_parad);
        ix_subj = cell(n_subj, n_parad);
        
        S0 = W0.get_S0_file;
        
        %%
        for i_subj = 1:n_subj
            for i_parad = 1:n_parad
                subj = W0.subjs{i_subj};
                parad = W0.parads{i_parad};
                
                S = varargin2S({
                    'subj', subj
                    'parad', parad
                    }, S0);
                C = S2C(S);
                W = feval(class(W0), C{:});
                ch{i_subj, i_parad} = W.Data.ch;
                cond{i_subj, i_parad} = W.Data.cond;

                disp({subj, parad});
                disp(crosstab(W.Data.cond, W.Data.ch)); % DEBUG
                
                siz = size(ch{i_subj, i_parad});
                
                wSdt{i_subj, i_parad} = repmat( ...
                    ~isempty(strfind(parad, 'wSDT')), ...
                    siz);
                ix_subj{i_subj, i_parad} = i_subj + zeros(siz);
            end
        end
        
        cond = cell2vec(cond')';
        wSdt = cell2vec(wSdt')';
        ix_subj = cell2vec(ix_subj')';
        ch = cell2vec(ch')';
        tbl = table(cond, wSdt, ix_subj, ch);
        W0.tbl = tbl;
    end
    function fit_indiv(W0)
        n_subj = numel(W0.subjs);
        ress = cell(n_subj, 1);
        txts = cell(n_subj, 1);
        tbl = W0.tbl;
        
        columns = {'Intercept', 'Condition', 'Reported_SDT', 'Interaction'};
        n_col = numel(columns);
        
        for i_subj = 1:n_subj
            incl = tbl.ix_subj == i_subj;
            res1 = fitglm(tbl(incl,:), ...
                'ch ~ cond * wSdt', ...
                'Distribution', 'binomial');
            
            txt1 = struct;
            txt1.subj = sprintf('S%d', i_subj);
            for i_col = 1:n_col
                col1 = columns{i_col};
                txt1.(col1) = sprintf('%1.1f +- %1.1f (p=%1.2g)', ...
                    res1.Coefficients.Estimate(i_col), ...
                    res1.Coefficients.SE(i_col), ...
                    res1.Coefficients.pValue(i_col));
            end
            txt1.df = res1.DFE;
            
            ress{i_subj} = res1;
            txts{i_subj} = txt1;
        end
        ds_txt = bml.ds.from_Ss(txts);
        disp(ds_txt);
        
        file = W0.get_file({
            'tbl', 'within_subj'
            });
        mkdir2(fileparts(file));
        save([file, '.mat'], 'ress', 'ds_txt');
        export(ds_txt, 'File', [file, '.csv'], 'Delimiter', ',');
        fprintf('Saved to %s.csv and .mat\n', file);
    end
    function bootstrap(W0)
        n_boot = W0.n_boot;
        n_subj = numel(W0.subjs);
        
        b0 = zeros(n_boot, n_subj);
        
        tbl = W0.tbl;
        
        n_regressors = 4; % intercept, cond, wSdt, cond:wSdt
        b_all = zeros(n_regressors, n_subj, n_boot);
        t_st = tic;
        
        fprintf('Starting %d bootstrap\n', n_boot);
        
        parfor i_boot = 1:n_boot
            [b0(i_boot,:), b_all(:,:,i_boot)] = W0.fit_unit(tbl, i_boot);
        end
        W0.b0 = b0;
        W0.b_all = b_all;
        
        t_el = toc(t_st);
        fprintf('%d bootstraps took %1.1f seconds\n', n_boot, t_el);    
    end
    function [b,b_all,ress] = fit_unit(~, tbl, i_boot)
        n = size(tbl);
        if i_boot == 1
            ix = 1:n;
        else
            [~,~,grp] = unique(tbl(:, {'cond', 'wSdt', 'ix_subj'}), 'rows');
            ix = cell2mat(bml.stat.bootstrp_ix(1, grp));
        end
        tbl = tbl(ix,:);
        
        n_subj = max(tbl.ix_subj);
        n_regressors = 4; % intercept, cond, wSdt, cond:wSdt
        b = zeros(1, n_subj);
        b_all = zeros(n_regressors, n_subj);
        ress = cell(1, n_subj);
        for i_subj = 1:n_subj
            incl = tbl.ix_subj == i_subj;

            ress{1,i_subj} = fitglm(tbl(incl,:), ...
                'ch ~ cond * wSdt', ...
                'Distribution', 'binomial');
            b(1,i_subj) = ress{i_subj}.Coefficients.Estimate(n_regressors);
            b_all(:,i_subj) = ress{i_subj}.Coefficients.Estimate;
        end
    end
    function summarize(W0)
        columns = {'Intercept', 'Condition', 'Reported_SDT', 'Interaction'};
        b_all = W0.b_all;
        b_mean = squeeze(mean(b_all, 2))'; % (boot,reg) <- (reg,subj,boot)
        m = mean(b_mean);
        se = std(b_mean);
        p = bml.stat.pval_from_stat(b_mean);
        
        ds_txt = dataset;
        n_regressors = numel(columns);
        for i_reg = 1:n_regressors
            col1 = columns{i_reg};
            m1 = m(i_reg);
            se1 = se(i_reg);
            p1 = p(i_reg);
            
            if p1 == 1 / W0.n_boot
                p_str = sprintf('p<=%1.2g', p1);
            else
                p_str = sprintf('p=%1.2g', p1);
            end
            
            ds_txt.(col1) = {
                sprintf('%1.1f +- %1.1f (%s)', m1, se1, p_str)};
        end
        disp(ds_txt);
        
        file = W0.get_file({
            'tbl', 'across_subj'
            });
        mkdir2(fileparts(file));
        save([file, '.mat'], 'W0');
        export(ds_txt, 'File', [file, '.csv'], 'Delimiter', 'tab');
    end
    function file = get_file(W0, args)
        if nargin < 2
            args = {};
        end
        args = varargin2C(args, {
            'sbj', W0.subjs
            'prd', W0.parads
            });
        file = W0.get_file@Fit.Common.CommonWorkspace(args);
    end
    function fs = get_file_fields(W0)
        fs = [
            W0.get_file_fields@Fit.Common.CommonWorkspace
            {
            'n_boot', 'nbt'
            }];
    end
end
end