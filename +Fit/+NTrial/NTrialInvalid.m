classdef NTrialInvalid < Fit.Common.CommonWorkspace
methods
    function W = NTrialInvalid(varargin)
        W.set_Data(Fit.Common.DataChRtPdfRaw);
        W.tr_incl = [1 0];
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function batch(W0, varargin)
        S_batch = varargin2S(varargin, {
            'parad', Data.Consts.dtb_wSDT_parads_short
            'subj', Data.Consts.subjs
            });
        [Ss, n] = factorizeS(S_batch);
        
        ress = cell(n, 1);
        for ii = 1:n
            S = Ss(ii);
            C = S2C(S);
            W = feval(class(W0), C{:});
            
            res0 = struct;
            i_subj = find(strcmp(S.subj, Data.Consts.subjs));
            res0.Paradigm = S.parad;
            res0.Subject = sprintf('S%d', i_subj);
            res1 = W.main;
            res0 = copyFields(res0, res1);
            ress{ii} = res0;
        end
        ds = bml.ds.from_Ss(ress);
        for col = ds.Properties.VarNames(:)'
            for jj = 1:size(ds, 1)
                v = ds.(col{1}){jj};
                if isempty(v)
                    ds.(col{1}){jj} = '0 (0.00%)';
                end
            end
        end
        
        disp(ds);
        
        file = W0.get_file({
            'sbj', S_batch.subj
            'prd', S_batch.parad
            'tbl', 'timing'
            });
        mkdir2(fileparts(file));
        export(ds, 'File', [file, '.csv'], 'Delimiter', ',');
        fprintf('Saved to %s.csv\n', file);
    end
    function [res, ds] = main(W)
        %%
        ds0 = W.Data.ds0;
        incl = ~strcmp(ds0.flag_timing, 'user_stop');
        ds0 = ds0(incl, :);
        
        ds = tabulate(ds0.flag_timing);
        ds = [
            {'Type', 'NTrial', 'Percent'}
            ds];
        
        ds = cell2dataset(ds, ...
            'ReadVarNames', true, ...
            'ReadObsNames', false);
        
        res = struct;
        n_row = size(ds, 1);
        for ii = 1:n_row
            f = ds.Type{ii};
            res.(f) = sprintf('%d (%1.2f%%)', ...
                ds.NTrial(ii), ds.Percent(ii));
        end
        
        ds.Percent = vVec(csprintf('%1.2f%%', ds.Percent));
        disp(ds);
        
%         file = W.get_file({'tbl', 'timing'});
%         mkdir2(fileparts(file));
%         export(ds, 'File', [file, '.csv'], 'Delimiter', ',');
%         fprintf('Saved to %s.csv\n', file);
    end
end
end