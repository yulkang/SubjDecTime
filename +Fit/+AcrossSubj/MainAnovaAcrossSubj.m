classdef MainAnovaAcrossSubj < Fit.Common.CommonWorkspace
methods
    function W = MainAnovaAcrossSubj(varargin)
        W.parad = 'VD_wSDT';
        W.rt_field = 'SDT_ClockOn';
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function main(W0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            'parad', W0.parad
            });
        [Ss, n] = factorizeS(S_batch);
        
        %% Load data
        sdts = cell(n, 1);
        ad_conds = cell(n, 1);
        subjs = cell(n, 1);
        
        for ii = 1:n
            S = Ss(ii);
            C = S2C(S);
            W = feval(class(W0), C{:});
            
            % W.Data.rt
            % : depending on W.Data.rt_field, 'SDT_ClockOn' or 'RT'.
            sdts{ii} = W.Data.rt;
            ad_conds{ii} = W.Data.ad_cond;
            
            n_tr = numel(sdts{ii});
            subjs{ii} = zeros(n_tr,1) + ii;
        end
        sdt_vec = vVec(cell2vec(sdts));
        ad_cond_vec = vVec(cell2vec(ad_conds));
        subjs_vec = vVec(cell2vec(subjs));
        
        %%
        [p, tbl, stats] = anovan(sdt_vec, {ad_cond_vec, subjs_vec}, ...
            'VarNames', {'Absolute Coherence', 'Subject'});
        
        %%
        file = W0.get_file({
            'sbj', S_batch.subj
            });
        mkdir2(fileparts(file));
        
        ds = cell2dataset(tbl);
        export(ds, 'File', [file, '.csv'], 'Delimiter', ',');
        fprintf('Saved to %s.csv\n', file);
        
        L = packStruct(p, tbl, stats, sdt_vec, ad_cond_vec, subjs_vec);
        save(file, '-struct', 'L');
        fprintf('Saved to %s.mat\n', file);
    end
end 
end