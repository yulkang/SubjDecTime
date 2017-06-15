classdef PowerParamCorr
properties
    param_est_se = [
        28.2, 1.1
        8.5, 0.4
        17.6, 0.6
        23.6, 0.9
        20.2, 1.2
        ];
    subj_incl = 1:5;
    
    n_sim = 2e4;
    rho_true = 0.95;
    
    %% Batch
    rhos = 0.8:0.01:1;
    p_sig = [];
end
methods
    function batch(W)
        %%
        subj_incls = {1:5, 1:4};
        n_incls = numel(subj_incls);
        
        p_sig = cell(1, n_incls);
        for i_incl = 1:n_incls
            W.subj_incl = subj_incls{i_incl};
            p_sig{i_incl} = W.main;
        end
        
        rho_obs = 0.97;
        
        file = fullfile('Data', class(W), 'p_sig_by_rho_true');
        
        %%
        if exist([file '.txt'], 'file')
            delete([file '.txt']);
        end
        diary([file '.txt']);
        for ii = 1:n_incls
            i_thres(ii) = find(p_sig{ii} >= 0.8, 1, 'first');
            thres(ii) = W.rhos(i_thres(ii));
            p_sig_w_obs(ii) = p_sig{ii}(W.rhos == rho_obs);
            
            fprintf('For subj_incl=[%s]:\n', ...
                sprintf('%d,', subj_incls{ii}));
            fprintf('  thres rho for p_sig=0.8: %1.5f\n', ...
                thres(ii));
            fprintf('  p_sig when rho=rho_obs=%1.5f: %1.5f\n', ...
                rho_obs, p_sig_w_obs(ii));
        end
        diary('off');
        fprintf('Saved to %s.txt\n', file);
        
        %%
        for i_incl = 1:n_incls
            plot(W.rhos(:), p_sig{i_incl}(:));
            hold on;
        end
        hold off;
        
        set(gca, 'XTick', 0:0.05:1, 'YTick', 0:0.2:1);
        xlabel('\rho_{true}');
        ylabel('P_{significant}');
        bml.plot.beautify;
        mu2 = bsxfun(@plus, ...
            mu1_centered, ...
            randvec * tan(acos(W.rho_true)) .* sqrt(sum(mu1_centered.^2))) ...
            + mean(mu1);
        
        %%
        th2 = normrnd(mu2, ...
                      repmat(se1, [1, n_sim]));
           
        rho = zeros(n_sim, 1);
        pval = zeros(n_sim, 1);
        for i_sim = 1:n_sim
            [rho(i_sim), pval(i_sim)] = corr(th1(:,i_sim), th2(:,i_sim));
        end
        
        p_sig = mean(pval < 0.05);
%         ecdf(pval)
%         disp(p_sig);
    end
end
end