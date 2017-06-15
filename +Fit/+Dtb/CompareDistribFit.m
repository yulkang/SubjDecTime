classdef CompareDistribFit < Fit.Dtb.Main
%% Settings
properties
    fit_orig_files = {
        'Data/Fit.Dtb.Main/sbj=S1+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=betamean+tnd=gamma+ntnd=1+bayes=none+lps0=1+igch=0+imk=0+bch=0.mat'
        'Data/Fit.Dtb.Main/sbj=S2+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=betamean+tnd=gamma+ntnd=1+bayes=none+lps0=1+igch=0+imk=0+bch=0.mat'
        'Data/Fit.Dtb.Main/sbj=S3+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=betamean+tnd=gamma+ntnd=1+bayes=none+lps0=1+igch=0+imk=0+bch=0.mat'
        'Data/Fit.Dtb.Main/sbj=S4+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=betamean+tnd=gamma+ntnd=1+bayes=none+lps0=1+igch=0+imk=0+bch=0.mat'
        'Data/Fit.Dtb.Main/sbj=S5+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=betamean+tnd=gamma+ntnd=1+bayes=none+lps0=1+igch=0+imk=0+bch=0.mat'
        };
    
    i_subj = 1;
    n_boot = 200;
    seed = 0;
    
    max_shift_rel = .4;

    % divergence_kinds
    % 'orig': Original JS divergence between data and pred. Simply means that the fitting works.
    % 'matched_ch': After matching ch proportion. Simply means that the fitting works.
    % 'best_shift': Minimum divergence among possible shifts to exclude the possibility that the fitting only fits the mean.
    % 'match_mean': Match mean to exclude the possibility that the fitting only fits the mean.
    divergence_kinds = {'match_mean'};
end
%% Internal
properties (Dependent)
    fit_orig_file
end
properties
    L % original fit
end
%% Results
properties
    tr_boot % (tr, boot)
    
    data_pdf % (fr, ch, cond)
    pred_pdf % (fr, ch, cond)
    
    divergence % (1, kind)
    
    boot_data % {boot, 1}(fr, ch, cond)
    boot_pred % {boot, 1}(fr, ch, cond)
    
    divergence_boot % (boot, kind)
    
    shifts % (1, i_shift)
    divergence_all_shift % (i_shift, cond, ch)
    best_shift % (cond, ch)
end
%% Init
methods
    function Comp = CompareDistribFit(varargin)
        if nargin > 0
            Comp.init(varargin{:});
        end
    end
end
%% Batch plot
methods
    function batch(Comp0, varargin)
        %%
        n_subj = numel(Comp0.fit_orig_files);
        d = cell(n_subj, 1);
        d_boot = cell(n_subj, 1);
        d_ci = cell(n_subj, 1);
        d_est = cell(n_subj, 1);
        d_err = cell(n_subj, 1);
        
        for i_subj = 1:n_subj
            Comp = feval(class(Comp0));
            Comp.i_subj = i_subj;

            [d{i_subj}, d_boot{i_subj}, Comp] = Comp.main;
            d_ci{i_subj} = prctile(d_boot{i_subj}, [2.5, 97.5], 1);
            d_est{i_subj} = median(d_boot{i_subj}, 1);
            d_err{i_subj} = bsxfun(@minus, ...
                d_ci{i_subj}, d_est{i_subj});
        end
        
        %% Save text
        file = Comp0.get_file({'sbj', 1:n_subj});
        mkdir2(fileparts(file));
        
        subj = vVec(csprintf('S%d', 1:n_subj));
        ds = dataset(subj, d, d_ci, d_est, d_err);
        export(ds, 'File', [file '.csv'], 'Delimiter', ',');

        fprintf('Saved to %s.csv\n', file);
        
        %% Test difference
        n_kind = numel(Comp0.divergence_kinds);
        p_diff = nan(n_subj, n_subj, n_kind);
        ns = cellfun(@numel, d_boot);
        
        for i_kind = 1:n_kind
            for subj1 = 1:n_subj
                for subj2 = 1:n_subj
                    if subj1 ~= subj2
                        p_diff(subj1, subj2, i_kind) = ...
                            Comp.test_diff( ...
                                d_boot{subj1}(:,i_kind), ...
                                d_boot{subj2}(:,i_kind));
                    end
                end
            end
        end
        
        %% Plot best shift
        Comp0.batch_plot_best_shift;
        
        %% Plot
        d_est1 = cell2mat(d_est);
        d_err1 = permute( ...
            reshape(cell2mat(d_err), 2, n_subj, n_kind), ...
            [2, 1, 3]);
        
        %%
        for i_kind = 1:n_kind
            kind = Comp0.divergence_kinds{i_kind};
            
            clf;
            bml.plot.bar_w_error( ...
                1:n_subj, ...
                d_est1(:,i_kind), ...
                d_err1(:,1,i_kind), ...
                d_err1(:,2,i_kind));
            title({strrep(kind, '_', ' '), ' '});
            
            set(gca, 'XTickLabel', csprintf('S%d', 1:n_subj));
            ylabel('Jensen-Shannon Divergence');
            bml.plot.beautify;
            
            file = Comp0.get_file({
                'sbj', 1:n_subj
                'plt', 'bar_err'
                'knd', kind
                });
            savefigs(file);
        end
    end
    function fs = get_file_fields(Comp0)
        fs = {
            'to_match_ch', 'mch'
            };
    end
    function p = test_diff(~, samp1, samp2, varargin)
        % Gives two-sided p-value that a random sample from one vector
        % is consistently bigger than the other.
        S = varargin2S(varargin, {
            'n_sim', 1e4
            });
        
        n1 = numel(samp1);
        n2 = numel(samp2);
        r1 = randi(n1, S.n_sim, 1);
        r2 = randi(n2, S.n_sim, 1);
        r_samp1 = samp1(r1);
        r_samp2 = samp2(r2);
        
        p = mean(r_samp1 < r_samp2);
        p = min(p, 1 - p) * 2;
    end
    function batch_plot_best_shift(Comp0)
        n_subj = numel(Comp0.fit_orig_files);
        for i_subj = 1:n_subj
            Comp = feval(class(Comp0));
            Comp.i_subj = i_subj;
            [~,~,Comp] = Comp.main;
            
%             Comp.get_divergence([],[],'to_store', true);
%             Comp.bootstrap_calc_divergence;
%             Comp.save_mat;
            Comp.plot_divergence_by_shift;
        end
    end
end
%% Main - fit and get divergence
methods
    function [d, d_boot, Comp] = main(Comp)
        %% Load results if exists
        [Comp, d, d_boot] = Comp.load_mat;
        if ~isempty(d)
            n_kind_loaded = size(d, 2);
%             n_kind = numel(Fit.Dtb.CompareDistribFit.divergence_kinds);
            Comp.divergence_kinds = {'orig', 'matched_ch', 'best_shift', 'match_mean'};
            n_kind = numel(Comp.divergence_kinds);
            if n_kind_loaded < n_kind
                for i_kind = n_kind:-1:(n_kind_loaded+1)
                    kind = Comp.divergence_kinds{i_kind};
                    d(i_kind) = Comp.get_divergence([], [], ...
                        'kind', kind);
                    
                    d_boot(:,i_kind) = Comp.bootstrap_calc_divergence( ...
                        'kind', kind);
                end
                Comp.save_mat;
            end
            
            return;
        end
        
        %% Load original fit
        Comp.load_fit_orig;

        %% Get divergence
        d = Comp.get_divergence([], [], ...
            'to_store', true);
        
        %% Bootstrap w/ refit
        d_boot = Comp.bootstrap;
        
        %% Bootstrap w/o refit (deprecated)
%         % wrong: JS divergence is overestimated when not refitted
%         % (or not underestimated)
%         siz0 = size(data_pdf);
%         n_cond = siz0(3);
%         data_pdf_boot = bml.stat.bootstrap_hist( ...
%             reshape(data_pdf, [], n_cond));
%         data_pdf_boot = cellfun(@(v) reshape(v, siz0), ...
%             data_pdf_boot, 'UniformOutput', false);
%         
%         n_boot = numel(data_pdf_boot);
%         d_boot = zeros(n_boot, 1);
%         for i_boot = 1:n_boot
%             d_boot(i_boot) = Comp.get_divergence(pred_pdf, ...
%                 data_pdf_boot{i_boot});
%         end
        
        %% Output
        Comp.divergence = d;
        Comp.divergence_boot = d_boot;
        
        %% Plot
        Comp.plot_divergence_by_shift;
        
        %% Save
        Comp.save_mat;
    end
    function [Comp, d, d_boot] = load_mat(Comp)
        file = Comp.get_file({'isbj', Comp.i_subj});
        if exist([file, '.mat'], 'file') ...
                && Comp.skip_existing_fit
            L = load(file);
            fprintf('Loaded Comp from %s.mat\n', file);
            Comp = L.Comp;
            d = Comp.divergence;
            d_boot = Comp.divergence_boot;
        else
            d = [];
            d_boot = [];
        end
    end
    function [L, Fl, W] = load_fit_orig(Comp)
        file0 = Comp.fit_orig_file;
        L = load(file0);
        fprintf('Loaded %s\n', file0);
        
        Fl = L.Fl;
        Fl.res2W;
        W = Fl.W;

%         Fl.W.plot_PlotFcns; % check
        
        Comp.L = L;
        
        %% Get pred/data_pdf
        f = @(v) permute(v, [1, 3, 2]);
        pred_pdf = f(W.Data.RT_pred_pdf);
        data_pdf = f(W.Data.RT_data_pdf);
        
        Comp.pred_pdf = pred_pdf;
        Comp.data_pdf = data_pdf;
    end
    function S = get_S_divergence(~, varargin)
        S = varargin2S(varargin, {
            'kind', 'all' % 'all'|'orig'|'matched_ch'|'best_shift'
            'to_store', true % store intermediate results to Comp
            });
    end
    function d = get_divergence(Comp, pred_pdf, data_pdf, varargin)
        S = Comp.get_S_divergence(varargin{:});
        
        if nargin < 2 || isempty(pred_pdf)
            pred_pdf = Comp.pred_pdf;
        end
        if nargin < 3 || isempty(data_pdf)
            data_pdf = Comp.data_pdf;
        end
        
        switch S.kind
            case 'all'
                n_kind = numel(Comp.divergence_kinds);
                d = zeros(1, n_kind);
                
                for i_kind = 1:n_kind
                    C = varargin2C({
                        'kind', Comp.divergence_kinds{i_kind}
                        }, varargin);
                    d(i_kind) = Comp.get_divergence( ...
                        pred_pdf, data_pdf, C{:});
                end
                return;
                
            case 'match_mean'
                % Use matched_ch after shifting, 
                % and get the minimum divergence
                
                n_cond = size(pred_pdf, 3);
                n_ch = size(pred_pdf, 2);

                pred_pdf1 = zeros(size(pred_pdf));
                
                f = @(v) mean_distrib( ...
                    bsxfun(@rdivide, v + eps, sum(v + eps)));
                mean_pred = f(pred_pdf);
                mean_data = f(data_pdf);                
                shift_needed = round(mean_data - mean_pred);

                for cond = 1:n_cond
                    for ch = 1:n_ch
                        pred_pdf1(:, ch, cond) = ...
                            shift_pad( ...
                                pred_pdf(:, ch, cond), ...
                                shift_needed(1, ch, cond));
                    end
                end
                
                d = Comp.get_divergence(pred_pdf1, data_pdf, ...
                        'kind', 'matched_ch');
                
                return;                
                
            case 'best_shift'
                % Use matched_ch after shifting, 
                % and get the minimum divergence
                
                n_cond = size(pred_pdf, 3);
                n_ch = size(pred_pdf, 2);
                nt = size(pred_pdf, 1);
                
                shifts = -round(nt*Comp.max_shift_rel): ...
                                round(nt*Comp.max_shift_rel);
                n_shift = numel(shifts);

                best_shift = zeros(n_cond, n_ch);
                divs_all = nan(n_shift, n_cond, n_ch);

                pred_pdf1 = zeros(size(pred_pdf));
                
                for cond = 1:n_cond
                    for ch = 1:n_ch
                        pred0 = pred_pdf(:, ch, cond);
                        data0 = data_pdf(:, ch, cond) + eps;
                        data0 = data0 / sum(data0);
                        
                        % Consider only the shifts that include at least 
                        % min_sum_pred of the original density.
                        sum_pred0 = sum(pred0 + eps);
                        min_sum_pred = 0.9;
                        
                        divs = nan(1, n_shift);
                        
                        for i_shift = 1:n_shift
                            shift1 = shifts(i_shift);
                            pred1 = shift_pad(pred0, shift1) + eps;
                            
                            if sum(pred1) < sum_pred0 * min_sum_pred
                                continue;
                            end
                            
                            pred1 = pred1 / sum(pred1);
                            
                            divs(i_shift) = bml.math.jsdivergence( ...
                                pred1, data0);
                        end
                        
%                         d_div = diff(divs);
%                         shifts1 = shifts(1:(end-1));
%                         ix1 = find(shifts1 <= 0);
%                         ix = find((d_div(ix1) > 0), 1, 'last');
%                         if ~isempty(ix)
%                             divs(1:ix1(ix)) = nan;
%                         end
%                         
%                         shifts1 = shifts(2:end);
%                         ix1 = find(shifts1 >= 0);
%                         ix = find((d_div(ix1) < 0), 1, 'first');
%                         if ~isempty(ix)
%                             divs(ix1(ix):end) = nan;
%                         end
                        
                        [~, best_shift_ix1] = min(divs);
                        
                        pred_pdf1(:, ch, cond) = ...
                            shift_pad(pred0, shifts(best_shift_ix1));
                        divs_all(:, cond, ch) = vVec(divs);
                        best_shift(cond, ch) = shifts(best_shift_ix1);
                    end
                end
                
                if S.to_store
                    Comp.shifts = shifts;
                    Comp.divergence_all_shift = divs_all;
                    Comp.best_shift = best_shift;
                end
                
                d = Comp.get_divergence(pred_pdf1, data_pdf, ...
                        'kind', 'matched_ch');
                
                return;
        end
        
        switch S.kind
            case 'orig'
                % Match proportion of each condition
                prop_cond = sums(data_pdf, [1,2]);
                pred_pdf = pred_pdf + eps;
                pred_pdf = bsxfun(@times, ...
                    bsxfun(@rdivide, pred_pdf, sums(pred_pdf, [1,2])), ...
                    prop_cond);
                
            case 'matched_ch'
                % Match choice proportions
                prop_ch = sum(data_pdf, 1);

                pred_pdf = pred_pdf + eps;
                pred_pdf = bsxfun(@times, ...
                    bsxfun(@rdivide, pred_pdf, sum(pred_pdf, 1)), ...
                    prop_ch);
        end
        
        %% Make it a PMF with positive mass everywhere
        pred_pdf = pred_pdf + eps;
        data_pdf = data_pdf + eps;
        
        pred_pdf = pred_pdf(:) ./ sum(pred_pdf(:));
        data_pdf = data_pdf(:) ./ sum(data_pdf(:));
        
        %% Compute divergence
        d = bml.math.jsdivergence(pred_pdf(:), data_pdf(:));
    end
    function plot_divergence_by_shift(Comp)
        clf;
        d = Comp.divergence_all_shift;
        n_ch = size(d, 3);
        n_cond = size(d, 2);
        shifts = Comp.shifts;
        best_shift = Comp.best_shift;
        
        ch_names = {'Left choice', 'Right choice'};
        conds = [-51.2, -25.6, -12.8, -6.4, -3.2, 0, ...
            3.2, 6.4, 12.8, 25.6, 51.2];
        
        for ch = 1:n_ch
            for i_cond = 1:n_cond
                subplotRC(n_cond, 2, n_cond + 1 - i_cond, ch);
                
                plot(shifts * Comp.dt, d(:, i_cond, ch), 'k-');
                hold on;
                
                plot(best_shift(i_cond, ch) * Comp.dt + [0 0], ...
                    [0 1], 'k-');
                hold off;
                
                ylim([0 1]);
                xlim(shifts([1, end]) * Comp.dt);            
                bml.plot.beautify;
                xticks = get(gca, 'XTick');
                set(gca, 'XTick', [xticks(1), 0, xticks(end)]);
                
                if i_cond > 1
                    set(gca, ...
                        'XTickLabel', {'', '', ''});
                end
                set(gca, ...
                    'YTick', [0, 0.5, 1], ...
                    'YTickLabel', {'', '', ''});
                
%             set(gca, 'XTick', [xticks(1), 0, xticks(end)], ...
%                 'XGrid', 'on', 'YGrid', 'on');

                if i_cond == n_cond
                    title(ch_names{ch});
                end
                if ch == 1
                    cond = conds(i_cond);
                    if cond == 0
                        ylabel({
                            'Coherence (%)'
                            ' '
                            sprintf('%1.1f', cond)
                            });
                    else
                        ylabel(sprintf('%1.1f', cond));
                    end
                end
                if i_cond == 1 && ch == 1
                    xlabel('Shift (sec)');
                end
            end
        end
        file = Comp.get_file({'isbj', Comp.i_subj, 'plt', 'shift'});
        savefigs(file);
    end
    function save_mat(Comp)
        file = Comp.get_file({'isbj', Comp.i_subj});
        mkdir2(fileparts(file));
        
        save(file, 'Comp');
        fprintf('Saved Comp to %s\n', file);
    end
end
%% Bootstrap
methods
    function d_boot = bootstrap(Comp)
        % [d_boot, d_boot_match_ch] = bootstrap(Comp)

        Comp.bootstrap_fit;
        d_boot = Comp.bootstrap_calc_divergence;
    end
    function bootstrap_fit(Comp)
        %%
        W0 = Comp.L.Fl.W;
        ds0 = W0.Data.ds;
        
        [~,~,d_cond0] = unique(ds0.cond);
        
        rng(Comp.seed);
        Comp.tr_boot = cell2mat(bml.stat.bootstrp_ix(Comp.n_boot, d_cond0));
        
        fprintf('Beginning %d bootstrap refitting at %s\n', ...
            Comp.n_boot, datestr(now, 30));
        t_st = tic;
        
        boot_data = cell(Comp.n_boot, 1);
        boot_pred = cell(Comp.n_boot, 1);
        parfor i_boot = 1:Comp.n_boot
            [boot_data{i_boot}, boot_pred{i_boot}] = ...
                Comp.bootstrap_unit(i_boot);
            
            if mod(i_boot, 50) == 0
                fprintf('%d\n', i_boot);
            end
        end        
        
        t_el = toc(t_st);
        fprintf('\n\n');
        fprintf('%d refits done in %1.1f sec at %s\n', ...
            Comp.n_boot, t_el, datestr(now, 30));
        
        Comp.boot_data = boot_data;
        Comp.boot_pred = boot_pred;
    end
    function d_boot = bootstrap_calc_divergence(Comp, varargin)
        %%
        boot_data = Comp.boot_data;
        boot_pred = Comp.boot_pred;
        
%         n_kind = numel(Comp.divergence_kinds);
        d_boot = cell(Comp.n_boot, 1); % zeros(Comp.n_boot, n_kind);
        
        for i_boot = 1:Comp.n_boot
            C = varargin2C(varargin, {
                    'kind', 'all'
                    'to_store', false
                    });
            
%             d_boot(i_boot, :) = Comp.get_divergence( ...
            d_boot{i_boot} = Comp.get_divergence( ...
                    boot_data{i_boot}, boot_pred{i_boot}, ...
                    C{:});
        end
        d_boot = cell2mat(d_boot);
        
        if nargout == 0
            Comp.divergence_boot = d_boot;
        end
    end
    function [data_pdf, pred_pdf, res] = bootstrap_unit(Comp, i_boot)
        W0 = Comp.L.Fl.W;
        ds0 = W0.Data.ds;
        tr = Comp.tr_boot(:, i_boot);
        th0 = Comp.L.res.th;
        
        % Load if exists and tr identical
        file = Comp.get_file_boot(i_boot);
        if exist([file, '.mat'], 'file')
            L1 = load([file, '.mat']);
            
            if isequal(tr, L1.tr)
                try
                    data_pdf = L1.data_pdf;
                    pred_pdf = L1.pred_pdf;
                    res = L1.res;
                    
                    fprintf('o');
                    return;
                catch err
                    warning(err_msg(err));
                end
            end
        end
        
        % Save if fitted anew.
        ds = ds0(tr, :);
        W = W0.deep_copy;
        W.Data.ds = ds;
        W.Data.RT_data_pdf = [];
        W.th0 = th0;
        W.th = th0;
        [~, res] = W.fit;
        data_pdf = W.Data.RT_data_pdf;
        pred_pdf = W.Data.RT_pred_pdf;
        
        L1 = packStruct(tr, data_pdf, pred_pdf, res); %#ok<NASGU>
        mkdir2(fileparts(file));
        save([file, '.mat'], '-struct', 'L1');
        
        fprintf('v');
%         fprintf('Saved bootstrap result # %d to %s.mat\n', i_boot, ...
%             file);
    end
    function file = get_file_boot(Comp, i_boot)
        [pth, name] = fileparts(Comp.fit_orig_file);
        class0 = fileparts(pth);
        name1 = [name, sprintf('+bt=%d', i_boot)];
        file = fullfile('Data', class(Comp), 'boot', class0, name1);
    end
end
%% Get/Set
methods
    function v = get.fit_orig_file(Comp)
        v = Comp.fit_orig_files{Comp.i_subj};
    end
end
end