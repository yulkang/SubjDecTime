classdef CorrSdtRt < Fit.Common.CommonWorkspace
%% Internal
properties (Transient)
    Ws = {}; % {subj,1}
end
%% Results
properties
    res_corr = struct;
    res_glmfit = struct;
    
    ds_txt = dataset;
end
methods
    function W = CorrSdtRt(varargin)
        W.parad = 'RT_wSDT';
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function main(W)
        sdt = W.Data.ds.SDT_ClockOn;
        rt = W.Data.ds.RT;
        [rho, pval] = corr(rt, sdt);
        res_glmfit = glmwrap(rt, sdt, 'normal');
        
        W.res_corr = packStruct(rho, pval);
        W.res_glmfit = res_glmfit;
    end
end
%% Batch
methods
    function batch(W0, varargin)
        %%
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            });
        [Ss, n] = factorizeS(S_batch);
        S0 = W0.get_S0_file;
        
        Ws = cell(n, 1);
        ress = cell(n, 1);
        
        for ii = 1:n
            S = varargin2S(Ss(ii), S0);
            C = S2C(S);
            
            W = feval(class(W0), C{:});
            W.main;
            Ws{ii} = W;
            
            res1 = struct;
            res1.subj = sprintf('S%d', ii);
            res1.rho = sprintf('%1.2f (p=%1.2g)', ...
                W.res_corr.rho, W.res_corr.pval);
            
            f_beta = @(b) sprintf('%1.2f +- %1.2f (p=%1.2g)', ...
                W.res_glmfit.b(b), W.res_glmfit.se(b), W.res_glmfit.p(b));
            res1.b0 = f_beta(1);
            res1.b1 = f_beta(2);
            
            ress{ii} = res1;
        end
        
        W0.Ws = Ws;
        ds_txt = bml.ds.from_Ss(ress);
        W0.ds_txt = ds_txt;
        
        disp(ds_txt);
        
        %%
        file = W0.get_file({
            'sbj', S_batch.subj
            'tbl', 'corr_glmfit'
            });
        mkdir2(fileparts(file));
        save([file, '.mat'], 'ress', 'ds_txt');
        export(ds_txt, 'file', [file '.csv'], 'Delimiter', 'tab');
        fprintf('Saved to %s.csv and .mat\n', file);
    end
end
end