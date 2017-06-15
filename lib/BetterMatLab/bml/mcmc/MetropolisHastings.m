classdef MetropolisHastings
methods (Static)
function proposal = parse_proposal(proposal_ds, varargin)
    % proposal = parse_prop(ds, varargin)
    %
    % ds : proposal dataset with columns of name, x0, rnd, [logp]
    % name: a string
    % x0  : a scalar numeric
    % rnd : @(x) f_rnd
    % logp: @(x) f_logp
    %
    % ds can be a cell array that would give the proper dataset
    % through cell2ds(ds, true, true). See cell2ds for more info.
    %
    % proposal : proposal struct
    % 'ds', [] 
    % 'rnd_op', 'dx' % 'dx'|'x' - if 'dx', samples are added to the current position.
    % 'rnd', [] % Gets a position vector and returns a new random position.
    % 'logp', [] % Gets a proposal for the position vector and returns its log likelihood (wrt the proposal distribution)
    proposal = varargin2S(varargin, {
        ...
        % ds - columns: name, x0, rnd, [logp]
        % rnd : @(x) f_rnd
        % logp: @(x) f_logp
        'ds', [] 
        'rnd_op', 'normrnd_trunc' 
        % 'rnd_op' : 'normrnd'|'normrnd_trunc'|'dx'|'x'
        % -------
        % 'normrnd' : each entry has stdev of the normrnd of mean 0.
        % 'dx' : samples are added to the current position.
        % 'x'
        'rnd', [] % Gets a position vector and returns a new random position.
        'logp', [] % Gets a proposal for the position vector and returns its log likelihood (wrt the proposal distribution)
        });
    if ~isa(proposal_ds, 'dataset')
        assert(iscell(proposal_ds));
        proposal_ds = cell2ds(proposal_ds, true, true);
    end
    proposal.ds = proposal_ds;
    for column = {'x0', 'lb', 'ub'}
        if isdscolumn(proposal_ds, column{1})
            proposal.(column{1}) = cell2mat2(proposal.ds.(column{1}))';
        end
    end
    proposal.names = proposal.ds.Properties.ObsNames';

    switch proposal.rnd_op
        case 'normrnd_trunc'
            proposal.rnd = ...
                @(x, n_samp) f_rnd_trunc(x, ...
                    proposal.ds.rnd, proposal.lb(:) - x(:), proposal.ub(:) - x(:), ...
                    proposal.rnd_op, n_samp);
        otherwise
            proposal.rnd = ...
                @(x, n_samp) f_rnd(x, proposal.ds.rnd, proposal.rnd_op, n_samp);
    end
    
    if isdscolumn(proposal.ds, 'logp')
        proposal.logp = @(x) f_logp(x, proposal.ds.logp);
    else
        proposal.logp = [];
    end
    
    function r = f_rnd_trunc(~, sd, lb, ub, ~, n_samp)
        sd = cell2mat2(sd);
        r = truncnormrnd(0, sd(:)', lb(:)', ub(:)', [n_samp, length(sd)]);
    end
    
    function r = f_rnd(x, rnd_prop, op, n_samp)
        n = length(x);
        if nargin < 4 || isempty(n_samp), n_samp = 1; end
        
        switch op
            case 'normrnd'
                % Ignore x. Just give dx.
                rnd_prop = hVec(cell2mat2(rnd_prop));
                r = normrnd(0, repmat(rnd_prop, [n_samp, 1]));
            case 'dx'
                for ii = n:-1:1
                    r(ii) = rnd_prop{ii}(x(ii)) + x(ii);
                end
            case 'x'
                for ii = n:-1:1
                    r(ii) = rnd_prop{ii}(x(ii));
                end
            otherwise
                error('Unknown op!');
        end
    end
    function lp = f_logp(x, logp_prop)
        error('Not implemented yet!');
    end
end
function [xhat, se, res, opt] = get_posterior(nll_targ, proposal, varargin)
    opt = varargin2S(varargin, {
        'n_samp', 1000
        'burnin', 0.1
        });
    n_samp_all = ceil(opt.n_samp * (1 + opt.burnin));
    
    MH = MetropolisHastings;
    fprintf('Sampling %d samples including burn-in: ', n_samp_all);
    tic;
    samp = MH.sample_logprob_indep_sym(proposal.x0, n_samp_all, ...
        @(x) -nll_targ(x), proposal.rnd, ...
        'names', proposal.names, 'lb', proposal.lb, 'ub', proposal.ub);
    toc;
    samp = samp((end - opt.n_samp + 1):end, :);
    
    xhat = median(samp);
    se   = sem(samp);
    res  = packStruct(xhat, se, samp);
    
    % DEBUG
    disp(dataset({xhat(:), 'xhat'}, {se(:), 'se'}, ...
        'ObsNames', proposal.names));
    
    samp_rel = bsxfun(@rdivide, bsxfun(@minus, samp, proposal.lb), proposal.ub - proposal.lb);
    cla;
    plot(samp_rel);
    legend(strrep(proposal.names, '_', '-'), 'Location', 'EastOutside');
    title('Sample history');
end
function samp = sample_logprob_indep_sym(x0, n_samp, logp_targ, rnd_prop, varargin)
    % logp_targ(x) ~ log(p_targ(x)) + (constant)
    %
    % Symmetric proposal distribution independent of x.
    %
    % rnd_prop(~, n_samp) : n_samp-by-n_dim random numbers
    
    S = varargin2S(varargin, {
        'plot', true
        'plot_every', 10
        'names', {}
        'lb', []
        'ub', []
        });
    
    assert(isrow(x0));
    n_dim = length(x0);
    samp = nan(n_samp, n_dim);
    fvals = nan(n_samp, 1);
    
    if isempty(S.names)
        S.names = csprintf('%d', 1:n_dim);
    end    
    if S.plot
        y_plot = x0(:)';
        if ~isempty(S.lb) && ~isempty(S.ub)
            y_plot = (y_plot - S.lb) ./ (S.ub - S.lb);
        end
        clf;
        subplot(2,1,1);
        h_th = plot(zeros(2,n_dim), repmat(y_plot, [2,1]));
        legend(strrep(S.names, '_', '-'), 'Location', 'EastOutside');
        
        subplot(2,1,2);
        h_fval = plot(nan, nan);
        legend('log(p)', 'Location', 'EastOutside');
        
        last_plot = 0;
    end
    
    thres_accept = log(rand(n_samp, 1));
    xprop = rnd_prop(x0, n_samp);
    logp_targ_x0 = logp_targ(x0);
    
    for i_samp = 1:n_samp
        x1 = x0 + xprop(i_samp, :);

        logp_targ_x1 = logp_targ(x1);
        logodds_accept = min(0, ...
              logp_targ_x1 - logp_targ_x0);

        if logodds_accept < thres_accept(i_samp)
            % Reject
            x1 = x0;
            logp_targ_x1 = logp_targ_x0;
        else
            % Transition
            x0 = x1;
            logp_targ_x0 = logp_targ_x1;
        end
        samp(i_samp, :) = x1;
        fvals(i_samp) = logp_targ_x1;

%         % DEBUG
%         disp(i_samp);
%         disp(x0);

        % Plot
        if S.plot && mod(i_samp, S.plot_every) == 0
            plot_incl = (last_plot+1):i_samp;
            y_plot = samp(plot_incl,:);
            if ~isempty(S.lb) && ~isempty(S.ub)
                y_plot = bsxfun(@rdivide, ...
                            bsxfun(@minus, y_plot, S.lb(:)'), ...
                        S.ub(:)' - S.lb(:)');
            end
            add_point(h_th, plot_incl(:), y_plot);
%             for i_dim = 1:n_dim
%                 x_data = [get(hx(i_dim), 'XData'), plot_incl];
%                 y_data = [get(hx(i_dim), 'YData'), y_plot(:,i_dim)'];
%                 set(hx(i_dim), 'XData', x_data, 'YData', y_data);
%             end
            
            add_point(h_fval, plot_incl(:), fvals(plot_incl));
            last_plot = i_samp;
            drawnow;
        end
    end
end
function samp = sample_logprob_indep_dx_sym(x0, n_samp, logp_targ, rnd_prop)
    % logp_targ(x) ~ log(p_targ(x)) + (constant)
    %
    % Symmetric proposal displacement independent of x.
    %
    % rnd_prop(n_samp) : n_samp-by-n_dim random numbers
    assert(isrow(x0));
    n_dim = length(x0);
    samp = nan(n_samp, n_dim);

    thres_accept = log(rand(n_samp, 1));
    dx = rnd_prop(n_samp);

    for i_samp = 1:n_samp
        x1 = x0 + dx(i_samp, :);

        logodds_accept = min(0, ...
              logp_targ(x1) - logp_targ(x0));

        if logodds_accept < thres_accept(i_samp)
            % Reject
            x1 = x0;
        end
        samp(i_samp, :) = x1;

        % Transition
        x0 = x1;
    end
end
function samp = sample_logprob(x0, n_samp, logp_targ, logp_prop, rnd_prop)
    % logp_targ(x) ~ log(p_targ(x)) + (constant)
    % logp_prop(x1,x0) ~ log(p_prop(x1,x0)) + (constant)
    % if symmetric, set logp_prop(x1,x0) = @(x1,x0) 0.
    assert(isrow(x0));
    n_dim = length(x0);
    samp = nan(n_samp, n_dim);

    thres_accept = log(rand(n_samp, 1));
    logp_targ_x0 = logp_targ(x0);

    for i_samp = 1:n_samp
        x1 = rnd_prop(x0);

        logodds_accept = min(0, ...
              logp_targ(x1) - logp_targ_x0 ...
            + logp_prop(x1,x0) - logp_prop(x0,x1));

        if logodds_accept < thres_accept(i_samp)
            % Reject
            x1 = x0;
        else
            % Transition
            x0 = x1;
            logp_targ_x0 = logp_targ(x0);
        end
        samp(i_samp, :) = x1;            
    end
end
function samp = sample_logodds(x0, n_samp, logodds_targ, logodds_prop, rnd_prop)
    % samp = sample_logodds(x0, n_samp, logodds_targ, logodds_prop, rnd_prop)
    %
    % logodds_targ(x1, x0) = log(p_targ(x1) / p_targ(x0))
    % logodds_prop(x1, x0) = log(p_prop(x1, x0) / p_prop(x0, x1))
    % if symmetric, set logodds_prop = @(x) 0.
    assert(isrow(x0));
    n_dim = length(x0);
    samp = nan(n_samp, n_dim);

    thres_accept = log(rand(n_samp, 1));

    for i_samp = 1:n_samp
        x1 = rnd_prop(x0);

        logodds_accept = min(0, ...
            logodds_targ(x1, x0) + logodds_prop(x1, x0));

        if logodds_accept < thres_accept(i_samp)
            % Reject
            x1 = x0;
        end
        samp(i_samp, :) = x1;

        % Transition
        x0 = x1;
    end
end
function demo
    MH = MetropolisHastings;

    %% sample_logprob_indep_sym
    x_min = 0;
    x_max = 4;
    dx = 0.1;
    x = x_min:dx:x_max;

    logp_targ = @(x) log(gampdf_ms(x, 1, 0.5));
    logp_prop = @(x1, x0) 0;

    p_target = @(x) gampdf_ms(x, 1, 0.5);
    cdf_target = @(x) gamcdf_ms(x, 1, 0.5);

    % Proposal is better wide than narrow.
    rand_proposal = @(n) normrnd(0, 2, [n, 1]);

    n_sim = 5000;
    n_burnin = 500;

    %%
    x0 = 3;
    tic;
    samp = MH.sample_logprob_indep_sym(x0, n_sim, logp_targ, ...
        rand_proposal);
    toc;    

    %%
    clf;

    subplot(3,1,1);
    cla;
    plot(1:n_sim, samp, '.');
    xlabel('# step');

    subplot(3,1,2);
    cla;
    samp0 = samp(1:n_burnin);
    samp1 = samp((n_burnin+1):end);

    count = hist(samp1, x);
    count = count / sum(count);
    bar(x, count);
    hold on;
    plot(x, p_target(x) * dx, 'r-');

    subplot(3,1,3);
    cla;
    [fcdf, xcdf] = ecdf(samp0);
    plot(xcdf, fcdf, 'g-');
    hold on;

    [fcdf, xcdf] = ecdf(samp1);
    plot(xcdf, fcdf, 'b-');

    hold on;
    plot(x, cdf_target(x), 'r--');

    legend({'Burn-in', 'Sampled', 'Target'});            
end        
function demo_logprob
    MH = MetropolisHastings;

    %% sample_logprob
    x_min = 0;
    x_max = 4;
    dx = 0.1;
    x = x_min:dx:x_max;

    logp_targ = @(x) log(gampdf_ms(x, 1, 0.5));
    logp_prop = @(x1, x0) 0;

    p_target = @(x) gampdf_ms(x, 1, 0.5);
    cdf_target = @(x) gamcdf_ms(x, 1, 0.5);

    % Proposal is better wide than narrow.
    rand_proposal = @(x) x + normrnd(0, 2); % Very wide proposal
%             p_proposal = @(x0, x1) normpdf(x1 - x0, 0, 2); % Very wide proposal

    n_sim = 5000;
    n_burnin = 500;

    %%
    x0 = 3;
    tic;
    samp = MH.sample_logprob(x0, n_sim, logp_targ, logp_prop, ...
        rand_proposal);
    toc;

    %%
    clf;

    subplot(3,1,1);
    cla;
    plot(1:n_sim, samp, '.');
    xlabel('# step');

    subplot(3,1,2);
    cla;
    samp0 = samp(1:n_burnin);
    samp1 = samp((n_burnin+1):end);

    count = hist(samp1, x);
    count = count / sum(count);
    bar(x, count);
    hold on;
    plot(x, p_target(x) * dx, 'r-');

    subplot(3,1,3);
    cla;
    [fcdf, xcdf] = ecdf(samp0);
    plot(xcdf, fcdf, 'g-');
    hold on;

    [fcdf, xcdf] = ecdf(samp1);
    plot(xcdf, fcdf, 'b-');

    hold on;
    plot(x, cdf_target(x), 'r--');

    legend({'Burn-in', 'Sampled', 'Target'});            
end
function demo_logodds
    MH = MetropolisHastings;

    %% sample_logodds
    x_min = 0;
    x_max = 4;
    dx = 0.1;
    x = x_min:dx:x_max;

    logodds_targ = @(x1, x0) log(gampdf_ms(x1, 1, 0.5)) - log(gampdf_ms(x0, 1, 0.5));
    logodds_prop = @(x1, x0) 0;

    p_target = @(x) gampdf_ms(x, 1, 0.5);
    cdf_target = @(x) gamcdf_ms(x, 1, 0.5);

    % Proposal is better wide than narrow.
    rand_proposal = @(x) x + normrnd(0, 2); % Very wide proposal
%             p_proposal = @(x0, x1) normpdf(x1 - x0, 0, 2); % Very wide proposal

    n_sim = 5000;
    n_burnin = 500;

    %%
    x0 = 3;
    samp = MH.sample_logodds(x0, n_sim, logodds_targ, logodds_prop, ...
        rand_proposal);

    %%
    subplot(3,1,1);
    plot(1:n_sim, samp, '.');
    xlabel('# step');

    subplot(3,1,2);
    cla;
    samp0 = samp(1:n_burnin);
    samp1 = samp((n_burnin+1):end);

    count = hist(samp1, x);
    count = count / sum(count);
    bar(x, count);
    hold on;
    plot(x, p_target(x) * dx, 'r-');

    subplot(3,1,3);
    cla;
    [fcdf, xcdf] = ecdf(samp0);
    plot(xcdf, fcdf, 'g-');
    hold on;

    [fcdf, xcdf] = ecdf(samp1);
    plot(xcdf, fcdf, 'b-');

    hold on;
    plot(x, cdf_target(x), 'r--');

    legend({'Burn-in', 'Sampled', 'Target'});            
end
function demo_proof_of_concept
    MH = MetropolisHastings;

    %% Proof-of-concept
    x_min = 0;
    x_max = 4;
    dx = 0.1;
    x = x_min:dx:x_max;

    p_target = @(x) gampdf_ms(x, 1, 0.5);
    cdf_target = @(x) gamcdf_ms(x, 1, 0.5);

    % Proposal is better wide than narrow.
    rand_proposal = @(x) x + normrnd(0, 2); % Very wide proposal
    p_proposal = @(x0, x1) normpdf(x1 - x0, 0, 2); % Very wide proposal

    n_sim = 5000;
    n_burnin = 500;

    %%
    samp = nan(n_sim, 1);
    prob = rand(n_sim, 1);
    cx0 = 2;
    for i_sim = 1:n_sim
        cx1 = rand_proposal(cx0);

        cp = min(1, ...
            p_target(cx1) / p_target(cx0) ...
            * p_proposal(cx1, cx0) / p_proposal(cx0, cx1));

        if cp > prob(i_sim)
            % accept
        else
            % reject
            cx1 = cx0; 
        end 
        samp(i_sim) = cx1;

        % Transition
        cx0 = cx1;
    end

    %%
    subplot(3,1,1);
    plot(1:n_sim, samp, '.');
    xlabel('# step');

    subplot(3,1,2);
    cla;
    samp0 = samp(1:n_burnin);
    samp1 = samp((n_burnin+1):end);

    count = hist(samp1, x);
    count = count / sum(count);
    bar(x, count);
    hold on;
    plot(x, p_target(x) * dx, 'r-');

    subplot(3,1,3);
    cla;
    [fcdf, xcdf] = ecdf(samp0);
    plot(xcdf, fcdf, 'g-');

    [fcdf, xcdf] = ecdf(samp1);
    plot(xcdf, fcdf, 'b-');

    hold on;
    plot(x, cdf_target(x), 'r--');

    legend({'Burn-in', 'Sampled', 'Target'});
end
end
end