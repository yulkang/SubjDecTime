classdef Main < Fit.Common.CommonWorkspace
    % Fit.Dtb.Main
    
    % 2016 YK wrote the initial version.
    
%% Props - Settings
properties
    bound_shape = 'betamean'; % 'const'|'betamean'
    
%     kB2_range = [0.9, 1.1];
    
    n_tnd = 2; % 1 or 2
    tnd_distrib_ = '';

    tnd_bayes_ = ''; 
    lapse0 = true;
    
    to_plot_incl = 'all';
    
    ignore_choice = false;
    
    to_import_k = []; % [] to skip importing. {'prop', prop, ..} to import.
    to_import_k_class_ = []; % [] to use the same class.
    
    data_style = {};
    data_tick_style = {};
    pred_style = {'Color', bml.plot.color_lines('b')};
   
    kind_kb = ''; % ''|'ratio'|'logb'|'b'
    
    bias_cond_from_ch = [];
    
    to_use_p_prior = [];
    n_p_prior = 2;
    p_prior_distrib = '';
    
    did_MC = []; % for file names.
    
    skip_existing_fit = false; % true;
end
properties (Dependent)
    to_import_k_class
    to_import_k_cl
    
    % tnd_distrib:
    % '': Auto. 'gamma' for rt_field = 'RT', 'normal' for rt_field = 'SDT'
    % 'gamma'
    % 'normal'
    tnd_distrib
    
    tnd_bayes
    
    th_names_fixed_for_file % th_fixed - {'lapse'}
end
%% Props - Results
properties
%     Fl = [];
    
    res_logit = struct;
end
%% Props - Intermediate results
properties (Transient)
    drift = []; % (n_cond, 1)
    bound = []; % (n_cond, nt)
    tnd = {}; % {1, ch}(n_cond, nt)
    p_prior = []; % (t, 1)
    D = struct;
    
    ds_models = dataset;
    ds_models_txt = dataset;
    
    ds_best = dataset;
    ds_best_txt = dataset;
end
%% Props - Data stats
properties (Dependent)
    conds
    conds_bias
    
    t_tnd
    
    accu_aft_bias
    obs_mean_rt_accu
    obs_sem_rt_accu
end
properties (Dependent)
    obs_mean_rt_accu_vec
    obs_sem_rt_accu_vec
end
properties
    obs_mean_rt_accu_
    obs_sem_rt_accu_
    obs_mean_rt_accu_vec_
    obs_sem_rt_accu_vec_
end
%% == Init
methods
    function W = Main(varargin)
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function init(W, varargin)
        W.init@Fit.Common.CommonWorkspace(varargin{:});
        W.init_params0;
    end
    function [Fl, res] = fit(W)
        Fl = W.get_Fl;
        fprintf('Cost before fit: %1.2f\n', Fl.W.get_cost);
        res = Fl.fit('opts', {'UseParallel', 'never'}); % DEBUG % 'always'}); %
        fprintf('Cost after fit: %1.2f\n', Fl.W.get_cost); % Final cost
    end
    function Fl = get_Fl(W)
        Fl = W.get_Fl@FitWorkspace;
        
        Fl.fit_opt('FminconReduce.fmincon') = @(Fl) varargin2S({
            'PlotFcns',  Fl.get_plotfun()
            'OutputFcn', Fl.get_outputfun() % includes Fl.OutputFcn, history, etc
            'TypicalX',  Fl.get_th_typical_scale_free % Should supply this because FminconReduce does not reduce it internally
            'FinDiffRelStep', 1e-5 % If too small, SE becomes funky
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
    end
    function add_plotfun(W, Fl)
        W.add_plotfun@FitWorkspace(Fl);
        
        Fl.add_plotfun({
            @(Fl) @(x,v,s) void(@() Fl.W.plot_ch, 0)
            @(Fl) @(x,v,s) void(@() Fl.W.plot_rt, 0)
            @(Fl) @(x,v,s) void(@() Fl.W.plot_rt('yfun', 'std'), 0)
            @(Fl) @(x,v,s) void(@() Fl.W.plot_rt('yfun', 'skew'), 0)
            @(Fl) @(x,v,s) void(@() Fl.W.plot_rt_dstr('cond', 1, 'ch', 1), 0)
            @(Fl) @(x,v,s) void(@() Fl.W.plot_rt_dstr('cond', 3, 'ch', 1), 0)
            @(Fl) @(x,v,s) void(@() Fl.W.plot_rt_dstr('cond', 5, 'ch', 1), 0)
            @(Fl) @(x,v,s) void(@() Fl.W.plot_rt_dstr('cond', 5, 'ch', 2), 0)
            @(Fl) @(x,v,s) void(@() Fl.W.plot_bnd, 0)
            @(Fl) @(x,v,s) void(@() Fl.W.plot_tnd, 0)
            });        
    end
end
%% == Batch Facades
methods
    function files = batch_VD_const_bound(W0, varargin)
        files = W0.batch_VD('bound_shape', 'const', varargin{:});
    end
    function files = batch_VD(W0, varargin)
        C = S2C(W0.get_S_batch_VD(varargin{:}));
        files = W0.batch(C{:});
    end
    function S_batch = get_S_batch_VD(~, varargin)
        S_batch = varargin2S(varargin, {
            'parad', {'VD_wSDT'}
            'rt_field', {'SDT_ClockOn'}
            'n_tnd', 1
            'to_import_k', {false} % {[]}
            'ignore_choice', false
            'bias_cond_from_ch', false
            });
    end
    function S_batch = get_S_batch_VD_sdt_only(~, varargin)
        S_batch = varargin2S(varargin, {
            'parad', {'VD_wSDT'}
            'rt_field', {'SDT_ClockOn'}
            'n_tnd', 1
            'to_import_k', {[]}
            'ignore_choice', true
            'bias_cond_from_ch', false
            });
    end
    
    function files = batch_RT(W0, varargin)
        C = S2C(W0.get_S_batch_RT(varargin{:}));
        files = W0.batch(C{:});        
    end    
    function S_batch = get_S_batch_RT(~, varargin)
        S_batch = varargin2S(varargin, {
            'parad', {'RT_wSDT'}
            'rt_field', {'RT'}
            'n_tnd', 2
            'to_import_k', {false} % {[]}
            'ignore_choice', false
            'bias_cond_from_ch', false
            });
    end
    
    function [files, S_batch, Ls] = get_batch_files(W0, varargin)
        S_batch = W0.get_S_batch(varargin{:});
        [Ss, n] = bml.args.factorizeS(S_batch);
        files = cell(n, 1);
        if nargout >= 3
            Ls = cell(n, 1);
        end
        for ii = 1:n
            C = S2C(Ss(ii));
            
            W = feval(class(W0));
            bml.oop.varargin2props(W, C, true);
            files{ii} = W.get_file;
            
            if nargout >= 3
                fprintf('Loading %s\n', files{ii});
                Ls{ii} = load(files{ii});
            end
        end
    end
    
    function batch_CI_VD_demo(W0, varargin)
        C = varargin2C(varargin, {
            'subj', 'S3'
            'n_samp_max', 1e3
            'n_samp_burnin', 5e2
            'n_samp_btw_plot', 50
            'n_samp_bef_adapt_cov', 1e2
            'n_samp_btw_adapt_cov', 1e2
            'n_samp_btw_check_convergence', 200
            'n_MCs', 2
            'parallel_mode', 'none' % 'chain'
            });
        W0.batch_CI_VD(C{:}); 
    end
    function batch_CI_RT_demo(W0, varargin)
        C = varargin2C(varargin, {
            'subj', 'S3'
            'n_samp_max', 2e2
            'n_samp_burnin', 60
            'n_samp_btw_plot', 10
            'n_samp_bef_adapt_cov', 40
            'n_samp_btw_adapt_cov', 10
            'n_samp_btw_check_convergence', 40
            'n_MCs', 2
            'parallel_mode', 'none'
            });
        W0.batch_CI_RT(C{:}); 
    end
    
    function batch_CI_VD(W0, varargin)
        C_batch = S2C(W0.get_S_batch_VD(varargin{:}));
        W0.batch_CI(C_batch{:});
    end
    function batch_CI_RT(W0, varargin)
        C_batch = S2C(W0.get_S_batch_RT(varargin{:}));
        W0.batch_CI(C_batch{:});
    end
    
    function batch_CI(W0, varargin)
        opt = varargin2S(varargin, {
            'parallel_mode', 'chain' % 'none'|'batch'|'chain'
            'n_MCs', 12
            ...
            'n_samp_max', 5e4
            'n_samp_burnin', 5e3
            ...
            'n_samp_bef_adapt_cov', 1e2
            'n_samp_btw_adapt_cov', 1e2
            'n_samp_max_adapt_cov', 1e3
            ...
            'n_samp_btw_check_convergence', 5e3
            ...
            'typical_scale_to_sigma_proposal_factor', 1e-5
            'typical_scale_to_sigma_initial_point_factor', 1e-2
            'thres_convergence', 1.1
            ...
            'to_plot_online', true
            'n_samp_btw_plot', 5e2
            });
        C = varargin2C(opt);
        
        files = W0.get_batch_files(C{:});
        n = numel(files);
        
        if strcmp(opt.parallel_mode, 'batch')
            parfor ii = 1:n
                tic; 
                CI = FitCI;
                CI.main_w_file_Fl(files{ii}, C{:}); %#ok<PFBNS>
                toc;
            end
        else
            for ii = 1:n
                tic; 
                CI = FitCI;
                CI.main_w_file_Fl(files{ii}, C{:});
                toc;
            end
        end
    end
    
    function batch_CI_postprocess_res_VD(W0, varargin)
        C_batch = S2C(W0.get_S_batch_VD(varargin{:}));
        W0.batch_CI_postprocess_res(C_batch{:});
    end
    function batch_CI_postprocess_res_RT(W0, varargin)
        C_batch = S2C(W0.get_S_batch_RT(varargin{:}));
        W0.batch_CI_postprocess_res(C_batch{:});
    end
    function batch_CI_postprocess_res(W0, varargin)
        % Convert old format (th as vec) to new (th as struct)
        files = W0.get_batch_files(varargin{:});
        n = numel(files);
        
        for ii = 1:n
            file = files{ii};
            [pth, nam, ext] = fileparts(file);
            
            nam1 = [nam, '+MC=1'];
            file_MC = fullfile(pth, [nam1, ext]);
            
            L = load(file_MC);
            fprintf('Loaded from %s\n', file_MC);
            
%             if ~isfield(L.res, 'th_mode')
%                 warning('Not in vector format: %s\n', file);
%                 continue;
%             end
            
            L.res.CI.postprocess_Fl_res;
            L.res = L.res.CI.Fl.res;
            
            save(file_MC, '-struct', 'L');
            fprintf('Saved to %s\n', file_MC);
            
            delete([file '.mat']);
            copyfile([file_MC '.mat'], [file '.mat']);
            fprintf('Copied to %s\n', file);
        end
    end
    
    function varargout = batch_CI_check_VD(W0, varargin)
        C_batch = S2C(W0.get_S_batch_VD(varargin{:}));
        [varargout{1:nargout}] = W0.batch_CI_check(C_batch{:});
    end
    function varargout = batch_CI_check_RT(W0, varargin)
        C_batch = S2C(W0.get_S_batch_RT(varargin{:}));
        [varargout{1:nargout}] = W0.batch_CI_check(C_batch{:});
    end
    function [ds, files] = batch_CI_check(W0, varargin)
        files = W0.get_batch_files(varargin{:});
        n = numel(files);
        
        if n == 0
            ds = dataset;
            Fl = [];
            return;
        end
        
        for ii = n:-1:1
            file = files{ii};
            [pth, nam, ext] = fileparts(file);
            
            nam1 = [nam, '+MC=1'];
            file_MC = fullfile(pth, [nam1, ext]);
            files{ii} = file_MC;
            
            L = load(file_MC);
            fprintf('Loaded from %s\n', file_MC);
            
            Fl = L.Fl;
            tf_th_free = ~Fl.W.th_fix_vec;

            MC = L.res.CI.MCMC;
            
            row = struct;
            row.subj = Fl.W.subj;
            row.parad = Fl.W.parad;
            row.rt_field = Fl.W.rt_field;
            
            row.n_samp = MC.n_samp;
            try row.n_MCs = MC.n_MCs; catch, row.n_MCs = 1; end
            
            row.nll_mode = L.res.fval_mode;
            row.nll_mean = L.res.fval_mean;
            row.nll_grad = L.res.res_grad_desc.fval;
            row.nll_mode_dif  = row.nll_mode - row.nll_grad;
            row.nll_mean_dif  = row.nll_mode - row.nll_mean;
            
            row.th_mode  = L.res.th_vec_free_mode;
            row.th_mean  = L.res.th_vec_free_mean;
            row.th_grad  = L.res.res_grad_desc.out.x(tf_th_free);
            row.th_mode_dif   = row.th_mode -  row.th_grad;
            row.th_mean_dif   = row.th_mean -  row.th_grad;
            row.th_mode_ratio = row.th_mode ./ row.th_grad;
            row.th_mean_ratio = row.th_mean ./ row.th_grad;
            
            row.se_mode  = L.res.out.se(tf_th_free);
            row.se_mean  = L.res.out.se(tf_th_free);
            row.se_grad  = L.res.res_grad_desc.out.se(tf_th_free);
            row.se_mode_dif   = row.se_mode -  row.se_grad;
            row.se_mean_dif   = row.se_mean -  row.se_grad;
            row.se_mode_ratio = row.se_mode ./ row.se_grad;
            row.se_mean_ratio = row.se_mean ./ row.se_grad;
            
            rows(ii) = row;
        end
        ds = bml.ds.from_Ss(rows);
        ds = bml.ds.cell2mat2(ds);
        
        ds.Properties.UserData.th_names_free = Fl.W.th_names_free;
    end
    
    function S_batch = get_S_batch_w_imported_k(~, varargin)
        S_batch = varargin2S(varargin, {
            'parad', 'RT_wSDT'
            'rt_field', 'RT'
            'n_tnd', 2
            'to_import_k', {varargin2C({
                'parad', 'VD_wSDT'
                'rt_field', 'SDT_ClockOn'
                'n_tnd', 1
                })}
            });
    end
    function varargout = batch_w_imported_k(W0, varargin)
        S_batch = W0.get_S_batch_w_imported_k(varargin{:});
        C_batch = S2C(S_batch);
        [varargout{1:nargout}] = W0.batch(C_batch{:});
    end
end
%% == Batch
methods
    function main_demo(W, varargin)
        C_batch = varargin2C(varargin, {
            'subj', 'S3'
            'parad', 'VD_wSDT'
            'tnd_distrib', 'normal'
            'rt_field', 'SDT_ClockOn'
            });
        W.main(C_batch{:});
    end
    function [S_batch, Ss, n] = get_S_batch(~, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            'parad', Data.Consts.dtb_wSDT_parads_short
            'tnd_distrib', {'gamma'} % {'gamma', 'normal'}
            'rt_field', Data.Consts.rt_fields
            'from_ix', 1
            'to_ix', inf
            'use_parallel', 'none' % 'batch'
            'to_fit', true
            'to_plot', nan
            });        
        [Ss, n] = bml.args.factorizeS(S_batch);

        % Filter out unnecessary trials
        incl = false(n, 1);
        for ii = 1:n
            S = Ss(ii);
            
            % For RT reports, only inlcude gamma without bayesLeastSq
            if strcmp(S.rt_field, 'RT') ...
                    && strcmp(S.tnd_distrib, 'normal')
                    
                incl(ii) = false;
            else
                incl(ii) = true;
            end
        end
        
        Ss = Ss(incl);
        n = numel(Ss);
    end
    function files = batch(W0, varargin)
        [S_batch, Ss, n_batch] = W0.get_S_batch(varargin{:});
        files = cell(n_batch, 1);
        
        t_st_batch = tic;
        fprintf('Batch of %d units began at %s\n\n', n_batch, datestr(now, 30));
        
        if S_batch.to_fit
            ix_batch = S_batch.from_ix:min(n_batch, S_batch.to_ix);
            
            if strcmp(S_batch.use_parallel, 'batch')
                parfor ii = ix_batch
                    S = Ss(ii);
                    C = S2C(S);

                    if strcmp(S.parad, 'VD_wSDT') && strcmp(S.rt_field', 'RT')
                        continue;
                    end

                    fprintf('Starting %d/%d units: %s\n', ii, n_batch,...
                        bml.str.Serializer.convert(S));
                    W = feval(class(W0), C{:});
                    W.main;
                    files{ii} = W.get_file;
                end
            else
                for ii = ix_batch
                    S = Ss(ii);
                    C = S2C(S);

                    if strcmp(S.parad, 'VD_wSDT') && strcmp(S.rt_field', 'RT')
                        continue;
                    end

                    fprintf('Starting %d/%d units: %s\n', ii, n_batch,...
                        bml.str.Serializer.convert(S));
                    W = feval(class(W0), C{:});
                    W0.W_now = W;
                    W.main;
                    files{ii} = W.get_file;
                end
            end
        end
        if isnan(S_batch.to_plot)
            S_batch.to_plot = strcmp(S_batch.use_parallel, 'batch');
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
end
%% == Main
methods
    function main(W, varargin)
        file = W.get_file;
        if ~isempty(varargin)
            W.Data.loaded = false;
            W.init(varargin{:});
        end
        if W.skip_existing_fit && exist([file '.mat'], 'file')        
            L = load([file '.mat']);
            Fl = W.get_Fl;
            Fl.res = L.res;
            Fl.res2W;
            
%             props_to_preserve = {
%                 'to_plot_incl'
%                 };
%             S = bml.oop.copyprops(struct, W, 'props', props_to_preserve);
%             bml.oop.copyprops(W, S, 'props', props_to_preserve);
        else
            W.fit;
            W.save_mat;
        end
        
        if ~is_in_parallel
            W.plot_and_save_all;
        end
    end
    function save_mat(W)
        file = W.get_file;
        mkdir2(fileparts(file));
        fprintf('Saving results to %s\n', file);
        
        Fl = W.Fl;
        if ~isempty(Fl)
            res = W.Fl.res; %#ok<NASGU>
        else
            res = [];
        end
        save(file, 'W', 'Fl', 'res', 'file');        
    end
end
%% Tabulate
methods
    function varargout = tabulate_RT(W0, varargin)
        [varargout{1:nargout}] = W0.compare_params( ...
            W0.get_S_batch_RT(varargin{:}));
    end
    function varargout = tabulate_VD(W0, varargin)
        C = varargin2C(varargin, {
            'n_tnd', 1
            'ignore_choice', false
            });
        [varargout{1:nargout}] = W0.compare_params( ...
            W0.get_S_batch_VD(C{:}));
    end
end
%% ---- Compare parameters
methods
    function save_ds_params_RT_collapsing_bound(W0, varargin)
        W0.save_ds_params( ...
            'subj', Data.Consts.subjs, ...
            'parad', 'RT_wSDT', ...
            'rt_field', 'RT', ...
            'n_tnd', 2, ...
            'bound_shape', 'betacdf', ...
            'tnd_distrib', 'gamma');
    end
    function save_ds_params(W0, varargin)
        W0.compare_params(varargin{:});
    end
    function [ds, ds_txt, file_batch] = get_ds_models(W0, varargin)
        % [ds, ds_txt, file_batch] = get_ds_models(W0, batch_args{:}, ...)
%         if isempty(W0.ds_models)
            [W0.ds_models, W0.ds_models_txt, file_batch] = W0.compare_params(varargin{:});
%         end
        ds = W0.ds_models;
        ds_txt = W0.ds_models_txt;
    end
    
    function [ds, ds_txt, file_batch] = compare_params(W0, varargin)
%         file_batch = W0.get_file_batch({'tab', 'compare_all'}, ...
%             varargin);
        
        [~, Ss, n_batch] = W0.get_S_batch(varargin{:});
        Ls = cell(n_batch, 1);
        
        for ii = 1:n_batch
            S = Ss(ii);
            C = S2C(S);
            W = feval(class(W0), C{:});
%             bml.oop.varargin2props(W, C, true);
            file = W.get_file;
            
            if ~exist([file '.mat'], 'file')
                warning('%s.mat is missing! Skipping..\n', file);
                continue;
            end
            
            fprintf('Loading %d/%d res from %s\n', ii, n_batch, file);
            Ls{ii} = load([file '.mat']);
            
            fprintf('Loading done.\n');
            to_incl(ii) = true;
        end
        
        [ds, ds_txt, file_batch] = W0.compare_params_from_Ls(Ls);
    end
    function [ds, ds_txt, file_batch] = compare_params_from_Ls(W0, Ls)
        ds = dataset;
        ds_txt = dataset;
        n_batch = numel(Ls);
        to_incl = false(n_batch, 1);
        for ii = n_batch:-1:1
            L = Ls{ii};
            th = L.res.th;
            se = L.res.se;
            W = L.W;
            file = W.get_file;
            
            S0 = W.get_S0_file;
            S0.subj = S0.subj;
            ds = ds_set(ds, ii, S0);
            
            th_txt = struct;
            for nam = fieldnames(th)'
                switch nam{1}
                    case 'k'
                        fmt = '%1.1f';
                    case {'b', 'b_mean', 'b_logbsum'}
                        fmt = '%1.2f';
                    case {'tnd_std_1', 'tnd_std_2', 'lapse'}
                        if se.(nam{1}) == 0
                            continue;
                        end
                    otherwise
                        fmt = '%1.3f';
                end
                
                v = th.(nam{1});
                e = se.(nam{1});
                if e == 0
                    th_txt.(nam{1}) = sprintf(fmt, v);
                else
                    th_txt.(nam{1}) = sprintf([fmt ' +- ' fmt], ...
                        v, e);
                end
            end
            
            ds_txt = ds_set(ds_txt, ii, S0);
            ds_txt = ds_set(ds_txt, ii, th_txt);

            ds = ds_set(ds, ii, bml.struct.prefix_fields(th, 'th_'));
            ds = ds_set(ds, ii, bml.struct.prefix_fields(se, 'se_'));
            
            res = copyFields(struct, L.res, {
                'fval', 'bic', 'aic', 'aic_c', 'n', 'k'});
            res.n_trial = res.n;
            res.n_param = res.k;
            res = rmfield(res, {'n', 'k'});
            ds = ds_set(ds, ii, res);
            ds.file{ii,1} = file;
            
            for nam = setdiff(fieldnames(res)', {'n_trial', 'n_param'}, ...
                    'stable')
                res.(nam{1}) = sprintf('%1.1f', res.(nam{1}));
            end
            ds_txt = ds_set(ds_txt, ii, res);
            
            to_incl(ii) = true;
        end
        if isempty(ds)
            warning('No file exists!\n');
            return;
        end
        ds = ds(to_incl, :);
        ds_txt = ds_txt(to_incl, :);
        W0.ds_models = ds;
        W0.ds_models_txt = ds_txt;
        
        %%
        S_pool = struct;
        fs = intersect(fieldnames(W0.get_S0_file), ds.Properties.VarNames, ...
            'stable');
        for f = fs(:)'
            S_pool.(f{1}) = bml.matrix.unique_general(ds.(f{1}));
        end
        fs = W0.get_file_fields;
        S_pool2 = struct;
        for ii = 1:size(fs, 1)
            if isfield(S_pool, fs{ii,1})
                S_pool2.(fs{ii,2}) = S_pool.(fs{ii,1});
            end
        end
        S_pool = S_pool2;
        S_pool.tab = 'compare_all';

        %%
        file_batch = fullfile('Data', class(W0), ...
            bml.str.Serializer.convert(S_pool));
        
        fprintf('Saving to %s\n', file_batch);
        mkdir2(fileparts(file_batch));
        
        export(ds_txt, 'File', [file_batch '.csv'], 'Delimiter', ',');
        save(file_batch, 'ds');
    end
end
%% ---- Correlation between k
methods
    function [info, h] = plot_param(W0, varargin)
        S = varargin2S(varargin, {
            'param', 'k'
            'corr_kind', 'Pearson'
            });
        
        ds_best = W0.ds_best;
        incl_rt = strcmp(ds_best.parad, 'RT_wSDT') ...
               & strcmp(ds_best.rt_field, 'RT');
        incl_sdt = strcmp(ds_best.parad, 'VD_wSDT') ...
               & strcmp(ds_best.rt_field, 'SDT_ClockOn');
           
        th_field = ['th_' S.param];
           
        if ~isdscolumn(ds_best, th_field)
            warning('%s was not used!\n', th_field);
            info = [];
            h = [];
            return;
        end
        
        y = ds_best.(th_field)(incl_rt);
        x = ds_best.(th_field)(incl_sdt);
        
        if isempty(y) || all(y == y(1)) || isempty(x) || all(x == x(1))
            warning('%s was not used!\n', th_field);
            x = [];
            y = [];
            txt = '';
            info = packStruct(x, y, txt);
            h = [];
            return;
        end
        
        h.plot = plot(x, y, 'o', ...
            'MarkerSize', 8, ...
            'MarkerFaceColor', 'k', ...
            'MarkerEdgeColor', 'w');
%         x_lim = xlim;
%         y_lim = ylim;
        axis equal square;
        if strcmp(S.param, 'bias_cond')
            max_lim = max(abs([x(:); y(:)])) * 1.1;
            xlim([-max_lim, max_lim]);
            ylim([-max_lim, max_lim]);
        else
            max_lim = max([x(:); y(:)]) * 1.1;
            xlim([0, max_lim]);
            ylim([0, max_lim]);
        end
        
        ylabel(sprintf('%s from RT in RT experiment', ...
            strrep(S.param, '_', '\_')));
        xlabel(sprintf('%s from SDT in VD-SDT experiment', ...
            strrep(S.param, '_', '\_')));
        
        rho = corr(x, y);
%         slope = regress(y, x);
%         
        txt = {
            sprintf([S.corr_kind, '''s \\rho=%1.2f'], rho)
            };
%         
%         if strcmp(S.param, 'k')
%             txt = [txt; {
%                 sprintf('Regression slope = %1.2f', slope)
%                 }];
%         end
%         
        h.txt = bml.plot.text_align(txt, 'text_props', {'FontSize', 12});
        fprintf('%s\n', txt{:});
        
        crossline_style = {'--', [0.7 0.7 0.7]};
        h.crossLine = bml.plot.crossLine('NE', 0, crossline_style);
        
        if strcmp(S.param, 'k')            
%             x_lim = xlim;
%             y_lim = ylim;
%             hold on;
%             h.regressLine = plot(xlim, slope * xlim, 'k-');
%             hold off;
%             xlim(x_lim);
%             ylim(y_lim);
            
        elseif strcmp(S.param, 'bias_cond')
            bml.plot.crossLine('h', 0, crossline_style);
            bml.plot.crossLine('v', 0, crossline_style);            
        end
        bml.plot.beautify;
        
        info = packStruct(x, y, txt);
    end
end
%% == Saving
methods
    function f = get_file_fields(W)
        f = [
            W.get_file_fields@Fit.Common.CommonWorkspace
            {
            'bound_shape',  'bnd'
            'tnd_distrib',  'tnd'
            'n_tnd',        'ntnd'
            'tnd_bayes',    'bayes'
            'lapse0',       'lps0'
            'ignore_choice','igch'
            'to_import_k',  'imk'
            'to_import_k_cl', 'imkcl'
            'bias_cond_from_ch', 'bch'
            'kind_kb', 'kb'
            'did_MC', 'MC'
            'to_use_p_prior', 'pr'
            'p_prior_distrib', 'prd'
            'th_names_fixed_for_file', 'thf'
            }
            ];
    end
    function nam = get.th_names_fixed_for_file(W)
        nam = setdiff(W.th_names_fixed, {'lapse'});
        if isempty(nam)
            nam = [];
        end
    end
    function set.th_names_fixed_for_file(W, nam)
        nam_rest = setdiff(setdiff(W.th_names, {'lapse'}), nam);
        for ii = 1:numel(nam)
            W.th_fix.(nam{ii}) = true;
        end
        for ii = 1:numel(nam_rest)
            W.th_fix.(nam_rest{ii}) = false;
        end
    end
    function file = get_file_batch(W0, add_fields, batch_args)
        % file = get_file_batch(W0, add_fields = {'name1', 'desc1', ...}, ...)
        
        if ~exist('add_fields', 'var')
            add_fields = {};
        end
        if ~exist('batch_args', 'var')
            batch_args = {};
        end
        
        S_batch = structfun(@arg2cell, W0.get_S_batch(batch_args), ...
            'UniformOutput', false);
        S0_file = structfun(@arg2cell, W0.get_S0_file, 'UniformOutput', false);
        S = varargin2S(S_batch, S0_file);
        
        file = W0.get_file_batch@Fit.Common.CommonWorkspace( ...
            S, 'add_fields', add_fields);
        
%         S = varargin2S(varargin, {
%             'ds', W0.get_ds_models
%             });
%         
%         file = W0.get_file_batch@Fit.Common.CommonWorkspace( ...
%             S.ds, 'add_fields', add_fields, varargin{:});
    end
end
%% == Main
methods
    function init_params0(W)
        % Fit GLM
        W.res_logit = bml.stat.glmwrap(W.Data.cond, W.Data.ch, 'binomial');
        W.res_logit.bias_cond = W.res_logit.b(1) / W.res_logit.b(2);
        W.res_logit.kB2 = W.res_logit.b(2);
        
        % Bound
        switch W.bound_shape
            case 'const'
                W.add_params({
                    {'b', 1, 0, 3}
                    });
            case 'betamean'
                W.add_params({
                    {'b',        1, 0.05, 3}
                    {'b_logbsum',  2, 1, 5}
                    {'b_mean',  0.2, 0.05, 0.95};
                    });
        end
        
        % Drift
        W.add_params({
            {'k',     25, 0, 100}
            {'bias_cond', 0, -0.512, 0.512}
            });
        
        % Set drift according to res_logit
%         W.th0.k = W.res_logit.kB2 / 2 / W.th0.b;
%         W.lb.k = min(W.th0.k / 2, W.lb.k);
%         W.ub.k = max(W.th0.k * 2, W.ub.k);
        
%         W.th0.bias_cond = -W.res_logit.bias_cond;
%         W.lb.bias_cond = W.th0.bias_cond + W.lb.bias_cond;
%         W.ub.bias_cond = W.th0.bias_cond + W.ub.bias_cond;

        % Import k if requested
        if ~isequal(W.to_import_k, []) && ~isequal(W.to_import_k, false)
            if islogical(W.to_import_k)
                if ismember(W.subj, Data.Consts.subjs_w_SDT_modul)
                    to_import_k = varargin2C({
                        'parad', 'VD_wSDT'
                        'rt_field', 'SDT_ClockOn'
                        'n_tnd', 1
                        'ignore_choice', true
                        });
                else
                    to_import_k = varargin2C({
                        'parad', 'VD_wSDT'
                        'rt_field', 'SDT_ClockOn'
                        'n_tnd', 1
                        'ignore_choice', false
                        });                    
                end
            else
                to_import_k = W.to_import_k;
            end
            
            C2 = varargin2C(varargin2C(to_import_k, {
                'to_import_k', []
                'to_import_k_class', []
                }), W.get_S0_file);
            W2 = feval(W.to_import_k_class, C2{:});
            file2 = W2.get_file;
            L2 = load(file2);
            W.th0.k = L2.res.th.k;
            W.fix_to_th0_('k');

            fprintf('Fixed k to %1.2f as imported from %s\n', ...
                W.th0.k, file2);
        end
        
        % Constrain k and b
%         W.add_constraints({
%             {'c', {'k', 'b'}, ...
%                 {@(v)   W.res_logit.kB2 * W.kB2_range(2) / 2 - v(1) * v(2)}}
%             {'c', {'k', 'b'}, ...
%                 {@(v) -(W.res_logit.kB2 * W.kB2_range(1) / 2 - v(1) * v(2))}}
%             });        
        
        %% Use kbratio and kbprod instead of k and b
        switch W.kind_kb
            case 'ratio'
                W.add_params({
                    {'k_x_b', 25, 0.1, 100}
                    {'k_ov_b', 25, 0.1, 100}
                    });
                
            case 'logb'
                W.add_params({
                    {'log10_kb', log10(25), -1, log10(200)}
                    {'log10_b', 0, -1, log10(6)}
                    });
                
            case 'b'
                W.add_params({
                    {'kb', 25, 0, 200}
                    {'b', 1, 0.1, 6}
                    });
                
            case ''
                % Use k and b
                
            otherwise
                error('Unknown kind_kb=%s\n', W.kind_kb);
        end
        W.use_kb;

        %% Tnd
        for i_tnd = 1:W.n_tnd
            mean_name = str_con('tnd_mean', i_tnd);
            std_name = str_con('tnd_std', i_tnd);

            switch W.tnd_distrib
                case 'normal'
                    W.add_params({
                        {mean_name, 0.2, 0, 2.7} % 2.7} % Allow negative Tnd for SDT
                        {std_name,  1, 0.1, 2.7}
                        });
                case 'gamma'
                    W.add_params({
                        {mean_name, 0.2, 0, 2.7}
                        {std_name,  0.1, 0.01, 1}
                        });
                    % std < mean
                    W.add_constraints({
                        {'A', {std_name, mean_name}, {[1, -1], 0.01}}
                        });
            end
        end
        
        % Miss
        if W.lapse0
            W.add_params({
                {'lapse', eps, eps, eps}
                });
        else
            W.add_params({
                {'lapse', 0.001, eps, 0.05}
                });
        end
    end
    function use_kb(W)
        switch W.kind_kb
            case 'ratio'
                W.th0.k = sqrt(W.th.k_x_b * W.th.k_ov_b);
                W.th0.b = sqrt(W.th.k_x_b / W.th.k_ov_b);
                W.fix_to_th0_('k');
                W.fix_to_th0_('b');
                
            case 'logb'
                W.th0.k = 10.^(W.th.log10_kb - W.th.log10_b);
                W.th0.b = 10.^(W.th.log10_b);
                W.fix_to_th0_('k');
                W.fix_to_th0_('b');
                
            case 'b'
                W.th0.k = W.th.kb / W.th.b;
                W.fix_to_th0_('k');
                
            case ''
                % Use k and b as they are
                
            otherwise
                error('Unknown kind_kb=%s\n', W.kind_kb);
        end
    end
%     function varargout = get_cost(W, x)
%         % [cost, grad, hess[ = W.get_cost
%         W.pred;
%         [varargout{1:nargout}] = W.calc_cost;
%     end
    function pred(W)
        W.use_kb;
        
        W.Data.bias_cond = W.th.bias_cond;
        
        W.calc_drift;
        W.calc_bound;
        W.calc_td;
        W.calc_tnd;
        W.calc_rt;
        W.calc_lapse;
    end
    function drift = calc_drift(W, varargin)
        S = varargin2S(varargin, {
            'k', W.th.k
            'conds_bias', W.conds_bias
            });
        
        drift = S.conds_bias * S.k;
        
        if nargout == 0
            W.drift = drift;
        end
    end
    function v = get.conds(W)
%         if W.Data.is_loaded
            v = W.Data.conds;
%         else
%             v = [];
%         end
    end    
    function v = get.conds_bias(W)
%         if W.Data.is_loaded && isfield(W.th, 'bias_cond')
        if isfield(W.th, 'bias_cond')
            v = W.Data.conds - W.th.bias_cond;
        else
            v = [];
        end
    end
    function bound = calc_bound(W, varargin)
        switch W.bound_shape
            case 'const'
                S = varargin2S(varargin, {
                    'b', W.th.b
                    'size_t', [1, W.nt]
                    });
                bound = S.b + zeros(S.size_t);
                
            case 'betamean'
                nt = W.get_nt;
                b  = W.get_th_('b');
                bound = 1 + zeros(nt,1); % [lb(:), ub(:)]
%                 bound = [-1 + zeros(nt,1), 1 + zeros(nt,1)]; % [lb(:), ub(:)]

                t = W.get_t;
                max_t = W.get_max_t;
                t_norm = t / max_t;

                s = W.get_th_('b_logbsum');
                m = W.get_th_('b_mean');
                beta_1 = sqrt( m ./ (1 - m) .* 10.^s );
                beta_2 = sqrt( (1 - m) ./ m .* 10.^s );
                b_modulated = 1 - betacdf(t_norm, beta_1, beta_2);

                bound = bsxfun(@times, bound, b_modulated(:));

                bound = bound * b;
%                 bound = bound * b - W.get_th_('bias');
                
        end
        if nargout == 0
            W.bound = bound;
        end
    end
    function td = calc_td(W, varargin)
        S = varargin2S(varargin, {
            'drifts', W.drift
            'bound', W.bound
            });
        
        D = dtb.pred.spectral_dtbAA(S.drifts, W.t, S.bound, -S.bound, ...
            W.y, W.y0, false);
        td = cat(3,  D.lo.pdf_t, D.up.pdf_t);
%         td(end, :, :) = cat(3, ...
%             D.notabs.neg_t(:,1,end)', ...
%             D.notabs.pos_t(:,1,end)');
        
%         D = dtb.pred.spectral_dtbAA(S.drifts, W.t, S.bound, -S.bound, ...
%             W.y, W.y0, true);
%         td = cat(3,  D.lo.pdf_t, D.up.pdf_t);
%         td(end, :, :) = cat(3, ...
%             D.notabs.neg_t(:,1,end)', ...
%             D.notabs.pos_t(:,1,end)');
        
        if nargout < 1
            W.Data.Td_pred_pdf = td;
        end
        if nargout < 2
            W.D = D;
        end
    end
    function tnd = calc_tnd(W, varargin)
        t_tnd = W.t_tnd;
        
        for i_tnd = W.n_tnd:-1:1
            tnd_mean = W.th.(str_con('tnd_mean', i_tnd));
            tnd_std  = W.th.(str_con('tnd_std',  i_tnd));
            
            switch W.tnd_distrib
                case 'gamma'
                    tnd{i_tnd} = gampdf_ms(t_tnd, tnd_mean, tnd_std, 1);
                case 'normal'
                    tnd{i_tnd} = ...
                        pmf(@normcdf, t_tnd, ...
                            tnd_mean, tnd_std);
            otherwise
                error('Unknown t_tnd=%s\n', W.tnd_distrib);
            end
        end
        if W.n_tnd == 1
            tnd{2} = tnd{1};
        end
        
        if nargout == 0
            W.tnd = tnd;
        end
    end
    function t_tnd = get.t_tnd(W)
        switch W.tnd_distrib
            case 'gamma'
                t_tnd = W.t(:);
            case 'normal'
                t_tnd = [-flipud(W.t(:)); vVec(W.t(2:end))];
            otherwise
                error('Unknown t_tnd=%s\n', W.tnd_distrib);
        end
    end
    function rt_pred_pdf = calc_rt(W, varargin)
        persistent Tnd
        
        S = varargin2S(varargin, {
            'td_pred_pdf', []
            });
        
        if ~isempty(S.td_pred_pdf)
            td_pred_pdf = S.td_pred_pdf;
        else
            td_pred_pdf = W.Data.Td_pred_pdf;
        end
        rt_pred_pdf = zeros(size(td_pred_pdf));
        
        n_ch = 2;
        for ch = 1:n_ch
            % Copy variables for the given choice
            tnd = W.tnd{ch};
            td  = W.Data.Td_pred_pdf(:,:,ch);

            if W.n_tnd == 1
                i_tnd = 1;
            else
                i_tnd = ch;
            end
                        
            if strcmp(W.tnd_distrib, 'normal')
                rt_pred_pdf_ch = bml.math.conv(td, tnd, 'same');
            else
                rt_pred_pdf_ch = bml.math.conv_t(td, tnd);
            end
            rt_pred_pdf(:,:,ch) = rt_pred_pdf_ch;            
        end
        
        assert(strcmp(W.tnd_bayes, 'none'));
        
        if W.ignore_choice
            rt_pred_pdf = bsxfun(@rdivide, ...
                rt_pred_pdf + eps, ...
                sum(rt_pred_pdf, 1));
        end
        
        if nargout == 0
            W.Data.RT_pred_pdf = rt_pred_pdf;
        end
    end
    
    function v = get.to_import_k_class(W)
        v = W.to_import_k_class_;
        if isempty(v)
            v = class(W);
        end
    end
    
    function v = get.to_import_k_cl(W)
        if isempty(W.to_import_k_class_)
            v = [];
        else
            v = strrep(W.to_import_k_class, '.', '^');
        end
    end
    
    function v = get.tnd_distrib(W)
        % tnd_distrib:
        % '': Auto. 'gamma' for rt_field = 'RT', 'normal' for rt_field = 'SDT'
        % 'gamma'
        % 'normal'
        % 'halfnorm'
        if isempty(W.tnd_distrib_)
            switch W.rt_field
                case 'RT'
                    v = 'gamma';
                case 'SDT_ClockOn'
                    v = 'gamma'; % 'normal'; % All gamma by default.
            end
        else
            v = W.tnd_distrib_;
        end
    end
    function set.tnd_distrib(W, v)
        W.tnd_distrib_ = v;
    end
    
    function v = get.tnd_bayes(W)
        % tnd_bayes:
        % '': Auto. 'none' for tnd_distrib = 'gamma' & 'halfnorm'
        if isempty(W.tnd_bayes_)
            switch W.tnd_distrib
                case 'normal'
                    assert(isa(W, 'Fit.Dtb.MeanRt.Main'));
                    v = 'none'; 
                case 'gamma'
                    v = 'none';
                otherwise
                    error('Cannot determine tnd_bayes for tnd_distrib=%s\n', ...
                        W.tnd_distrib);
            end
        else
            v = W.tnd_bayes_;
        end
    end
    function set.tnd_bayes(W, v)
        W.tnd_bayes_ = v;
    end
    
    function rt_pdf = calc_lapse(W, varargin)
        lapse = W.th.lapse;
        rt_pdf = W.Data.RT_pred_pdf;
        
        n_ch = size(rt_pdf, 3);
        rt_pdf = rt_pdf * (1 - lapse) + lapse / n_ch / W.nt;
        
        if nargout == 0
            W.Data.RT_pred_pdf = rt_pdf;
        end
    end
    function cost = calc_cost(W)
        cost = bml.stat.nll_bin( ...
            reshape(permute(W.Data.RT_pred_pdf, [1, 3, 2]), [], W.Data.n_cond), ...
            reshape(permute(W.Data.RT_data_pdf, [1, 3, 2]), [], W.Data.n_cond));
    end
end
%% == Accu vs Wrong RT
methods
    function varargout = fit_rt_vs_accu_RT(W0, varargin)
        C = S2C(W0.get_S_batch_RT(varargin{:}));
        [varargout{1:nargout}] = W0.fit_rt_vs_accu(C{:});
    end
    function varargout = fit_rt_vs_accu_VD(W0, varargin)
        C = S2C(W0.get_S_batch_VD(varargin{:}));
        [varargout{1:nargout}] = W0.fit_rt_vs_accu(C{:});
    end
    function [mdl, mdls, tbl_accu, tbl] = fit_rt_vs_accu(W0, varargin)
        S = W0.get_S_batch(varargin{:});
        C = S2C(S);
        files = W0.get_batch_files(C{:});
        n = numel(files);
        
        mdls = cell(1, n);
        
        tbl = table;
        tbl_accu = table;
        for ii = 1:n
            file = files{ii};
            fprintf('Loading %s\n', file);
            L = load(file);
            
            W = L.Fl.W;
            W.Data.load_data;
            
            % Get bias from choices only
            cond0 = W.Data.cond;
            ch0 = W.Data.ch;
            b = glmfit(cond0, ch0, 'binomial');
            bias = -b(1) / b(2);
            
            W.Data.bias_cond = bias; % L.res.th.bias_cond;
            
            cond = abs(W.Data.cond_bias);
            accu = logical(W.Data.accu);
            
            n_tr = length(cond);
            subj1 = sprintf('S%d', ii);
            subj = repmat(categorical({subj1}), [n_tr, 1]);
            
            rt = W.Data.rt;
            
            [~,~,d_cond] = unique(cond);
            n_cond = max(d_cond);
            n_accu_by_cond = accumarray([d_cond, accu + 1], 1, ...
                [n_cond, 2], @sum);
            incl_by_cond = n_accu_by_cond > 0;
            
            incl = false(n_tr, 1);
            for accu1 = 1:2
                for d_cond1 = 1:n_cond
                    incl((d_cond == d_cond1) & (accu == accu1 - 1)) = ...
                        incl_by_cond(d_cond1, accu1);
                end
            end
            
            tbl1 = table(subj, cond, accu, rt);
            tbl1.accu = logical(tbl1.accu);
            mdls{ii} = W0.fit_rt_vs_accu_wi_subj(tbl1);
            
            tbl_accu1 = mdls{ii}.Coefficients('accu_1', :);
            tbl_accu1.Properties.RowNames = {subj1};
            tbl_accu = [tbl_accu; tbl_accu1];
            
            file_tbl1 = [
                W.get_file({'sbj', subj1, 'tbl', 'rt_accu_mdl'}), ...
                '.csv'];
            writetable(mdls{ii}.Coefficients, file_tbl1, ...
                'WriteRowNames', true);
            fprintf('Wrote table to %s\n', file_tbl1);
            
            tbl = [tbl; tbl1(incl,:)];
        end
        tbl.accu = logical(tbl.accu);
        mdl = W0.fit_rt_vs_accu_across_subjs(tbl);
        
        ix_row = strcmp(mdl.Coefficients.Name, 'accu_1');
        tbl_accu1 = dataset2table(mdl.Coefficients( ...
            ix_row, {'Estimate', 'SE', 'tStat', 'pValue'}));
        tbl_accu1.Properties.RowNames = {'all'};
        tbl_accu = [tbl_accu; tbl_accu1];
        
        file_tbl_pv = [W.get_file({ ...
            'sbj', subj(:), ...
            'tbl', 'rt_vs_accu_1_coef'}), '.csv'];
        writetable(tbl_accu, file_tbl_pv, ...
                'WriteRowNames', true);
            
        file_tbl_pv_rfx = [W.get_file({ ...
            'sbj', subj(:), ...
            'tbl', 'rt_vs_accu_1_rfx'}), '.csv'];
        [~,~,rfx] = mdl.randomEffects;
        writetable(dataset2table(rfx), file_tbl_pv_rfx);
        
        file_tbl = [W.get_file({ ...
            'sbj', subj(:), ...
            'tbl', 'rt_accu_mdl'}), '.csv'];
        writetable(dataset2table(mdl.Coefficients), file_tbl, ...
                'WriteRowNames', true);
        fprintf('Wrote table to %s\n', file_tbl);        
    end
    function mdl = fit_rt_vs_accu_across_subjs(~, tbl)
        mdl = fitglme(tbl, ...
            'rt ~ accu * cond + (accu * cond | subj)');
    end
    function mdl = fit_rt_vs_accu_wi_subj(~, tbl)
        mdl = fitglm(tbl, ...
            'rt ~ accu * cond');
    end
end
%% == Data stats
methods
    function v = get.accu_aft_bias(W)
        if isfield(W.th, 'bias_cond')
            ans_aft_bias = sign(W.Data.cond - W.th.bias_cond);
            v = double( ...
                  (sign(W.Data.ds.subjAns - 1.5) == ans_aft_bias) ...
                | (ans_aft_bias == 0));
        else
            v = [];
        end
    end
    function v = get.obs_mean_rt_accu(W)
        if isempty(W.obs_mean_rt_accu_)
            v = W.Data.obs_mean_rt_accu;
        else
            v = W.obs_mean_rt_accu_;
        end
    end
    function v = get.obs_sem_rt_accu(W)
        if isempty(W.obs_sem_rt_accu_)
            v = W.Data.obs_sem_rt_accu;
        else
            v = W.obs_sem_rt_accu_;
        end
    end
    function v = get.obs_mean_rt_accu_vec(W)
        if isempty(W.obs_mean_rt_accu_vec_)
            v = W.Data.get_obs_mean_rt_accu_vec;
        else
            v = W.obs_mean_rt_accu_vec_;
        end
    end
    function v = get.obs_sem_rt_accu_vec(W)
        if isempty(W.obs_sem_rt_accu_vec_)
            v = W.Data.get_obs_sem_rt_accu_vec;
        else
            v = W.obs_sem_rt_accu_vec_;
        end
    end
end
%% == Dense Prediction for Smooth Plot
properties
    % n_pred_dense
    % : Defaults to 301 points between [min(cond), max(cond)]
    %   Should be an odd number to produce a gapless line.
    n_pred_dense = 301; 
end
properties (Dependent)
    conds_dense
    conds_bias_dense
    is_pred_dense
end
methods
    function pred_with_dense_cond(W)
        % For smooth prediction plots.
        
        W.Data.bias_cond = W.th.bias_cond;
        W.calc_drift('conds_bias', W.conds_bias_dense);
        W.calc_bound;
        W.calc_td;
        W.calc_tnd;
        W.calc_rt;
        W.calc_lapse;
    end
    function v = get.conds_dense(W)
        % The value without bias. Used for plotting.
        v = W.conds;
        if ~isempty(v)
            v = linspace(v(1), v(end), W.n_pred_dense);
        end
    end
    function v = get.conds_bias_dense(W)
        v = W.conds_bias;
        if ~isempty(v)
            v = linspace(v(1), v(end), W.n_pred_dense);
        end
    end
    function v = get.is_pred_dense(W)
        v = W.get_is_pred_dense;
    end
    function v = get_is_pred_dense(W)
        v = size(W.Data.RT_pred_pdf, 2) == W.n_pred_dense;
    end
end
%% == Plot-Batch
methods
    function batch_load_and_plot_VD(W0, varargin)
        W0.batch_load_and_plot(W0.get_S_batch_VD(varargin{:}));
    end
    function batch_load_and_plot_RT(W0, varargin)
        W0.batch_load_and_plot(W0.get_S_batch_RT(varargin{:}));
    end
    function batch_load_and_plot(W0, varargin)
        C = varargin2C(varargin, {
            'to_fit', false
            'to_plot', true
            'to_plot_incl', 'all'
            'use_parallel', 'none'
            });
        W0.batch(C{:});
    end
    function plot_and_save_all(W)
        W.pred_with_dense_cond;
        for tag = {
                'rt_mean', 'ch', 'rt_std', 'rt_skew', ...
                'rt_mean_ac01', 'rt_std_ac01', 'rt_skew_ac01'
                }
            if isequal(W.to_plot_incl, 'all') || ismember(tag, W.to_plot_incl)
                for n_se = 0:2
                    % std and skew doesn't have se yet.
                    if n_se == 0 ...
                            || ismember(tag, {'rt_mean', 'ch', 'rt_mean_ac01'})
                        
                        fig_tag(tag{1});
                        clf;
                        W.(['plot_' tag{1}])('n_se', n_se);
                        file = W.get_file({'plt', tag{1}, 'nse', n_se});
                        savefigs(file);
                    end
                end
            end
        end
        
        % Restore original coherences
        W.pred; 
        
        tag = {'PlotFcns'};
        if isequal(W.to_plot_incl, 'all') || ismember(tag, W.to_plot_incl)
            fig_tag(tag{1});
            clf;
            W.(['plot_' tag{1}]);
            file = W.get_file({'plt', tag{1}});
            try
                savefigs(file, 'size', [1200 900]);
            catch err
                warning(err_msg(err));
            end
        end
        
        for tag = {'rt_pdf_all'}; % 'rt_dstr_all'
            if isequal(W.to_plot_incl, 'all') || ismember(tag, W.to_plot_incl)
                fig_tag(tag{1});
                clf;
                W.(['plot_' tag{1}]);
                file = W.get_file({'plt', tag{1}});
                savefigs(file, 'size', [300 1200]);
            end
        end
    end
    function plot_PlotFcns(W)
        Fl = W.get_Fl;
        Fl.runPlotFcns;
    end    
end
%% Plot-RT
methods
    function plot_rt_mean(W, varargin)
        C = varargin2C(varargin, {'yfun', 'mean'});
        W.plot_rt(C{:});
    end
    function plot_rt_std(W, varargin)
        C = varargin2C(varargin, {'yfun', 'std'});
        W.plot_rt(C{:});
    end
    function plot_rt_skew(W, varargin)
        C = varargin2C(varargin, {'yfun', 'skew'});
        W.plot_rt(C{:});
    end
    
    function plot_rt_mean_ac01(W, varargin)
        C = varargin2C(varargin, {'yfun', 'mean'});
        W.plot_rt_ac01(C{:});
    end
    function plot_rt_std_ac01(W, varargin)
        C = varargin2C(varargin, {'yfun', 'std'});
        W.plot_rt_ac01(C{:});
    end
    function plot_rt_skew_ac01(W, varargin)
        C = varargin2C(varargin, {'yfun', 'skew'});
        W.plot_rt_ac01(C{:});
    end
    
    function plot_rt_ac01(W, varargin)
        jitter = 0.001;
        
        C = varargin2C(varargin2C({'color', 'k'}, varargin), {
            'accu', 1
            'n_se', 1
            'jitter', -jitter
            });
        W.plot_rt(C{:});
        hold on;
        
        C = varargin2C(varargin2C({'color', [0 0 0] + 0.7}, varargin), {
            'accu', 0
            'n_se', 1
            'jitter', jitter
            });
        W.plot_rt(C{:});
        hold off;
    end
    
    function h = plot_rt(W, varargin)
        S = varargin2S(varargin, {
            'jitter', 0 % 0.1
            'pred_line_style', {}
            'pred_tick_style', {'LineStyle', 'none'}
            'obs_line_style', {}
            'obs_tick_style', {'LineStyle', 'none'}
            'normfit', false
            'yfun', 'mean' % 'mean'|'std'|'skew'
            'color', []
            'color_obs', 'k'
            'color_pred', bml.plot.color_lines('b')
            'dense', W.is_pred_dense
            'n_se', 2 % 1 SE for comparison, 2 SE for standalone.
            'accu', 1 % 1 for accu, 0 for ~accu
            'n_tr_thres', 3 
            });
        if ~isempty(S.color)
            S.color_obs = S.color;
            S.color_pred = S.color;
        end
        
        h = struct;
        h.data = ghandles(0,1);
        h.err = ghandles(0,1);
        h.pred = ghandles(0,1);
        
        S.pred_line_style = varargin2C({'Color', S.color_pred}, ...
            Fit.Plot.style_pred(S.pred_line_style));
        S.pred_tick_style = varargin2C({'Color', S.color_pred}, ...
            Fit.Plot.style_pred(S.pred_line_style));
        
        S.obs_line_style = varargin2C({'MarkerFaceColor', S.color_obs}, ...
            Fit.Plot.style_data);
        S.obs_tick_style = Fit.Plot.style_data_tick({
            'Color', S.color_obs
            });
%             fig_tag('rtFl');

        jitter = S.jitter;
%         jitter = S.jitter * min(diff(W.Data.conds));

        sgn_accu = sign(S.accu - 0.5);
        for ch = 1:2
            h_data = ghandles(0,1);
            h_err = ghandles(0,1);
            h_pred = ghandles(0,1);
            
            tf_data = sign(W.conds_bias) ~= -sgn_accu .* sign(ch - 1.5);
            x_data = W.conds(tf_data);
            
            if S.dense
                tf_pred = sign(W.conds_bias_dense) ~= -sgn_accu .* sign(ch - 1.5);
                x_pred = W.conds_dense(tf_pred);
            else
                tf_pred = sign(W.conds_bias) ~= -sgn_accu .* sign(ch - 1.5);
                x_pred = W.conds(tf_pred);
            end
            
            switch S.yfun
                case 'mean'
                    y_pred = W.Data.pred_mean_rt(tf_pred, ch);
                    y_data = W.Data.obs_mean_rt(tf_data, ch);
                    e_data = W.Data.obs_sem_rt(tf_data, ch) * S.n_se;
                    
                case 'std'
                    y_pred = W.Data.pred_std_rt(tf_pred, ch);
                    y_data = W.Data.obs_std_rt(tf_data, ch);
                    e_data = []; % Not implemented yet
                    
                case 'skew'
                    y_pred = W.Data.pred_skew_rt(tf_pred, ch);
                    y_data = W.Data.obs_skew_rt(tf_data, ch);
                    e_data = []; % Not implemented yet
            end
            
            n_tr_data = W.Data.obs_n_in_cond_ch(tf_data,ch);
            incl_data = ~isnan(y_data) & (n_tr_data >= S.n_tr_thres);

            if ~any(incl_data)
                continue;
            end
            
            x_data_min = min(x_data(incl_data));
            x_data_max = max(x_data(incl_data));

            pred_incl = (x_pred >= x_data_min) ...
                      & (x_pred <= x_data_max);
            
            if S.accu == 0
                if ch == 2
                    pred_incl = (x_pred >= max(x_data_min - 0.06, min(x_data))) ...
                              & (x_pred <= x_data_max);
                else
                    pred_incl = (x_pred >= x_data_min) ...
                              & (x_pred <= min(x_data_max + 0.06, max(x_data)));
                end
            end
            
            x_data(~incl_data) = nan;
            y_data(~incl_data) = nan;
            if ~isempty(e_data)
                e_data(~incl_data) = nan;
            end
            
            x_pred = x_pred(pred_incl);
            y_pred = y_pred(pred_incl);
            
            h_pred = ...
                plot(x_pred + jitter, y_pred, S.pred_line_style{:});
            hold on;
            
            if isempty(e_data) || all(isnan(e_data))
                h_data = ... 
                    plot(x_data + jitter, y_data, S.obs_line_style{:});
                hold on;
            else
                [h_data, h_err] = ...
                    bml.plot.errorbar_wo_tick(x_data + jitter, y_data, e_data, [], ...
                        S.obs_line_style, S.obs_tick_style);
            end
            
            h.data = [h.data; h_data(:)];
            h.err = [h.err; h_err(:)];
            h.pred = [h.pred; h_pred(:)];
        end
        
        W.beautify_plot_rt('desc_y', [bml.str.upper(S.yfun, 'sentence') ' ']);

        title(sprintf('%s RT', S.yfun));
    end
    function beautify_plot_rt(W, varargin)
        S = varargin2S(varargin, {
            'desc_y', ''
            });
        
        hold off;
        grid on;
        
        switch W.rt_field
            case 'RT'
                ylabel([S.desc_y, 'RT (s)']);
            case 'SDT_ClockOn'
                ylabel([S.desc_y, 'SDT (s)']);
        end
        
        bml.plot.beautify;
        Fit.Plot.beautify_rt_axis;
        Fit.Plot.beautify_coh_axis;
    end
end
%% Plot-Ch
methods
    function h = plot_ch(W, varargin)
        S = varargin2S(varargin, {
            'color', 'k'
            'dense', W.is_pred_dense
            'n_se', 2 % 1 SE for comparison, 2 SE for standalone.
            'color_pred', bml.plot.color_lines('b'); % ''
            });
        
        h = struct;
        
        if S.dense
            x_pred = W.conds_dense;
        else
            x_pred = W.conds;
        end
        y_pred = W.get_ch_pred;
        
        if isempty(S.color_pred)
            S.color_pred = S.color;
        end
        style_pred_default = {'Color', S.color_pred};
        if W.ignore_choice
            style_pred_default = [style_pred_default
                {'LineStyle', '--'}];
        end
        style_pred = Fit.Plot.style_pred(style_pred_default);
        h.pred = plot(x_pred, y_pred, style_pred{:});
        
        hold on;
        x_data = W.Data.conds;
        y_data = W.Data.obs_ch;
        
        alpha = (1 - normcdf(S.n_se)) * 2;
        e_data = bsxfun(@minus, W.Data.get_obs_ci_ch(alpha), y_data(:));
        
        style_data = Fit.Plot.style_data({'MarkerFaceColor', S.color});
        style_data_tick = Fit.Plot.style_data_tick({'Color', S.color});
        if exist('e_data', 'var') && ~isempty(e_data)
            [h.data, h.err] = ...
                bml.plot.errorbar_wo_tick(x_data, y_data, e_data(:,1), e_data(:,2), ...
                style_data, style_data_tick);
        else
            h.data = plot(x_data, y_data, style_data{:});
            h.err = ghandles(0,1);
        end
        hold off;
        
        title('Choice');

        W.beautify_plot_ch;
    end
    function ch_pred = get_ch_pred(W)
        ch_pred = W.Data.pred_ch;
    end
    function beautify_plot_ch(~)
        grid on;
        bml.plot.beautify;
        Fit.Plot.beautify_ch_axis;
        Fit.Plot.beautify_coh_axis;
    end
end
%% Plot - Bound, Tnd, Prior
methods
    function plot_bnd(W, varargin)
%         fig_tag('bound'); 

%         W.Bound.plot;

        plot(W.t, W.bound);
        xlabel('Time (s)');
        ylabel('Bound');

        xlim([0, W.max_t]);
        ylim([0, max(W.bound) * 1.1]);
        
        grid on;
        bml.plot.beautify;
    end
    function plot_tnd(W, varargin)
        t_tnd = W.t_tnd;
        
        for ch = 2:-1:1
            h(ch) = plot(t_tnd, W.tnd{ch});
            hold on;
        end
        hold off;

        xlim(t_tnd([1, end]));
        
        max_y = max([W.tnd{1}(:); W.tnd{2}(:)]);
        ylim([0, max_y * 1.1]);
        grid on;
        bml.plot.beautify;
        
        legend(h, {'T_{nd,L}', 'T_{nd,R}'}, 'FontSize', 12, ...
            'Location', 'NorthEast', 'Box', 'off');
        xlabel('Time (s)');
        ylabel('P(T_{nd})');
    end
    function plot_p_prior(W)
        t = W.t;
        p = W.p_prior;
        plot(t, p);
        xlim([0, t(end)]);
        bml.plot.beautify;
        xlabel('Time (s)');
        ylabel('P_SDT (=prior)');        
    end
end
%% Plot - RT distribution
methods
    function plot_rt_dstr(W, varargin)
        S = varargin2S(varargin, {
            'sigma', 0.05
            ... 'figTag', 'rtDistrib'
            'cond', 1
            'ch',   1 % 1 or 2
            'ySign',[]
            'cost_scale', []
            'yfun', 'cumsum' % 'orig'|'cumsum'
            });

%             if ~isempty(S.figTag)
%                 fig_tag(S.figTag); 
%             end
        if isempty(S.ySign), S.ySign = sign(S.ch - 1.5); end
%             if isempty(S.cost_scale), S.cost_scale = 1 / max(W.cost_sep(:)); end

%             cost = cumsum(W.cost_pdf(:,S.cond,S.ch));
%             plot(W.t, cost * S.cost_scale * S.ySign, 'Color', 'g');
%             hold on;

        obs_n = sums(W.Data.RT_data_pdf(:,S.cond,:));
        obs_scale = 1 / W.dt / obs_n;

        if ~isempty(W.Data.RT_pred_pdf)
            pred_n = sums(W.Data.RT_pred_pdf(:,S.cond,:));
            pred_scale = 1 / W.dt / pred_n;
        end
        
        obs  = W.Data.RT_data_pdf(:,S.cond,S.ch);
        switch S.yfun
            case 'orig'
                y = smooth_gauss(obs, S.sigma/W.dt) * S.ySign * obs_scale;
            case 'cumsum'
                y = cumsum(obs .* S.ySign) / obs_n;
        end
        plot(W.t, y, 'Color', bml.plot.color_lines('r'));
        hold on;

        if ~isempty(W.Data.RT_pred_pdf)
            pred = W.Data.RT_pred_pdf(:,S.cond,S.ch);
            switch S.yfun
                case 'orig'
                    y = pred * S.ySign * pred_scale;
                case 'cumsum'
                    y = cumsum(pred .* S.ySign) / pred_n;
            end
            plot(W.t, y, '--', 'Color', bml.plot.color_lines('b'));
        end
        
%         bml.plot.crossLine('h', 0, {'-', 0.3 + [0 0 0]});
        
        hold off;
        grid on;
        bml.plot.beautify;

        title(sprintf('Coh=%1.1f', W.Data.conds(S.cond)*1e2));
        xlabel('Time (s)');
        xlim([0, W.max_t]);
        switch S.yfun
            case 'cumsum'
                set(gca, ...
                    'YTick', -1:0.5:1, ...
                    'YTickLabel', {'-1', '', '0', '', '1'});
                
                if S.ySign == 1
                    ylim([0 1]);
                else
                    ylim([-1, 0]);
                end
        end
    end
    function plot_rt_dstr_all(W, varargin)
        S = varargin2S(varargin, {
            ... 'figTag', 'rtDistribAll'
            'ori', 'v' % Subplot arrangement
            'yfun', 'cumsum'
            });
        C = S2C(S);
%             if ~isempty(S.figTag)
%                 fig_tag(S.figTag);
%             end

        nCond = numel(W.Data.conds);

        switch S.ori
            case 'v'
                nR = nCond;
                nC = 1;
            case 'h'
                nR = 1;
                nC = nCond;
        end

        for ii = nCond:-1:1
            h(ii) = subplot(nR,nC,nR+1-ii);
            cla;

            for jj = 1:2
                C = varargin2C({
                    'figTag', ''
                    'cond', ii
                    'ch', jj
                    }, S);
                W.plot_rt_dstr(C{:});
                hold on;
            end
            bml.plot.crossLine('h', 0, {'-', 0.7 + [0 0 0]});
            
            switch S.yfun
                case 'cumsum'
                    ylim([-1, 1]);
            end
            ylabel(sprintf('%1.1f', W.Data.conds(ii) * 1e2));
            xlabel('');
            title('');
        end

        sameAxes(nR,nC,1:nCond,'y');
    end
    function plot_rt_pdf(W, varargin)
        W.plot_rt_dstr(varargin2C({'yfun', 'orig'}, varargin));
    end
    function plot_rt_pdf_all(W, varargin)
        W.plot_rt_dstr_all(varargin2C({'yfun', 'orig'}, varargin));
    end
    rtDistribAll(Fl, varargin)
end
%% == Imgather
methods
    function imgather_RT_ac01_parads_ch_rt(~)
        %%
        figs{1} = '/Users/yulkang/Dropbox/CodeNData/ExtRepos/ShadlenLab/SDT/SDT_ANALYSIS/ANALYSIS/Data/figs/final/SFig2_WrongRT_VD_sbj={S1,S2,S3,S4,S5}+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=betamean+tnd=gamma+ntnd=1+bayes=none+lps0=1+igch=0+bch=0+plt={rt_mean_ac01,ch}+prd_rtf={VD_wSDT,SDT_ClockOn}+nse=1.fig';
        figs{2} = '/Users/yulkang/Dropbox/CodeNData/ExtRepos/ShadlenLab/SDT/SDT_ANALYSIS/ANALYSIS/Data/figs/final/SFig3_WrongRT_RT_sbj={S1,S2,S3,S4,S5}+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=betamean+tnd=gamma+ntnd=2+bayes=none+lps0=1+igch=0+bch=0+plt={rt_mean_ac01,ch}+prd_rtf={RT_wSDT,RT}+nse=1.fig';
        
        nr = 4;
        nc = 5;
        
        clf;
        ax = subplotRCs(nr, nc);
        
        ax(1:2,:) = bml.plot.openfig_to_axes(figs{1}, ax(1:2,:));
        ax(3:4,:) = bml.plot.openfig_to_axes(figs{2}, ax(3:4,:));
        
        %%
        for col = 1:nc
            ax1 = ax(2,col);
            set(ax1, ...
                'XTickLabel', []);
            xlabel(ax1, '');
            
            ax1 = ax(3,col);
            title(ax1, '');
        end
        
        ylabel(ax(3,1), sprintf('Reaction time (s)'));
        
        %% Place axes
        ht1 = 7.5;
        btw_row = 0.05 * ht1;
        margin_bottom = 0.17 * ht1;
        margin_top = 0.07 * ht1;
        plot_row = (ht1 - btw_row - margin_bottom - margin_top) / 2;
        
        ht2 = plot_row * nr + btw_row + margin_bottom + margin_top;
        
        bml.plot.position_subplots(ax, ...
            'btw_row', btw_row / ht2, ...
            'btw_col', 0.05, ...
            'margin_left', 0.1, ...
            'margin_bottom', margin_bottom / ht2, ...
            'margin_right', 0.025, ...
            'margin_top', margin_top / ht2);
            
        %%
        file = W0.get_file({
            'sbj', Data.Consts.subjs
            'plt', 'rt_mean_ac01'
            'prd_rtf', {{'VD_wSDT', 'SDT_ClockOn'}, {'RT_wSDT', 'RT'}}
            'nse', 1
            });
        savefigs(file, ...
            'PaperPosition', ...
                [0, 0, ...
                Fit.Plot.Print.width_column2_cm, ...
                ht2], ...
            'ext', {'.fig', '.png', '.tif'}); % [600, n_subj * 400]);        
    end
    function imgather_RT_ac01_parads(W0, varargin)
        % alias
        W0.imgather_rt_parads(varargin{:});
    end
    function imgather_rt_parads(W0, varargin)
        opt = varargin2S(varargin, {
            'plt', 'rt_mean_ac01'
            'nse', 1
            });
        
        subjs = Data.Consts.subjs;
        n_subj = numel(subjs);
        
        S_batches = {
            bml.args.factorizeS(bml.struct.rmfield(W0.get_S_batch_VD, 'subj'))
            bml.args.factorizeS(bml.struct.rmfield(W0.get_S_batch_RT, 'subj'))
            };
        n_parad = numel(S_batches);
        
        clf;
        for i_parad = 1:n_parad
            for i_subj = 1:n_subj
                subj = subjs{i_subj};
                S_batch = varargin2S({'subj', subj}, S_batches{i_parad});
                C = S2C(S_batch);
                W = feval(class(W0), C{:});
                file = [W.get_file, ...
                    sprintf('+plt=%s+nse=%d', opt.plt, opt.nse), '.fig'];
                
                ax1 = subplotRC(n_parad, n_subj, i_parad, i_subj);
                ax(i_parad, i_subj) = bml.plot.openfig_to_axes(file, ax1);
            end
        end
        
        %%
        for i_parad = 1:n_parad
            for i_subj = 1:n_subj
                ax1 = ax(i_parad, i_subj);
                title(ax1, '');
                
                S_batch = S_batches{i_parad};
                if i_parad == 1
                    title(ax1, sprintf('S%d', i_subj));
                end
                if i_subj == 1
                    switch S_batch.parad
                        case 'VD_wSDT'
                            ylabel(ax1, ...
                                sprintf('Subjective\ndecision time (s)'));
                            
                        case 'RT_wSDT'
                            ylabel(ax1, ...
                                sprintf('Reaction time (s)'));
                    end
                else
                    ylabel(ax1, '');
                end
                if i_parad == n_parad ...
                        && i_subj == round(n_subj / 2)
                    xlabel(ax1, {'','Motion strength (%)'});
                else
                    xlabel(ax1, '');
                end
                if i_parad < n_parad
                    set(ax1, 'XTickLabel', []);
                end
                
                h = bml.plot.figure2struct(ax1);
                    
                set(h.marker, 'MarkerSize', 4, 'LineWidth', 0.25);
                set(h.segment_vert, 'LineWidth', 0.25);
                set(h.nonsegment, 'LineWidth', 1);                
                set(ax1, 'FontSize', 9);
                
                xy = bml.plot.get_all_xy(ax1);
                y1 = [min(xy(:,2)), max(xy(:,2))];
                yd = diff(y1);
                ylim(ax1, [y1(1) - yd / 10, y1(2) + yd / 10]);
            end
        end
        
        %%
        bml.plot.position_subplots(ax, ...
            'btw_row', 0.05, ...
            'btw_col', 0.05, ...
            'margin_left', 0.1, ...
            'margin_bottom', 0.17, ...
            'margin_right', 0.025, ...
            'margin_top', 0.07);
        
        %%
        Ss = [S_batches{:}];
        file = W.get_file_batch(Ss, {'sbj', subjs, 'plt', 'rt_mean_ac01'});
        savefigs(file, 'PaperPosition', [0, 0, 18.3, 3 * n_parad + 1.5], ...
            'ext', {'.fig', '.png', '.tif'}); % [600, n_subj * 400]);
    end
    function imgather_parads(W0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs % unique(Data.Consts.subjs_w_SDT_modul)
            'parad_rt_field', {
%                 {{'RT_wSDT', 'SDT_ClockOn', bml.plot.color_lines('b'), 'Fit to SDT_{RT} & choice', 'SDT_RT'}
%                  {'VD_wSDT', 'SDT_ClockOn', bml.plot.color_lines('r'), 'Fit to SDT_{VD} & choice', 'SDT_VD'}
%                  }
                {{'VD_wSDT', 'SDT_ClockOn', bml.plot.color_lines('r'), 'Fit to SDT_{VD} & choice', 'SDT_VD'}
                 {'VD_wSDT', 'RT',          bml.plot.color_lines('g'), 'Fit to RT_{VD} & choice',  'RT_VD'}
                 }
%                 {{'RT_wSDT', 'RT',          'k',                      'Fit to RT_{RT} & choice',  'RT_RT'}
%                  {'RT_wSDT', 'SDT_ClockOn', bml.plot.color_lines('b'), 'Fit to SDT_{RT} & choice', 'SDT_RT'}
%                  }
                }
            'plot', {'rt_mean_ac01'} % 'rt_mean', 'ch', 'rt_std', 'rt_skew'}
            });
        [Ss, n] = bml.args.factorizeS(rmfield(S_batch, {'subj'}));

        n_subj = numel(S_batch.subj);
            
        for ii = 1:n
            S = Ss(ii);

            clf;
            h_axes = ghandles(n_subj, 1);
            
            for i_subj = 1:n_subj
                S.subj = S_batch.subj{i_subj};
                dst = subplot(n_subj, 1, i_subj);
                
                n_pair = numel(S.parad_rt_field);
                legends = cell(n_pair, 1);
                label_short = cell(n_pair, 1);
                
                for i_pair = 1:n_pair % n_pair:-1:1
                    [S.parad, S.rt_field, color, legends{i_pair}, ...
                        label_short{i_pair}] = ...
                            deal(S.parad_rt_field{i_pair}{:});
                    
                    C = S2C(S);
                    W = feval(class(W0), C{:});
                    
                    if ismember(S.plot, {'rt_std', 'rt_skew'})
                        file = W.get_file({'sbj', S.subj, 'plt', S.plot});
                    else
                        file = W.get_file({'sbj', S.subj, 'plt', S.plot, 'nse', 1});
                    end

                    [dst, h] = bml.plot.openfig_to_axes(file, dst);
                    h_axes(i_subj, 1) = dst;

                    bml.plot.change_color_line(h.src.line, color);
                    
                    shift = (i_pair - (1 + n_pair) / 2) * 0.032 / 10;
                    line_data = [h.src.marker; h.src.segment_vert];
                    bml.plot.shift_line(line_data, shift, 0);
                end
                
                if i_subj == 1
                    line_pred = [h.dst.nonsegment(1), h.src.nonsegment(1)];
                    
                    if ismember(S.plot, {'rt_mean', 'rt_skew'})
                        loc_legends = 'West';
                    else
                        loc_legends = 'NorthWest';
                    end
                    legend(line_pred, legends, ...
                        'Location', loc_legends);
                end
                title('');
                
                if bml.str.strcmpStart('rt', S.plot)
                    if ismember(S.plot, {'rt_std'})
                        set(gca, 'YTick', 0:0.25:5);
                    else
                        set(gca, 'YTick', 0:0.5:5);
                    end
                end
            end
            
            joinaxes(h_axes, 'sameAxes', 'xy');
            
            file = W.get_file({'sbj', S_batch.subj, 'plt', S.plot, ...
                'prd_rtf', {S.parad_rt_field{1}(1:2), S.parad_rt_field{2}(1:2)}});
            savefigs(file, 'size', [600, n_subj * 400]);
        end
    end
    function imgather_k_fixed_vs_free(W0, varargin)
        % Multiple rows; One kind of plot (e.g., ch or RT) in each row.
        
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            'parad_rt_field', {
                {'RT_wSDT', 'RT',  'k', ...
                    '\kappa free',  false}
                {'RT_wSDT', 'RT',  'r', ...
                    '\kappa fixed', true}
                }
            'plot', {'rt_mean', 'ch'}
            'n_tnd', {2}
            'nse', {1}
            'ignore_choice', {false}
            'bias_cond_from_ch', {false}
            });
        [Ss, n_kind] = bml.args.factorizeS(rmfield(S_batch, {'subj', 'plot'}));

        n_subj = numel(S_batch.subj);
        n_plot = numel(S_batch.plot);

        legends = cell(1, n_kind);
        
        clf;
        ax = subplotRCs(n_plot, n_subj);
        for i_kind = 1:n_kind
            for i_plot = 1:n_plot
                for i_subj = 1:n_subj
                    S = Ss(i_kind);
                    S.subj = S_batch.subj{i_subj};
                    S.plot = S_batch.plot{i_plot};

                    ax1 = ax(i_plot, i_subj);

                    [S.parad, S.rt_field, color, label_long, to_import_k] = ...
                                deal(S.parad_rt_field{:});
                    S.to_import_k = to_import_k;
%                     if to_import_k
%                         S.to_import_k = varargin2C({
%                             'parad', 'VD_wSDT'
%                             'rt_field', 'SDT_ClockOn'
%                             'n_tnd', 1
%                             });
%                     else
%                         S.to_import_k = [];
%                     end
                    legends{i_kind} = label_long;
                            
                    C = S2C(S);
                    W = feval(class(W0), C{:});

                    if ismember(S.plot, {'rt_std', 'rt_skew'})
                        file = W.get_file({'sbj', S.subj, 'plt', S.plot});
                    else
                        file = W.get_file({'sbj', S.subj, 'plt', S.plot, ...
                            'nse', S.nse});
                    end

                    [ax1, h] = bml.plot.openfig_to_axes(file, ax1);
                    ax(i_plot, i_subj) = ax1;

                    if ~ismember(S.plot, {
                            'rt_mean_ac01', 'rt_std_ac01', 'rt_skew_ac01'})
                        bml.plot.change_color_line(h.src.nonsegment, color);
                    end
                    set(h.src.marker, 'MarkerSize', 4, 'LineWidth', 0.25);
                    set(h.src.segment_vert, 'LineWidth', 0.25);
                    set(h.src.nonsegment, 'LineWidth', 1);
                    set(ax1, 'FontSize', 9);

                    if i_plot == 1
                        title(ax1, sprintf('S%d', i_subj));
                    else
                        title(ax1, '');
                    end
                    
                    if strcmpStart('rt', S.plot)
                        switch S.rt_field
                            case 'SDT_ClockOn'
                                ylabel(ax1, sprintf( ...
                                    'Subjective\ndecision time (s)'));
                            case 'RT'
                                ylabel(ax1, sprintf( ...
                                    'Reaction time (s)'));
                        end
                    end
                    
                    if strcmpStart('ch', S_batch.plot{i_plot})
                        Fit.Plot.beautify_ch_axis(ax1);
%                         if i_subj > 1
%                             set(h_axes1, 'YTickLabel', []);
%                         end
                    elseif strcmpStart('rt', S_batch.plot{i_plot})
                        ax1 = ax(i_plot, i_subj);
                        Fit.Plot.beautify_rt_axis(ax1);
                    end
                    
                    Fit.Plot.beautify_coh_axis(ax1);
                    
                    if i_plot == n_plot ...
                            && i_subj == round((n_subj + 1) / 2)
                        xlabel(ax1, sprintf('\nMotion strength (%%)'));
                    else
                        xlabel(ax1, '');
                    end
                    
                    if i_subj > 1
                        ylabel(ax1, '');
                    end
                    if (i_plot < n_plot)
                        set(ax1, 'XTickLabel', []);
                    end
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
        hline1 = findobj(hs.nonsegment, 'Color', 'r');
        hline(1) = hline1(1);
        hline1 = findobj(hs.nonsegment, 'Color', 'k');
        hline(2) = hline1(1);
%         h_legend = legend(ax(1,1), hline, {'\kappa fixed', '\kappa free'}, ...
%             'Location', 'NorthEast');
%         pos_legend = get(h_legend, 'Position');
%         set(h_legend, 'Position', [0.22, pos_legend(2), 0.005, pos_legend(4)]);
        
        %%
        [legend_h, object_h] = legendflex(hline, {'\kappa fixed', '\kappa free'}, ...
            'xscale', 0.2, ...
            'buffer', [0.025, -0.073], ...
            'bufferunit', 'normalized', ...
            'anchor', {'ne', 'ne'});
            
        %%
        legend_h.Position(3) = legend_h.Position(3) + 1;
        
%         %%
%         shift_edge = 60;
%         legend_h.Position(1) = legend_h.Position(1) + shift_edge;
%         
%         shrink_width = shift_edge - 20;
%         legend_h.Position(3) = legend_h.Position(3) - shrink_width;
%         
%         %%
%         shift_text = -18;
%         for ii = [1 2]
%             object_h(ii).Position(1) = object_h(ii).Position(1) ...
%                 + shift_text;
%         end
%         
%         %%
%         shift_line = shift_text;
%         line_len = 15;
%         for ii = [3 5]
%             object_h(ii).XData(2) = object_h(ii).XData(2) + shift_line;
%             object_h(ii).XData(1) = object_h(ii).XData(2) - line_len;
%         end
        
        %%
        file = W.get_file({'sbj', S_batch.subj, 'plt', S_batch.plot, ...
            'prd_rtf', {S.parad, S.rt_field}, 'nse', S.nse});
        savefigs(file, 'PaperPosition', [0, 0, 18.3, 3 * n_plot + 1.5], ...
            'ext', {'.fig', '.png', '.tif'}); % [600, n_subj * 400]);
    end
    function imgather_collapsing_bound(W0, varargin)
        C = varargin2C({
            'parad_rt_field', {
                {'VD_wSDT', 'SDT_ClockOn', [0, 0, 0]}
                }
            'n_tnd', 1
            });
        clf;
        W0.imgather_collapsing_bound_unit(C{:});
        
        %%
%         C = varargin2C({
%             'parad_rt_field', {
%                 {'RT_wSDT', 'RT', [0, 0, 0]}
%                 }
%             'n_tnd', 2
%             });
%         clf;
%         W0.imgather_collapsing_bound_unit(C{:});        
    end
    function imgather_collapsing_bound_unit(W0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            ... 'subj', Data.Consts.subjs_w_SDT_modul
            'parad_rt_field', {
                {'VD_wSDT', 'SDT_ClockOn', [0 0 0]} % bml.plot.color_lines('b')}
                }
            'plot', {'rt_mean_ac01', 'ch'}
            'n_tnd', {1}
            'nse', {1}
            'ignore_choice', {false}
            'bias_cond_from_ch', {false}
            'bnd', {'betamean'}
            });
        n_row = numel(S_batch.plot);
        n_col = numel(S_batch.subj);
        ax = subplotRCs(n_row, n_col);
        
        [ax, W, S] = W0.imgather_single_parad_plots_in_rows(ax, S_batch);
        
        %% Remove x/y labels
        for ii = 1:size(ax,1)
            ax1 = ax(ii, end);
            ylabel(ax1, '');
            xlabel(ax1, '');
        end
        
        %% Subject number
        for ii = 1:size(ax, 2)
            ax1 = ax(1,ii);
            title(ax1, sprintf('S%d', ii));
        end
        
        %% Place axes
        bml.plot.position_subplots(ax, ...
            'btw_row', 0.05, ...
            'btw_col', 0.05, ...
            'margin_left', 0.1, ...
            'margin_bottom', 0.17, ...
            'margin_right', 0.025, ...
            'margin_top', 0.07);
            
        %%
        file = W.get_file({
            'sbj', Data.Consts.subjs
            'plt', S_batch.plot
            'prd_rtf', {S.parad, S.rt_field}
            'nse', S.nse
            });
        n_plot = numel(S_batch.plot);
        savefigs(file, 'PaperPosition', [0, 0, 18.3, 3 * n_plot + 1.5], ...
            'ext', {'.fig', '.png', '.tif'}); % [600, n_subj * 400]);        
    end
    function imgather_VD(W0, varargin)
        % Multiple rows; One kind of plot (e.g., ch or RT) in each row.

        S0 = varargin2S(varargin, {
            'to_determine_accu_from_bias_ch', true
            'incl_S5_SDT_fit', true
            });
        
        %%
        n_col = numel(Data.Consts.subjs);
        
        clf;
        n_plot = 2;
        ax = subplotRCs(n_plot, n_col);
        
        %% SDT only
        S_batch = varargin2S(S0, {
            'subj', Data.Consts.subjs
            ... 'subj', Data.Consts.subjs_w_SDT_modul
            'parad_rt_field', {
                {'VD_wSDT', 'SDT_ClockOn', [0.1 0.2 1]} % bml.plot.color_lines('b')}
                }
            'plot', {'rt_mean', 'ch'}
            'n_tnd', {1}
            'nse', {1}
            'ignore_choice', {true}
            'bias_cond_from_ch', {false}
            });

        if S0.incl_S5_SDT_fit
            S_batch.subj = Data.Consts.subjs;
            ix_col = 1:size(ax, 2);
        else
            S_batch.subj = Data.Consts.subjs_w_SDT_modul;
            ix_col = 1:(size(ax, 2) - 1);
        end
        [ax(:,ix_col), W, S] = ...
            W0.imgather_single_parad_plots_in_rows(ax(:,ix_col), S_batch);
        
        %% SDT & choice
        S_batch = varargin2S(S0, {
            'subj', Data.Consts.subjs_wo_SDT_modul
            'parad_rt_field', {
                {'VD_wSDT', 'SDT_ClockOn', 0.7 + zeros(1,3)}
                }
            'plot', {'rt_mean', 'ch'}
            'n_tnd', {1}
            'nse', {1}
            'ignore_choice', {false}
            'bias_cond_from_ch', {false}
            });

        [ax(:,end), W] = W0.imgather_single_parad_plots_in_rows(ax(:,end), S_batch);
        
        for ii = 1:size(ax,1)
            ax1 = ax(ii, end);
            ylabel(ax1, '');
            xlabel(ax1, '');
        end
        
        %% Subject number
        for ii = 1:size(ax, 2)
            ax1 = ax(1,ii);
            title(ax1, sprintf('S%d', ii));
        end
        
        %% Place axes
        bml.plot.position_subplots(ax, ...
            'btw_row', 0.05, ...
            'btw_col', 0.05, ...
            'margin_left', 0.1, ...
            'margin_bottom', 0.17, ...
            'margin_right', 0.025, ...
            'margin_top', 0.07);
            
        %%
        file = W.get_file({'sbj', Data.Consts.subjs, 'plt', S_batch.plot, ...
            'prd_rtf', {S.parad, S.rt_field}, 'nse', S.nse, 'S5sdt', S0.incl_S5_SDT_fit});
        savefigs(file, 'PaperPosition', [0, 0, 18.3, 3 * n_plot + 1.5], ...
            'ext', {'.fig', '.png', '.tif'}); % [600, n_subj * 400]);
    end   
    function [ax, W, S] = imgather_single_parad_plots_in_rows(W0, ax, S_batch)
        [Ss, n_kind] = bml.args.factorizeS(rmfield(S_batch, {'subj', 'plot'}));

        n_subj = numel(S_batch.subj);
        n_plot = numel(S_batch.plot);

        legends = cell(1, n_kind);
        
        for i_kind = 1:n_kind
            for i_plot = 1:n_plot
                for i_subj = 1:n_subj
                    S = Ss(i_kind);
                    S.subj = S_batch.subj{i_subj};
                    S.plot = S_batch.plot{i_plot};

                    ax1 = ax(i_plot, i_subj);

                    [S.parad, S.rt_field, color] = ...
                                deal(S.parad_rt_field{:});
                    S.to_import_k = false; % [];
%                     if to_import_k
%                         S.to_import_k = varargin2C({
%                             'parad', 'VD_wSDT'
%                             'rt_field', 'SDT_ClockOn'
%                             'n_tnd', 1
%                             });
%                     else
%                         S.to_import_k = [];
%                     end
                            
                    C = S2C(S);
                    W = feval(class(W0), C{:});

                    if ismember(S.plot, {'rt_std', 'rt_skew'})
                        file = W.get_file({'sbj', S.subj, 'plt', S.plot});
                    else
                        file = W.get_file({'sbj', S.subj, 'plt', S.plot, ...
                            'nse', S.nse});
                    end

                    [ax1, h] = bml.plot.openfig_to_axes(file, ax1);
                    ax(i_plot, i_subj) = ax1;

                    if ismember(S.plot, {
                            'rt_mean_ac01', 'rt_std_ac01', 'rt_skew_ac01'})
                        for color1 = {[0 0 0], [1 0 0]}
                            for src_kind = {'marker', 'segment_vert'}
                                obj1 = findobj(h.src.(src_kind{1}), ...
                                    'Color', color1{1});
                                uistack(obj1, 'top');
                            end
                            pause(0.2);
                        end
                    else
                        bml.plot.change_color_line(h.src.nonsegment, color);
                    end
                    set(h.src.marker, 'MarkerSize', 4, 'LineWidth', 0.25);
                    set(h.src.segment_vert, 'LineWidth', 0.25);
                    set(h.src.nonsegment, 'LineWidth', 1);
                    set(ax1, 'FontSize', 9);

                    if i_plot == 1
                        title(ax1, sprintf('S%d', i_subj));
                    else
                        title(ax1, '');
                    end
                    
                    if strcmpStart('rt', S.plot)
                        switch S.rt_field
                            case 'SDT_ClockOn'
                                ylabel(ax1, sprintf( ...
                                    'Subjective\ndecision time (s)'));
                            case 'RT'
                                ylabel(ax1, sprintf( ...
                                    'Reaction time (s)'));
                        end
                    end
                    
                    if strcmpStart('ch', S_batch.plot{i_plot})
                        Fit.Plot.beautify_ch_axis(ax1);
%                         if i_subj > 1
%                             set(h_axes1, 'YTickLabel', []);
%                         end
                    elseif strcmpStart('rt', S_batch.plot{i_plot})
                        ax1 = ax(i_plot, i_subj);
                        Fit.Plot.beautify_rt_axis(ax1);
                    end
                    
                    Fit.Plot.beautify_coh_axis(ax1);
                    
                    if i_plot == n_plot ...
                            && i_subj == round((n_subj + 1) / 2)
                        xlabel(ax1, sprintf('\nMotion strength (%%)'));
                    else
                        xlabel(ax1, '');
                    end
                    
                    if i_subj > 1
                        ylabel(ax1, '');
                    end
                    if (i_plot < n_plot)
                        set(ax1, 'XTickLabel', []);
                    end
                end
            end
        end
    end
end
%% Imgather - unused
methods
    function imgather_single_parad_single_row(W0, varargin)
        % Only gathers one row of one kind of plot (e.g., choice).
        % For multiple rows, use imgather_single_parad_plot_in_row.
        
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs % unique(Data.Consts.subjs_w_SDT_modul)
            'parad_rt_field', {
%                 {'RT_wSDT', 'SDT_ClockOn', 'k', 'Fit to SDT_{RT} & choice', 'SDT_RT'}
%                 {'VD_wSDT', 'SDT_ClockOn', 'k', 'Fit to SDT_{VD} & choice', 'SDT_VD'}
                {'RT_wSDT', 'RT',          'k', 'Fit to RT_{RT} & choice',  'RT_RT'}
                }
            'plot', {'ch', 'rt_mean'} % {'rt_mean_ac01'} % {'ch', 'rt_mean', 'rt_std', 'rt_skew'}
            'bias_cond_from_ch', {false}
            'nse', {1}
            });
        [Ss, n] = bml.args.factorizeS(rmfield(S_batch, {'subj'}));

        n_subj = numel(S_batch.subj);
            
        for ii = 1:n
            S = Ss(ii);

            clf;
            h_axes = ghandles(1, n_subj);
            
            for i_subj = 1:n_subj
                S.subj = S_batch.subj{i_subj};
                dst = subplot(1, n_subj, i_subj);
                
                [S.parad, S.rt_field, color, label_long, label_short] = ...
                            deal(S.parad_rt_field{:});
                    
                C = S2C(S);
                W = feval(class(W0), C{:});
                
                if ismember(S.plot, {'rt_std', 'rt_skew'})
                    file = W.get_file({'sbj', S.subj, 'plt', S.plot});
                else
                    file = W.get_file({'sbj', S.subj, 'plt', S.plot, 'nse', S.nse});
                end

                [dst, h] = bml.plot.openfig_to_axes(file, dst);
                h_axes(i_subj) = dst;

                if ~ismember(S.plot, {
                        'rt_mean_ac01', 'rt_std_ac01', 'rt_skew_ac01'})
                    bml.plot.change_color_line(h.src.line, color);
                end
                set(h.src.marker, 'MarkerSize', 8, 'LineWidth', 1.5);
                set(h.src.segment_vert, 'LineWidth', 1.5);
                set(h.src.nonsegment, 'LineWidth', 1.5);

%                 shift = (i_set - (1 + n_set) / 2) * 0.032 / 10;
%                 line_data = [h.src.marker; h.src.segment_vert];
%                 bml.plot.shift_line(line_data, shift, 0);
                
%                 if i_subj == 1
%                     line_pred = [h.dst.nonsegment(1), h.src.nonsegment(1)];
%                     legend(line_pred, legends, ...
%                         'Location', 'NorthWest');
%                 end
                if i_subj == 1
                    title(label_long);
                else
                    title('');
                end
                
                if bml.str.strcmpStart('rt', S.plot)
                    if ismember(S.plot, {'rt_std'})
                        set(gca, 'YTick', 0:0.25:5);
                    else
                        set(gca, 'YTick', 0:0.5:5);
                    end
                end
            end

            if strcmpStart('ch', S.plot)
                joinaxes(h_axes, 'sameAxes', 'xy');
            else
                joinaxes(h_axes, 'sameAxes', 'x');
            end
            
            file = W.get_file({'sbj', S_batch.subj, 'plt', S.plot, ...
                'prd_rtf', {S.parad, S.rt_field}, 'nse', S.nse});
            savefigs(file, 'size', [n_subj * 250, 200]); % [600, n_subj * 400]);
        end
    end
    function imgather_ch(W0, varargin)
        %%
        C_batch = varargin2C(varargin, varargin2S({
            'subj', Data.Consts.subjs_w_SDT_modul
            'parad', {'VD_wSDT'}
            'rt_field', {'SDT_ClockOn'}
            'n_tnd', {1, 2}
            }, W0.get_S0_file));
        S_batch = W0.get_S_batch(C_batch{:});
        [Ss, n] = bml.args.factorizeS(S_batch);
        
        files = cell(n, 1);
        for ii = n:-1:1
            S = Ss(ii);
            C = S2C(S);
            W = feval(class(W0), C{:});
            files{ii} = [W.get_file({'plt', 'ch'}) '.fig'];
            
            S0s(ii) = W.get_S0_file;
        end
        
        %%
        h = imgather(files, {}, 'opt_joinaxes', {'xpos', 0.2});
        
        xlabel(h(end), 'Coherence (%)');
        ylabel(h(end), 'P_{right}');
        
        file = W0.get_file_compare_S0s(S0s);
        savefigs(file, 'size', [300, n * 200]);
    end
end
%% Imgather - RT Distrib
methods
    function h_ax = imgather_rt_distrib_all_RT(W0, varargin)
        C = varargin2C(varargin, W0.get_S_batch_RT);
        h_ax = W0.imgather_rt_distrib_all(C{:});
    end
    function h_ax = imgather_rt_distrib_all_VD(W0, varargin)
        C = varargin2C(varargin, W0.get_S_batch_VD);
        h_ax = W0.imgather_rt_distrib_all(C{:});
    end
    function h_ax = imgather_rt_distrib_all(W0, varargin)
        S_batch = varargin2S(varargin, {
            'plt', 'rt_pdf_all' % 'rt_distr_all'|'rt_pdf_all'
            });
        S = bml.args.factorizeS(varargin2S(S_batch));
        assert(isscalar(S));
        subjs = Data.Consts.subjs;
        n_subj = numel(subjs);
        
        clf;
        for i_subj = n_subj:-1:1
            subj = subjs{i_subj};
            C = varargin2C({
                'subj', subj
                }, S);
            W = feval(class(W0), C{:});
            file_fig = [W.get_file({'plt', S.plt}), '.fig'];
            
            n_conds = W.Data.n_cond;
            
            if i_subj == n_subj
                h_ax = subplotRCs(n_conds, n_subj);
            end
            
            try
                h_ax(:,i_subj) = openfig_to_axes(file_fig, ...
                    h_ax(:,i_subj));
            catch err
                warning('Error loading subj %d (%s):\n', i_subj, subj);
                warning(err_msg(err));
            end
        end
        
        %%
        conds = W.Data.conds;
        n_cond = length(conds);
        for i_subj = 1:n_subj
            title(h_ax(1, i_subj), sprintf('S%d', i_subj));
            
            for i_cond = 1:n_conds
                h_ax1 = h_ax(i_cond, i_subj);
                if i_subj > 1
                    set(h_ax1, 'YTickLabel', []);
                    ylabel(h_ax1, '');
                else
                    cond = conds(n_cond + 1 - i_cond);
                    ylabel(h_ax1, {sprintf('%1.1f', cond*100), ' '});
                end
                if i_cond < n_conds
                    set(h_ax1, 'XTickLabel', []);
                end
                if i_cond < n_conds || i_subj > 1
                    set(h_ax1, 'XTickLabel', {' ', ' ', ' '});
                    set(h_ax1, 'YTickLabel', {' ', ' ', ' '});
                    
%                     h_ax1.YRuler.TickLabels.ColorData = ...
%                         uint8([255 255 255 0]');
%                     h_ax1.XRuler.TickLabels.ColorData = ...
%                         uint8([255 255 255 0]');
                end
                set(h_ax1, 'XGrid', 'off', 'YGrid', 'off');
                
                switch S.plt
                    case 'rt_pdf_all'
                        xy = bml.plot.get_all_xy(h_ax1);
                        y_max = max(abs(xy(:,2)));
                        ylim(h_ax1, [-1.1, 1.1] * y_max);
                        set(h_ax1, 'YTick', []);
                end
                
                hs = bml.plot.figure2struct(h_ax1);
                
                set(hs.nonsegment, 'LineWidth', 1);
                
                h_dat = findobj(hs.line, 'Color', bml.plot.color_lines('r'));
                set(h_dat, 'Color', bml.plot.color_lines('k'));
                
                h_pred = findobj(hs.line, 'LineStyle', '--');
                set(h_pred, 'LineStyle', '-', ...
                    'Color', 'r'); % bml.plot.color_lines('r'));
                
                bml.plot.crossLine(h_ax1, 'h', 0, {'-', 0.7 + [0 0 0]});
                uistack(h_dat, 'top');
            end
        end
        
        %%
        switch S.rt_field
            case 'RT'
                t_label = 'RT';
            case 'SDT_ClockOn'
                t_label = 'SDT';
        end
        xlabel(h_ax(end, round(end/2)), [t_label, ' (s)']);
        ylabel(h_ax(round(end/2), 1), {'Coherence (%)', ' ', '0.0', ' '});
        
        switch S.plt
            case 'rt_dstr_all'
                for i_subj = 1:n_subj
                    h_ax(1,i_subj).Title.Position(2) = 1.5;

        %             h_title = get(h_ax(1,i_subj), 'Title');
        %             pos = get(h_title, 'Position');
        %             pos(2) = 1.5;
        %             set(h_title, pos);
                end

            case 'rt_pdf_all'
        end
        
%         title(h_ax(1, round(end/2)), 'S3'); % {'Subject', ' ', 'S3'});
        
        %%
        bml.plot.position_subplots(h_ax, ...
            'btw_row', 0.02, ...
            'btw_col', 0.03, ...
            'margin', [0.14, 0.06, 0.025, 0.05])
        
        %%
        file = W.get_file({'sbj', subjs, 'plt', S.plt});
        savefigs(file, 'PaperPosition', [0, 0, 18.3, 1.8 * n_conds + 1], ...
            'ext', {'.fig', '.png', '.tif'}); % [600, n_subj * 400]);
    end
end
end