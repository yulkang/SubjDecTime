classdef CorrCohSdt < Fit.Common.CommonWorkspace
methods
    function W = CorrCohSdt(varargin)
        W.rt_field = 'SDT_ClockOn';
        W.parad = 'VD_wSDT';
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function res = main(W)
        coh = abs(W.Data.cond);
        sdt = W.Data.rt;
        [rho, pval] = corr(coh, sdt, 'type', 'Spearman');
        res = packStruct(rho, pval);
    end
    function batch(W0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            'parad', 'VD_wSDT';
            });
        [Ss, n] = factorizeS(S_batch);
        
        ress = cell(n, 1);
        for ii = 1:n
            S = Ss(ii);
            C = S2C(S);
            W = feval(class(W0), C{:});
            res = W.main;
            
            ress{ii} = res;
        end
        ds_txt = bml.ds.from_Ss(ress);
        
        file = W0.get_file_from_S0(varargin2S(S_batch, W0.get_S0_file));
        mkdir2(fileparts(file));
        export(ds_txt, 'file', [file, '.csv'], 'Delimiter', ',');
        fprintf('Saved to %s.csv\n', file);
    end
end
end