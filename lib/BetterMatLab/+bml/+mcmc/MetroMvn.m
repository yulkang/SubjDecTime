classdef MetroMvn < bml.mcmc.MCMC
    % Metropolis sampling with multivariate normal proposal distribution.
        
    % 2016 (c) Yul Kang. hk2699 at columbia dot edu.

%% Props - Settings - Required
properties
    th0
    fun_nll_targ
end
%% Props - Settings - Optional
properties
    mu_proposal
    sigma_proposal
    
    Constr
    
    n_samp_max = 2e4;
    n_samp_burnin = 2e3;
    
    % sigma_hessian: = inv(hessian). 
    % Optional. If given, used for sigma_proposal and sigma_th0s.
    sigma_hessian = [];
    
    % sigma_hessian_to_sigma_proposal_factor
    % : Used if sigma_hessian is given.
    sigma_hessian_to_sigma_proposal_factor = 0.01;
    
    % typical_scale_to_sigma_proposal_factor
    % : Used if sigma_hessian is not given,
    %   or as the minimum variance to keep on diagonal.
    typical_scale_to_sigma_proposal_factor = 1e-5;
    
    to_plot_online = true;
    n_samp_btw_plot = 50;
    
    seed = 'shuffle';
end
%% Props - Results
properties (Dependent)
    th_samp
    nll_samp
    p_accept
    transitioned
    
    th_samp_aft_burnin
    p_accept_aft_burnin
    nll_samp_aft_burnin
end
properties
    th_samp_ = [];
    nll_samp_ = [];
    p_accept_ = [];
    transitioned_ = [];
end
%% Props - Intermediate
properties 
    fun_proposal % function(th_src, n) % gives th_mat
    fun_nll_proposal % function(th_src, th_dst) % gives p (column vec)
    
    n_samp_ = 0;
    
    RStream = [];
    
    th_now
    nll_now
end
properties (Dependent)
    n_samp
    n_th
    sigma_proposal_from_typical_scale
end
%% Init
methods
    function MC = MetroMvn(varargin)
        MC.Constr = fitflow.VectorConstraints;
        if nargin > 0
            MC.init(varargin{:});
        end
    end
    function init(MC, varargin)
        bml.oop.varargin2props(MC, varargin, true);
        
        % Required inputs
        for th = {'th0', 'fun_nll_targ'}
            assert(~isempty(MC.(th{1})), '%s is required!', th{1});
        end
        
        % Initial sigma_proposal
        if isempty(MC.sigma_proposal)
            MC.sigma_proposal = MC.get_sigma_proposal_auto;
        end
        
        % Random number generator
        MC.RStream = RandStream('mt19937ar', 'Seed', MC.seed);
%         rng('shuffle');
        
        % Multivariate normal proposal
        MC.mu_proposal = zeros(1, MC.n_th);
        MC.fun_proposal = @(th_src, n, mu, sigma) bsxfun(@plus, th_src, ...
            bml.math.mvnrnd_stream(MC.RStream, mu, sigma, n));
        MC.fun_nll_proposal = @(th_src, th_dst, mu, sigma) ...
            bml.stat.logmvnpdf(bsxfun(@minus, th_dst, th_src), mu, sigma);
        
        % Preallocate
        MC.preallocate;
        
        % Initial point
        MC.add_initial_point;
    end
    function v = get_sigma_proposal_auto(MC)
        v = MC.get_sigma_proposal_from_typical_scale;
        if ~isempty(MC.sigma_hessian)
            v = max(v, MC.sigma_hessian ...
                    .* MC.sigma_hessian_to_sigma_proposal_factor);
        end
    end
    function v = get_sigma_proposal_from_typical_scale(MC, factor)
        if ~exist('factor', 'var')
            factor = MC.typical_scale_to_sigma_proposal_factor;
        end
        v = diag(abs(MC.Constr.typical_scale)) .* factor;
    end
    function preallocate(MC)
        MC.n_samp = 0;
        MC.th_samp_ = nan(MC.n_samp_max, MC.n_th);
        MC.nll_samp_ = nan(MC.n_samp_max, 1);
        MC.p_accept_ = nan(MC.n_samp_max, 1);
        MC.transitioned_ = false(MC.n_samp_max, 1);
    end
    function add_initial_point(MC)
        MC.th_now = MC.th0;
        MC.nll_now = MC.fun_nll_targ(MC.th_now);
        MC.add_samp(MC.th_now, MC.nll_now, 1, true);
    end
end
%% Main
methods
    function main(MC)
        if MC.n_samp < MC.n_samp_max
            MC.append(MC.n_samp_max - MC.n_samp);
        end
    end
    function append(MC, n_samp)
        for i_samp = 1:n_samp
            MC.append_unit;
        end
    end
    function append_unit(MC)
        th_proposal = MC.get_proposal;
        nll_proposal = MC.fun_nll_targ(th_proposal);
        MC.transition(nll_proposal, th_proposal);

        MC.plot_online;
    end
    function th_proposal = get_proposal(MC)
        all_met = false;
        while ~all_met
            th_proposal = MC.fun_proposal(MC.th_now, 1, ...
                MC.mu_proposal, MC.sigma_proposal);
            all_met = MC.Constr.is_constr_met(th_proposal);
        end
    end
    function transition(MC, nll_proposal, th_proposal)
        assert(isscalar(nll_proposal));
        assert(isvector(th_proposal));
        
        [to_transition, p_accept] = MC.get_to_transition( ...
            MC.nll_now, nll_proposal);
        if to_transition
            MC.th_now = th_proposal;
            MC.nll_now = nll_proposal;
        end
        MC.add_samp(MC.th_now, MC.nll_now, p_accept, to_transition);
    end
    function [to_transition, p_accept]= get_to_transition(MC, ...
            nll_now, nll_proposal)
        
        if nll_proposal == inf
            p_accept = 0;
            to_transition = false;
            
        elseif nll_proposal < nll_now
            p_accept = 1;
            to_transition = true;
            
        else % nll_proposal >= nll_now
            p_accept = exp(nll_now - nll_proposal); % <= 1
            r = rand(MC.RStream);
            to_transition = r <= p_accept;
        end
    end
    function add_samp(MC, th, nll, p_accept, transitioned)
        n_samp_to_add = size(th, 1);
        ix_samp = MC.n_samp + (1:n_samp_to_add);
        
        MC.th_samp_(ix_samp, :) = th;
        MC.nll_samp_(ix_samp) = nll;
        MC.p_accept_(ix_samp) = p_accept;
        MC.transitioned_(ix_samp) = transitioned;
        
        MC.n_samp = MC.n_samp + n_samp_to_add;
        
%         disp([MC.n_samp, th]); % debug
    end
    function [th, nll, p_accept, transitioned] = get_samp(MC, ix_samp)
        th = MC.th_samp_(ix_samp, :);
        nll = MC.nll_samp_(ix_samp, :);
        p_accept = MC.p_accept_(ix_samp, :);
        transitioned = MC.transitioned_(ix_samp, :);
    end
end
%% Plot
methods
    function plot_online(MC)
        if MC.to_plot_online ...
                && ~is_in_parallel ...
                && mod(MC.n_samp, MC.n_samp_btw_plot) == 0
            MC.plot_all;
            drawnow;
        end
    end
    function plot_all(MC)
        tags = MC.get_plot_tags;
        for tag = tags(:)'
            try
                fig_tag(tag{1});
                MC.(['plot_' tag{1}]);
            catch err
                warning(err_msg(err));
            end
        end
        MC.print_stat;
    end
    function plot_all_and_save(MC, file)
        % plot_all_and_save(MC, file)
        tags = MC.get_plot_tags;
        for tag = tags(:)'
            try
                fig_tag(tag{1});
                MC.(['plot_' tag{1}]);
                savefigs([file, sprintf('+plt=%s', tag{1})], 'size', []);
            catch err
                warning(err_msg(err));
            end
        end
        
        file_txt = [file, '.txt'];
        if exist(file_txt, 'file'), delete(file_txt); end
        diary(file_txt);
        MC.print_stat;
        diary('off');
        fprintf('diary saved to %s\n', file_txt);
    end
    function tags = get_plot_tags(MC)
        tags = {'nll', 'samp', 'cov', 'split', 'p_accept'};
    end
    function plot_samp(MC)
        samp_z = standardize(MC.th_samp);
        n_samp = size(samp_z, 1);
        n_th = size(samp_z, 2);
        
        win = 1;
        samp_incl = round(win/2):round(n_samp - win/2);
        
        if win > 1
            for ii = 1:n_th
                samp_z(:,ii) = smooth(samp_z(:,ii), win);
            end
        end
        
        n_th_per_plot = 5;
        n_plot = ceil(n_th / n_th_per_plot);
        
        for i_plot = 1:n_plot
            subplot(n_plot, 1, i_plot);
            
            plot_incl_min = (i_plot - 1) * n_th_per_plot + 1;
            plot_incl_max = min(plot_incl_min + n_th_per_plot - 1, n_th);
            plot_incl = plot_incl_min:plot_incl_max;
            
            plot(samp_incl, samp_z(samp_incl, plot_incl));
            xlim([0, samp_incl(end)]);
            
            title(sprintf('Param %d-%d', plot_incl(1), plot_incl(end)));
            if i_plot == n_plot
                xlabel('Step');
                ylabel('Param (Z-score)');
            end
        end
        set_size(gcf, [300, 400]);
    end
    function plot_cov(MC)
        slice = [
            1
            ceil(min(MC.n_samp, MC.n_samp_burnin) / 2)
            min(MC.n_samp, MC.n_samp_burnin)
            max(MC.n_samp_burnin, ceil((MC.n_samp + MC.n_samp_burnin) / 2))
            MC.n_samp + 1
            ];
        slice = min(slice, MC.n_samp + 1);
        n_slice = length(slice) - 1;
            
        n_th = MC.n_th;
        cov_all = nan(n_th, n_th, n_slice);
        
        samp_z = standardize(MC.th_samp);
        
        for i_slice = n_slice:-1:1
            h(i_slice) = subplot(n_slice, 1, i_slice);
            
            tr_st = slice(i_slice);
            tr_en = max(slice(i_slice + 1) - 1, slice(i_slice));
            
            if tr_en - tr_st < n_th * 3
                continue;
            end
            
            samp = samp_z(tr_st:tr_en, :);
            cov_mat = cov(samp);
            cov_all(:,:,i_slice) = cov_mat;
            
            imagesc(cov_mat);
            colorbar;
            axis square;
            title(sprintf('Trials %d-%d', tr_st, tr_en));
        end
        c_lim = prctile(cov_all(:), [5, 95]);
        set(h, 'CLim', c_lim);
        set_size(gcf, [300, 1200]);
    end
    function plot_split(MC)
        slice = [
            1
            ceil(min(MC.n_samp, MC.n_samp_burnin) / 2)
            min(MC.n_samp, MC.n_samp_burnin)
            max(MC.n_samp_burnin, ceil((MC.n_samp + MC.n_samp_burnin) / 2))
            MC.n_samp + 1
            ];
        slice = min(slice, MC.n_samp + 1);
        n_slice = length(slice) - 1;

        n_th = MC.n_th;
        trs = cell(1, n_slice);
        for i_slice = 1:n_slice
            tr_st = slice(i_slice);
            tr_en = max(slice(i_slice + 1) - 1, slice(i_slice));
            if tr_en - tr_st < n_th * 3
                continue;
            end
            trs{i_slice} = tr_st:tr_en;
        end
        
        if MC.n_samp > MC.n_samp_burnin + MC.n_samp_burnin / 2
            samp0 = MC.th_samp_aft_burnin;
        else
            samp0 = MC.th_samp;
        end
        mu_samp = mean(samp0);
        std_samp = std(samp0);

        samp_all = bsxfun(@rdivide, bsxfun(@minus, ...
            MC.th_samp, mu_samp), std_samp);
        
        f_shift = @(ii) (ii - (n_slice + 1) / 2) / n_slice / 20;
        
        n_row = 2;
        row = 0;
        row = row + 1;
        for i_slice = n_slice:-1:1
            samp = samp_all(trs{i_slice}, :);
            m = mean(samp);
            s = sem(samp);
            
            subplotRC(n_row, 1, row, 1);
            
            shift = f_shift(i_slice);
            h(i_slice) = errorbar((1:n_th) + shift, m, s);
            hold on;
        end
        hold off;
        legend(h, {'burnin1', 'burnin2', 'aft1', 'aft2'}, ...
            'Location', 'EastOutside');
        title('mean');
        grid on;
        
        row = row + 1;
        for i_slice = n_slice:-1:1
            samp = samp_all(trs{i_slice}, :);
            m = std(samp);
            s = sestd(samp);
            
            subplotRC(n_row, 1, row, 1);
            
            shift = f_shift(i_slice);
            h(i_slice) = errorbar((1:n_th) + shift, m, s);
            hold on;
        end
        hold off;
        legend(h, {'burnin1', 'burnin2', 'aft1', 'aft2'}, ...
            'Location', 'EastOutside');
        title('std');
        grid on;
        set_size(gcf, [300, 400]);
    end
    function plot_nll(MC)
        plot(MC.nll_samp);
        ylabel('NLL');
        xlabel('Step');
        set_size(gcf, [300, 200]);
    end
    function plot_p_accept(MC)
        subplot(3,1,1);
        title('p accept by sample');
        plot(MC.p_accept);    
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
    function print_stat(MC)
        fprintf('----- n_samp: %d\n', MC.n_samp);
        
        disp('cov');
        disp(cov(MC.th_samp_aft_burnin));
        
        disp('mean');
        disp(mean(MC.th_samp_aft_burnin));
        
        disp('std');
        disp(std(MC.th_samp_aft_burnin));

        disp('mean p_accept');
        disp(mean(MC.p_accept));
        
        disp('mean p_accept after burnin');
        disp(mean(MC.p_accept_aft_burnin));
    end
end
%% Utilities
methods
    function v = get.n_th(MC)
        v = length(MC.th0);
    end
    
    function v = get.n_samp(MC)
        v = MC.get_n_samp;
    end
    function v = get_n_samp(MC)
        v = MC.n_samp_;
    end
    function set.n_samp(MC, v)
        MC.set_n_samp(v);
    end
    function set_n_samp(MC, v)
        MC.n_samp_ = v;
    end
    
    function v = get.th_samp(MC)
        v = get_th_samp(MC);
    end
    function v = get_th_samp(MC)
        v = MC.th_samp_(1:MC.n_samp, :);
    end
    
    function v = get.th_samp_aft_burnin(MC)
        v = get_th_samp_aft_burnin(MC);
    end
    function v = get_th_samp_aft_burnin(MC)
        v = MC.th_samp_((MC.n_samp_burnin + 1):MC.n_samp, :);
    end
    
    function v = get.nll_samp(MC)
        v = get_nll_samp(MC);
    end
    function v = get_nll_samp(MC)
        v = MC.nll_samp_(1:MC.n_samp);
    end
    
    function v = get.nll_samp_aft_burnin(MC)
        v = get_nll_samp_aft_burnin(MC);
    end
    function v = get_nll_samp_aft_burnin(MC)
        v = MC.nll_samp_((MC.n_samp_burnin + 1):MC.n_samp);
    end
    
    function v = get.p_accept(MC)
        v = get_p_accept(MC);
    end
    function v = get_p_accept(MC)
        v = MC.p_accept_(1:MC.n_samp);
    end
    
    function v = get.p_accept_aft_burnin(MC)
        v = get_p_accept_aft_burnin(MC);
    end
    function v = get_p_accept_aft_burnin(MC)
        v = MC.p_accept_((MC.n_samp_burnin + 1):MC.n_samp);
    end
    
    function v = get.transitioned(MC)
        v = get_transitioned(MC);
    end
    function v = get_transitioned(MC)
        v = MC.transitioned_(1:MC.n_samp);
    end
end
%% Adaptors
methods
    
end
%% Demo
methods
    function demo(MC)
        %%
        mu_targ = [3 4];
        sigma_targ = [2 1; 1 2];
        sigma_proposal = [1 0; 0 1];

        %% Tight bound
        MC.init( ...
            'th0', [2 2], ...
            'fun_nll_targ', @(th) -bml.stat.logmvnpdf(th, mu_targ, sigma_targ), ...
            'sigma_proposal', sigma_proposal, ...
            'Constr', fitflow.VectorConstraints( ...
                'lb', [-1, -2], ...
                'ub', [5, 6]), ...
            'n_samp_max', 4e3, ...
            'n_samp_burnin', 2e3);
        MC.main;
        
        %%
        samp = MC.th_samp_aft_burnin;
        plot(samp(:,1), samp(:,2), '.');
        disp(mean(samp));
        disp(cov(samp));
        
        %% Loose bound
%         MC.init( ...
%             'th0', [2 2], ...
%             'fun_nll_targ', @(th) -bml.stat.logmvnpdf(th, mu_targ, sigma_targ), ...
%             'sigma_proposal', sigma_proposal, ...
%             'Constr', fitflow.VectorConstraints( ...
%                 'lb', [-10, -10], ...
%                 'ub', [10, 10]), ...
%             'n_samp_max', 4e3, ...
%             'n_samp_burnin', 2e3);
%         MC.main;
%         
%         %%
%         samp = MC.th_samp_aft_burnin;
%         plot(samp(:,1), samp(:,2), '.');
%         disp(mean(samp));
%         disp(cov(samp));
    end
end
end