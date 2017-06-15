classdef CorrCohSdtGroup < Fit.Common.CommonWorkspace
methods
    function W = CorrCohSdtGroup(varargin)
        W.parad = 'VD_wSDT';
        W.rt_field = 'SDT_ClockOn';
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function [b, x, y] = main(W)
        %%
        x = abs(W.Data.ds.cond);
        y = W.Data.rt; % depends on rt_field
        
        b = glmfit(x, y, 'normal');
    end
    function batch(W0, varargin)
        %%
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            });
        [Ss, n] = factorizeS(S_batch);
        
        b = nan(n, 2);
        x = cell(n, 1);
        y = cell(n, 1);
        
        for ii = 1:n
            S = Ss(ii);
            C = S2C(S);
            W = feval(class(W0), C{:});
            [b(ii,:), x{ii}, y{ii}] = W.main;
        end
        
        [~, p, ~, stats] = ttest(b(:,2));
        
        %%
        subj = S_batch.subj(:);
        bias = b(:,1);
        slope = b(:,2);
        
        file = W0.get_file({
            'sbj', S_batch.subj
            'prd', W.parad
            });
        mkdir2(fileparts(file));
        
        ds = dataset(subj, bias, slope);
        export(ds, 'File', [file, '.csv'], 'Delimiter', ',');
        
        fid = fopen([file, '.txt'], 'w');
        fprintf(fid, 'T(%d)=%1.3f, p=%1.2g\n', ...
            stats.df, stats.tstat, p);
        fclose(fid);
        fprintf('Saved to %s.csv and .txt\n', file);
    end
    function fs = get_file_fields(W0)
        fs = {};
    end
end
end