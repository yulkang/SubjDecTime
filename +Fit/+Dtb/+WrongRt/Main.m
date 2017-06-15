classdef Main < Fit.Common.CommonWsFiltCond
    % Fit.Dtb.WrongRt.Main
properties
%     param_file = 'Data/Fit.Dtb.Main/sbj={S1,S2,S3,S5,S4}+prd={RT_wSDT,VD_wSDT}+rtfd={RT,SDT_ClockOn}+tr={[201,0]}+bal={1}+bnd={betacdf}+tnd={gamma}+ntnd={2}+bayes={none}+lps0={1}+igch={0}+tab=compare_all.mat';
    W
end
methods
    function W = Main(varargin)
        % Defaults
        W.rt_field = 'SDT_ClockOn';
        W.parad = 'VD_wSDT';
        W.ad_cond_incl = 1:5;
        
        if nargin > 0
            W.init(varargin{:});
        end
    end
end
%% GLM
methods
    function mdl = fitglme(W0, W, varargin)
        files = W.get_batch_files(varargin{:});
        n = numel(files);
    end
    function ds = batch_fitglm_wi_subj_RT(W0, varargin)
        C = varargin2C(varargin, {
            'parad', 'RT_wSDT'
            });
        ds = W0.batch_fitglm_wi_subj(C{:});
    end
    function ds = batch_fitglm_wi_subj(W0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            'parad', 'VD_wSDT'
            });
        [Ss, n] = bml.args.factorizeS(S_batch);
        
        b_names = {'Intercept', 'Accuracy', 'Absolute_Coherence', ...
            'Interaction'};
        
        for ii = n:-1:1
            S = Ss(ii);
            C = S2C(S);
            
            W = feval(class(W0), C{:});
            res1 = W.fitglm_wi_subj;
            res(ii).Subject = sprintf('S%d', ii);
            for jj = 2 % 1:numel(res1.b)
                name1 = b_names{jj};
                res(ii).(name1) = sprintf('%1.3f +- %1.3f (p=%1.3g)', ...
                    res1.b(jj), res1.se(jj), res1.p(jj));
            end
        end
        ds = bml.ds.from_Ss(res);
        file = [W0.get_file({
            'sbj', S_batch.subj
            'prd', S_batch.parad
            'tbl', 'glm_wi_subj'
            }) '.csv'];
        mkdir2(fileparts(file));
        export(ds, 'File', file, 'Delimiter', ',');
        fprintf('Saved to %s\n', file);
    end
    function res = fitglm_wi_subj(W)
        %%
        rt = W.Data.rt;
        ch = W.Data.ch;
        cond = W.Data.cond;
        b = glmfit(cond, ch == 1, 'binomial');
        bias = -b(1) / b(2);
        cond_bias = cond - bias;
        accu = sign(ch - 0.5) == sign(cond_bias);
        
        %% Choose only the condition with both accurate and wrong
        [~,~,d_cond] = unique(cond);
        n_cond = max(d_cond);
        cond_incl = zeros(1, n_cond);
        n_thres = 1;
        for ii = 1:n_cond
            accu1 = accu(d_cond == ii);
            cond_incl(ii) = nnz(~accu1) >= n_thres;
        end
        cond_incl = find(cond_incl);
        incl = ismember(d_cond, cond_incl);
        
        abs_cond_bias = abs(cond_bias);
        X = [accu, abs_cond_bias, abs_cond_bias .* accu];
        y = rt;
%         res = bml.stat.glmwrap(X(incl,:), y(incl), ...
%             'normal');
        
        tbl = table(accu, cond_bias, abs_cond_bias, rt);
        tbl.abs_cond_bias = categorical(tbl.abs_cond_bias);
        mdl = fitglm(tbl, 'rt ~ accu + abs_cond_bias', ...
            'CategoricalVars', [1, 2, 3]);

        res.b = mdl.Coefficients.Estimate;
        res.se = mdl.Coefficients.SE;
        res.p = mdl.Coefficients.pValue;
        
%         %%
        W.subj
        m = accumarray([d_cond, accu + 1], rt, [], @mean, nan)
        n = accumarray([d_cond, accu + 1], rt, [], @numel, nan)
    end
end
%% ANOVA
methods
    function varargout = anova_accu_across_subjs_VD(W0, W, varargin)
        if ~exist('W', 'var') || isempty(W)
            W = Fit.Dtb.Main;
        end
        W0.W = W;
        
        C = varargin2C(varargin, varargin(W.get_S_batch_VD, {
            'ad_cond_incl', 1
            }));
        [varargout{1:nargout}] = W0.anova_accu_across_subjs(C{:});
    end
    function varargout = anova_accu_across_subjs_RT(W0, W, varargin)
        if ~exist('W', 'var') || isempty(W)
            W = Fit.Dtb.Main;
        end
        W0.W = W;
        
        C = varargin2C(varargin, varargin(W.get_S_batch_RT, {
            'ad_cond_incl', 1
            }));
        [varargout{1:nargout}] = W0.anova_accu_across_subjs(C{:});
    end
    function [res, inp, ress] = anova_accu_across_subjs(W0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs % Data.Consts.subjs_w_SDT_modul
            });
        [Ss, n] = bml.args.factorizeS(S_batch);
        
        ress = cell(n, 1);
        inp = dataset;
        for ii = 1:n
            C = S2C(Ss(ii));
            bml.oop.varargin2props(W0.W, C, true);
            file = W0.W.get_file;
            fprintf('Loading %s\n', file);
            L = load(file);
            W = L.W;
            [ress{ii}, inp1] = W0.anova_accu(W);
            inp = [inp; inp1];
        end
        
        %%
        x = {inp.cond, inp.accu, inp.subj};
        vnam = {'cond', 'accu', 'subj'};
        model = 'full';
        r = [];
        
        [p, tbl, stats, terms] = anovan(inp.rt, x, ...
            'varnames', vnam, 'model', model, 'random', r);
        res = packStruct(p, tbl, stats, terms);
        
        %%
        file =[W0.get_file_from_S0(S_batch) '+tbl=anova'];
        mkdir2(fileparts(file));
        save([file '.mat'], 'res', 'inp');
        
        ds = cell2ds2(res.tbl, 'get_colname', true, 'get_rowname', true);
        export(ds, 'file', [file '.csv'], 'Delimiter', ',');
        fprintf('Saved to %s.mat and .csv\n', file);
    end
    
    function batch_anova_accu_wi_subj(W0, varargin)
        
    end
    function [res, inp] = anova_accu(W0, W)
        [accu, bias_cond] = W0.get_accu_biased(W);
        cond = abs(W.Data.cond - bias_cond);
        [conds, ~, d_cond] = unique(cond);
        n_conds = length(conds);
        incl = false(n_conds, 1);
        for d_cond1 = 1:n_conds
            incl1 = d_cond == d_cond1;
            incl(d_cond1) = any(~accu(incl1));
        end
        incl_tr = any(bsxfun(@eq, d_cond, find(incl(:)')), 2);
        
        x = {cond(incl_tr), accu(incl_tr)};
        
        rt = W.Data.rt(incl_tr);
        
        vnam = {'cond', 'accu'}';
        model = 'full';
        r = [];
        
        [p, tbl, stats, terms] = anovan(rt, x, ...
            'varnames', vnam, 'model', model, 'random', r);
        res = packStruct(p, tbl, stats, terms);
        
        inp = copyFields(dataset, packStruct(cond, accu, rt));
        inp.subj = repmat({W.subj}, [size(inp, 1), 1]);
    end
    function demo_summary(W)
        W.init;
        
        %%
        rt = W.Data.rt;
        ch = W.Data.ch;
        ch_rwd = W.Data.cond > 0;
        accu = ch == ch_rwd;
        cond = W.Data.cond;
        [conds, ~, d_cond] = unique(cond);
        td = W.rt2td(rt, ch);
        
        %%
        n_conds = max(d_cond);
        mean_rt = accumarray([d_cond, accu + 1], td, [n_conds, 2], ...
            @nanmean, nan);
        sem_rt = accumarray([d_cond, accu + 1], td, [n_conds, 2], ...
            @nansem, nan);
        
        cla;
        colors = {'r', 'k'};
        for accu1 = [1 0]
            bml.plot.errorbar_wo_tick(conds(:) + (accu1 - 0.5) / 1e3, ...
                mean_rt(:,accu1 + 1), sem_rt(:,accu1 + 1), [], ...
                Fit.Plot.style_data({'MarkerFaceColor', colors{accu1 + 1}}), ...
                Fit.Plot.style_pred({'Color', colors{accu1 + 1}}));
            hold on;
        end
        hold off;
        bml.plot.beautify;
        xlabel('Coherence');
        ylabel('SDT (s)');
    end
    function td = rt2td(W, rt, ch)
        %%
        L = load(W.param_file);
        row = bml.ds.find(L.ds, {
            'subj', W.subj
            'parad', W.parad
            'rt_field', W.rt_field
            });
        assert(size(row, 1) == 1);
        row = ds2struct(row);
        
        %%
%         tnd_mean = [0 0];
        tnd_mean = [row.th_tnd_mean_1, row.th_tnd_mean_2];
        td = zeros(size(rt));
        for ch1 = 0:1
            tnd_mean1 = tnd_mean(ch1 + 1);
            incl = ch == ch1;
            td(incl) = rt(incl) - tnd_mean1;
        end
    end
    function [accu, bias_cond] = get_accu_biased(~, W)
        %%
        cond = W.Data.cond;
        ch = W.Data.ch;
        b = glmfit(cond, ch == 1, 'binomial');
        bias_cond = -b(1) / b(2);
        
%         bias_cond = W.th.bias_cond;
        W.Data.bias_cond = bias_cond;
        accu = W.Data.accu;
    end    
    function demo(W)
        %
        W.init;
        
        %%
        rt = W.Data.rt;
        ch = W.Data.ch;
        ch_rwd = W.Data.cond > 0;
        accu = ch == ch_rwd;

        td = W.rt2td(rt, ch);
        
        %%
        name_side = {'Left', 'Right'};
        
        for side = [0 1]
            incl = ch_rwd == side;
            td1 = td(incl);
            accu1 = ch(incl) == side;
            
            subplot(2, 1, side + 1);
            cla;
            colors = {bml.plot.color_lines('r'), bml.plot.color_lines('b')};
            any_incl_accu = false(1, 2);
            for c_accu = [0 1]
                c_td = td1(accu1 == c_accu);
                if ~isempty(c_td)
                    [f, x] = ecdf(c_td);
                    h(c_accu + 1) = ...
                        stairs(x, f, '-', 'Color', colors{c_accu + 1});
                    hold on;
                    any_incl_accu(c_accu + 1) = true;
                end
            end 
            hold off;
            legends = {'Wrong', 'Correct'};
            legend( ...
                flip(h(any_incl_accu)), ...
                flip(legends(any_incl_accu)), ...
                'Location', 'NorthWest');
            grid on;
            bml.plot.beautify;
            title(sprintf('Rewarded Side: %s', name_side{side + 1}));
        end
        
        %% Cross-validate within each condition
        cond = W.Data.cond;
        [conds, ~, d_cond] = unique(cond);
        n_conds = max(d_cond);
        for i_cond = 1:n_conds
            cond1 = conds(i_cond);
            incl_cond = d_cond == i_cond;
            rt1 = td(incl_cond);
            accu1 = accu(incl_cond);
            
            %%
            [loss_rt_all, loss_chance_all] = W.crossval(rt1, accu1);
            m_loss_rt(i_cond) = mean(loss_rt_all);
            se_loss_rt(i_cond) = sem(loss_rt_all);
            m_loss_chance(i_cond) = mean(loss_chance_all);
            se_loss_chance(i_cond) = sem(loss_chance_all);
            
            %%
            [thres(i_cond), loss_train(i_cond)] = W.train(rt1, accu1);
        end
        
        disp(m_loss_rt);
        disp(m_loss_chance);
    end
    function [thres, loss] = train(~, rt, accu)
        % Wrong trials would have longer RT.
        [loss, ~, thres] = bml.mlearn.dynamic_stump_uni(rt, sign((~accu) - 0.5));
        loss = loss / length(rt);
    end
    function [accu_pred, loss, loss_all] = test(~, rt, accu_data, thres)
        accu_pred = rt < thres;
        loss_all = accu_pred ~= accu_data;
        loss = mean(loss_all);
    end
    function [loss, pred, thres] = train_test_w_rt(W, ...
            rt_train, accu_train, rt_test, accu_test)
        thres = W.train(rt_train, accu_train);
        [pred, loss] = W.test(rt_test, accu_test, thres);

        % DEBUG
%         disp([thres, rt_test]);
%         disp([pred, accu_test]);
    end
    function [loss, pred_accu] = train_test_w_prop(~, ...
            ~, accu_train, ~, accu_test)
        prop_accu = mean(accu_train);
        if prop_accu > 0.5
            pred_accu = 1;
            loss = mean(~accu_test);
        else
            pred_accu = 0;
            loss = mean(accu_test);
        end
    end
    function [loss_rt_all, loss_chance_all] = crossval(W, rt, accu, varargin)
        S = varargin2S(varargin, {
            'cv_args', {'leaveout', 1}
            });
        loss_rt_all = crossval(@W.train_test_w_rt, rt, accu, S.cv_args{:});
        
        loss_chance_all = crossval(@W.train_test_w_prop, rt, accu, S.cv_args{:});
    end
end
end