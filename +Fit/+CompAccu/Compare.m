classdef Compare < Fit.Common.CommonWorkspace
properties
    parads = {'VD_woSDT', 'VD_wSDT'};
    res_logit = [];
    ress = [];
    
    res_subjs = [];
    ress_subjs = [];
    res_ixn = [];
end
properties (Dependent)
    ixn
    rfx
end
properties (Transient)
    Main = Fit.CompAccu.Main;
end
%% Batch
methods
    function [S_batch, Ss, n] = get_S_batch(~, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            });
        [Ss, n] = factorizeS(S_batch);
    end
    function res_subjs = batch(W0, varargin)
        [~, Ss, n] = W0.get_S_batch(varargin{:});
        
        res_subjs = dataset;
        ress_subjs = dataset;
        
        for ii = n:-1:1
            W = feval(class(W0));
            
            S = Ss(ii);
            C = S2C(S);
            
            W.main(C{:});
            
            b_woSDT = W.ress.b(1,:);
            se_woSDT = W.ress.se(1,:);
            t_woSDT = W.ress.b(1,:) ./ W.ress.se(1,:);
            p_woSDT = W.ress.p(1,:);
            
            b_wSDT = W.ress.b(2,:);
            se_wSDT = W.ress.se(2,:);
            t_wSDT = W.ress.b(2,:) ./ W.ress.se(2,:);
            p_wSDT = W.ress.p(2,:);
            
            b_ixn = W.ixn.Estimate;
            se_ixn = W.ixn.SE;
            t_ixn = W.ixn.tStat;
            p_ixn = W.ixn.pValue;
            
            res = packStruct( ...
                b_woSDT, se_woSDT, t_woSDT, p_woSDT, ...
                b_wSDT,  se_wSDT,  t_wSDT,  p_wSDT, ...
                b_ixn,   se_ixn,   t_ixn,   p_ixn);
            S0_file = W.get_S0_file;
            S0_file.parads = bml.str.Serializer.convert(S0_file.parads);
            res_subjs = ds_set(res_subjs, ii, S0_file);
            
            res_subjs = ds_set(res_subjs, ii, res);
            res_subjs.file{ii, 1} = W.get_file;
            
            ress = W.ress;
            ress.subj = repmat({W.subj}, [size(ress,1), 1]);
            ress_subjs = ds_set(ress_subjs, (ii * 2) + [-1, 0], ...
                ress);
        end
        ress_subjs.w_sdt = strcmp(ress_subjs.parad, 'VD_wSDT');
        
        W0.res_subjs = res_subjs;
        W0.ress_subjs = ress_subjs;
        
        W0.summarize_subjs;
        W0.save_summary_subjs;
        
        W0.plot_all;
        
%         W0.save_ixn;
    end
    function res_ixn = summarize_subjs(W0, ds)
        if ~exist('ds', 'var')
            ds = W0.ress_subjs;
        end
        
        n_row = size(ds, 1);

        subj = {};
        cond = [];
        w_sdt = [];
        p_resp = [];
        n_resp = [];
        for i_row = 1:n_row
            row = ds(i_row, :);
            n_conds = length(row.conds);
            subj = [
                subj
                repmat(row.subj, [n_conds, 1]);
                ]; %#ok<AGROW>
            cond = [
                cond
                vVec(row.conds)
                ]; %#ok<AGROW>
            p_resp = [
                p_resp
                vVec(row.obs_ch)
                ]; %#ok<AGROW>
            n_resp = [
                n_resp
                vVec(row.obs_n)
                ]; %#ok<AGROW>
            w_sdt = [
                w_sdt
                row.w_sdt + zeros(n_conds, 1)
                ]; %#ok<AGROW>
        end
%         [~,~,subj] = unique(subj);
        tbl = table(subj, cond, w_sdt, p_resp, n_resp);
        tbl = tbl(n_resp > 0, :);
        
%         res_ixn = fitglme(tbl, ...
%             ['p_resp ~ 1 + cond + (1 + cond | w_sdt)' ...
%              '+ (1 + cond | w_sdt:subj)'], ...
%              'Distribution', 'binomial', ...
%              'BinomialSize', tbl.n_resp);

        res_ixn = fitglme(tbl, ...
            ['p_resp ~ 1 + cond*w_sdt' ...
             '+ (1 + cond*w_sdt | subj)'], ...
             'Distribution', 'binomial', ...
             'BinomialSize', tbl.n_resp);
         
%         res_ixn = glmwrap(ones(n, 1), ds.b_ixn, 'normal', ...
%             'constant', 'off', ...
%             'weights', 1 ./ ds.se_ixn.^2);

        W0.res_ixn = res_ixn;
    end
    function rfx = get.rfx(W0)
        if isempty(W0.res_ixn)
            rfx = [];
        else
            [~, ~, rfx] = W0.res_ixn.randomEffects;
        end
    end
    function save_summary_subjs(W0)
        res_subjs = W0.res_subjs;
        res_ixn = W0.res_ixn; %#ok<NASGU>
        
        file_batch = W0.get_file_batch(res_subjs);
        mkdir2(fileparts(file_batch));
        
        fprintf('Saving comparison to %s\n', file_batch);
        save(file_batch, 'W0', 'res_subjs', 'res_ixn');
        
        res_subjs.parads = strrep(res_subjs.parads, ',', ';');
        export(res_subjs, 'File', [file_batch '+tab=res_subjs.csv'], ...
            'Delimiter', ',');
        
        export(W0.rfx, 'File', [file_batch '+tab=rfx.csv'], ...
            'Delimiter', ',');
        
        export(W0.res_ixn.Coefficients, 'File', [file_batch '+tab=ffx.csv'], ...
            'Delimiter', ',');
        W0.save_ffx;
        
        file_batch_txt = [file_batch '.txt'];
        delete(file_batch_txt);
        diary(file_batch_txt);
%         disp('W0.res_ixn.stats');
%         disp(W0.res_ixn.stats);

        disp('W0.res_ixn');
        disp(W0.res_ixn);
        disp('W0.rfx');
        disp(W0.rfx);
        
        diary('off');
    end
    function save_ffx(W0)
        ffx = W0.res_ixn.Coefficients;
        
        for ii = size(ffx, 1):-1:1
            ffx1 = ffx(ii,:);
            row.Name = bml.str.strrep_cell(ffx1.Name{1}, {
                '(Intercept)', 'Intercept'
                'cond:w_sdt', 'Interaction'
                'cond', 'Coherence'
                'w_sdt', 'SDT report'
                });
            row.Estimate = sprintf( ...
                '%1.2f (+- %1.2f)', ...
                ffx1.Estimate, ffx1.SE);
            row.df = ffx1.DF;
            row.p_value = sprintf('%1.2g', ffx1.pValue);
            rows(ii) = row;
        end
        ds = bml.ds.from_Ss(rows);
        
        file_batch = W0.get_file_batch(W0.res_subjs);
        file = [file_batch '+tab=ffx.csv'];
        export(ds, 'File', file, 'Delimiter', ',');
        fprintf('Saved to %s\n', file);
    end
    function file_batch = W0.get_file_batch(varargin)
        if nargin == 0
            varargin = {W0.res_subjs};
        end
        file_batch = W0.get_file_batch(varargin{:});
    end
end
%% Main : Compare parads
methods
    function W = Compare(varargin)
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function main(W, varargin)
        W.init(varargin{:});
        W.fit;
    end
    function [res_logit, ress] = fit(W0)
        n_parads = numel(W0.parads);
        
        W = W0.Main;
        ress = dataset;
        for i_parad = n_parads:-1:1
            W.subj = W0.subj;
            W.parad = W0.parads{i_parad};
            file = W.get_file;
            
            fprintf('Loading %s\n', file);
            L = load(file, 'res_logit');
            ress = ds_set(ress, i_parad, L.res_logit);
            ress.parad{i_parad, 1} = W.parad;
        end
        for f = {'b', 'p', 'se', 'conds', 'obs_ch', 'obs_n'}
            ress.(f{1}) = cell2mat2(ress.(f{1}));
        end
        
        n_conds = size(ress.conds, 2);
        conds_parads = vVec(ress.conds');
        obs_ch_parads = vVec(ress.obs_ch');
        obs_n_parads = vVec(ress.obs_n');
        ix_parad_sdt = [zeros(n_conds, 1); ones(n_conds, 1)];
%         ixn_cond_parad = conds_parads .* ix_parad_sdt;
        
        resp = [obs_ch_parads, obs_n_parads];
        tbl = table(conds_parads, ix_parad_sdt, resp);
        
        res_logit = fitglm(tbl, 'interactions', ...
            'ResponseVar', 'resp', ...
            'Distribution', 'binomial');
        
        W0.res_logit = res_logit;
        W0.ress = ress;
    end
    function v = get.ixn(W)
        if isempty(W.res_logit)
            v = [];
        else
            v = W.res_logit.Coefficients('conds_parads:ix_parad_sdt', :);
        end
    end
end
%% Save
methods
    function save_res(W)
        file = W.get_file;
        mkdir2(fileparts(file));
        fprintf('Saving to %s\n', file);
        
        res = W.res; %#ok<NASGU>
        save(file, 'W', 'res_accu', 'res_logit', 'file');
    end
    function fs = get_file_fields(W)
        fs = [
            W.get_file_fields@Fit.Common.CommonWorkspace
            {
            'parads', 'prds'
            }
            ];
        fs = fs(~any(bsxStrcmp(fs(:,1), {'parad', 'rt_field'}), 2), :);
    end
end
%% Plot
methods
    function plot_all(W)
        W.plot_thres;
        W.batch_plot_ch;
    end
end
%% Compare choices
methods
    function batch_plot_ch(W)
        ress = W.ress_subjs;
        subjs = unique(ress.subj)';
        n_subj = numel(subjs);
        
        for i_subj = 1:n_subj
            subj = subjs{i_subj};
            
            clf;
            res_subj = bml.ds.find(ress, {'subj', subj});
            W.plot_ch(res_subj);
            
            file = W.get_file({'sbj', subj, 'plt', 'ch'});
            savefigs(file);
        end
    end
    function imgather_plot_ch(W, varargin)
    	S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            });
        [Ss, n] = bml.args.factorizeS(S_batch);
    
        files = cell(n, 1);
        for ii = n:-1:1
            S = Ss(ii);
            files{ii} = [W.get_file({'sbj', S.subj, 'plt', 'ch'}), '.fig'];
        end
        imgather(files);
        
        file = W.get_file({'sbj', {Ss.subj}, 'plt', 'ch'});
        savefigs(file, 'size', [300, 200 * n]);
    end
    function plot_ch(W, res_subj)
        res_woSDT = bml.ds.find(res_subj, {'parad', 'VD_woSDT'});
        res_wSDT  = bml.ds.find(res_subj, {'parad', 'VD_wSDT'});
        
        h_woSDT = W.plot_ch_unit(res_woSDT, 'k');
        hold on;
        
        h_wSDT = W.plot_ch_unit(res_wSDT,  'r');
        hold off;
        
        uistack(h_woSDT.obs, 'top');
        uistack(h_wSDT.obs, 'top');
        
        bml.plot.beautify;
        Fit.Plot.beautify_ch_axis;
        Fit.Plot.beautify_coh_axis;
        
        grid on;
        title(sprintf('Subject %s', res_subj.subj{1}));
        
        legend([h_woSDT.pred, h_wSDT.pred], ...
            {'VD without SDT', 'VD with SDT'}, ...
            'Location', 'SouthEast');
    end
    function h = plot_ch_unit(W, res, color)
        x_obs = res.conds;
        y_obs = res.obs_ch;
        
        x_pred = linspace(x_obs(1), x_obs(end));
        y_pred = glmval(res.b(:), x_pred(:), 'logit', 'size', 1);
        h.pred = plot(x_pred, y_pred, '-', 'Color', color);
        hold on;
        
        h.obs = plot(x_obs, y_obs, 'o', ...
            'MarkerFaceColor', color, ...
            'MarkerEdgeColor', 'w');
        
        hold off;
    end
end
%% Compare slope
methods
    function plot_thres(W)
        ress = W.ress_subjs;
        subjs = unique(ress.subj)';
        parads = {'VD_woSDT', 'VD_wSDT'}; % unique(ress.parad)';
        
        for ii = 1:size(ress, 1)
            b = ress.b(ii,:);
            covb = ress.stats(ii).covb;
            [thres, spe, bnd_thres, bnd_spe] = bml.stat.logit2thres(b, [], covb);
            
            ress.thres(ii, 1) = thres;
            ress.spe(ii, 1) = spe;
            ress.bnd_thres(ii, 1:2) = bnd_thres(:)';
            ress.bnd_spe(ii, 1:2) = bnd_spe(:)';
        end
        
        thres = [];
        spe = [];
        lb_thres = [];
        ub_thres = [];
        lb_spe = [];
        ub_spe = [];
        
        n_subj = numel(subjs);
        n_parad = numel(parads);
        
        for i_subj = 1:n_subj
            for i_parad = 1:n_parad
                subj = subjs{i_subj};
                parad = parads{i_parad};
                
                res = bml.ds.find(ress, {'subj', subj, 'parad', parad});
                thres(i_subj, i_parad) = res.thres;
                lb_thres(i_subj, i_parad) = res.bnd_thres(1);
                ub_thres(i_subj, i_parad) = res.bnd_thres(2);
                spe(i_subj, i_parad) = res.spe;
                lb_spe(i_subj, i_parad) = res.bnd_spe(1);
                ub_spe(i_subj, i_parad) = res.bnd_spe(2);
            end
        end
        le_thres = lb_thres - thres;
        ue_thres = ub_thres - thres;
        le_spe = lb_spe - spe;
        ue_spe = ub_spe - spe;
        
        colors = {'k', 'r'};
        
        clf;
        
        for i_parad = 1:n_parad
            x = (1:n_subj) + (i_parad - (1 + n_parad) / 2) / 10;
            h.(parads{i_parad}) = ...
                bml.plot.errorbar_wo_tick(x, thres(:,i_parad), ...
                    le_thres(:,i_parad), ue_thres(:,i_parad), ...
                    {'Color', colors{i_parad}, 'LineStyle', 'none'}, ...
                    {'LineStyle', '-'});
            hold on;
        end
        hold off;
        
        initials = cellfun(@(c) c(1), subjs, 'UniformOutput', false);
        set(gca, 'XTick', x, 'XTickLabel', initials);
        xlabel('Subject');
        
        y_lim = ylim;
        ylim([0, y_lim(2)]);
        bml.plot.beautify;
        
        set(gca, 'YTick', 0:0.05:0.5, ...
            'YTickLabel', csprintf('%d', 0:5:50), ...
            'YGrid', 'on');
        ylabel('Threshold Coherence (%)');
        
        legend([h.VD_woSDT, h.VD_wSDT], {'VD without SDT', 'VD with SDT'}, ...
            'Location', 'NorthWest');
        
        file = W.get_file({'sbj', subjs, 'plt', 'thres'});
        savefigs(file);

%         for i_parad = 1:n_parad
%             bml.plot.errorbar_wo_tick(1:n_subj, thres(:,i_parad), ...
%                 le_thres(:,i_parad), ue_thres(:,i_parad), ...
%                 {'Color', colors{i_parad}, 'LineStyle', 'none'}, ...
%                 {'LineStyle', '-'});
%         end
    end
end
%% Compare accuracy
methods
end
end