classdef Main < Fit.Common.CommonWorkspace
properties
    res_anova = struct;
    abs_cond = true;
end
methods
    function S_batch = get_S_batch(~, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            'parad', Data.Consts.dtb_wSDT_parads_short
            'data_file_type', {'orig'}
            'rt_field', Data.Consts.rt_fields
            'abs_cond', {true, false}
            });
    end
    function batch(W0, varargin)
        S_batch = W0.get_S_batch(varargin{:});
        [Ss, n] = factorizeS(S_batch);
        
        for ii = 1:n
            S = Ss(ii);
            C = S2C(S);
            
            W = feval(class(W0));
            W.init(C{:});
            
            W.main;
        end
    end
end
methods
    function W = Main(varargin)
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function main(W, varargin)
        %%
        if nargin > 0
            W.init(varargin{:});
        end
        
        W.fit;
        W.save_res;
    end
    function res_anova = fit(W)
        if W.abs_cond        
            x = abs(W.Data.cond);
            vnam = 'abs_cond';
        else
            x = W.Data.cond;
            vnam = 'cond';
        end
        
        rt = W.Data.rt;
        
        [p, tbl, stats, terms] = anovan(rt, x, ...
            'varnames', {vnam});
        tbl = cell2ds2(tbl, 'get_rowname', true);
        res_anova = packStruct(p, tbl, stats, terms);
        W.res_anova = res_anova;
    end
    function save_res(W)
        file = W.get_file;
        res_anova = W.res_anova;
        
        mkdir2(fileparts(file));
        export(res_anova.tbl, 'File', [file '.csv'], 'Delimiter', ',');
        
        fprintf('Saving to %s\n', file);
        save(file, 'W', 'res_anova', 'file');
    end
    function fs = get_file_fields(W)
        fs = [
            W.get_file_fields@Fit.Common.CommonWorkspace
            {'abs_cond', 'abs_cond'}
            ];
    end
end
end