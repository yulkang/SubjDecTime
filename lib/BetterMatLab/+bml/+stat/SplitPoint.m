classdef SplitPoint < DeepCopyable
properties
    
end
methods
    function [est, ci, cdf_across_boot, lik_all_boot] = ...
            get_est_all_boot(Sp, samp_boot, varargin)
        
        S = varargin2S(varargin, {
            'prctile_ci', [5, -5]./2 + [0 100]
            });
        C = S2C(S);
        
        [mle, ~, lik_all_boot] = Sp.get_mle_all_boot(samp_boot, C{:});
        
        lik_across_boot = nansum(lik_all_boot, 2);
        lik_across_boot = lik_across_boot ./ sum(lik_across_boot);
        cdf_across_boot = cumsum(lik_across_boot);
        
%         ix = bsxClosest([0.5, S.prctile_ci / 100], ...
%             cdf_across_boot);
%         
%         est = ix(1);
%         ci = ix(2:3);
        
        est = median(mle);
        ci = prctile(mle, S.prctile_ci);
    end
    function [mle, lik_mle, lik_all_boot] = ...
            get_mle_all_boot(Sp, samp_boot, varargin)
        % samp_boot(t, boot)
        %
        % mle(boot, 1) : most likely split in BOOT.
        
        n_boot = size(samp_boot, 2);
        
        for i_boot = n_boot:-1:1
            [mle(i_boot, 1), lik_mle(i_boot, 1), lik_all_boot(:,i_boot)] ...
                = Sp.get_mle_all_split(samp_boot(:, i_boot), varargin{:});
        end
    end
    function [mle, lik_mle, lik_all] = get_mle_all_split(Sp, samp, varargin)
        % samp(t, 1)
        %
        % llk : maximum log likelihood
        % llk_all(t_split, 1)
        
        lik_all = arrayfun(@(split) Sp.get_lik(samp, split, varargin{:}), ...
                        (1:length(samp))');
        lik_all = lik_all ./ nansum(lik_all);
        [lik_mle, mle] = max(lik_all);
    end
    function p = get_lik(~, samp, split, varargin)
        % samp(t, 1)
        % p : likelihood of 
        %       mean(samp(t <= split)) 
        %    ~= mean(samp(t > split)) 
        % as tested with ttest2
        
%         S = varargin2S(varargin, {
%             'tail', 'both'
%             });
        
        n = length(samp);
        if split == n
            p = eps;
            return;
        end
        
        ix = 1:n;
        samp1 = samp(ix <= split);
        samp2 = samp(ix > split);
        
%         p1 = 1 - ttest(samp1, 0, 'tail', 'left');
%         p2 = 1 - ttest(samp2, 0, 'tail', 'right');
        
        p1 = 1 - signtest(samp1, 0, 'tail', 'left');
        p2 = 1 - signtest(samp2, 0, 'tail', 'right');
        
        p = p1 * p2;
        
%         [~, p] = ttest2(samp1, samp2, 'tail', S.tail);
        
%         p = ranksum(samp1, samp2, 'tail', S.tail);
    end
end
end