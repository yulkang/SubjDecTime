classdef LogisticWithLapse < DeepCopyable
    % 2015 (c) Yul Kang. hk2699 at columbia dot edu.
    
properties
end
methods
    %% Check fitting
    function res = demo(W, varargin)
        lapses = [0 0.1 0.2 0.4]; %  0.49]; % , 0.9];
        
        lgt = (-3:0.05:3)';
        
        n_lapse = length(lapses);
        for i_lapse = n_lapse:-1:1
            lapse = lapses(i_lapse);
            
            ch = W.sim(lgt, lapse);
            [b, dev, stats] = ...
                W.glmfit(lgt/2, ch, lapse);
            se = stats.se;
            
            [x, fval, exitflag, out] = ...
                W.fmincon(lgt/2, ch, [0, 1, lapse]);
                        
            res(i_lapse) = packStruct( ...
                b, se, dev, stats, x, fval, exitflag, out);
        end
        
        disp('b, se');
        disp([cell2mat2({res.b}), cell2mat2({res.se})]);
        disp('x');
        disp(cell2mat2({res.x}));
    end
    
    %% Simulate
    function ch = sim(W, lgt, lapse)
        p = W.inv_logit_w_lapse(lgt, lapse);
        ch = rand(size(p)) < p;
    end
    
    %% Fit
    function varargout = glmfit(W, X, ch, lapse, varargin)
        [varargout{1:nargout}] = ...
            glmfit(X, ch, 'binomial', ...
            'link', W.linkfun(lapse), ...
            varargin{:});
    end
    function varargout = fmincon(W, X, ch, x0, varargin)
        % varargout = fmincon(W, X, ch, x0, varargin)
        %
        % x0(1)   : bias
        % x0(end) : lapse
        % length(x0) == size(X,2) + 2
        
        assert(length(x0) == size(X,2) + 2);
        
        X1 = [ones(size(X,1), 1), X];
        f = @(b) W.cost(X1 * vVec(b(1:(end-1))), ch, b(end));
        [varargout{1:nargout}] = fmincon(f, x0, varargin{:});
    end
    
    %% Likelihood
    function nll = cost(W, lgt, ch, lapse)
        p = W.inv_logit_w_lapse(lgt, lapse);
        p = min(max(p, eps), 1-eps);
        nll = -(sum(log(p(ch))) + sum(log(1 - p(~ch))));
    end
end 
%% Link functions
methods
    function f = linkfun(W, lapse)
        f = {
            @(p) W.logit_w_lapse(p, lapse)
            @(p) W.d_logit_w_lapse(p, lapse)
            @(lgt) W.inv_logit_w_lapse(lgt, lapse)
            };
    end
end
methods (Static)
    function lgt = logit_w_lapse(p, lapse)
        assert(all(0 <= p(:)));
        assert(all(p(:) <= 1));
        assert(isscalar(lapse));
        assert(0 <= lapse);
        assert(lapse <= 1);
        
%         lapse = max(lapse, eps);
        
        p = (p - 0.5) ./ (1 - lapse) + 0.5;
        
%         p = min(max(p, eps), 1 - eps);
        
        lgt = log(p) - log(1 - p);
        
        lgt(p >= 1) = inf;
        lgt(p <= 0) = -inf;
    end
    function dl_dp = d_logit_w_lapse(p, lapse)
        
        dl_dp = 1 ./ (p - lapse ./ 2) + 1 ./ (1 - p - lapse ./ 2);
        
        incl_inf = (p <= lapse / 2) | (p >= 1 - lapse / 2);
        dl_dp(incl_inf) = 1e5;
        dl_dp = min(dl_dp, 1e5);
        
%         dl_dp = log(max(p - lapse / 2, eps)) ...
%               - log(max(1 - p - lapse / 2, eps));
        
%         atten = 1 - lapse;
%         dl_dp = (atten ./ (atten .* p + lapse ./ 2)) ...
%               + (atten ./ (1 - lapse ./ 2 - atten .* p));
    end
    function p = inv_logit_w_lapse(lgt, lapse)
        p = 1 ./ (1 + exp(-lgt));
        p = p .* (1 - lapse) + 0.5 .* lapse;
        
        p(lgt == -inf) = 0;
        p(lgt == inf) = 1;
        
        if any(isnan(p(:)))
            keyboard;
        end
    end
end
%% Plot
methods
    function plot_sanity_link(W)
        lapses = [0, 0.1, 0.2, 0.4, 0.9];
        n_plot = 3;
        
        p = 0:1e-3:1;
%         p = 0:1e-5:1; % Works with this, too.
%         p = 0.05:0.1:0.95;
            
        n_lapse = length(lapses);
        cols = hsv2(n_lapse);
        spec = '-';
        spec2 = 'o';
        
        clf;
        for i_lapse = 1:n_lapse
            
            lapse = lapses(i_lapse);
            lgt = W.logit_w_lapse(p, lapse);
            p2 = W.inv_logit_w_lapse(lgt, lapse);
            
            col = cols(i_lapse, :);
            
            % Logit
            subplot(1,n_plot,1);
            plot(p, lgt, spec, 'Color', col);
            hold on;
            plot(p2, lgt, spec2, 'Color', col);
            hold on;
            grid on;
            set(gca, 'XTick', 0:0.1:1);
%             ylim([-5, 5]);
            
            % dLogit/dp
            subplot(1,n_plot,2);
            dl_dp = W.d_logit_w_lapse(p, lapse);
            plot(p, dl_dp, spec, 'Color', col);
            hold on;
            plot((p(2:end) + p(1:(end-1))) / 2, ...
                 diff(lgt) ./ (p(2) - p(1)), spec2, 'Color', col);
            hold on;
            grid on;
            set(gca, 'XTick', 0:0.1:1);
%             ylim([0 1e3]);
            
            % p
            subplot(1,n_plot,3);
            plot(lgt, p2, spec, 'Color', col);
            hold on;
            plot(lgt, p, spec2, 'Color', col);
            hold on;
            grid on;
            set(gca, 'YTick', 0:0.1:1);
%             xlim([-5, 5]);
            
%             disp([p(:), p2(:), lgt(:)]);
        end
    end
end
end