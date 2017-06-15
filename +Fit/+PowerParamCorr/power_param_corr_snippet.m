function power_param_corr_snippet
    W = struct;
    W.param_est_se = [
        28.2, 1.1
        8.5, 0.4
        17.6, 0.6
        23.6, 0.9
        20.2, 1.2
        ];
    W.subj_incl = 1:4; % 1:5 or 1:4

    W.n_sim = 2e4;
    
    subj_incls = {1:5, 1:4};
    n_incls = numel(subj_incls);

    p_sig = cell(1, n_incls);
    for i_incl = 1:n_incls
        W.subj_incl = subj_incls{i_incl};
        p_sig{i_incl} = W.main;
    end

    rho_obs = 0.97;
    
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

    %%
    rhos = 0.8:0.01:1;
    n_rho = numel(rhos);
    p_sig = zeros(n_rho, 1);
    for ii = 1:n_rho
        rho_true = rhos(ii); 
        p_sig(ii) = p_sig_given_effect_snippet(W, rho_true); 
    end
    plot(rhos, p_sig);
end

function p_sig = p_sig_given_effect_snippet(W, rho_true)
    n_subj = numel(W.subj_incl);
    n_sim = W.n_sim;

    mu1 = W.param_est_se(W.subj_incl,1);
    se1 = W.param_est_se(W.subj_incl,2);

    th1 = normrnd(repmat(mu1, [1, n_sim]), ...
                  repmat(se1, [1, n_sim]));

    %% Make mu2 with given Pearson correlation coefficient
    randvec = randn(n_subj, n_sim);
    randvec = bsxfun(@minus, ...
        randvec, ...
        mean(randvec));
    mu1_centered = mu1 - mean(mu1);

    for i_sim = 1:n_sim
        [~,~,randvec(:,i_sim)] = regress(randvec(:,i_sim), mu1_centered);
    end

    % Make it length 1
    randvec = bsxfun(@rdivide, randvec, sqrt(sum(randvec.^2)));

    % Make mu2
    mu2 = bsxfun(@plus, ...
        mu1_centered, ...
        randvec * tan(acos(W.rho_true)) .* sqrt(sum(mu1_centered.^2))) ...
        + mean(mu1);

    %% Make th2 given mu2 and se1
    th2 = normrnd(mu2, ...
                  repmat(se1, [1, n_sim]));

    rho = zeros(n_sim, 1);
    pval = zeros(n_sim, 1);
    for i_sim = 1:n_sim
        [rho(i_sim), pval(i_sim)] = corr(th1(:,i_sim), th2(:,i_sim));
    end

    p_sig = mean(pval < 0.05);

    %%
%         ecdf(pval)
%         disp(p_sig);
end