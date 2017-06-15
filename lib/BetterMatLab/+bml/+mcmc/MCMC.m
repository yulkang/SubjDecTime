classdef MCMC < DeepCopyable
properties (Abstract)
    fun_nll_targ % function(th) % neg log likelihood
    fun_proposal % function(th_src, n) % gives th_mat
    fun_nll_proposal % function(th_src, th_dst) % gives p (column vec)
    
    th0
    
    n_samp
    n_samp_max
    n_samp_burnin
    
    th_now
    nll_now
    
    th_samp
end
methods (Abstract)
    init(MC, varargin)
    main(MC)
    append(MC, n_samp)
end
methods
    function samp = get_proposal(MC, th_src, n)
        samp = MC.fun_proposal(th_src, n);
    end
    function nll = get_nll_proposal(MC, th_src, th_dst)
        nll = MC.fun_nll_proposal(th_src, th_dst);
    end
    function nll = get_nll_targ(MC, th)
        nll = MC.fun_nll_targ(th);
    end
end
end