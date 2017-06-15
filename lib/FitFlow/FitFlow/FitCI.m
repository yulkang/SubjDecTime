classdef FitCI ...
        < DeepCopyable ...
        & bml.oop.PropFileName
%% Settings
properties
    summary_to_use = 'mean';
end
%% Intermediate variables
properties (Dependent)
    Fl
end
properties
    Fl_ = [];
    MCMC = []; 
end
%% Main
methods
    function CI = FitCI(Fl, varargin)
        CI.MCMC = bml.mcmc.MetroMvnMultiChain;
        CI.add_deep_copy({'Fl_', 'MCMC'});
        if nargin > 0
            CI.init(Fl, varargin{:});
        end
    end
    function init(CI, Fl, varargin)
        bml.oop.varargin2props(CI, varargin, true);
        if ~isempty(Fl)
            CI.set_Fl(Fl);
            
            % Using sigma_hessian: doesn't work well. Don't use.
%             th_free = ~Fl.W.th_fix_vec;
%             sigma_hessian = inv(Fl.res.out.hessian(th_free, th_free));
%             if any(~isfinite(sigma_hessian(:)))
                sigma_hessian = []; 
%             end
        
            constr = Fl.W.get_fmincon_cond;
            Constr = fitflow.VectorConstraints([
                {Fl.W.th_lb_vec, Fl.W.th_ub_vec}, ...
                constr(:)']);
            Constr.reduce;
%             if ~isempty(constr) && ~all(cellfun(@isempty, constr))
%                 warning('Constraints exist other than lb and ub but not imported!');
%             end

            C = varargin2C(varargin, {
                'fun_nll_targ', @Fl.get_cost_from_th_free_vec
                'th0', Fl.W.th_vec_free
                'sigma_hessian', sigma_hessian
                'Constr', Constr
%                 'MC_props', {
%                     'fun_nll_targ', @Fl.get_cost_from_th_free_vec
%                     }
                });
            CI.MCMC.init(C{:});
        end
    end
end
%% Replace existing results
methods
    function replace_file_Fl(CI, file_Fl, varargin)
        warning(['Deprecated: using main_w_file_Fl, ' ...
            'which does not remove the original file.']);
        CI.main_w_file_Fl(file_Fl, varargin{:});
    end
    function main_w_file_Fl(CI, file_Fl, varargin)
        fprintf('Loading Fl from %s\n', file_Fl);
        L = load(file_Fl);
        L.Fl.res2W;
        
        CI.main_w_Fl(L.Fl, varargin{:});
        
        [pth, name_Fl, ext] = fileparts(file_Fl);
        if isempty(ext)
            ext = '.mat';
            file_Fl = [file_Fl, ext];
        end

        mkdir2(pth);
        
        file_MC0 = fullfile(pth, [name_Fl, '+MC=0', ext]);
        fprintf('Copying the original file to %s\n', file_MC0);
        copyfile(file_Fl, file_MC0);
        
        file_MC1 = fullfile(pth, ...
            [name_Fl, '+MC=1', ext]);
        file_MC1_nmc = fullfile(pth, ...
            [name_Fl, sprintf('+MC=1+nmc=%d', CI.MCMC.n_samp), ext]);
        fprintf('Saving CI from MCMC to %s\n', file_MC1);
        fprintf('Copying CI from MCMC to %s\n', file_MC1_nmc);
        
        L.Fl = CI.Fl;
        L.res = CI.Fl.res;
        save(file_MC1, '-struct', 'L');
        copyfile(file_MC1, file_MC1_nmc);
        
        % Replace original file with MC1.
        delete(file_Fl);
        copyfile(file_MC1, file_Fl);
        
        CI.MCMC.plot_all_and_save(fullfile(pth, [name_Fl, '+MC=1']));
    end
    function main_w_Fl(CI, Fl, varargin)
        CI.init(Fl, varargin{:});
        CI.MCMC.main;
        
        CI.MCMC.plot_all;
        
        CI.postprocess_Fl_res;
    end
    function postprocess_Fl_res(CI)
        samp = CI.MCMC.th_samp_aft_burnin;
        nll = CI.MCMC.nll_samp_aft_burnin;

        % Copy from Fl
        Fl = CI.Fl;
        res = Fl.res;

        th_free = find(~Fl.W.th_fix_vec);
        n_th_free = length(th_free);
        n_th_all = res.k + res.n_fixed;

        if ~isfield(res, 'res_grad_desc')
            cov_mat = inv(res.out.hessian(th_free, th_free));
            res.res_grad_desc = res;
            res.res_grad_desc.out.cov_th_free = cov_mat;
            res.res_grad_desc.out.cov = zeros(n_th_all, n_th_all);
            res.res_grad_desc.out.cov(th_free, th_free) = cov_mat;
        end
        res_grad = res.res_grad_desc;
        
        % Results from mode
        [min_nll, ix_nll] = min(nll);
        if ~isempty(ix_nll) && min_nll < res_grad.fval
            th_min = samp(ix_nll, :);
        else
            th_min = hVec(res_grad.out.x(~Fl.W.th_fix_vec));
            min_nll = res_grad.fval;
        end
        res.th_vec_free_mode = th_min;
        res.fval_mode = min_nll;            
        
        % Mean-related stats
        mu = mean(samp);
        se = std(samp);
        cov_mat = cov(samp);
        
        % Results from th_mean
        Fl.W.th_vec_free = mu;
        res.th_vec_free_mean = Fl.W.th_vec_free;
        try
            res.fval_mean = Fl.get_cost;
        catch err
            warning(err_msg(err));
            warning('cost(th_mean) = NaN!');
            res.fval_mean = nan;
        end
        
        % Permil of th samples
        pmil_incl = [0, 2.5, 5, 25, 50, 75, 95, 97.5, 100] * 10;
        
        for pmil = pmil_incl
            field = sprintf('pmil%04d', pmil);
            
            for i_free = 1:n_th_free
                i_th = th_free(i_free);
                name = Fl.W.th_names{i_th};
                
                res.(field).(name) = ...
                    vVec(prctile(samp(:,i_free), pmil / 10));
            end
            for i_th = setdiff(1:n_th_all, th_free)
                name = Fl.W.th_names{i_th};
                res.(field).(name) = res.th0.(name);
            end
        end
        
        % Results from th_median
        Fl.W.th_vec_free = median(samp);
        res.th_vec_free_median = Fl.W.th_vec_free;
        try
            res.fval_median = Fl.get_cost;
        catch err
            warning(err_msg(err));
            warning('cost(th_median) = NaN!');
            res.fval_mean = nan;
        end

        % Take results from summary_to_use.
        res.th_vec_free = res.(['th_vec_free_', CI.summary_to_use]);
        res.fval = res.(['fval_', CI.summary_to_use]);
        
        % Store struct
        Fl.W.th_vec_free = res.th_vec_free;
        res.th = Fl.W.th;
        
        % Copy to res.out
        % NOTE: th_mean and median are very similar but not the same.
        % Here, res.out.x is from th_median,
        % but se and cov makes more sense with th_mean.
        res.out.fval = res.fval;
        res.out.x = CI.Fl.W.th_vec;
        res.out.se(th_free) = se;
        res.out.cov_th_free = cov_mat;
        res.out.cov = zeros(n_th_all, n_th_all);
        res.out.cov(th_free, th_free) = cov_mat;
        res.out.hessian = zeros(n_th_all, n_th_all);
        res.out.hessian(th_free, th_free) = inv(cov_mat);
        
        for i_th = 1:n_th_free
            th_name = Fl.W.th_names_free{i_th};
            res.se.(th_name) = res.out.se(i_th);
        end
        
        % Assign back into CI.Fl.res after filling in ICs.
        res = CI.Fl.calc_ic(res);
        res.CI = CI;
        CI.Fl.res = res;
    end
end
%% Utilities
methods
    function set.Fl(CI, Fl)
        CI.set_Fl(Fl);
    end
    function set_Fl(CI, Fl)
        if isempty(Fl)
            CI.Fl_ = Fl;
            return;
        end
        
        assert(isa(Fl, 'FitFlow'));
        
%         if ~Fl.W.Data.is_loaded || Fl.cost ~= Fl.res.fval ...
%                 || ~isequal(Fl.res.th, Fl.W.th)
            Fl.res2W; % Should run once.
%         end
        CI.Fl_ = Fl;
    end
    function Fl = get.Fl(CI)
        Fl = CI.Fl_;
    end
end
%% Demo
methods
    function demo(CI)
        file = 'Data/Fit.D2.Inh.MainBatch/sbj=DX+prd=RT+dtb=DnIvJt+dft=Const+bnd=Const+ssq=Const+tnd=gamma+kb=0+p1=50+d1=0+d2=0+s1=16+s2=16+fn1=50+fn2=50+ntnd=4+pf=0+d1f=0+d2f=0+db1f=0+db2f=0+s1f=0+s2f=0+bif1=0+baif1=0+bif2=0+baif2=0+fn1f=1+fn2f=1+msf=0+cv=1+ncv=2+ist=0.mat';
        L = load(file);
        Fl = L.Fl;
        Fl.W.Dtb.DEBUG_THRES = 1e-4;

        %%
        CI.Fl = Fl;
        CI.MCMC.n_samp_burnin = 5e3;
        CI.MCMC.n_samp_max = 1e4;
        CI.MCMC.n_samp_bef_cov_update = 200;
        CI.MCMC.n_samp_btw_cov_update = 40;
        CI.MCMC.verbose = false;
        CI.MCMC.th_scale_factor = 1e-4;
        
        %%
        tic;
        CI.MCMC.main;
        toc;
        
        %%
        CI.MCMC.plot_all;
    end
    function demo2(CI0)
        %%
%         file = 'Data/Fit.Dtb.MeanRt.Main/sbj=MA+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0.mat';
        file = 'Data/Fit.Dtb.Main/sbj=MA+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=betacdf+tnd=gamma+ntnd=1+bayes=none+lps0=1+igch=0+bch=0.mat';
        L = load(file);
        
        %%
        CI = FitCI;
        C = varargin2C({
            ... 'parallel_mode', 'none'
            'n_samp_burnin', 5e3
            'n_samp_btw_check_convergence', 5e3
            'factor_bound_to_cov_initial', 1e-4
            'n_MCs', 10
            });
        
        Fl = L.Fl;
        Fl.res2W;
        disp(Fl.W.th_vec_free);
        
%         aa = cell(1,2);
%         parfor ii = 1:2, aa{ii} = Fl.W.get_cost; end
%         disp(aa);
        
        %%
        CI.main_w_Fl(Fl, C{:});
        
    end
end
end