classdef Main < Fit.Dtb.Main
    % Fit.Dtb.MeanRt.Main
    
    % 2016 YK wrote the initial version.
    
properties
    td_mean
    td_var
    rt_mean_pred
    rt_var_pred
    
    ch_pred
    mdl
    
    to_determine_accu_from_bias_ch = true; % [];
    
    to_import_params = false;
    to_use_analytic_cost = true; % false; % 
end
properties (Dependent)
    bias_cond_glm
end
%% == Init / Fit
methods
    function W = Main(varargin)
        W.parad = 'VD_wSDT';
        W.subj = Data.Consts.subjs{2};
        W.bound_shape = 'const';
        W.tnd_bayes_ = 'none';
        W.tnd_distrib = 'normal';
        W.lapse0 = true;
        W.ignore_choice = true;
        W.n_tnd = 1;
        W.bias_cond_from_ch = false;
        W.kind_kb = '';
        
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function init(W, varargin)
        W.init@Fit.Common.CommonWorkspace(varargin{:});
        
        for cc = {
                'bound_shape', 'const'
                'tnd_bayes_',  'none'
                'tnd_distrib', 'normal'
                'lapse0',      true
                }'
            if ~isequal(W.(cc{1}), cc{2})
                warning('Unexpected property value for %s\n', cc{1});
                fprintf('W.%s was ', cc{1});
                disp(W.(cc{1}));
                fprintf('W.%s is enforced to be ', cc{1});
                disp(cc{2});
                W.(cc{1}) = cc{2};
            end
        end
        
        W.init_params0;
    end
    function init_params0(W)
        W.init_params0@Fit.Dtb.Main;
        
        W.th0.tnd_std_1 = 0;
        W.fix_to_th0_('tnd_std_1');
        
        if W.n_tnd >= 2
            W.th0.tnd_std_2 = 0;
            W.fix_to_th0_('tnd_std_2');
        end

        if W.bias_cond_from_ch
            W.th0.bias_cond = W.bias_cond_glm;
            W.fix_to_th0_('bias_cond');
            W.Data.bias_cond = W.bias_cond_glm;
        end
        if W.to_determine_accu_from_bias_ch
            W.Data.bias_cond = W.bias_cond_glm;
        end
        
%         W.th0.bias_cond = 0;
%         W.fix_to_th0_('bias_cond');
    end
    function v = get.bias_cond_glm(W)
        if isempty(W.mdl) && W.Data.is_loaded
            ch = logical(W.Data.ch);
            cond = W.Data.cond;

            W.mdl = fitglm(cond, ch, 'Distribution', 'binomial');
        end
        if ~isempty(W.mdl)
            v = -W.mdl.Coefficients.Estimate(1) ...
               / W.mdl.Coefficients.Estimate(2);
        else
            v = [];
        end
    end
    function pred(W)
        if W.to_determine_accu_from_bias_ch
            W.Data.bias_cond = W.bias_cond_glm;
        else
            W.Data.bias_cond = W.th.bias_cond;
        end
        
        W.calc_drift;
        W.calc_rt;
        W.calc_ch_pred;
    end
    function calc_rt(W)
        W.calc_td_mean;
        W.calc_td_var;
        
        W.calc_rt_mean_pred;
        W.calc_rt_var_pred;
    end
    function td_mean = calc_td_mean(W, drift, b)
        if ~exist('drift', 'var')
            drift = W.drift; 
        end
        if ~exist('b', 'var')
            b = W.th.b;
        end
        
        td_mean = b ./ drift .* tanh(b .* drift);
        td_mean(drift == 0) = b .^ 2;
        
        if nargout == 0
            W.td_mean = td_mean;
        end
    end
    function td_var = calc_td_var(W, drift, b)
        if ~exist('drift', 'var')
            drift = W.drift; 
        end
        if ~exist('b', 'var')
            b = W.th.b;
        end
        
        td_var = (b .* tanh(b .* drift) ...
               - b .* drift .* sech(b .* drift) .^ 2) ...
               ./ drift .^ 3;
        td_var(drift == 0) = 2 ./ 3 .* b.^4;
        
        if nargout == 0
            W.td_var = td_var;
        end
    end
    function rt_mean_pred = calc_rt_mean_pred(W, td_mean, tnd_mean)
        if ~exist('td_mean', 'var')
            td_mean = W.td_mean;
        end
        if ~exist('tnd_mean', 'var')
            if W.n_tnd == 1
                tnd_mean = [W.th.tnd_mean_1, W.th.tnd_mean_1];
            else
                tnd_mean = [W.th.tnd_mean_1, W.th.tnd_mean_2];
            end
        end
        
        rt_mean_pred = bsxfun(@plus, td_mean(:), tnd_mean(:)');
        
        if nargout == 0
            W.rt_mean_pred = rt_mean_pred;
        end
    end
    function rt_var_pred = calc_rt_var_pred(W, td_var, tnd_var)
        if ~exist('td_var', 'var')
            td_var = W.td_var;
        end
        if ~exist('tnd_var', 'var')
            if W.n_tnd == 1
                tnd_var = [W.th.tnd_std_1, W.th.tnd_std_1].^2;
            else
                tnd_var = [W.th.tnd_std_1, W.th.tnd_std_2].^2;
            end
        end
        
        rt_var_pred = bsxfun(@plus, td_var(:), tnd_var(:)');
        
        if nargout == 0
            W.rt_var_pred = rt_var_pred;
        end
    end
    function ch_pred = calc_ch_pred(W, drift, b)
        if ~exist('drift', 'var')
            drift = W.drift; 
        end
        if ~exist('b', 'var')
            b = W.th.b;
        end
        
        ch_pred = 1 ./ (1 + exp(-2 .* drift .* b));
        
        if nargout == 0
            W.ch_pred = ch_pred;
        end
    end
    function varargout = calc_cost(W)
        if W.to_use_analytic_cost
            [varargout{1:nargout}] = W.calc_cost_analytic;
        else
            varargout{1} = W.calc_cost_numeric;
        end
    end
    function hess = get_hessian(W, varargin)
        [~,~,hess] = W.get_cost(varargin{:});
    end
    function [cost, grad, hess] = calc_cost_analytic(W)
        % Params
        th = W.th;        

%         if W.n_tnd == 1
        % SEM from data
        rt_sem_obs = W.obs_sem_rt_accu;
        rt_sem_obs_vec = W.obs_sem_rt_accu_vec; % Data.get_obs_sem_rt_accu_vec;
        
        % SEM from pred
%         n_in_cond_ch = W.Data.obs_n_in_cond_ch_accu;
%         rt_sem_pred = sqrt(W.rt_var_pred ./ n_in_cond_ch);

        % Mean
        rt_mean_obs = W.obs_mean_rt_accu;
        rt_mean_obs_vec = W.obs_mean_rt_accu_vec; % Data.get_obs_mean_rt_accu_vec;
    
        % Cost
        if W.n_tnd == 1
            tnd = th.tnd_mean_1 + zeros(1, 2);
        else
            tnd = [th.tnd_mean_1, th.tnd_mean_2];
        end
        
        conds = W.conds;
        conds_bias = conds - th.bias_cond;
        n_cond = size(conds_bias, 1);
        
        if ~W.ignore_choice
            n_obs = W.Data.obs_n_in_cond_ch;
            n_ch2 = n_obs(:,2);
            n_tot = sum(n_obs, 2);
        end
        
        n_tnd = W.n_tnd;
        assert(n_tnd == 1 || n_tnd == 2);
        
        if n_tnd == 1
            chs = 1;
            n_free = 4;
        else
            assert(n_tnd == 2);
            chs = 1:2;
            n_free = 5;
            n_bef_tnd = n_free - n_tnd;
            ix_tnd = n_bef_tnd + [1, 2];
            ix_th = {
                [1:n_bef_tnd, ix_tnd(1)]
                [1:n_bef_tnd, ix_tnd(2)]
                };
        end
        cost = 0;
        grad = zeros(1, n_free);
        hess = zeros(n_free, n_free);
        
        for i_cond = 1:n_cond
            cond1 = conds(i_cond);
            cond_bias1 = conds_bias(i_cond);

            for ch1 = chs
                tnd1 = tnd(ch1);

                if n_tnd == 1
                    rt_mean_obs1 = rt_mean_obs_vec(i_cond);
                    rt_sem_obs1 = rt_sem_obs_vec(i_cond);
                else
                    rt_mean_obs1 = rt_mean_obs(i_cond, ch1);
                    rt_sem_obs1 = rt_sem_obs(i_cond, ch1);
                    
                    if isnan(rt_mean_obs1) || isnan(rt_sem_obs1)
                        continue;
                    end
                end

                if W.ignore_choice
                    if cond_bias1 == 0
                        [cost1, grad1, hess1] = ...
                            Fit.Dtb.MeanRt.cost_rtonly_drift0( ...
                                th.b, ...
                                rt_mean_obs1, rt_sem_obs1, tnd1 ...
                                );                        
                    else
                        [cost1, grad1, hess1] = ...
                            Fit.Dtb.MeanRt.cost_rtonly( ...
                                th.b, ...
                                cond1, th.bias_cond, ...
                                th.k, ...
                                rt_mean_obs1, rt_sem_obs1, tnd1 ...
                                );
                    end
                else
                    n_ch21 = n_ch2(i_cond);
                    n_tot1 = n_tot(i_cond);
                    n_ch21 = min(max(n_ch21, 1e-6), n_tot1 - 1e-6);

                    if abs(cond_bias1) == 0 % < 1e-8 % 
                        [cost1, grad1, hess1] = ...
                            Fit.Dtb.MeanRt.cost_ch_rt_drift0( ...
                                th.b, ...
                                cond1, th.bias_cond, ...
                                th.k, ...
                                n_ch21, n_tot1, ...
                                rt_mean_obs1, rt_sem_obs1, tnd1 ...
                                );                        
                    else
                        [cost1, grad1, hess1] = ...
                            Fit.Dtb.MeanRt.cost_ch_rt( ...
                                th.b, ...
                                cond1, th.bias_cond, ...
                                th.k, ...
                                n_ch21, n_tot1, ...
                                rt_mean_obs1, rt_sem_obs1, tnd1 ...
                                );
                    end
                end

                if n_tnd == 1
                    cost = cost + cost1;
                    grad = grad + grad1;
                    hess = hess + hess1;
                else
                    cost = cost + cost1;
                    ix_th1 = ix_th{ch1};
                    grad(ix_th1) = grad(ix_th1) + grad1;
                    hess(ix_th1, ix_th1) = hess(ix_th1, ix_th1) + hess1;
                end
            end
        end
        
        grad0 = grad;
        hess0 = hess;
        n_th_all = numel(W.th_vec);
        grad = zeros(1, n_th_all);
        hess = zeros(n_th_all, n_th_all);
        
        f = @(s) strcmpfinds(s, W.th_names);
        grad(f('b')) = grad0(1);
        grad(f('k')) = grad0(2);
        grad(f('bias_cond')) = grad0(3);
        grad(f('tnd_mean_1')) = grad0(4);
        if n_tnd == 1
            ix = strcmpfinds({'b', 'k', 'bias_cond', 'tnd_mean_1'}, ...
                W.th_names);
            hess(ix, ix) = hess0;
        else
            grad(f('tnd_mean_2')) = grad0(5);
            ix = strcmpfinds({'b', 'k', 'bias_cond', ...
                              'tnd_mean_1', 'tnd_mean_2'}, ...
                W.th_names);
            hess(ix, ix) = hess0;
        end
        
%         disp(grad); % DEBUG
        
        if ~W.ignore_choice
            % To avoid NaNs when p_pred = 0 or 1.
            % The formula for cost are identical 
            % except for max(, eps) in numeric.
            cost = W.calc_cost_numeric;
        end
    end
    function cost = calc_cost_numeric(W)
        % SEM from data
        rt_sem_obs = W.obs_sem_rt_accu;
        
        % SEM from pred
%         n_in_cond_ch = W.Data.obs_n_in_cond_ch_accu;
%         rt_sem_pred = sqrt(W.rt_var_pred ./ n_in_cond_ch);

        % Mean
        rt_mean_obs = W.obs_mean_rt_accu;
        rt_mean_pred = W.rt_mean_pred;
    
        % DEBUG
%         disp(size(rt_sem_obs));
%         disp(size(rt_mean_obs));
%         disp(size(rt_mean_pred));
        
        cost = nansum(vVec( ...
            log(rt_sem_obs) ...
             + (rt_mean_obs - rt_mean_pred) .^ 2 ./ (2 .* rt_sem_obs .^ 2)));
         
%         % SEM from pred (Palmer 2005, eq. 3)
%         cost = nansum(vVec( ...
%             log(rt_sem_pred) ...
%              + (rt_mean_obs - rt_mean_pred) .^ 2 ./ (2 .* rt_sem_pred .^ 2)));

        if ~W.ignore_choice
            n_obs = W.Data.obs_n_in_cond_ch;
            n_ch2 = n_obs(:,2);
            n_tot = sum(n_obs, 2);
            p_pred = W.ch_pred;
            
            % Palmer 2005, eqs. 4 and 5.
            cost = cost - nansum(vVec( ...
                 + gammaln(n_tot + 1) ...
                 - gammaln(n_ch2 + 1) - gammaln(n_tot - n_ch2 + 1) ...
                 + n_ch2 .* log(p_pred) ... log(max(p_pred, eps)) ...
                 + (n_tot - n_ch2) .* log(1 - p_pred) ... log(max(1 - p_pred, eps)) ...
                ));
        end
    end
end
%% == Fitting
methods
    function Fl = get_Fl(W)
        if ~isempty(W.Fl)
            Fl = W.Fl;
            return;
        end
        
        if W.to_use_analytic_cost
            Fl = W.get_Fl@FitWorkspace(FitFlow_hess);
            
            Fl.specify_grad = true;
            Fl.specify_hess = true;
            
            if verLessThan('matlab', '8.7')
                opt_hess = varargin2S({
                    'Algorithm','interior-point'
                    'GradObj', 'on'
                    'GradConstr', 'on'
                    'Hessian', 'user-supplied'
                    'HessFcn', @W.get_hessian
                    });
            else
                opt_hess = varargin2S({
                    'Algorithm','interior-point'
                    'SpecifyObjectiveGradient', true
                    'SpecifyConstraintGradient', true
                    'HessianFcn', @W.get_hessian
                    });
            end
        else
            Fl = W.get_Fl@FitWorkspace;
            opt_hess = struct;
        end
        W.Fl = Fl;
        
        Fl.fit_opt('FminconReduce.fmincon') = @(Fl) varargin2S(opt_hess, {
            'PlotFcns',  Fl.get_plotfun()
            'OutputFcn', Fl.get_outputfun() % includes Fl.OutputFcn, history, etc
            'TypicalX',  Fl.get_th_typical_scale_free % Should supply this because FminconReduce does not reduce it internally
            'FinDiffRelStep', 1e-6 % If too small, SE becomes funky
%             'DiffMinChange', 1e-4
%             'TolX', 1e-5
            });
        
        Fl.OutputFcns = {
%             @(x,v,s) void(@() ...
%                 fprintf('sum_pred: %1.3f\n', ...
%                     sum(Fl.W.Data.RT_pred_pdf(:))), 0)                
%             @(x,v,s) void(@() ...
%                 fprintf('kB: %1.3f, kB / (res_logit.kB2 / 2): %1.3f\n', ...
%                     Fl.W.k * Fl.W.b, ...
%                     Fl.W.k * Fl.W.b / (Fl.W.res_logit.kB2 / 2) ...
%                     ), 0)
%             @(x, v, s) void(@() disp(Fl.W.th))
            };
        
        Fl.remove_plotfun_all;
        Fl.add_plotfun({
            @(Fl) @Fl.optimplotx
            @(Fl) @Fl.optimplotfval
            @(Fl) @(x,v,s) void(@() Fl.W.plot_rt_mean, 0)
            @(Fl) @(x,v,s) void(@() Fl.W.plot_ch, 0)
            });
    end
end
%% == Dense Prediction for Plots
properties
    accu_cond_ch
end
methods
    function pred_with_dense_cond(W)
        % For smooth prediction plots.
        
        if W.to_determine_accu_from_bias_ch
            W.Data.bias_cond = W.bias_cond_glm;
        else
            W.Data.bias_cond = W.th.bias_cond;
        end
        
        W.calc_drift('conds_bias', W.conds_bias_dense);
        W.calc_rt;
        W.calc_ch_pred;
    end
    function v = get_is_pred_dense(W)
        v = size(W.rt_mean_pred, 1) == W.n_pred_dense;
    end
    function tf = get.accu_cond_ch(W)
        if W.is_pred_dense
            v = repmat(W.conds_bias_dense(:), [1, 2]);
        else
            v = repmat(W.conds_bias(:), [1, 2]);
        end
        for ch = 2:-1:1
            tf(:,ch) = sign(v(:,ch)) ~= -sign(ch - 1.5);
        end
    end
end
%% == Plot
methods
    function plot_and_save_all(W)
        W.save_mat;
        
        %%
        W.pred_with_dense_cond;
        for tag = {'rt_mean', 'ch'}
            if isequal(W.to_plot_incl, 'all') || ismember(tag, W.to_plot_incl)
                for n_se = 0:2
                    % std and skew doesn't have se yet.
                    if n_se == 0 ...
                            || ismember(tag, {'rt_mean', 'ch', 'rt_mean_ac01'})
                        
                        fig_tag(tag{1});
                        clf;
                        W.(['plot_' tag{1}])('n_se', n_se);
                        file = W.get_file({'plt', tag{1}, 'nse', n_se});
                        savefigs(file, 'size', [300 200]);
                    end
                end
            end
        end
        
        %%
        W.pred; % Restore previous state
        
        tag = {'PlotFcns'};
        if isequal(W.to_plot_incl, 'all') || ismember(tag, W.to_plot_incl)
            fig_tag(tag{1});
            clf;
            W.(['plot_' tag{1}]);
            file = W.get_file({'plt', tag{1}});
            savefigs(file, 'size', [1200 900]);        
        end
    end
    function plot_rt(W, varargin)
        warning('Only plot_rt_mean is implemented yet.');
        W.plot_rt_mean(varargin{:});
    end
    function plot_rt_mean(W, varargin)
        S = varargin2S(varargin, {
            'color', 'k'
            'dense', W.is_pred_dense
            'color_pred', bml.plot.color_lines('b')
            'n_se', 2
            });
        
        x_data = W.Data.conds;
        y_data = W.obs_mean_rt_accu;
        e_data = W.obs_sem_rt_accu;
        
        if S.dense
            x_pred = W.conds_dense;
        else
            x_pred = W.conds;
        end
        y_pred = W.rt_mean_pred;
        y_pred(~W.accu_cond_ch) = nan;
%         e2 = sqrt(W.rt_var_pred ./ W.Data.obs_n_in_cond_ch_accu);

        cla;
%         for ch = 1:2
%             errorbar(x, y2(:,ch), e2(:,ch), 'k-');
%             hold on;
%         end
        if isempty(S.color_pred)
            S.color_pred = S.color;
        end
        style_pred = Fit.Plot.style_pred({'Color', S.color_pred});
        plot(x_pred, y_pred, style_pred{:});
        hold on;
        
        style_data = Fit.Plot.style_data({'MarkerFaceColor', S.color});
        style_data_tick = Fit.Plot.style_data_tick({'Color', S.color});
        for ch = 1:2
            bml.plot.errorbar_wo_tick(x_data, y_data(:,ch), ...
                e_data(:,ch) * S.n_se, [], ...
                style_data, style_data_tick);
            hold on;
        end
%         plot(x, y1, 'ko', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'w');
        hold off;
        
        W.beautify_plot_rt('desc_y', 'Mean ');
        
        title('Mean RT and SEM');
    end
%     function plot_ch(W, varargin)
%         S = varargin2S(varargin, {
%             'color', 'k'
%             'dense', W.is_pred_dense
%             'n_se', 2 % 1 SE for comparison, 2 SE for standalone.
%             });
%         
%         x_data = W.conds;
%         y_data = W.Data.obs_ch;
%         
%         alpha = (1 - normcdf(S.n_se)) * 2;
%         e_data = bsxfun(@minus, W.Data.get_obs_ci_ch(alpha), y_data(:));
%         
%         if S.dense
%             x_pred = W.conds_dense;
%         else
%             x_pred = W.conds;
%         end
%         y_pred = W.get_ch_pred;
%         
%         style_pred = Fit.Plot.style_pred({'Color', S.color});
%         plot(x_pred, y_pred, style_pred{:});
%         hold on;
%         
%         style_data = Fit.Plot.style_data({'MarkerFaceColor', S.color});
%         if exist('e_data', 'var') && ~isempty(e_data)
%             bml.plot.errorbar_wo_tick(x_data, y_data, e_data(:,1), e_data(:,2), ...
%                 style_data, style_pred);
%         else
%             plot(x_data, y_data, style_data{:});
%         end
%         hold off;
%         
%         title('Choice');
%         
%         W.beautify_plot_ch;
%     end
    function ch_pred = get_ch_pred(W)
        ch_pred = W.ch_pred;
    end
end
%% == Table
methods
    function tabulate_SDT_VD(W0, varargin)
        C = varargin2C(varargin, {
            'subj', Data.Consts.subjs_w_SDT_modul
            });
        Ls1 = W0.load_files({
            'Data/Fit.Dtb.MeanRt.Main/sbj=S1+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1.mat'
            'Data/Fit.Dtb.MeanRt.Main/sbj=S2+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1.mat'
            'Data/Fit.Dtb.MeanRt.Main/sbj=S3+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1.mat'
            'Data/Fit.Dtb.MeanRt.Main/sbj=S4+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1.mat'
            });
%         [~,~,Ls1] = W0.get_batch_files(W0.get_S_batch_VD_sdt_only(C{:}));
            
        C = varargin2C(varargin, {
            'subj', Data.Consts.subjs_wo_SDT_modul
            });
        Ls2 = W0.load_files({
            'Data/Fit.Dtb.MeanRt.Main/sbj=S5+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=0+bch=0+thf={tnd_std_1}+acbch=1.mat'
%             'Data/Fit.Dtb.MeanRt.Main/sbj=S5+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1.mat'           
            });
%         [~,~,Ls2] = W0.get_batch_files(W0.get_S_batch_VD_ch_sdt(C{:}));
            
        W0.compare_params_from_Ls([Ls1(:); Ls2(:)]);
    end
    function tabulate_RT_RT_k_free(W0, varargin)
        C = varargin2C(varargin, {
            'to_import_k', false
            });
%         [~,~,Ls1] = W0.get_batch_files(W0.get_S_batch_RT(C{:}));
        Ls1 = W0.load_files({
            'Data/Fit.Dtb.MeanRt.Main/sbj=S1+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=0+bch=0+thf={tnd_std_1,tnd_std_2}+acbch=1.mat'
            'Data/Fit.Dtb.MeanRt.Main/sbj=S2+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=0+bch=0+thf={tnd_std_1,tnd_std_2}+acbch=1.mat'
            'Data/Fit.Dtb.MeanRt.Main/sbj=S3+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=0+bch=0+thf={tnd_std_1,tnd_std_2}+acbch=1.mat'
            'Data/Fit.Dtb.MeanRt.Main/sbj=S4+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=0+bch=0+thf={tnd_std_1,tnd_std_2}+acbch=1.mat'
            'Data/Fit.Dtb.MeanRt.Main/sbj=S5+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=0+bch=0+thf={tnd_std_1,tnd_std_2}+acbch=1.mat'           
            });
        W0.compare_params_from_Ls(Ls1);
    end
    function tabulate_RT_RT_k_fixed(W0, varargin)
        C = varargin2C(varargin, {
            'to_import_k', true
            });
%         [~,~,Ls1] = W0.get_batch_files(W0.get_S_batch_RT(C{:}));
        Ls1 = W0.load_files({
            'Data/Fit.Dtb.MeanRt.Main/sbj=S1+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=1+bch=0+thf={k,tnd_std_1,tnd_std_2}+acbch=1.mat'
            'Data/Fit.Dtb.MeanRt.Main/sbj=S2+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=1+bch=0+thf={k,tnd_std_1,tnd_std_2}+acbch=1.mat'
            'Data/Fit.Dtb.MeanRt.Main/sbj=S3+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=1+bch=0+thf={k,tnd_std_1,tnd_std_2}+acbch=1.mat'
            'Data/Fit.Dtb.MeanRt.Main/sbj=S4+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=1+bch=0+thf={k,tnd_std_1,tnd_std_2}+acbch=1.mat'
            'Data/Fit.Dtb.MeanRt.Main/sbj=S5+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=1+bch=0+thf={k,tnd_std_1,tnd_std_2}+acbch=1.mat'
            });
        W0.compare_params_from_Ls(Ls1);
    end
    function Ls = load_files(~, files)
        for ii = numel(files):-1:1
            Ls{ii,1} = load(files{ii});
        end
    end
end
%% == Batch
methods
    function batch_all(W0, varargin)
        W0.batch_VD_sdt_all(varargin{:});
        W0.batch_RT_all(varargin{:});
    end
    
    function batch_VD_sdt_all(W0, varargin)
        W0.batch_VD_sdt_only(varargin{:});
        W0.batch_VD_ch_sdt(varargin{:});
    end
    function S = get_S_batch_VD_sdt_only(W0, varargin)
        C = varargin2C(varargin, {
            'parad', {'VD_wSDT'}
            'rt_field', {'SDT_ClockOn'}
            'n_tnd', 1
%             'to_import_k', false
            'bias_cond_from_ch', false
            'ignore_choice', true
            'th_names_fixed_for_file', {{'tnd_std_1', 'tnd_std_2'}}
            });
        S = W0.get_S_batch(C{:});
    end
    function batch_VD_sdt_only(W0, varargin)
        C = S2C(W0.get_S_batch_VD_sdt_only(varargin{:}));
        W0.batch(C{:});
    end
    function S = get_S_batch_VD_ch_sdt(W0, varargin)
        C = varargin2C(varargin, {
            'parad', {'VD_wSDT'}
            'rt_field', {'SDT_ClockOn'}
            'n_tnd', 1
            'bias_cond_from_ch', false
            'ignore_choice', false
            'th_names_fixed_for_file', {{'tnd_std_1', 'tnd_std_2'}}
            });
        S = W0.get_S_batch(C{:});
    end
    function batch_VD_ch_sdt(W0, varargin)
        C = S2C(W0.get_S_batch_VD_ch_sdt(varargin{:}));
        W0.batch(C{:});
    end
    
    function batch_RT_all(W0, varargin)
        C = varargin2C(varargin, {
            'to_import_k', false
            });
        W0.batch_RT(C{:});
        W0.batch_RT_import_k(varargin{:});
    end
    function batch_RT_import_k(W0, varargin)
        C = varargin2C(varargin, {
            'to_import_k', true
            });
        W0.batch_RT(C{:});
        
%         C = varargin2C(varargin, {
%             'subj', Data.Consts.subjs_w_SDT_modul
%             'to_import_k', {varargin2C({
%                 'parad', 'VD_wSDT'
%                 'rt_field', 'SDT_ClockOn'
%                 'n_tnd', 1
%                 'ignore_choice', true
%                 })};
%             });
%         W0.batch_RT(C{:});
%         
%         C = varargin2C(varargin, {
%             'subj', Data.Consts.subjs_wo_SDT_modul
%             'to_import_k', {varargin2C({
%                 'parad', 'VD_wSDT'
%                 'rt_field', 'SDT_ClockOn'
%                 'n_tnd', 1
%                 'ignore_choice', false
%                 })};
%             });
%         W0.batch_RT(C{:});
    end
    function batch_RT(W0, varargin)
        C = varargin2C(varargin, {
            'parad', {'RT_wSDT'}
            'rt_field', {'RT'}
            'n_tnd', 2
            'bias_cond_from_ch', false
            'ignore_choice', false
            });
        W0.batch(C{:});
    end
    function [S_batch, Ss, n] = get_S_batch(~, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            'parad', Data.Consts.dtb_wSDT_parads_short
            'rt_field', Data.Consts.rt_fields
            'from_ix', 1
            'to_ix', inf
            'to_import_k', false
            'use_parallel', 'none' % 'batch'
            'to_fit', true
            'to_plot', nan
            'n_tnd', 1
            });        
        [Ss, n] = bml.args.factorizeS(S_batch);
    end
    function f = get_file_fields(W)
        f = [
            W.get_file_fields@Fit.Dtb.Main
            {
            'to_determine_accu_from_bias_ch', 'acbch'
            }
            ];
    end
end
%% == Import Params
methods
    function batch_import_params_VD_RT(W0, varargin)
        %% SDT_VD ignoring choice
        C = varargin2C(varargin, {
            'subj', Data.Consts.subjs_w_SDT_modul
            'parad', {'VD_wSDT'}
            'rt_field', {'SDT_ClockOn'}
            'n_tnd', 1
            'ignore_choice', true % The only one to ignore choice
            'bias_cond_from_ch', false
            ...
            'to_import_params', true
            'to_plot', true
            });        
        W0.batch_import_params(C{:});
        
        %% SDT_VD with choice
        C = varargin2C(varargin, {
            'subj', Data.Consts.subjs_wo_SDT_modul % This is important
            'parad', {'VD_wSDT'}
            'rt_field', {'SDT_ClockOn'}
            'n_tnd', 1
            'ignore_choice', false
            'bias_cond_from_ch', false
            ...
            'to_import_params', true
            'to_plot', true
            });        
        W0.batch_import_params(C{:});

        %% RT_RT with choice, kappa free
        C = varargin2C(varargin, {
            'subj', Data.Consts.subjs
            'parad', {'RT_wSDT'}
            'rt_field', {'RT'}
            'n_tnd', 2
            'ignore_choice', false
            'bias_cond_from_ch', false
            ...
            'to_import_params', true
            'to_import_k', false
            'to_plot', true
            });        
        W0.batch_import_params(C{:});
        
        %% RT_RT with choice, kappa fixed
        C = varargin2C(varargin, {
            'subj', Data.Consts.subjs
            'parad', {'RT_wSDT'}
            'rt_field', {'RT'}
            'n_tnd', 2
            'ignore_choice', false
            'bias_cond_from_ch', false
            ...
            'to_import_params', true
            'to_import_k', true
            'to_plot', true
            });        
        W0.batch_import_params(C{:});
    end
    function files = batch_import_params(W0, varargin)
        [S_batch, Ss, n_batch] = W0.get_S_batch(varargin{:});
        files = cell(n_batch, 1);
        
        t_st_batch = tic;
        fprintf('Batch of %d units began at %s\n\n', n_batch, datestr(now, 30));
        
        ix_batch = S_batch.from_ix:min(n_batch, S_batch.to_ix);
        for ii = ix_batch
            S = Ss(ii);
            C = S2C(S);
            W = feval(class(W0), C{:});
        
            assert(W.to_import_params);        
            W.import_params_from_file_ds;
        end
        
        if S_batch.to_plot
            ix_batch = S_batch.from_ix:min(n_batch, S_batch.to_ix);
            errs = cell(n_batch, 1);
            files = cell(n_batch, 1);
            for ii = ix_batch
                S = Ss(ii);
                C = S2C(S);

                if strcmp(S.parad, 'VD_wSDT') && strcmp(S.rt_field', 'RT')
                    continue;
                end

                fprintf('Starting %d/%d units: %s\n', ii, n_batch,...
                    bml.str.Serializer.convert(S));
                W = feval(class(W0), C{:});

                file = W.get_file;
                files{ii} = file;
                
                try
                    L = load(file);
                    L.Fl.W.Data.load_data;
                    L.Fl.res2W;
                    W = L.Fl.W;
                    bml.oop.varargin2props(W, C, true);
                    W.plot_and_save_all;
                catch err
                    warning(err_msg(err));
                    errs{ii} = err;
                end
            end        
            for ii = ix_batch
                if ~isempty(errs{ii});
                    fprintf('-----\n');
                    fprintf('Error plotting %d/%d - %s\n', ii, n_batch, ...
                        files{ii});
                    warning(err_msg(errs{ii}));
                    fprintf('-----\n');
                end
            end
        end
        
        t_el_batch = toc(t_st_batch);
        fprintf('Batch of %d units took %1.1fs\n', n_batch, t_el_batch);
    end
    function import_params_from_file_ds(W)
        switch W.parad
            case 'VD_wSDT'
                if W.ignore_choice
                    file_ds = 'Data/Fit.Dtb.MeanRt.Main/ds_SDT_VD_rtonly.csv';
                else
                    file_ds = 'Data/Fit.Dtb.MeanRt.Main/ds_SDT_VD_chrt.csv';
                end

            case 'RT_wSDT'
                if W.to_import_k
                    file_ds = 'Data/Fit.Dtb.MeanRt.Main/ds_RT_RT_chrt_k_fixed.csv';
                else
                    file_ds = 'Data/Fit.Dtb.MeanRt.Main/ds_RT_RT_chrt.csv';
                end
        end
        ds = dataset('File', file_ds, 'Delimiter', ',');
        
        ix1 = strcmp(W.subj, ds.subj);
        row1 = ds(ix1,:);
        
        Fl = W.get_Fl;
        th_names = Fl.W.th_names;
        for th = th_names(:)'
            
            if ismember(['th_' th{1}], row1.Properties.VarNames)
                th1 = ['th_' th{1}];
                se1 = ['se_' th{1}];

                v_th1 = row1.(th1);
                v_se1 = row1.(se1);
                
                if strcmp(th{1}, 'bias_cond')
                    v_th1 = -v_th1;
                end
            else
                v_th1 = W.th0.(th{1});
                v_se1 = 0;
            end

            W.th.(th{1}) = v_th1;
            Fl.W.th.(th{1}) = v_th1;
            Fl.res.th.(th{1}) = v_th1;
            Fl.res.se.(th{1}) = v_se1;
        end
        Fl.res.out.x = Fl.W.th_vec;
        cost = W.get_cost;
        Fl.res.fval = cost;
        
        W.save_mat;
    end
end
end