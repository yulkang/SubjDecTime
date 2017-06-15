classdef MetroMvnAdaCov < bml.mcmc.MetroMvn
    % Metropolis sampling with multivariate normal proposal distribution.
    
    % 2016 (c) Yul Kang. hk2699 at columbia dot edu.
    
%% Intermediate variables
properties
    n_samp_bef_adapt_cov = 1e2;
    n_samp_btw_adapt_cov = 1e2;
    n_samp_max_adapt_cov = 1e3; % max number of trials to calculate cov with.
   
    n_samp_last_adapt_cov = 0; % n_samp at last update
    
    to_adapt_cov = true;
end
    
%% Main
methods
    function MC = MetroMvnAdaCov(varargin)
        if nargin > 0
            MC.init(varargin{:});
        end
    end
    function init(MC, varargin)
        MC.init@bml.mcmc.MetroMvn(varargin{:});
    end
    function append_unit(MC)
        if MC.to_adapt_cov ...
                && (MC.n_samp <= MC.n_samp_burnin) ...
                && (MC.n_samp >= MC.n_samp_bef_adapt_cov) ...
                && (MC.n_samp >= MC.n_samp_last_adapt_cov ...
                               + MC.n_samp_btw_adapt_cov)

            MC.adapt_cov;
            MC.n_samp_last_adapt_cov = MC.n_samp;
            fprintf('sigma_proposal updated at n_samp=%d\n', MC.n_samp);
        end
        
        MC.append_unit@bml.mcmc.MetroMvn;
    end
    function sigma_proposal = adapt_cov(MC, ix_samp_incl)
        if ~exist('ix_samp_incl', 'var')
            ix_samp_incl = ...
                max(1, MC.n_samp - MC.n_samp_max_adapt_cov):MC.n_samp;
        end
        samp = MC.th_samp(ix_samp_incl, :);
        
        % Following Haario 2006 and Gelman 1995
        cov_samp = cov(samp);
        sigma_proposal = MC.get_sigma_proposal_from_cov_samp(cov_samp);
        
        if nargout == 0
            MC.update_sigma_proposal(sigma_proposal);
        end
    end
    function update_sigma_proposal(MC, sigma_proposal)
        MC.sigma_proposal = sigma_proposal;

%         disp(sigma_proposal);
    end
    function sigma_proposal = get_sigma_proposal_from_cov_samp(MC, cov_samp)
        sigma_proposal = nan0(cov_samp) .* 2.4^2 ./ MC.n_th ...
            + MC.get_sigma_proposal_from_typical_scale;
    end
end
end