classdef CompDur < Fit.Dtb.Main
    % Compare accuracy between RDK durations
    
%% Settings
properties
    % durs_compare_msec{set} = vector of RDK durations in ms
    durs_compare_msec = {800, 200};
    to_keep_total_dur_same = false; % true;
    
    class_dtb = 'Fit.Dtb.Main';
end
%% Internal
properties (Transient)
    Ws_dtb = {}; % {set} : W of the fitted DTB
    Ls = {}; % {set}
    
    Ws_batch = {}; % {set, subj}
    Ls_batch = {}; % {set, subj}
end
%% Results
properties (Transient)
    ds_txt = dataset;
    res_accu = {};
    res_rt = {};
end
%% Methods
methods
    function W0 = CompDur(varargin)
        W0.incl_tRDKDur_msec = [200, 800];
        W0.rt_field = 'SDT_ClockOn';
        W0.parad = 'VD_wSDT';
        if nargin > 0
            W0.init(varargin{:});
        end
    end
    function batch(W0, varargin)
        C2 = varargin2C2(varargin, {
            'subj', Data.Consts.subjs
            });
        [Ss, n] = factorizeC(C2);
        
        for ii = 1:n
            C = S2C(Ss(ii));
            W = feval(class(W0), C{:});
            
            W.main;
        end
        
%         W0.imgather_ch_rt;
    end
    function main(W0)
%         W0.get_Ws_dtb;
        W0.compare_p_accu_and_rt;
%         W0.plot_and_save_all;
%         W0.compare_params;
    end
end
%% Fit DTB separately to each dur
methods
    function [Ws, Ls] = get_Ws_dtb(W0)
        durs = W0.durs_compare_msec;
        n_durs = numel(durs);
        
        W0.Ws_dtb = cell(1, n_durs);
        for i_dur = 1:n_durs
            fprintf('Getting %d/%d W_dtb:\n', i_dur, n_durs);
            [W0.Ws_dtb{i_dur}, W0.Ls{i_dur}] = W0.get_W_dtb(i_dur);
        end
        
        Ws = W0.Ws_dtb;
        Ls = W0.Ls;
    end
    function [W, L] = get_W_dtb(W0, i_dur, varargin)
        durs1 = W0.durs_compare_msec{i_dur};
        
        S0_file = W0.get_S0_file;
        S = varargin2S({
            'incl_tRDKDur_msec', durs1
            'n_tnd', 1 + strcmpStart('RT', W0.parad)
            }, S0_file);
        if W0.to_keep_total_dur_same
            S.incl_tRDK2Go_msec = 1000 - S.incl_tRDKDur_msec;
        end
        C = S2C(S);
        
        W = feval(W0.class_dtb);
        varargin2props(W, C, true);
        file = W.get_file;
        
        if exist([file '.mat'], 'file')
            L = load(file);
            fprintf('Loaded %s\n', file);
            W = L.W;
            W.pred_with_dense_cond;
            W.Fl = L.Fl;
            W.Fl.res = L.res;
        else
            W.init;
            L = packStruct(W);
        end
    end
end
%% Compare RT and accuracy between durations
methods
    function compare_p_accu_and_rt(W0, varargin)
        % Shorter duration decreases both accuracy and SDT
        
        %% Inputs
        S = varargin2S(varargin, {
            'accu_kind', 'slope' % 'raw'|'slope'
            'rt_test', 'anovan' % 'anovan'|'fitglm'
            'rt_distrib', 'normal' % 'gamma'|'normal'
            'to_correct_bias', false % true
            'ad_cond_incl', 'all' % 1:3
            'incl_tRDK2Go', 0.8
            });
 
        %% Load Ws
        Ls = W0.get_Ls_batch';
        Ws = cellfun(@(L) L.W, Ls, 'UniformOutput', false);
        W0.Ls_batch = Ls;
        W0.Ws_batch = Ws;
        
        %% Get IVs and DVs
        n_subj = size(Ws,2);
        n_dur = size(Ws,1);
        
        cond = cell(n_dur, n_subj);
        rt = cell(n_dur, n_subj);
        ch = cell(n_dur, n_subj);
        accu = cell(n_dur, n_subj);
        dur = cell(n_dur, n_subj);
        
        for i_subj = 1:n_subj
            for i_dur = 1:n_dur
                W1 = Ws{i_dur, i_subj};
                
                W1.Data.ad_cond_incl = S.ad_cond_incl;
                W1.Data.filt_ds;
                
                if S.to_correct_bias
                    cond{i_dur, i_subj} = W1.Data.cond_bias;
                else
                    cond{i_dur, i_subj} = W1.Data.cond;
                end
                rt{i_dur, i_subj} = W1.Data.rt;
                ch{i_dur, i_subj} = W1.Data.ch;
                accu{i_dur, i_subj} = sign(ch{i_dur, i_subj} - 0.5) ...
                                   == sign(cond{i_dur, i_subj});
                dur{i_dur, i_subj} = i_dur ...
                                   + zeros(size(cond{i_dur, i_subj}));
            end
        end
        
        %% Compare between durations
        tstat_accu = zeros(n_subj, 1);
        df_accu = zeros(n_subj, 1);
        
        tstat_rt = zeros(n_subj, 1);
        df_rt = zeros(n_subj, 1);
        
        res_accu = cell(n_subj, 1);
        res_rt = cell(n_subj, 1);
        
        %% Run tests
        for i_subj = 1:n_subj
            %%
            cond1 = cell2vec(cond(:,i_subj))';
            ch1 = cell2vec(ch(:,i_subj))' == 1;
            dur1 = cell2vec(dur(:,i_subj))' - 1.5;
            rt1 = cell2vec(rt(:,i_subj))';
            
            switch S.accu_kind
                case 'slope'
                    X = table(cond1, dur1, ch1);
                    res_accu1 = fitglm(X, ...
                        'ch1 ~ cond1*dur1', ...
                        'Distribution', 'binomial');
                    
%                     X = [cond1, dur1, cond1 .* dur1];
%                     res_accu1 = glmwrap(X, ch1, 'binomial');
%                     tstat_accu1 = res_accu1.stats.t(4);
%                     df_accu1 = res_accu1.stats.dfe;
                    
                case 'raw'
                    error('Not implemented yet!');
            end
            
            %%
            acond1 = abs(cond1);
            
            switch S.rt_test
                case 'anovan'
                    group = {
                        categorical(acond1)
                        categorical(dur1)
                        }';
                    [p, tbl, stats, terms] = anovan( ...
                        rt1, group, ...
                        'model', 'full', ...
                        'display', 'off');

                    rt1 = rt(:,i_subj);
                    dmean = mean(rt1{2}) - mean(rt1{1});
                    
                    res_rt1 = packStruct(p, tbl, stats, terms, dmean);
                    
                case 'fitglm'
                    X = table(acond1, dur1, rt1);
                    res_rt1 = fitglm(X, ...
                        'rt1 ~ acond1*dur1', ...
                        'Distribution', S.rt_distrib);
            end
            
%             X = [abs(cond1), dur1, abs(cond1) .* dur1];
%             res_rt1 = glmwrap(X, rt1, S.rt_distrib);
%             tstat_rt1 = res_rt1.stats.t(3);
%             df_rt1 = res_rt1.stats.dfe;
            
            res_accu{i_subj} = res_accu1;
%             tstat_accu(i_subj) = tstat_accu1;
%             df_accu(i_subj) = df_accu1;
            
            res_rt{i_subj} = res_rt1;
%             tstat_rt(i_subj) = tstat_rt1;
%             df_rt(i_subj) = df_rt1;
        end
        
        %% Fill text in a table
        subjs = cellfun(@(W) W.subj, Ws, 'UniformOutput', false);
        subjs = subjs(1,:);
        rows = cell(n_subj, 1);
        for i_subj = 1:n_subj
            res_accu1 = res_accu{i_subj};
            res_rt1 = res_rt{i_subj};
            
            row1 = struct;
            row1.subj = sprintf('S%d', i_subj);
            
            coi = res_accu1.Coefficients(4,:);
            row1.cond_x_dur_on_accuracy = sprintf('%1.1f +- %1.1f (p = %1.2g)', ...
                coi.Estimate, coi.SE, coi.pValue);
%             row1.cond_x_dur_on_accuracy = sprintf('%1.1f +- %1.1f %s', ...
%                 coi.Estimate, coi.SE, bml.str.pval2marks(coi.pValue));

            switch S.rt_test
                case 'anovan'
                    f_report = @(row) sprintf( ...
                        'F(%d,%d) = %1.1f (p = %1.2g)', ...
                        res_rt1.tbl{row,3}, res_rt1.tbl{5,3}, ...
                        res_rt1.tbl{row,6}, res_rt1.tbl{row,7});
                    
                    row1.dur_on_SDT = f_report(3);
                    row1.abs_cond_x_dur_on_SDT = f_report(4);
                    row1.dmean_msec = sprintf('%1.0f', ...
                        res_rt1.dmean * 1e3);
                    
                case 'fitglm'
                    coi = res_rt1.Coefficients(3,:);
                    row1.dur_on_SDT = sprintf('%1.1f +- %1.1f %s', ...
                        coi.Estimate, coi.SE, ...
                        bml.str.pval2marks(coi.pValue));

                    coi = res_rt1.Coefficients(4,:);
                    row1.abs_cond_x_dur_on_SDT = sprintf('%1.1f +- %1.1f %s', ...
                        coi.Estimate, coi.SE, ...
                        bml.str.pval2marks(coi.pValue));

                    row1.df = sprintf('%d', res_accu1.DFE);
            end            
            rows{i_subj} = row1;
        end
        ds_txt = bml.ds.from_Ss(rows);
        W0.ds_txt = ds_txt; % Cache for convenience
        W0.res_accu = res_accu;
        W0.res_rt = res_rt;
        
        disp(ds_txt);

        %% Write to files
        file = W0.get_file({
            'sbj', subjs
            'tbl', 'glm_comp_dur'
            'ack', S.accu_kind
            'rtt', S.rt_test
            ... 'rtd', S.rt_distrib
            'crb', S.to_correct_bias
            'dif', S.ad_cond_incl
            });
        mkdir2(fileparts(file));
        export(ds_txt, 'File' ,[file, '.csv'], 'Delimiter', 'tab');
        save([file, '.mat'], 'ds_txt', 'res_accu', 'res_rt');
        fprintf('Saved to %s.csv and .mat\n', file);
    end
end
%% Plot comparing durations
methods
    function plot_and_save_all(W0)
        for kind = {'rt', 'ch'}
            %%
            clf;
            W0.plot_sep(kind{1});
            file = W0.get_file({'plt', kind{1}});
            savefigs(file);
        end
    end
    function plot_sep(W0, kind, varargin)
        S = varargin2S(varargin, {
            'colors', {
                'k'
                bml.plot.color_lines('c')
                }
            'jitter', {
                -0.002
                0.002
                }
            });
        
        if nargin < 2
            kind = 'rt'; % 'rt'|'ch'| ...
        end
        
        %%
        durs = W0.durs_compare_msec;
        n_durs = numel(durs);
        Ws = W0.Ws_dtb;
        
        for ii = 1:n_durs
            W = Ws{ii};
            h = W.(['plot_' kind]);
            
            color = S.colors{ii};
            jitter = S.jitter{ii};
            
            set(h.data, 'MarkerFaceColor', color);
            set(h.err, 'Color', color);
            set(h.pred, 'Color', color);
            
            bml.plot.shift_line(h.data, jitter, 0);
            bml.plot.shift_line(h.err, jitter, 0);
            
            hold on;
        end
        hold off;
    end
end
%% Imgather
methods
    function ax = imgather_ch_rt(W0, batch_args)
        if ~exist('batch_args', 'var')
            batch_args = {};
        end
        S_batch = varargin2S(batch_args, {
            'subj', Data.Consts.subjs
            'kind', {'rt', 'ch'}
            'ylabel', {{'Subjective', 'Decision Time (s)'}, 'P_{right}'}
            });
        n_subj = numel(S_batch.subj);
        n_kind = numel(S_batch.kind);
        
        clf;
        ax = ghandles(n_kind, n_subj);
        for i_subj = 1:n_subj
            subj = S_batch.subj{i_subj};
            
            C = varargin2C({
                'subj', subj
                });
            W = feval(class(W0));
            varargin2props(W, C, true);
            
            for i_kind = 1:n_kind
                kind = S_batch.kind{i_kind};
                
                ax1 = subplotRC(n_kind, n_subj, i_kind, i_subj);
                
                file = W.get_file({'plt', kind});
                ax1 = openfig_to_axes(file, ax1);
                ax(i_kind, i_subj) = ax1;
            end
        end
        
        %%
        n_row = size(ax, 1);
        n_col = size(ax, 2);
        for row = 1:n_row
            for col = 1:n_col
                ax1 = ax(row, col);

                h = figure2struct(ax1);
                set(h.marker, 'MarkerSize', 4, 'LineWidth', 0.25);
                set(h.segment_vert, 'LineWidth', 0.25);
                set(h.nonsegment, 'LineWidth', 1);
                set(ax1, 'FontSize', 9);

                if row ~= n_row || col ~= round(n_col / 2)
                    xlabel(ax1, '');
                else
                    if ~iscell(ax1.XLabel.String)
                        ax1.XLabel.String = {' ', ax1.XLabel.String};
                    end
                end
                if col == 1
                    ylabel(ax1, S_batch.ylabel{row});
                else
                    ylabel(ax1, '');
                end
                if row == 1
                    title(ax1, sprintf('S%d', col));
                else
                    title(ax1, '');
                end
                if row ~= n_row
                    set(ax1, 'XTickLabel', []);
                end
            end
        end
        
        %% Place axes
        bml.plot.position_subplots(ax, ...
            'btw_row', 0.05, ...
            'btw_col', 0.05, ...
            'margin_left', 0.1, ...
            'margin_bottom', 0.17, ...
            'margin_right', 0.025, ...
            'margin_top', 0.07);
            
        %% Legend
        ax1 = ax(1,1);
        hs = bml.plot.figure2struct(ax1);
        hline1 = findobj(hs.nonsegment, 'Color', bml.plot.color_lines('c'));
        hline(1) = hline1(1);
        hline1 = findobj(hs.nonsegment, 'Color', 'k');
        hline(2) = hline1(1);
%         h_legend = legend(ax(1,1), hline, {'\kappa fixed', '\kappa free'}, ...
%             'Location', 'NorthEast');
%         pos_legend = get(h_legend, 'Position');
%         set(h_legend, 'Position', [0.22, pos_legend(2), 0.005, pos_legend(4)]);
        
        %%
        [legend_h, object_h] = legendflex(hline, {'0.2s', '0.8s'}, ...
            'xscale', 0.2, ...
            'buffer', [0.025, -0.073], ...
            'bufferunit', 'normalized', ...
            'anchor', {'ne', 'ne'} , ...
            'title', 'Stimulus');
%             'title', 'Duration');
            
        %%
        
        set(gcf, 'ResizeFcn', []);
        
        legend_h.Position(1) = legend_h.Position(1) + 8;
        legend_h.Position(2) = legend_h.Position(2) + 18;
        legend_h.Position(3) = legend_h.Position(3) - 8;
        legend_h.Position(4) = legend_h.Position(4) - 2;

%         legend_h.Position(1) = legend_h.Position(1) - 2; % + 3;
%         legend_h.Position(2) = legend_h.Position(2) + 5; % + 18;
%         legend_h.Position(3) = legend_h.Position(3) - 0; % - 2;
%         legend_h.Position(4) = legend_h.Position(4) - 0; % - 2;
        
        %%
        hs = figure2struct(legend_h);
        for ii = 1:numel(hs.text)
            text1 = hs.text(ii);
            text1.Position(2) = text1.Position(2) - 3;
        end
        hs.text(1).Position(2) = hs.text(1).Position(2) - 3.5;
        hs.text(2).Position(2) = hs.text(2).Position(2) + 0;
        hs.text(3).Position(2) = hs.text(3).Position(2) + 0;
        
        hs.text(1).Position(1) = hs.text(1).Position(1) - 0.6;
%         
        %%
        for ii = 1:numel(hs.line)
            bml.plot.shift_line(hs.line, 0, -0.7);
        end
        
        %%
        file = W.get_file({'sbj', S_batch.subj, 'plt', S_batch.kind});
        
        C = {file, 'PaperPosition', [0, 0, 18.3, 3 * n_row + 1.5], ...
            'ext', {'.fig', '.png', '.tif'}};
        savefigs(C{:}, 'to_save', false); % resize only
        
        %%
        
        savefigs(C{:}, 'to_resize', false); % save only
    end
    function f_shift_legend(~, fun, legend_h, varargin)
        fun();

        legend_h.Position(2) = legend_h.Position(2) + 5;
    end    
end
%% Compare and tabulate parameters
methods
    function compare_params(W0)
        Ls = W0.get_Ls_batch;
        
        %%
        [ds, ds_txt] = W0.compare_params_from_Ls(Ls');
    end
    function Ls = get_Ls_batch(W0)
        S_batch = varargin2S({
            'subj', Data.Consts.subjs
            });
        subjs = S_batch.subj;
        n_subj = numel(subjs);
        durs = W0.durs_compare_msec;
        n_dur = numel(durs);
        Ls = cell(n_subj, n_dur);    
        
        for ii = 1:n_subj
            subj = subjs{ii};
            
            S0_file = W0.get_S0_file;
            S0_file.subj = subj;
            C0_file = S2C(S0_file);
            W = feval(class(W0), C0_file{:});
            [~, Ls1] = W.get_Ws_dtb;
            Ls(ii,:) = Ls1(:)';
        end
    end
end
%% Save
methods
    function fs = get_file_fields(W0)
        fs = [
            W0.get_file_fields@Fit.Common.CommonWorkspace
            {
            'durs_compare_msec', 'dcmp'
            'to_keep_total_dur_same', 'kdr'
            }];
    end
end
end