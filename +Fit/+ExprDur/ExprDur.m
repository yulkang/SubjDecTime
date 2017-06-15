classdef ExprDur < Fit.Common.CommonWorkspace
properties
    parads = {
        'BeepOnly_longDelay4'
        'BeepFreeChoiceNoGo_longDelay4'
        'BeepFreeChoiceGo_longDelay4'
        'VD_woSDT'
        'VD_wSDT'
        'RT_wSDT'
        };
end
methods
    function main(W)
        %%
        subjs = Data.Consts.subjs(:);
        n_subj = numel(subjs);
        n_parad = numel(W.parads);
        
        Ls = cell(n_subj, n_parad);
        for i_subj = n_subj:-1:1
            subj = subjs{i_subj};
            
            for i_parad = 1:n_parad
                parad = W.parads{i_parad};
                file = fullfile('Data', 'Expr', [parad, '_orig_', subj]);
                
                Ls{i_subj, i_parad} = load(file);
            end
        end
        
        %%
        datestrs = cell(n_subj, 2);        
        days_unique = cell(n_subj, 1);
        n_days_visited = zeros(n_subj, 1);
        n_tr = zeros(n_subj, n_parad);
        
        for i_subj = n_subj:-1:1
            for i_parad = 1:n_parad
                L = Ls{i_subj, i_parad};
                datestr_on = L.obTr.datestr_on;
                
                if i_parad == 1
                    datestrs{i_subj, 1} = datestr_on{1};
                elseif i_parad == n_parad
                    datestrs{i_subj, 2} = datestr_on{end};
                end
                
                day1 = cell2mat(datestr_on);
                day1 = day1(:, 1:8);
                days_unique{i_subj} = [days_unique{i_subj}; unique(day1, 'rows')];
                
                n_tr(i_subj, i_parad) = numel(datestr_on);
            end
            n_days_visited(i_subj) = size(unique(days_unique{i_subj}, 'rows'), 1);
            
            datetime_st(i_subj,1) = min(datetime(cellstr(days_unique{i_subj}), ...
                'InputFormat', 'yyyyMMdd'));
            datetime_en(i_subj,1) = max(datetime(cellstr(days_unique{i_subj}), ...
                'InputFormat', 'yyyyMMdd'));
        end
        
        %%
        days_subj = round(days(datetime_en - datetime_st)) + 1;
        days_all = round(days(max(datetime_en) - min(datetime_st))) + 1;
        n_tr_all = sum(n_tr, 2);
        
        datestr_st = datestr(datetime_st, 'yyyymmdd');
        datestr_en = datestr(datetime_en, 'yyyymmdd');
        
        ds = dataset(subjs, datestr_st, datestr_en, days_subj, ...
            n_days_visited, n_tr_all);
        disp(ds);
        fprintf('Total duration (days):');
        disp(days_all);
        
        %%
        file = W.get_file({'sbj', subjs, 'prd', W.parads});
        mkdir2(fileparts(file));
        
        export(ds, 'File', [file, '.csv'], 'Delimiter', ',');
        fprintf('Saved to %s.csv\n', file);
        
        fid = fopen([file '.txt'], 'w');
        fprintf(fid, 'Total duration (days): %d\n', days_all);
        fclose(fid);
        fprintf('Saved to %s.txt\n', file);
        
    end
    function fs = get_file_fields(~)
        fs = {};
    end
end
end