classdef NTrialNoDecision < Fit.Common.CommonWorkspace
methods
    function batch(W0, varargin)
        S_batch = varargin2S(varargin, {
            'parad', Data.Consts.dtb_wSDT_parads_short
            'subj', Data.Consts.subjs
            'incl_tRDK2Go_msec', {'all'}
            'incl_tRDKDur_msec', {800, 200}
            });
        S0 = W0.get_S0_file;
        
        [Ss, n] = factorizeS(S_batch);
        ress = cell(n, 1);
        txts = cell(n, 1);
        incl = true(n, 1);
        
        for ii = 1:n
            S = Ss(ii);
            S1 = varargin2S(Ss(ii), S0);
            C1 = S2C(S1);
            
            if strcmp(S.parad, 'RT_wSDT')
                if ~isequal(S.incl_tRDKDur_msec, ...
                                S_batch.incl_tRDKDur_msec{1})
                    incl(ii) = false;
                    continue;
                else
                    S.incl_tRDKDur_msec = 'all';
                end
            end

            W = feval(class(W0));
            W.Data.init( ...
                'to_exclude_no_sdt', false, ...
                'to_exclude_no_decision', false);
            W.init(C1{:});
            W.Data.load_data;

            ds0 = W.Data.ds;
    %             ds0 = W.Data.ds0(W.Data.tr_incl_mlab(1):end,:);

            res1 = struct;
            res1 = copyFields(res1, S);

            txt1.paradigm = res1.parad(1:2);

            i_subj = find(strcmp(S.subj, S_batch.subj));
            txt1.subject = sprintf('S%d', i_subj);
            
            txt1.RDM_duration = res1.incl_tRDKDur_msec;
            txt1.delay = res1.incl_tRDK2Go_msec;
            
            res1.n_undecided = nnz(ds0.undecided & ds0.succT);
            res1.n_didntSee = nnz(ds0.didntSee & ds0.succT);
            res1.n_total_succT = nnz(ds0.succT);
            for kind = {'undecided', 'didntSee'}
                res1.(['prct_' kind{1}]) = ...
                    res1.(['n_' kind{1}]) ...
                    / res1.n_total_succT * 100;
                
                txt1.(kind{1}) = sprintf('%d (%1.2g%%)', ...
                    res1.(['n_' kind{1}]), ...
                    res1.(['prct_' kind{1}]));
            end
            txt1.total = sprintf('%d', res1.n_total_succT);
            ress{ii} = res1;
            txts{ii} = txt1;
        end
        
        ress = ress(incl);
        txts = txts(incl);
        ds_txt = bml.ds.from_Ss(txts);
        disp(ds_txt);
        
        %%
        file = W0.get_file({
            'sbj', S_batch.subj
            'prd', S_batch.parad
            'dur', S_batch.incl_tRDKDur_msec
            'dly', S_batch.incl_tRDK2Go_msec
            });
        mkdir2(fileparts(file));
        fprintf('Saving results to %s.csv and .mat\n', file);
        export(ds_txt, 'File', [file '.csv'], 'Delimiter', ',');
        save([file '.mat'], 'ds_txt', 'ress');
    end
    function W0 = NTrialNoDecision(varargin)
        if nargin > 0
            W0.init(varargin{:});
        end
    end
end
end