classdef ShuffleDeltaSDT ...
    < Fit.PerturbPred.PerturbPredIndiv
%% Settings
properties
    n_perm = 1000;
    seed_perm = 0;
    sim_kind = 'mean_abs_dev'; % pearson_rho'; % measure of similarity. On abscissa.
    sim_kind_color = 'r2'; % 'r2': R^2 % As color
end
%% Internal
properties
    obs_mean_rt_accu0
    obs_mean_rt_accu_vec0
    
    to_use_sim_pred = false; % true;
end
%% Results
properties
    perms = []; % (perm, rank)
    sdts = []; % (perm, cond)
    
%     res % original result, inherited from PerturbPredIndic
    ress = {}; % (perm, 1);
    
    pred_mean_rt_orig % (1, cond)
    pred_mean_rt_perm % (perm, cond)
    
    sim_perm = []; % (i_perm,1) : Similarity btw shuffled vs original SDTs
    sim_perm_pred = []; % (i_perm,1) : Similarity btw predicted SDTs from the fit
end
%% Init
methods
    function W = ShuffleDeltaSDT(varargin)
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function init(W0, varargin)
        W0.init@Fit.PerturbPred.PerturbPredIndiv(varargin{:});
        
        W = W0.W;
        W0.obs_mean_rt_accu0 = W.obs_mean_rt_accu;
        W0.obs_mean_rt_accu_vec0 = W.obs_mean_rt_accu_vec;
    end
end
%% Main
methods
    function batch(W0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs_w_SDT_modul
            });
        [Ss, n] = factorizeS(S_batch);
        for ii = 1:n
            C = S2C(Ss(ii));
            W = feval(class(W0), C{:});
            W0.W_now = W;
            
            W.main;
        end
    end
    function main(W0, varargin)
        S = varargin2S(varargin, {
            'new_fit', isempty(W0.ress)
            });
        
        W0.get_llk_orig;        
        W0.get_sdts_perm;
        
        if S.new_fit
            W0.get_res_perm;
        end
        
        W0.get_llk_perm;
        W0.get_sim_perm;
        
        if S.new_fit
            W0.save_mat;
        end
        W0.plot_and_save_all;
    end
    function get_sdts_perm(W0)
        W = W0.W;
        
        sdts = W.obs_mean_rt_accu_vec;
        [sdt_sorted, orig2sorted] = sort(sdts);
        [~, sorted2orig] = sort(orig2sorted);
        deltas = diff(sdt_sorted);
        n_cond = numel(sdt_sorted);
        n_diff = numel(deltas);
        min_sdt = min(sdts);
        
        %%
        rng(W0.seed_perm);
        perms = zeros(W0.n_perm, n_diff);
        for i_perm = 1:W0.n_perm
            perms(i_perm, :) = randperm(n_diff);
        end
        W0.perms = perms;
        
        %%
        W0.sdts = zeros(W0.n_perm, n_cond);
        for i_perm = 1:W0.n_perm
            perm1 = W0.perms(i_perm, :);
            sdts_perm_sorted = min_sdt + cumsum([0; vVec(deltas(perm1))]);
            sdts1 = sdts_perm_sorted(sorted2orig);
            
            W0.sdts(i_perm, :) = sdts1;
        end
    end
    function get_res_perm(W0)
        n_perm = W0.n_perm;
        sdts = W0.sdts;
        obs_mean_rt_accu0 = W0.obs_mean_rt_accu0;
        
        ress = cell(W0.n_perm, 1);
        parfor i_perm = 1:W0.n_perm
            fprintf('Starting %d/%d\n', i_perm, n_perm);
            
            W = W0.W;
            sdts1 = sdts(i_perm, :);
            W.obs_mean_rt_accu_vec_ = sdts1;
            W.obs_mean_rt_accu_ = obs_mean_rt_accu0;
            W.obs_mean_rt_accu_(~isnan(obs_mean_rt_accu0)) = sdts1;
            
%             W.to_use_analytic_cost = true;
            W.Fl = [];
            W.fit;
            
            ress{i_perm} = W.Fl.res;
        end
        
        W0.ress = ress;
    end
    function get_llk_orig(W0)
        W0.W.th = W0.res.th;
        W0.W.pred;
        W0.llk0 = W0.get_llk_ch(W0.W);
        W0.pred_mean_rt_orig = W0.W.rt_mean_pred(:,1)';
    end
    function get_llk_perm(W0)
        W = W0.W;
        
        W0.llk = nan(W0.n_perm, 1);
        for i_perm = 1:W0.n_perm
            W.to_use_analytic_cost = false; % DEBUG
            W.th = W0.ress{i_perm}.th;
            W.pred;
            
            W0.llk(i_perm) = W0.get_llk_ch(W);
            W0.pred_mean_rt_perm(i_perm, :) = W.rt_mean_pred(:,1)';
        end
    end
    function get_sim_perm(W0)
        W0.sim_perm = nan(W0.n_perm, 1);
        W0.sim_perm = W0.calc_sim_perm(W0.sim_kind, false);
        W0.sim_perm = W0.calc_sim_perm(W0.sim_kind, true);
    end
    function sim = calc_sim_perm(W0, sim_kind, is_pred)
        % sim = calc_sim_perm(W0, sim_kind, is_pred)
        %
        % sim(1, i_perm)
        % sim_kind: 'pearson_rho', 'mean_abs_dev', 'r2'
        % is_pred: true if about predicted; false if about observed
        if is_pred
            orig = W0.pred_mean_rt_orig;
            perm = W0.pred_mean_rt_perm;
        else
            orig = W0.obs_mean_rt_accu_vec0;
            perm = W0.sdts;
        end
        n_perm = W0.n_perm;
        sim = zeros(1, n_perm);
        n_cond = numel(orig);
        for i_perm = 1:n_perm
            switch sim_kind
                case 'pearson_rho'
                    sim(i_perm) = corr(perm(i_perm, :)', orig(:));
                    
                case 'mean_abs_dev' % in ms
                    sim(i_perm) = mean(abs(perm(i_perm, :)' - orig(:))) ...
                        * 1e3;
                    
                case 'r2'
                    % Regress permuted with original
                    [~,~,~,~,stat] = regress(perm(i_perm, :)', ...
                        [ones(n_cond,1), orig(:)]);
                    sim(i_perm) = stat(1);
                    
                otherwise
                    error('Unknown sim_kind = %s\n', W0.sim_kind);
            end
        end
    end
end
%% Saving
methods
    function L = get_struct2save(W0)
        L = copyFields( ...
            W0.get_struct2save@Fit.PerturbPred.PerturbPredIndiv, ...
            W0, {
                'n_perm'
                'seed_perm'
                'sim_kind'
                'obs_mean_rt_accu0'
                'obs_mean_rt_accu_vec0'
                'pred_mean_rt_orig'
                'pred_mean_rt_perm'
                'perms'
                'sdts'
                'sim_perm'
                'sim_perm_pred'
                'to_use_sim_pred'
                'ress'
                });
    end
    function fs = get_file_fields(W0)
        fs = union_general( ...
            W0.get_file_fields@Fit.PerturbPred.PerturbPredIndiv, {
            'to_use_sim_pred', 'smprd'
            'n_perm', 'nprm'
            }, 'stable', 'rows');
    end
end
%% Plot
properties (Dependent)
    sim_label
end
methods
    function plot_and_save_all(W0)
        for kind = {
                'sim_vs_llk'
                }'
            clf;
            W0.(['plot_' kind{1}]);
            file_fig = W0.get_file({'plt', kind{1}});
            savefigs(file_fig);
        end
%         W0.plot_sim_vs_llk;
    end
    function plot_sim_vs_llk(W0)
%         if W0.to_use_sim_pred
%             sim = W0.sim_perm_pred;
%         else
%             sim = W0.sim_perm;
%         end
        sim = W0.calc_sim_perm(W0.sim_kind, W0.to_use_sim_pred);
        cols = W0.calc_sim_perm(W0.sim_kind_color, true);
        x = sim;
        y = W0.llk - W0.llk0;
        
        scatter(x, y, [], cols, 'filled');
        colormap('jet');
        
%         plot(sim, y, 'ko');
        hold on;
        h = crossLine('h', 0, 'k-'); % W0.llk0, 'r-');
        uistack(h, 'top');
        hold off;
        
        xlabel(W0.sim_label);
        ylabel('Log likelihood ratio of predicted choice');
        bml.plot.beautify;
        
        % Plot logLR <= -10
        max_sim = max(sim);
        hold on;
        plot([0, max_sim], [-10, -10], 'k--', 'LineWidth', 1);
        hold off;
        
        %% Plot regression line
        b = glmfit(x, y, 'normal');
        x_intercept = -b(1) / b(2);
        x_regr = [x_intercept, max(x)];
        y_regr = b(1) + b(2) * x_regr;
        hold on;
        plot(x_regr, y_regr, 'b-', 'LineWidth', 1);
        hold off;
        
        %% ylim
%         bml.plot.lim_robust('xy', 'x');
%         bml.plot.lim_robust('xy', 'y');
        
        y_min = min(floor(y / 50) * 50);
        y_max = -y_min / 5;
        ylim([y_min, y_max]);

        %% xlim
        switch W0.sim_kind
            case 'mean_abs_dev'
                xlim([0, 100]);
        end
    end
    function v = get.sim_label(W0)
        switch W0.sim_kind
            case 'pearson_rho'
                v = 'Pearson \rho';
                if W0.to_use_sim_pred
                    v = [v, ' between fitted t_{SD}s'];
                else
                    v = [v, ' between the permuted and original t_{SD}s'];
                end
            case 'mean_abs_dev'
                v = 'Average absolute perturbation (ms)';
            otherwise
                error('Unsupported sim_kind=%s\n', W0.sim_kind);
        end
    end
end
%% Group analysis
methods
    function batch_group_stat(W0)
        subj = Data.Consts.subjs_w_SDT_modul(:);
        n = numel(subj);
        ress = cell(n, 1);
        for ii = n:-1:1
            file = W0.get_file({
                'sbj', subj{ii}
                });
            ress{ii} = load(file);
        end
        ress = [ress{:}];
        
        %%
        cor = zeros(n, 1);
        pval_cor = zeros(n, 1);
        
        llk0_all = [ress.llk0];
        llk_all = cell2mat({ress.llk});
        llk0_sum = sum(llk0_all);
        llk_sum = sum(llk_all, 2);
        pval_llk_sum = mean(llk_sum >= llk0_sum);
        pval_llk = mean(bsxfun(@ge, llk_all, llk0_all));
        
        sim_perm = cell2mat({ress.sim_perm});
        
        for ii = 1:n
            [cor(ii), pval_cor(ii)] = ...
                corr(sim_perm(:,ii), llk_all(:,ii), 'type', 'Kendall');
        end
        
        %%
        pval_cor = pval_cor(:);
        pval_llk = pval_llk(:);
        file = W0.get_file({
            'sbj', subj
            'kind', 'sim_vs_llk'
            });
        ds = dataset(subj, cor, pval_cor, pval_llk);
        export(ds, 'File', [file, '.csv'], 'Delimiter', ',');
        fprintf('Saved to %s.csv\n', file);
        
        %%
        fid = fopen([file, '.txt'], 'w');
        fprintf(fid, 'pval_llk_sum = %1.2g\n', pval_llk_sum);
        fprintf('Saved to %s.txt\n', file);
    end
    function batch_plot(W00)
        %%
        subj = Data.Consts.subjs_w_SDT_modul(:);
        n = numel(subj);
        ress = cell(n, 1);
        for ii = n:-1:1
            file = W00.get_file({
                'sbj', subj{ii}
                });
            ress{ii} = load(file);
        end
        ress = [ress{:}];
        
        %%
        for ii = 1:n
            W0 = feval(class(W00), 'subj', subj{ii});
            copyprops(W0, ress(ii));
            
            W0.main;
        end
    end
end
%% Imgather
methods
    function imgather_sim_vs_llk(W0)
        %%
        subj = Data.Consts.subjs_w_SDT_modul(:);
        axs = W0.imgather({}, {
            'sbj', subj
            }, {}, {
            'plt', 'sim_vs_llk'
            ... 'nprm', 4
            });
        axs = axs{1}; % page 1
        
        %%
        n = numel(axs);
        
        for ii = 1:n
            ax1 = axs(ii);
            
            if ii > 1
                xlabel(ax1, '');
                ylabel(ax1, '');
            end
            
%             bml.plot.lim_robust('ax', ax1, 'xy', 'x');
%             bml.plot.lim_robust('ax', ax1, 'xy', 'y');
            
            title(ax1, sprintf('Subject %d\n ', ii));
        end
        
        %%
        bml.plot.position_subplots(axs, ...
            'margin_top', 0.15, ...
            'margin_left', 0.08, ...
            'margin_bottom', 0.2);
        file = W0.get_file({
            'sbj', subj
            'plt', 'imgather'
            'kind', 'sim_vs_llk'
            });
        savefigs(file, ...
            'size', [50 + 200 * n, 200]);        
    end
end
end