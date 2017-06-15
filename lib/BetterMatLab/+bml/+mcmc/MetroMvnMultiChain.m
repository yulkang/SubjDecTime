classdef MetroMvnMultiChain < bml.mcmc.MetroMvn
    % Multiple chains with multivariate normal proposal distribution.
    % Supports Gelman-Rubin convergence test.
    
    % Yul Kang (c) 2016. hk2699 at columbia dot edu.
    
%% Props - Settings - Optional
properties
    n_MCs = 12;
    MC_props = {}; % Properties
    MCs = {}; % MCMCs
    
    % 'order'|'shuffle'|vector
    % seeds - if 'order', use 1:n_MCs.
    seeds = 'shuffle'; 
    
    th0s % th0s(c,k): initial value of k-th estimand of c-th subchain.
    sigma_th0s % sigma to sample th0s with.
    
    % typical_scale_to_sigma_initial_point_factor
    % : Scale of sigma to sample th0 for subchains with.
    %   Used when sigma_hessian is not given.
    typical_scale_to_sigma_initial_point_factor = 1e-2;

    % typical_scale_to_sigma_initial_point_max_factor
    % : Smaller of the variance from sigma_hessian
    %   or diag(Constr.typical_scale 
    %         * typical_scale_to_sigma_initial_point_max_factor)
    %   is used for sigma_initial_point.
    typical_scale_to_sigma_initial_point_max_factor = 0.05;
    
    % sigma_hessian_to_sigma_initial_point_factor
    % : Used if sigma_hessian is given.
    sigma_hessian_to_sigma_initial_point_factor = 10;
    
    % thres_convergence
    % : Potential reduction in variance when the chain is run more.
    %   Should be >= 1. 
    %   Smaller value is more stringent.
    %   Defaults to 1.1 as in Gelman et al., 2004.
    thres_convergence = 1.1; 

    n_samp_btw_check_convergence = 1e3; % after n_samp_burnin.
    
    % Use cov from samples pooled across subchains if 
    % convergence test fails on the first round.
    to_use_global_cov_for_subchains_aft_1st_round = false; % true;
    
    % Initial value of n_samp_burnin is overwritten to the value 
    % of the maximum n_samp before convergence, 
    % and the initial value is stored in n_samp_burnin0.
    n_samp_burnin0 = [];

    parallel_mode = 'chain'; % 'none'; % 
end
%% Props - Results
properties
    rhat % potential reduction in variance
end

%% Init
methods
    function MC = MetroMvnMultiChain(varargin)
        if nargin > 0
            MC.init(varargin{:});
        end
    end
    function init(MC, varargin)
        MC.init@bml.mcmc.MetroMvn(varargin{:});

        MC.n_samp_burnin0 = MC.n_samp_burnin;
        
        % Initialize subchains
        
        % Initial point - purposedly overdispersed.
        if isempty(MC.th0s)
            if isempty(MC.sigma_th0s)
                MC.sigma_th0s = MC.get_sigma_th0s_auto;
            end
            
            MC.th0s = bml.mcmc.importance_resampling_mvn( ...
                MC.th0, MC.sigma_th0s, ... 
                @(th) -MC.fun_nll_proposal(MC.th0, th, ...
                    MC.mu_proposal, MC.sigma_th0s), ...
                'constr', MC.Constr, ...
                'n_initial_sample', MC.n_MCs, ...
                'n_final_sample', MC.n_MCs);        
        end
        
        MC.MC_props = varargin2C(MC.MC_props, {
            'to_plot_online', false
            });
        
        for ii = 1:MC.n_MCs
            switch MC.seeds
                case 'order'
                    seed = ii;
                case 'shuffle'
                    seed = 'shuffle';
                otherwise
                    seed = MC.seeds(ii);
            end
            
            % Priority: MC_props > varargin > defaults
            C = varargin2C(varargin2C(MC.MC_props, varargin), {
                'th0', MC.th0s(ii, :)
                'mu_proposal', MC.mu_proposal
                'sigma_proposal', MC.sigma_proposal
                'fun_nll_targ', MC.fun_nll_targ
                'Constr', MC.Constr
                'n_samp_max', MC.n_samp_max
                'n_samp_burnin', MC.n_samp_burnin
                'parallal_mode', MC.parallel_mode
                'seed', seed
                });
            MC.MCs{ii} = bml.mcmc.MetroMvnAdaCov(C{:});
        end
    end
    function sigma = get_sigma_th0s_auto(MC)
        if isempty(MC.sigma_hessian)
            sigma = diag(abs(MC.Constr.typical_scale)) ...
                .* MC.typical_scale_to_sigma_initial_point_factor;
        else
            sigma = MC.sigma_hessian * ...
                MC.sigma_hessian_to_sigma_initial_point_factor;
            
            var_th0s_max = ...
                abs(MC.Constr.typical_scale) ...
                    .* MC.typical_scale_to_sigma_initial_point_max_factor;
            
            [v, d] = eig(sigma);
            d = min(d, diag(var_th0s_max));
            sigma = v * d / v;
                
%             v_diag = min(diag(v), var_th0s_max(:));
%             v = v / diag(diag(v)) * diag(v_diag);
        end
    end
    function v = get_sigma_proposal_from_typical_scale(MC, factor)
        if ~exist('factor', 'var')
            factor = MC.typical_scale_to_sigma_proposal_factor;
        end
        if length(MC.Constr.lb) == MC.n_th ...
                && length(MC.Constr.ub) == MC.n_th
            
            v = diag(abs(MC.Constr.typical_scale)) .* factor;
        else
            warning(['lb and ub are not set for all estimands! ' ...
                'sigma_proposal_from_typical_scale will default to eye(n_th)']);
            v = eye(MC.n_th);
        end
    end
    function preallocate(MC)
        MC.rhat = sparse(MC.n_samp_max, MC.n_th);
        % Do not preallocate other properties. Use subchains'.
    end
    function add_initial_point(~)
        % Do not add. Subchains will do it.
    end
end
%% Main
methods
    function main(MC)
        t_st = tic;
        n_samp_bef = MC.n_samp;
        fprintf('=== Sampling began at %s\n', datestr(now, 30));
        
        tf_converged = false;
        while ~tf_converged && (MC.n_samp < MC.n_samp_max)
            if MC.n_samp >= ...
                    (MC.n_samp_burnin0 + MC.n_samp_btw_check_convergence)
                
                % Consider previous samples burnin.
                MC.n_samp_burnin = MC.n_samp;
                for i_chain = 1:MC.n_MCs
                    MC.MCs{i_chain}.n_samp_burnin = MC.n_samp;
                end
                
                %%
                % If doesn't converge on the first round,
                % use cov from samples pooled across subchains
                % to update sigma_proposal.
                if MC.to_use_global_cov_for_subchains_aft_1st_round ...
                        && (MC.n_samp >= MC.n_samp_burnin0 ...
                              + MC.n_samp_btw_check_convergence)
                          
                    %%
                    ix_samp = MC.n_samp ...
                            - (0:(MC.n_samp_btw_check_convergence - 1));
                    sigma_proposal = ...
                        MC.MCs{1}.get_sigma_proposal_from_cov_samp( ...
                            cov(MC.get_th_samp(ix_samp)));
                          
                    for i_chain = 1:MC.n_MCs
                        MC.MCs{i_chain}.to_adapt_cov = false;
                        MC.MCs{i_chain}.update_sigma_proposal( ...
                            sigma_proposal);
                    end
                    
                    fprintf('sigma_proposal updated with cov(samp_pooled) at n_samp=%d\n', ...
                        MC.n_samp);
                end
            end
            
            tf_converged = MC.append;
        end
        
        if ~tf_converged
            warning('Chain did not converge up to n_samp = n_samp_max = %d', ...
                MC.n_samp);
        end
        
        t_el = toc(t_st);
        n_samp_aft = MC.n_samp;
        fprintf('=== Took %d samples in %1.1fs', n_samp_aft - n_samp_bef, t_el);
    end
    function tf_converged = append(MC, n_samp_to_append)
        n_samp_bef_append = MC.n_samp;
        if ~exist('n_samp_to_append', 'var')
            n_samp_min_bef_conv_check = ...
                  MC.n_samp_burnin ...
                + MC.n_samp_btw_check_convergence;
            
            if MC.n_samp < n_samp_min_bef_conv_check
                n_samp_to_append = n_samp_min_bef_conv_check - MC.n_samp;
            else
                n_samp_to_append = ...
                    MC.n_samp_btw_check_convergence - ...
                    mod(MC.n_samp - MC.n_samp_burnin, ...
                        MC.n_samp_btw_check_convergence);
            end
        end            
        
        ix_samp = n_samp_bef_append + (1:n_samp_to_append);
       
        MCs = MC.MCs;
        if strcmp(MC.parallel_mode, 'chain')
            parfor i_chain = 1:MC.n_MCs
                MCs{i_chain}.append(n_samp_to_append);
                [th{i_chain}, nll{i_chain}, ...
                    p_accept{i_chain}, transitioned{i_chain}] = ...
                        MCs{i_chain}.get_samp(ix_samp);
            end
            for i_chain = 1:MC.n_MCs
                if MCs{i_chain}.n_samp == n_samp_bef_append
                    MCs{i_chain}.add_samp( ...
                        th{i_chain}, nll{i_chain}, ...
                        p_accept{i_chain}, transitioned{i_chain});
                end
            end
        else
            for i_chain = 1:MC.n_MCs
                MCs{i_chain}.append(n_samp_to_append);
            end
        end
        
        n_samp_aft_append = MC.MCs{1}.n_samp;
        
        [tf_converged, ~, MC.rhat(MC.n_samp,1:MC.n_th)] = MC.is_converged( ...
            (n_samp_bef_append + 1):n_samp_aft_append);
        
        MC.plot_online;
    end
    function [tf_converged, tf_converged_all, rhat] = is_converged(MC, ix_samp)
        if ~exist('ix_samp', 'var')
            ix_samp = max( ...
                MC.n_samp_burnin + 1, ...
                MC.n_samp - MC.n_samp_btw_check_convergence + 1):MC.n_samp;
        end
        if isempty(ix_samp)
            tf_converged = false;
            tf_converged_all = false(1, MC.n_th);
            rhat = nan(1, MC.n_th);
            return;
        end
        
        n_samp_to_test = length(ix_samp);
        samp = zeros(n_samp_to_test, MC.n_th, MC.n_MCs);
        
        for i_chain = 1:MC.n_MCs
            samp(:,:,i_chain) = MC.MCs{i_chain}.th_samp(ix_samp, :);
        end
        
        [tf_converged, tf_converged_all, rhat] = bml.mcmc.is_converged( ...
            samp, MC.thres_convergence);
    end
end
%% Plot
methods
    function plot_online(MC)
        if MC.to_plot_online ...
                && ~is_in_parallel
            MC.plot_all;
            drawnow;
        end
    end
    function plot_nll(MC)
        plot(MC.reshape_to_samp_by_MCs(MC.nll_samp));
        ylabel('NLL');
        xlabel('Step');
        set_size(gcf, [300, 200]);
    end
    function plot_p_accept(MC)
        subplot(3,1,1);
        title('p accept by sample');
        plot(MC.reshape_to_samp_by_MCs(MC.p_accept));
        xlabel('Sample');
        ylabel('p accept');
        axis tight;
        
        subplot(3,1,2);
        ecdf(MC.p_accept);
        title('p accept all');
        grid on;
        
        subplot(3,1,3);
        ecdf(MC.p_accept_aft_burnin);
        title('p accept aft burnin');
        grid on;
        set_size(gcf, [300, 400]);
    end
    function v = reshape_to_samp_by_MCs(MC, v)
        assert(isvector(v));
        v = reshape(v, MC.n_MCs, [])';
    end
    function print_stat(MC)
        MC.print_stat@bml.mcmc.MetroMvn;
    	
        disp('Gelman-Rubin R_hat');
        disp(full(MC.rhat(MC.n_samp,:)));
    end
end
%% Utility
methods
    function v = get_n_samp(MC)
        if ~isempty(MC.MCs)
            v = MC.MCs{1}.n_samp;
        else
            v = 0;
        end
    end
    function set_n_samp(MC, v)
        warning('Cannot set %s.n_samp: it depends on subchain''s n_samp.', ...
            class(MC));
    end
    function v = get_th_samp(MC, ix_samp)
        % stack th_samp from subchains
        if ~exist('ix_samp', 'var') ...
                || (ischar(ix_samp) && isequal(ix_samp, ':'))
            ix_samp = 1:MC.n_samp;
        end
        
        if isempty(MC.MCs) || isempty(ix_samp)
            v = [];
            return;
        end
        
        n_ix = length(ix_samp);
        
        v = zeros(MC.n_MCs, n_ix, MC.n_th);
        for i_MC = 1:MC.n_MCs
            v(i_MC,:,:) = permute(MC.MCs{i_MC}.th_samp(ix_samp,:), [3, 1, 2]);
        end
        v = reshape(v, [], MC.n_th);
    end
    function v = get_nll_samp(MC)
        if isempty(MC.MCs)
            v = [];
            return;
        end
        
        v = zeros(MC.n_MCs, MC.n_samp);
        for i_MC = 1:MC.n_MCs
            v(i_MC,:) = MC.MCs{i_MC}.nll_samp';
        end
        v = v(:);
    end
    function v = get_p_accept(MC)
        if isempty(MC.MCs)
            v = [];
            return;
        end
        
        v = zeros(MC.n_MCs, MC.n_samp);
        for i_MC = 1:MC.n_MCs
            v(i_MC,:) = MC.MCs{i_MC}.p_accept';
        end
        v = v(:);
    end
    function v = get_transitioned(MC)
        if isempty(MC.MCs)
            v = [];
            return;
        end
        
        v = zeros(MC.n_MCs, MC.n_samp);
        for i_MC = 1:MC.n_MCs
            v(i_MC,:) = MC.MCs{i_MC}.transitioned';
        end
        v = v(:);
    end
    function v = get_th_samp_aft_burnin(MC)
        if isempty(MC.MCs)
            v = [];
            return;
        end
        
        % stack th_samp from subchains
        ix_samp = (MC.n_samp_burnin + 1):MC.n_samp;
        if isempty(ix_samp)
            v = zeros(0, MC.n_th);
            return;
        end
        
        n_samp_aft_burnin = length(ix_samp);
        v = zeros(MC.n_MCs, n_samp_aft_burnin, MC.n_th);
        for i_MC = 1:MC.n_MCs
            v(i_MC,:,:) = permute(MC.MCs{i_MC}.th_samp_(ix_samp,:), [3, 1, 2]);
        end
        v = reshape(v, [MC.n_MCs * n_samp_aft_burnin, MC.n_th]);
    end
    function v = get_p_accept_aft_burnin(MC)
        if isempty(MC.MCs)
            v = [];
            return;
        end
        
        % stack p_accept from subchains
        ix_samp = (MC.n_samp_burnin + 1):MC.n_samp;
        if isempty(ix_samp)
            v = [];
            return;
        end
        
        n_samp_aft_burnin = length(ix_samp);
        v = zeros(MC.n_MCs, n_samp_aft_burnin);
        for i_MC = 1:MC.n_MCs
            v(i_MC,:) = MC.MCs{i_MC}.p_accept_(ix_samp)';
        end
        v = v(:);
    end
    function v = get_nll_samp_aft_burnin(MC)
        if isempty(MC.MCs)
            v = [];
            return;
        end
        
        % stack p_accept from subchains
        ix_samp = (MC.n_samp_burnin + 1):MC.n_samp;
        if isempty(ix_samp)
            v = [];
            return;
        end
        
        n_samp_aft_burnin = length(ix_samp);
        v = zeros(MC.n_MCs, n_samp_aft_burnin);
        for i_MC = 1:MC.n_MCs
            v(i_MC,:) = MC.MCs{i_MC}.nll_samp_(ix_samp)';
        end
        v = v(:);
    end
end
%% Demo
methods
    function demo(MC)
        %%
        mu_targ = [3 4];
        sigma_targ = [3 1; 1 2];
        sigma_proposal = [5 0; 0 5]; % Overdispersed proposal

        %% Tight bound
%         MC.init( ...
%             'th0', [2 2], ...
%             'fun_nll_targ', @(th) -bml.stat.logmvnpdf(th, mu_targ, sigma_targ), ...
%             'sigma_proposal', sigma_proposal, ...
%             'Constr', fitflow.VectorConstraints( ...
%                 'lb', [-1, -2], ...
%                 'ub', [5, 6]), ...
%             'n_samp_max', 4e3, ...
%             'n_samp_burnin', 2e3, ...
%             'n_MCs', 3, ...
%             'n_samp_btw_check_convergence', 5e2);
%         
%         %%
%         MC.main;
%         
%         %%
%         samp = MC.th_samp_aft_burnin;
%         fig_tag('th_samp_aft_burnin');
%         plot(samp(:,1), samp(:,2), '.');
%         disp(mean(samp));
%         disp(cov(samp));
        
        %% Loose bound
        MC.init( ...
            'th0', [2 2], ...
            'fun_nll_targ', @(th) -bml.stat.logmvnpdf(th, mu_targ, sigma_targ), ...
            'sigma_proposal', sigma_proposal, ...
            'Constr', fitflow.VectorConstraints( ...
                'lb', [-20, -20], ...
                'ub', [20, 20]), ...
            'n_samp_max', 2e4, ...
            'n_samp_burnin', 1e2, ...
            'n_MCs', 30, ...
            'n_samp_btw_check_convergence', 1e2, ...
            'thres_convergence', 1.05);
        MC.main;
        
        %%
        fig_tag('th_samp_aft_burnin');
        clf;
        
        samp = MC.th0s;
        h_init = plot(samp(:,1), samp(:,2), 'o', ...
            'Color', bml.plot.color_lines('b'));
        disp('init');
        disp(mean(samp));
        disp(cov(samp));
        
        hold on;
        samp = MC.th_samp_aft_burnin;
        h_aft = plot(samp(:,1), samp(:,2), '.', ...
            'Color', bml.plot.color_lines('y'));
        disp('aft');
        disp(mean(samp));
        disp(cov(samp));

        hold on;
        samp = MC.th_samp(1:MC.n_samp_burnin,:);
        h_bef = plot(samp(:,1), samp(:,2), '.', ...
            'Color', bml.plot.color_lines('r'));
        disp('bef');
        disp(mean(samp));
        disp(cov(samp));
        
        legend([h_init, h_bef, h_aft], {'init', 'bef burnin', 'aft burnin'}, ...
            'Location', 'EastOutside');
    end
end
end