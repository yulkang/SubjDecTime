classdef NTrial < Fit.Common.CommonWorkspace
methods
    function batch(W0, varargin)
        S_batch = varargin2S(varargin, varargin2S({
            'subj', Data.Consts.subjs
            'parad', Data.Consts.parads_short_all % {'VD_woSDT', 'VD_wSDT', 'RT_wSDT'}
            }, W0.get_S0_file));
        [Ss, n] = bml.args.factorizeS(S_batch);
        
        ds = bml.ds.from_Ss(Ss);
        
        for ii = n:-1:1
            S = Ss(ii);
            C = S2C(S);
            
            W = feval(class(W0), C{:});
            W.Data.load_data;
            
            % tr_incl is from 1 in non-wSDT paradigms.
            ds.tr_incl_1(ii,1) = W.Data.tr_incl(1);
            
            ds.n_tr_all(ii,1) = W.Data.n_tr0;
            ds.n_tr_used(ii,1) = W.Data.n_tr;
            ds.n_run(ii,1) = max(W.Data.ds0.i_all_Run);
            
            ds.subj{ii} = ds.subj{ii};
%             Ss(ii).subj = Ss(ii).subj;
        end
        
        %%
        file = W.get_file_compare_S0s(Ss);
        mkdir2(fileparts(file));
        fprintf('Saving results to %s.csv and .mat\n', file);
        export(ds, 'File', [file '.csv'], 'Delimiter', ',');
        save([file '.mat'], 'ds');
    end
    function W0 = NTrial(varargin)
        if nargin > 0
            W0.init(varargin{:});
        end
    end
end
end