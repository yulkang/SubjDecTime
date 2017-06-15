classdef SmoothGaussProcRegItv < DeepCopyable
    % Gaussian process smoothing given scalar Gaussian measurements and 
    % a Wiener process prior with an empirical diffusion parameter.
    %
    % 2016 (c) Yul Kang. hk2699 at columbia dot edu.
properties
    max_iter = 1;
end
methods
    function Prior = PriorSmooth(varargin)
        varargin2props(Prior, varargin{:});
    end
    function [mu, se, nll] = smooth(Prior, m0, sem0, dt)
        % possibly also return nll
        n = numel(m0);
        
        diff0 = diff(m0);
        sv_diff0 = sem0(1:(end-1)).^2 + sem0(2:end).^2;
        sig0 = sqrt(var(diff0, max(1./sv_diff0, eps)) ./ dt);
%         sig0 = sqrt(var(diff0) ./ dt);
        
        mu0 = m0;
        err = inf;
        tol = 1e-6;
        
        nll0 = Prior.neg_log_lik(mu0, sig0, m0, sem0, dt);
        disp(nll0);
        
        d_nll = -inf;
        tol_abs_d_nll = 1;
        
        iter = 0;
        max_iter = Prior.max_iter;
        while err > tol % abs(d_nll) > tol_abs_d_nll % 
            mu = Prior.max_a_posterior(mu0, sig0, m0, sem0, dt);
            err = max((mu - mu0).^2); % ./ n;

%             disp([mu, mu - mu0]');
            mu0 = mu;
            
            nll = Prior.neg_log_lik(mu, sig0, m0, sem0, dt);
            d_nll = nll - nll0;
            nll0 = nll;
            
%             % DEBUG
%             disp(nll);
%             disp(d_nll);

            iter = iter + 1;
            if iter >= max_iter
                break;
            end
        end
        
        hess = Prior.hessian(mu, sig0, m0, sem0, dt);
        se = sqrt(diag(inv(hess)));
    end
    function mu = max_a_posterior(~, mu0, sig0, m0, sem0, dt)
        n = size(mu0, 1);
        mu = zeros(size(mu0));
        
        t = (1:n)';
        
        for ii = 1:n
            tau = abs((t - ii) .* dt);
            incl = abs(tau) == dt; % Markov
%             incl = tau ~= 0; % high order - too smooth
            
            % TODO : put tau in a matrix and rewrite mu in a matrix form
            numer = (m0(ii) ./ sem0(ii).^2 ...
                   + 2 ./ sig0.^2 .* sum(mu0(incl) ./ tau(incl)));
            denom = (1 ./ sem0(ii).^2 ...
                   + 2 ./ sig0.^2 .* sum(1 ./ tau(incl)));
            
            mu(ii) = numer ./ denom;
        end
    end
    function nll = neg_log_lik(~, mu, sig, m0, sem0, dt)
        n = size(mu, 1);
        t = (1:n)';
        
        nll = 0;
        
        for ii = 1:n
            tau = abs((t - ii) .* dt);
            incl = abs(tau) == dt; % Markov
%             incl = tau ~= 0; % high order - too smooth
            
            nll = nll ...
                + (mu(ii) - m0(ii) ./ (2 .* sem0(ii).^2)) ...
                + sum((mu(ii) - mu(incl)) .^ 2 ...
                   ./ (2 .* sig.^2 .* tau(incl)));
        end
    end
    function hess = hessian(~, mu, sig, m0, sem0, dt)
        n = size(mu, 1);
        hess = zeros(n, n);
        t = (1:n)';
        
        for t1 = 1:n
            for t2 = 1:n
                tau = abs((t - t1) .* dt);
                incl = abs(tau) == dt; % Markov
%             incl = tau ~= 0; % high order - too smooth
                
                if t1 == t2
                    hess(t1, t2) = 1 ./ sem0(t1).^2 ...
                                 + 1 ./ sig.^2 .* sum(2 ./ tau(incl));
                else
                    hess(t1, t2) = -2 ./ (sig.^2 .* abs(t1 - t2) .* dt);
                end
            end
        end
    end
end
end