classdef Main ...
        < Fit.Common.CommonWorkspace
properties (Transient)
    P
    G
    dsTr
end
properties 
    res
end
properties (Dependent)
    t_probe
    t_resp
end
%% Batch
methods
    function [S_batch, Ss, n] = get_S_batch(~, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            });
        [Ss, n] = bml.args.factorizeS(S_batch);
    end
    function batch(W0, varargin)
        [~, Ss, n] = W0.get_S_batch(varargin{:});
        
        for ii = 1:n
            W = feval(class(W0));
            W0.W_now = W;
            
            S = Ss(ii);
            C = S2C(S);
            
            W.main(C{:});
        end
    end
    function W = Main(varargin)
        W.parad = 'BeepFreeChoiceGo_longDelay4'; % 'BeepOnly_longDelay4';
        W.data_file_type = 'orig'; % 'addCols';
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function main(W, varargin)
        W.init(varargin{:});
        W.fit;
        W.plot_and_save_all;
    end
    function plot_and_save_all(W)
        clf;
        W.plot;
        title(bml.str.wrap_text(strrep(W.get_file_name, '_', '-')));
        file_fig = W.get_file({'plt', 't_orig'});
        savefigs(file_fig);
        
        W.save_res;
    end
    function [files, Ls] = get_batch_files(W0, varargin)
        % [files, Ls] = get_batch_files(W0, varargin)
        
        [~, Ss, n] = W0.get_S_batch(varargin{:});
        Ls = cell(n, 1);
        for ii = 1:n
            C = S2C(Ss(ii));
            W = feval(class(W0), C{:});
            file = W.get_file;
            
            files{ii} = file;
            if nargout >= 2
                Ls{ii} = load(file);
            end
        end
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
            
            res = copyFields(struct, L.res, {'b', 'bint', 'rsq', 'fstat', 'p'});
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
%% Init / Loading data
methods
    function init(W, varargin)
        bml.oop.varargin2props(W, varargin, true);
        W.load_data;
    end
    function load_data(W)
        file = W.get_file_data;

        fprintf('Loading %s\n', file);
        L = load(file);

        W.G = L.G;
        W.dsTr = L.obTr;

        tr_incl = W.dsTr.succT ...
               & ~isnan(W.dsTr.SDT_ClockOn) ...
               & ~isnan(W.dsTr.angSDT_ClockOn);

        W.dsTr = W.dsTr(tr_incl, :);
    end
    function file = get_file_data(W)
        file = fullfile('Data/Expr', ...
            [W.parad '_' W.data_file_type '_' W.subj]);
    end
end
%% Calculation
methods
    function fit(W)
        n = size(W.dsTr, 1);
        
        x = W.t_probe;
        y = W.t_resp;
        
        [b, bint, r, rint, stats] = ...
            regress(y, [ones(n,1), x]);
        
        rsq = stats(1);
        fstat = stats(2);
        p = stats(3);
        
        res_glm = bml.stat.glmwrap(x, y, 'normal');
        
        sd = std(y - x);
        se_sd = sestd(y - x);
        
        mdl = fitglm(x, y);
        
        W.res = packStruct(b, bint, r, rint, rsq, fstat, p, res_glm, ...
            sd, se_sd, mdl);
    end
    function v = get.t_probe(W)
        if isempty(W.dsTr)
            v = [];
        else
            v = W.dsTr.tProbe;
        end
    end
    function v = get.t_resp(W)
        if isempty(W.dsTr)
            v = [];
        else
            v = W.dsTr.SDT_ClockOn;
        end
    end
end
%% Table
methods
    function tabulate(W0, varargin)
        %%
        [~, Ls] = W0.get_batch_files(varargin{:});
        n = numel(Ls);
        
        %%
        clear row rows
        for ii = n:-1:1
            L = Ls{ii};
            res0 = L.res;
            res = L.res.res_glm;
            
            row.Subject = sprintf('S%d', ii);
            row.Slope = sprintf('%1.2f +- %1.2f', ...
                res.b(2), res.se(2));
            row.Offset = sprintf('%1.2f +- %1.2f', ...
                res.b(1), res.se(1));
            row.R2 = sprintf('%1.2f', res0.rsq);
            row.p = sprintf('%1.2g', res0.p(end));
            row.Stdev = sprintf('%1.2f +- %1.2f', ...
                res0.sd, res0.se_sd);
            rows(ii) = row;
        end
        ds = bml.ds.from_Ss(rows);
        
        %%
        subjs = cellfun(@(L) L.W.subj, Ls, 'UniformOutput', false);
        file = W0.get_file({'sbj', subjs, 'tbl', 'glm'});
        export(ds, 'File', [file, '.csv'], 'Delimiter', ',');
        fprintf('Table saved to %s.csv\n', file);
    end
end
%% Plot
methods
    function plot(W)
        plot(W.t_probe, W.t_resp, 'o');
        
        pWin = W.G.probeWin;
        tProbeMax = max(W.dsTr.tProbe);
        
        xlim([pWin(1), tProbeMax+pWin(2)]);
        ylim(xlim);
        axis square;
        crossLine('NE', 0, {'-', [0.7 0.7 0.7]});
        crossLine('NE', pWin, {'--', [0.7 0.7 0.7]});
        bml.plot.beautify;

        xlabel('Actual Probe Onset (s)');
        ylabel('Reported probe onset (s)');
        box off; set(gca, 'TickDir', 'out');

        b = W.res.b;
        bint = W.res.bint;
        rsq = W.res.rsq;
        
        timeEq = sprintf('y = %1.2f + %1.2fx (R^2=%1.2f)', b(1), b(2), rsq);
        timeEqB0 = sprintf('b_0: [%1.2f, %1.2f]', bint(1,:));
        timeEqB1 = sprintf('b_1: [%1.2f, %1.2f]', bint(2,:));
        
%         title(timeEq);
%         xLim = xlim;
%         yLim = ylim;
%         text(xLim(1) + diff(xLim)*0.05, ...
%              yLim(1) + diff(yLim)*0.96, timeEqB0, ...
%              'FontSize', 12);
%         text(xLim(1) + diff(xLim)*0.05, ...
%              yLim(1) + diff(yLim)*0.85, timeEqB1, ...
%              'FontSize', 12);
         
        txt = {timeEq, '', timeEqB0, timeEqB1};
        bml.plot.text_align(txt, 'text_props', {'FontSize', 12});
    end
end
%% Save
methods
    function save_res(W)
        file = W.get_file;
        mkdir2(fileparts(file));
        fprintf('Saving to %s\n', file);
        
        res = W.res; %#ok<NASGU>
        save(file, 'W', 'res', 'file');
    end
    function fs = get_file_fields(W)
        fs = {
            'subj', 'sbj'
            'parad', 'prd'
            };
    end
end
%% Imgather
methods
    function imgather(W0, varargin)
        %%
        [~, Ls] = W0.get_batch_files(varargin{:});
        n = numel(Ls);
        
        ax = subplotRCs(1, n);
        
        for ii = 1:n
            L = Ls{ii};
            W = L.W;
            file_fig = W.get_file({'plt', 't_orig'});
            
            ax1 = ax(ii);
            ax1 = bml.plot.openfig_to_axes(file_fig, ax1);
            
            ax(ii) = ax1;
        end
        
        %%
        for ii = 1:n
            ax1 = ax(ii);
            title(ax1, sprintf('S%d', ii));
            if ii == 1
                ylabel(ax1, sprintf('Reported\nprobe onset (s)'));
            else
                ylabel(ax1, '');
                set(ax1, 'YTickLabel', []);
            end
            if ii == round((n + 1) / 2)
                xlabel(ax1, 'Actual probe onset (s)');
            else
                xlabel(ax1, '');
            end
            
            set(ax1, ...
                'TickLen', [0.02, 0.01], ...
                'Fontsize', 9);
            
            txts = findobj(ax1, 'Type', 'text');
            delete(txts);
            
            hs = bml.plot.figure2struct(ax1);
            set(hs.marker, ...
                'Marker', 'o', ...
                'MarkerFaceColor', 'none', ...
                'MarkerEdgeColor', 'k', ...
                'MarkerSize', 2, ...
                'LineWidth', 0.1);
        end
        
        bml.plot.position_subplots(ax, ...
            'margin_top', 0.05, ...
            'margin_left', 0.08, ...
            'margin_bottom', 0.15, ...
            'margin_right', 0.01);
        
        %%
        subjs = cellfun(@(L) L.W.subj, Ls, 'UniformOutput', false);
        file = W0.get_file({'sbj', subjs, 'img', 'scatter'});
        savefigs(file, 'PaperPosition', [0, 0, 18.3, 4.2], ...
            'ext', {'.fig', '.png', '.tif'}); % [600, n_subj * 400]);        
    end
end
end