function [p, mean_sim, est_sim] = pval_group_from_est_and_se(est, se, varargin)
    % [p, mean_sim, est_sim] = pval_group_from_est_and_se(est, se, varargin)
    %
    % OPTIONS:
    % 'n_sim', 1e5
    % 'tail', 'two' % 'left' (H0: est_sim <= 0)|'right'|'two'    
    
    S = varargin2S(varargin, {
        'n_sim', 1e5
        'tail', 'two' % 'left' (H0: est_sim <= 0)|'right'|'two'
        });
    n_subj = numel(est);
    assert(n_subj == numel(se));
    
    est_sim = zeros(S.n_sim, n_subj);
    
    for ii = 1:n_subj
        est_sim(:, ii) = normrnd(est(ii), se(ii), [S.n_sim, 1]);
    end
    mean_sim = mean(est_sim, 2);
    
    switch S.tail
        case 'two'
            error('Not implemented yet!');
        case 'left'
            p = mean(mean_sim <= 0);
        case 'right'
            error('Not implemented yet!');
    end
end
    