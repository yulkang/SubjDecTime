classdef Summarize < Fit.Dtb.PermuteCoh.Main
% Across-subject analysis

%% Optional Settings
properties
    % stat_sumamry
    % : 'Pearson_rho'
    %   'SqDist' : mean squared distance of 
    %              k from SDT in VD_wSDT and 
    %              k from RT in RT_wSDT from the unity line
    %   'LogLikCh' : log likelihood of the choice predictions.
    stat_summary = 'SqDist'; % 'Pearson_rho'; 
    stat_perm = []; % (perm, 1) : Statistic from perm-th permutation.
    
    W_fit_perm = Fit.Dtb.PermuteCoh.Main;
    W_fit_RT = Fit.Dtb.Main;
    prop_fit_perm = {};
    prop_fit_RT = {};
    
    subjs = {};

    % Results from SDT
    res_subj = {};
    ix_tr_subj = {};
    ix_cond_subj = {};
    
    k_perm = []; % (subj, perm)
    se_k_perm = []; % (subj, perm)
    L_perm = {}; % (subj, 1)
    
    % Results from RT
    res_RT = {}; % {subj, 1}
    k_RT = []; % (subj, 1)
    se_k_RT = []; % (subj, 1)
    L_RT = {}; % {subj, 1}
    
    % Choice observation and prediction
    bias_ch_obs = []; % (subj, 1)
    slope_ch_obs = []; % (subj, 1)
    slope_ch_pred_perm = []; % (subj, perm)
    
    loglik_ch_obs = []; % (subj, 1)
    loglik_ch_pred_perm = []; % (subj, perm)
end
properties (Dependent)
    p_perm
    p_perm_tail
    
    p_loglik_ch
    
    n_subjs
    
    parads
    rt_fields
    
    stat_summary_label
    stat_text_result
    
    W_fit_RT_class
end
%% Main - Mixed SDT only + SDT-Ch vs RT
methods
    function main_meanSDT(W0, varargin)
        %% Load perm
        subjs = Data.Consts.subjs;
        n1 = numel(subjs);
        W_fit_perm = Fit.Dtb.PermuteCoh.Main( ...
            'bias_cond_from_ch', false, ...
            'bound_shape', 'const', ...
            'tnd_bayes', 'none', ...
            'n_tnd', 1, ...
            'ignore_choice', true);
        C = varargin2C(varargin, {
            'W_fit_class', 'Fit.Dtb.MeanRt.Main'
            'W_fit_perm', W_fit_perm
            'subjs', subjs
            'ix', 1:n1
            'to_postprocess', false
            });
        W0.load_res_perm(C{:});
        
        %%
        W0.postprocess_res_perm;        
        W0.save_res_perm;
    end
    function main_meanSDT_w_meanRT(W0, varargin)
        %% Load perm
        ignore_choice1 = true;
        
        subjs = Data.Consts.subjs_w_SDT_modul;
        n1 = numel(subjs);
        W_fit_perm = Fit.Dtb.PermuteCoh.Main( ...
            'bias_cond_from_ch', false, ...
            'bound_shape', 'const', ...
            'tnd_bayes', 'none', ...
            'n_tnd', 1, ...
            'ignore_choice', true);
        C = varargin2C(varargin, {
            'W_fit_class', 'Fit.Dtb.MeanRt.Main'
            'W_fit_perm', W_fit_perm
            'subjs', subjs
            'ix', 1:n1
            'to_postprocess', false
            });
        W0.load_res_perm(C{:});
        
        %% S5
        ignore_choice2 = false;
        
        W_fit_perm.ignore_choice = ignore_choice2;
        C = varargin2C(varargin, {
            'W_fit_class', 'Fit.Dtb.MeanRt.Main'
            'W_fit_perm', W_fit_perm
            'subjs', Data.Consts.subjs_wo_SDT_modul
            'ix', n1 + 1
            'to_postprocess', false
            });
        W0.load_res_perm(C{:});
        
        %%
        W0.postprocess_res_perm;        
        W0.save_res_perm;
        
        %%
        subj_fval = 1;
        fval = cellfun(@(res) res.fval, W0.res_subj{subj_fval});
        mean(fval <= fval(1))
        
        %% Load RT
        subjs = Data.Consts.subjs;
        W_fit_RT = Fit.Dtb.MeanRt.Main( ...
            'bias_cond_from_ch', false, ...
            'bound_shape', 'const', ...
            'tnd_bayes', 'none', ...
            'n_tnd', 2, ...
            'parad', 'RT_wSDT', ...
            'rt_field', 'RT', ...
            'to_import_k', false, ...
            'ignore_choice', false);
        C = varargin2C(varargin, {
            'W_fit_RT', W_fit_RT
            'subjs', subjs
            'to_postprocess', true
            });
        W0.load_res_RT(C{:});
        
        %% Produce scatterplot
        clf;
        W0.scatter;
        
        %% Change symbol for S5
        if ~ignore_choice2
            h = bml.plot.figure2struct;
            x = h.marker.XData(end);
            y = h.marker.YData(end);
            marker2 = copyobj(h.marker, h.axes);
            marker2.XData = x;
            marker2.YData = y;
            marker2.MarkerFaceColor = 0.7 + zeros(1,3);
            marker2.MarkerEdgeColor = 'w';
            uistack(marker2, 'top');
        end
        
        %%
        set(h.axes, 'FontSize', 9);
        set(h.text, 'FontSize', 9);
        
        %% Save scatterplot
        W0.bound_shape = 'const';
        W0.n_tnd = 1;
        W0.tnd_bayes = 'none';
        W0.ignore_choice = unique([ignore_choice1, ignore_choice2]);
        W0.save_scatter;
    end        
end
%% Main - Facades
methods
    function main_pred_from_meanSDT_w_pred_from_meanRT_k_fixed(W, varargin)
        W_fit_RT = Fit.Dtb.Main;
        S_fit_RT = bml.args.factorizeS(W_fit_RT.get_S_batch_w_imported_k);
        S_fit_RT.to_import_k = varargin2C(S_fit_RT.to_import_k);
        C_fit_RT = varargin2C(S_fit_RT(1), {
            'parad', 'RT_wSDT'
            'rt_field', 'RT'
            'bias_cond_from_ch', false
            'n_tnd', 2
            });
        
        C = varargin2C(varargin, {
            'n_perm', 401
            'parad', 'VD_wSDT'
            'rt_field', 'SDT_ClockOn'
            'n_tnd', 1
            'bound_shape', 'const'
            'abs_cond', true
            'ignore_choice', true
            'tnd_bayes', 'none'
            'W_fit_class', 'Fit.Dtb.MeanRt.Main'
            'W_fit_RT_class', 'Fit.Dtb.MeanRt.Main'
            'prop_fit_perm', varargin2C({
                'bias_cond_from_ch', false
                'bound_shape', 'const'
                })
            'prop_fit_RT', C_fit_RT
            });
        W.init(C{:});
        
        %%
        W.load_res_perm;
        W.save_mat;
        
        %%
        W.save_res_perm;
        W.save_mat;
        
%         %%
%         W.main;
    end
    function main_collapsing_bound(W, varargin)
        W_fit_RT = Fit.Dtb.Main;
        S_fit_RT = bml.args.factorizeS(W_fit_RT.get_S_batch_RT);
        if ~isempty(S_fit_RT.to_import_k)
            S_fit_RT.to_import_k = varargin2C(S_fit_RT.to_import_k);
        end
        C_fit_RT = varargin2C(S_fit_RT(1), {
            'parad', 'RT_wSDT'
            'rt_field', 'RT'
            'bias_cond_from_ch', false
            'n_tnd', 2
            'to_import_k', []
            'did_MC', []
            });
        
        C = varargin2C({
            'n_perm', 401
            'parad', 'VD_wSDT'
            'rt_field', 'SDT_ClockOn'
            'n_tnd', 1
            'bound_shape', 'betamean' % 'betacdf'
            'abs_cond', true
            'ignore_choice', false
            'tnd_bayes', 'none'
            'tnd_distrib', 'gamma'
            'W_fit_class', 'Fit.Dtb.Main'
            'W_fit_RT_class', 'Fit.Dtb.Main'
            'prop_fit_perm', varargin2C({
                'ignore_choice', false
                'bias_cond_from_ch', []
                'bound_shape', 'betamean' % 'betacdf'
                'did_MC', []
                })
            'prop_fit_RT', C_fit_RT
            'to_import_k', []
            });
        W.init(C{:});
        
        %%
        W.load_res_RT;
        
        %%
        W.load_res_perm;
        W.save_mat;
        
        %%
        W.save_res_perm;
        W.save_mat;
        
        %%
        stat_summary0 = W.stat_summary;
        for stat_summary = {'SqDist', 'Pearson_rho'}       
            W.stat_summary = stat_summary{1};
            W.summarize;
            
            clf;
            W.plot;
            W.save_plot;
        end
        W.stat_summary = stat_summary0;
        
        %%
        W.scatter;
        W.save_scatter;
        
        %%
        W.save_mat;
    end
end
%% Main
methods
    function main(W)
        %%
        W.load_res_RT;
        W.save_mat;
        
        %%
        W.load_res_perm;
        W.save_mat;
        
        %%
        W.save_res_perm;
        
        %%
        stat_summary0 = W.stat_summary;
        for stat_summary = {'SqDist'}
            W.stat_summary = stat_summary{1};
            W.summarize;
            
            clf;
            W.plot;
            W.save_plot;
        end
        W.stat_summary = stat_summary0;
        
        %%
        W.scatter;
        W.save_scatter;
        
        
        %%
        if strcmp(W.W_fit_class, 'Fit.Dtb.MeanRt.Main')
            W.plot_ch_all;
        end
        
        %%
        W.save_mat;
    end
    function W = Summarize(varargin)
        W.subjs = Data.Consts.subjs;
%         W.subjs = Data.Consts.subjs_w_SDT_modul;
        
        if nargin > 0
            W.init(varargin{:});
        end
        W.W_fit_RT.parad = 'RT_wSDT';
        W.W_fit_RT.rt_field = 'RT';
        
        W.add_children_props({'W_fit_perm'});
    end
    function init(W, varargin)
        W.init@Fit.Dtb.PermuteCoh.Main(varargin{:});
        
        C = varargin2C(W.prop_fit_perm, varargin);
        W.W_fit_perm.init(C{:});
        
        C = varargin2C(W.prop_fit_RT, varargin);
        W.W_fit_RT.init(C{:});
    end
end
%% == Load perm results
methods
    function load_res_perm(W, varargin)
        opt = varargin2S(varargin, {
            'W_fit_class', W.W_fit_class
            'W_fit_perm', W.W_fit_perm
            'subjs', W.subjs
            'ix', []
            'to_postprocess', true
            });
        W.W_fit_class = opt.W_fit_class;
        W.W_fit_perm = opt.W_fit_perm;
        W.subjs = opt.subjs;
        
        n = numel(opt.subjs);
        if isempty(opt.ix)
            ix = 1:n;
        else
            ix = opt.ix;
        end
        
        % Load results for each subject
        Main = opt.W_fit_perm;
        S0 = Main.get_S0_file;

%         W.res_subj(ix, 1) = cell(n, 1);
%         W.ix_tr_subj(ix, 1) = cell(n, 1);
%         W.ix_cond_subj(ix, 1) = cell(n, 1);
        
        for ii = n:-1:1
            ix1 = ix(ii);
            
            subj = opt.subjs{ii};
            S = varargin2S({
                'subj', subj
                'W_fit_class', opt.W_fit_class
                }, S0);
            C = S2C(S);
            Main.init(C{:});
            
            fprintf('Loading results for subject %s\n', subj);
            [W.res_subj{ix1,1}, W.ix_tr_subj{ix1,1}, W.ix_cond_subj{ix1,1}] = ...
                Main.load_res_perm;
            
            C0 = varargin2C({
                'subj', subj
                }, Main.get_S0_file);
            W_fit = feval(class(Main), C0{:});
            file = W_fit.W_fit.get_file;
            fprintf('Loading %s\n', file);
            W.L_perm{ix1,1} = load(file);
        end
        
        if opt.to_postprocess
            W.postprocess_res_perm;
        end
    end
    function save_res_perm(W)
        if isempty(W.p_loglik_ch)
            warning('p_loglik_ch is empty! Skipping save_res_perm...');
            return;
        end
        
        file = [W.get_file({'tbl', 'p_loglik_ch_indiv'}), '.csv'];
        pv = W.p_loglik_ch;
        ds = cell2dataset([
            {'Subject', 'P_loglik_ch'}
            W.subjs(:), num2cell(pv(:))
            ], 'ReadVarNames', true);
        
        mkdir2(fileparts(file));
        export(ds, 'File', file, 'Delimiter', ',');
        fprintf('Saved to %s\n', file);
    end
    function v = get.p_loglik_ch(W)
        if ~isempty(W.loglik_ch_pred_perm) && ...
                ~isempty(W.loglik_ch_obs)
            v = mean(bsxfun(@ge, W.loglik_ch_pred_perm, ...
                W.loglik_ch_pred_perm(:,1)), 2);
        else
            v = [];
        end
    end
    function postprocess_res_perm(W)
        W.postprocess_res_perm_k;
        
        if strcmp(W.W_fit_class, 'Fit.Dtb.MeanRt.Main')
            W.postprocess_res_perm_ch;
        end
    end
    function postprocess_res_perm_k(W)
        for i_subj = W.n_subjs:-1:1
            ress = W.res_subj{i_subj};
            
            for i_perm = numel(ress):-1:1
                W.k_perm(i_subj, i_perm) = ress{i_perm}.th.k;
                W.se_k_perm(i_subj, i_perm) = ress{i_perm}.se.k;
            end
        end
    end
end
%% == Load RT results
methods
    function load_res_RT(W, varargin)
        opt = varargin2S(varargin, {
            'W_fit_RT', W.W_fit_RT
            'subjs', W.subjs
            'ix', []
            'to_postprocess', true
            });
        n = numel(opt.subjs);
        if isempty(opt.ix)
            ix = 1:n;
        else
            ix = opt.ix;
        end
        
        % Load results for each subject
        Main = opt.W_fit_RT;
%         S0 = W.get_S0_file;
        
        subjs = opt.subjs;
        n = numel(subjs);
        
        for ii = n:-1:1
            ix1 = ix(ii);
            
            subj = subjs{ii};
            Main.subj = subj;
            
            file = Main.get_file;
            fprintf('Loading RT results from %s\n', file);
            L = load(file, 'res');
            
            W.res_RT{ix1} = L.res;
            W.L_RT{ix1} = L;
        end
        
        if opt.to_postprocess
            W.postprocess_res_RT;
        end
    end
    function postprocess_res_RT(W)
        for ii = W.n_subjs:-1:1
            W.k_RT(ii) = W.res_RT{ii}.th.k;
            W.se_k_RT(ii) = W.res_RT{ii}.se.k;
        end
    end
    function v = get.n_subjs(W)
        v = numel(W.subjs);
    end
    function set.W_fit_RT_class(W, v)
        if ~strcmp(class(W.W_fit_RT), v)
            W.W_fit_RT = feval(v);
        end
    end
end
%% == Load and summarize ch
methods
    function postprocess_res_perm_ch(W)
        for i_subj = W.n_subjs:-1:1
            ress = W.res_subj{i_subj};
            L = W.L_perm{i_subj};
            
            W_orig = L.W;
            W_orig.Data.load_data;
            W_orig.get_cost;
            
            %%
            ch_obs = vVec(W_orig.Data.obs_ch);
            n_obs = vVec(W_orig.Data.obs_n);
            y_obs = [ch_obs .* n_obs, n_obs];

            fun_llk = @(ch_pred) bml.stat.glmlik_binomial([], y_obs, ch_pred(:));
            
            ch_pred = W_orig.ch_pred(:);
            W.loglik_ch_obs(i_subj, 1) = fun_llk(ch_pred);
            
            b_temp = glmfit(W_orig.Data.conds, y_obs, 'binomial');
            W.bias_ch_obs(i_subj, 1) = b_temp(1);
            W.slope_ch_obs(i_subj, 1) = b_temp(2);
            
            %%
            W_perm = deep_copy(W_orig);
            for i_perm = numel(ress):-1:1
                W.slope_ch_pred_perm(i_subj, i_perm) = ...
                    2 * ress{i_perm}.th.k * ress{i_perm}.th.b;
                
                W_perm.th = ress{i_perm}.th;
                W_perm.get_cost;
                
                ch_pred = W_perm.ch_pred;
                W.loglik_ch_pred_perm(i_subj, i_perm) = fun_llk(ch_pred);
            end
        end
    end
    function plot_ch_all(W)
        clf;
        W.scatter_ch;
        file = W.get_file({'plt', 'scatter_ch'});
        savefigs(file);
        
        clf;
        W.ecdf_loglik_ch;
        file = W.get_file({'plt', 'ecdf_loglik_ch'});
        savefigs(file);
    end
    function scatter_ch(W)
        x = W.slope_ch_pred_perm(:, 1);
        y = W.slope_ch_obs(:);
        plot(x, y, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
        
        axis equal;
        max_lim = max(max(x), max(y)) * 1.1;
        xlim([0, max_lim]);
        ylim([0, max_lim]);
        
        bml.plot.crossLine('NE', 0, {'--', [0 0 0] + 0.7});
        
        dif_slope_ch_perm = mean( ...
            bsxfun(@minus, W.slope_ch_pred_perm, y(:)) .^ 2, 1);
        dif_slope_ch_orig = dif_slope_ch_perm(1);
        txt_pval = Fit.Plot.pval_txt_from_tf_shuf( ...
            dif_slope_ch_perm <= dif_slope_ch_orig);
        
        txt = {
            sprintf('Mean difference^2 = %1.3g (%s)', ...
                dif_slope_ch_orig, ...
                txt_pval);
            };
        bml.plot.text_align(txt);
        bml.plot.beautify;
    end
    function ecdf_loglik_ch(W)
        loglik_ch_perm = sum(W.loglik_ch_pred_perm, 1)';
        loglik_ch_pred = sum(W.loglik_ch_pred_perm(:,1));
        
        pval = mean(loglik_ch_perm >= loglik_ch_pred);
        
        ecdf(loglik_ch_perm);
        bml.plot.crossLine('v', loglik_ch_pred);
        xlabel('Log Likelihood');
        ylabel('Cumulative Proportion');
        
        if nnz(loglik_ch_perm >= loglik_ch_pred) == 1
            op = '<=';
        else
            op = '=';
        end
        txt = {
            sprintf('Log Likelihood = %1.2g (p %s %1.2g)', ...
                loglik_ch_pred, ...
                op, ...
                pval);
            };
        bml.plot.text_align(txt, 'text_props', {
            'FontSize', 12
            });
        bml.plot.beautify;
        grid on;
    end
end
%% == Summarize
methods
    function summarize(W)
        W.stat_perm = nan(W.n_perm, 1);

        x = W.k_RT(:);
        for i_perm = W.n_perm:-1:1
            y = W.k_perm(:, i_perm);
        
            switch W.stat_summary
                case 'Pearson_rho'
                    W.stat_perm(i_perm, 1) = ...
                        corr(x, y);
                    
                case 'SqDist'
                    sq_dist = mean((y - x)  .^ 2 ./ 2);
                    W.stat_perm(i_perm, 1) = sq_dist;
            end
        end
    end
    function summarize_ch(W)
        W_fit = W.W_fit;
    end
    function v = get.p_perm(W)
        if isempty(W.stat_perm)
            v = [];
        else      
            switch W.p_perm_tail
                case 'right'
                    v = nnz(W.stat_perm >= W.stat_perm(1)) / W.n_perm;        
                case 'left'
                    v = nnz(W.stat_perm <= W.stat_perm(1)) / W.n_perm;        
                otherwise
                    error('Not implemented yet!');
            end
        end
    end
    function v = get.p_perm_tail(W)
        switch W.stat_summary
            case 'Pearson_rho'
                v = 'right';
            case 'SqDist'
                v = 'left';
            otherwise
                error('Unknown stat_summary=%s\n', W.stat_summary);
        end
    end
    function plot(W)
        ecdf(W.stat_perm(2:end));
        crossLine('v', W.stat_perm(1));
        
        switch W.p_perm_tail
            case 'right'
                text_corner = 'NW';
            case 'left'
                text_corner = 'NW';
        end
        switch W.stat_summary
            case 'Pearson_rho'
                xlim([0 1]);
        end
            
        bml.plot.text_align(W.stat_text_result, ...
            'corner', text_corner, ...
            'text_props', {
                'FontSize', 12
                });

        xlabel(W.stat_summary_label);
        ylabel(sprintf('Cumulative proportion of\npermuted results'));
            
%         txt_title = bml.plot.beautify_title(W.get_file_name({
%             'stat', W.stat_summary
%             }));
%         title(txt_title);
        
        grid on;
        bml.plot.beautify;
    end
    function save_plot(W)
        file = W.get_file({
            'plt', 'ecdf'
            'stat', W.stat_summary
            });
        savefigs(file);
    end
    function h = scatter(W0)
%         W = feval(W0.W_fit_class);
%         
%         S0_perm = rmfield(W0.W_fit_perm.get_S0_file, 'subj');
%         
%         [infos, hs] = W.post_batch(varargin2C(S0_perm), ...
%             {
%             'param', {'k'}
%             'corr_kind', {'Pearson', 'Spearman'}
%             });
%         info = infos{1};
%         h = hs{1};
%         
%         if isempty(h)
%             return;
%         end
%         delete(h.txt);
%         

%         %%
%         C0_perm = S2C(rmfield(W0.W_fit_perm.get_S0_file, 'subj'));
%         W_fit_VD = feval(W0.W_fit_perm.W_fit_class);
%         W_fit_VD.ds_models = [];
%         ds_VD = W_fit_VD.get_ds_models(C0_perm{:});
%         
%         %%
%         C0_RT = varargin2C({
%             'to_import_k', []
%             }, rmfield(W0.W_fit_RT.get_S0_file, 'subj'));
%         
%         %%
%         W0.W_fit_RT.ds_models = [];        
%         ds_RT = W0.W_fit_RT.get_ds_models(C0_RT{:});
        
        %%
        style_data = Fit.Plot.style_data;
        x = W0.k_RT(:);
        
        for ii = numel(W0.L_perm):-1:1
            y(ii,1) = W0.L_perm{ii}.res.th.k;
        end
%         y = W0.k_perm(:,1);

        h.scatter = plot(x, y, style_data{:});
        bml.plot.beautify;
        
        min_k = min([x; y]);
        max_k = max([x; y]);
        axis equal;
        xlim([0, max_k * 1]);
        ylim([0, max_k * 1.1]);
        set(gca, 'XTick', 0:10:40);
        set(gca, 'YTick', 0:10:40);
        
        h.crossLine = bml.plot.crossLine('NE', 0, {'--', 0.5 + [0 0 0]});
        
        xlabel('\kappa from RT in RT experiment');
        ylabel('\kappa from SDT in VD experiment');
        
        stat_summary0 = W0.stat_summary;
        
        W0.stat_summary = 'SqDist';
        W0.summarize;
        sqdist = W0.stat_perm(1);
        p_sqdist = W0.p_perm;
        txt_sqdist = W0.stat_text_result;
        
        W0.stat_summary = stat_summary0;
        W0.summarize;
        
%         txt = [txt_sqdist; {''}; txt_rho];
        txt = txt_sqdist;
        bml.plot.text_align(txt, 'text_props', {'FontSize', 12});
        
%         info = packStruct(rho, p_rho, sqdist, p_sqdist, txt);

%         info = bml.oop.copyprops(info, ...
%             packStruct(rho, p_rho, sqdist, p_sqdist, txt));
    end
    function relabel_scatter(W)
        %%
%         uiopen('Data/Fit.Dtb.PermuteCoh.Summarize/sbjs={S1,S2,S3,S4,S5}+prds={VD_wSDT,RT_wSDT}+rtfds={SDT_ClockOn,RT}+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=0+absc=1+nprm=401+ftcl=Fit^Dtb^Main+plt=scatter.fig',1)
        
        %%
%         xlabel('\kappa from RT in free-response task');
%         ylabel('\kappa from SDT in controlled-duration task');
        ylabel({'\kappa from t_{SD}','of the controlled-duration task'});
        xlabel({'\kappa from RT', 'in the free-response task'});
        
        %%
        hs = figure2struct(gcf);
        delete(hs.text);
        
        %%
        file = 'Data/Fit.Dtb.PermuteCoh.Summarize/sbjs={S1,S2,S3,S4,S5}+prds={VD_wSDT,RT_wSDT}+rtfds={SDT_ClockOn,RT}+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=0+absc=1+nprm=401+ftcl=Fit^Dtb^Main+plt=scatter+lbl=CDFR';
        savefigs(file, ...
            'PaperPosition', ...
                [0, 0, Fit.Plot.Print.width_column1_cm + zeros(1,2)], ...
            'ext', {'.fig', '.png', '.tif'});        
    end
    function save_scatter(W)
        % Removed too long field
        file = W.get_file({'plt', 'scatter', 'thf', []});
%         savefigs(file);
        savefigs(file, ...
            'PaperPosition', ...
                [0, 0, Fit.Plot.Print.width_column1_cm + zeros(1,2)], ...
            'ext', {'.fig', '.png', '.tif'});
    end
    function v = get.stat_summary_label(W)
        switch W.stat_summary
            case 'Pearson_rho'
                v = 'Pearson \rho';
            case 'SqDist'
                v = sprintf('Mean of Dist^2 \nfrom the Identity Line');
            case {'LogLikCh'}
                v = 'Log Likelihood';
            otherwise
                v = strrep(W.stat_summary, '_', '-');
        end
    end
    function v = get.stat_text_result(W)
        if isempty(W.stat_perm)
            v = {};
        else
            if W.p_perm == 1 / W.n_perm
                p_op = '\leq';
            else
                p_op = '=';
            end
            v = {
                sprintf('%s = %1.2g\n(p %s %1.2g)', ...
                    W.stat_summary_label, W.stat_perm(1), ...
                    p_op, W.p_perm)
                };
        end
    end
end
%% == Save
methods
    function save_mat(W)
        file = [W.get_file '.mat'];
        mkdir2(fileparts(file));
        fprintf('Saving to %s\n', file);
        save(file, 'W');
    end
    function fs = get_file_fields(W)
        fs = [
            {
            'subjs', 'sbjs'
            'parads', 'prds'
            'rt_fields', 'rtfds'
            }
            W.W_fit.get_file_fields
            {
            'abs_cond', 'absc'
            'n_perm', 'nprm'
            'W_fit_class', 'ftcl'
            }
            ];
        fs = fs(~ismember(fs(:,1), {'subj', 'parad', 'rt_field'}), :);
    end
    function v = get.parads(W)
        v = {W.W_fit_perm.parad, W.W_fit_RT.parad};
    end
    function v = get.rt_fields(W)
        v = {W.W_fit_perm.rt_field, W.W_fit_RT.rt_field};
    end
end
end