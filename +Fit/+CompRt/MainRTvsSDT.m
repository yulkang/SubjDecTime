classdef MainRTvsSDT < Fit.Common.CommonWorkspace
properties
    rt_fields = {'RT', 'SDT_ClockOn'};
   
    Ws_class = 'Fit.CompRt.Main';
    Ws = {};
    
    % Results from ANOVA
    res_anova = struct;
    abs_cond = true;
    
    res_Fs = struct;
    
    ds_batch = dataset;
end
methods
    function S_batch = get_S_batch(~, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            'parad', Data.Consts.dtb_wSDT_parads_short
            'data_file_type', {'orig'}
            'abs_cond', {true, false}
            });
    end
    function batch(W0, varargin)
        S_batch = W0.get_S_batch(varargin{:});
        [Ss, n] = factorizeS(S_batch);
        
        ds_batch = dataset;
        for ii = n:-1:1
            S = Ss(ii);
            C = S2C(S);
            
            W = feval(class(W0));
            W.init(C{:});
            W.main;
            
            ds_batch = ds_set(ds_batch, ii, W.get_S0_file);
            
            c_res = varargin2S({
                'Fs', W.res_anova.Fs
                });
            ds_batch = ds_set(ds_batch, ii, c_res);
        end
        ds_batch.Fs = cell2mat2(ds_batch.Fs);
        W0.ds_batch = ds_batch;
        
        %%
        file = W0.get_file_batch(ds_batch, ...
            'add_fields', {'tab', 'comp'});
        fprintf('Saving to %s\n', file);
        export(ds_batch, 'File', [file '.csv'], 'Delimiter', ',');
        
        Fs = ds_batch.Fs;
        [p, h, stats] = signtest(Fs(:,1), Fs(:,2));
        med = median(Fs);
        W0.res_Fs.signtest = packStruct(p, h, stats);
        diary([file '.txt']);
        fprintf('Signtest: p=%1.2g, median: [%1.2f, %1.2f]\n', ...
            p, med(1), med(2));
        diary('off');
    end
end
methods
    function W = MainRTvsSDT(varargin)
        W.data_file_type = 'orig';
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
    function init(W0, varargin)
        W0.init@Fit.Common.CommonWorkspace(varargin{:});
        
        n_rt_fields = numel(W0.rt_fields);
        W0.Ws = cell(1, n_rt_fields);
        for ii = 1:n_rt_fields
            rt_field = W0.rt_fields{ii};
            C = varargin2C({'rt_field', rt_field}, W0.get_S0_file);
            W = feval(W0.Ws_class);
            W.init(C{:});
            
            W0.Ws{ii} = W;
        end
    end
    function res_anova = fit(W0)
        cond = [W0.Ws{1}.Data.cond; W0.Ws{2}.Data.cond];
        rt = [W0.Ws{1}.Data.rt; W0.Ws{2}.Data.rt];
        rt_type = [
            zeros(size(W0.Ws{1}.Data.ds, 1), 1)
            ones(size(W0.Ws{2}.Data.ds, 1), 1)
            ];
        
        if W0.abs_cond        
            x_cond = abs(cond);
            vnam = 'abs_cond';
        else
            x_cond = cond;
            vnam = 'cond';
        end
        x = [x_cond, rt_type];
        
        [p, tbl, stats, terms] = anovan(rt, x, ...
            'varnames', {vnam, 'rt_type'});
        
        for ii = 2:-1:1
            W0.Ws{ii}.fit;
            
            % CAUTION: comparing Fs is confusing because
            % larger F can be either due to 
            % larger gain or smaller dispersion 
            % of RT or SDT's dependence on coherence.
            Fs(ii) = W0.Ws{ii}.res_anova.tbl.F{1};
        end
        is_F_SDT_larger = Fs(2) > Fs(1);
        
        tbl = cell2ds2(tbl, 'get_rowname', true);
        res_anova = packStruct(p, tbl, stats, terms, ...
            Fs, is_F_SDT_larger);
        W0.res_anova = res_anova;
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
            {'rt_fields', 'rt_fields'}
            ];
        fs = fs(~strcmp(fs(:,1), 'rt_field'), :);
    end
end
end