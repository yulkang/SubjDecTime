classdef CrossvalFl < bml.oop.PropFileNameTree
%% Settings
properties (SetAccess = protected)
    Fl = []; % FitFlow;
    W = []; % FitWorkspace
end
properties
    % op:
    % 'Kfold'
    % 'KfoldCont' % Contiguous blocks
    op = 'KfoldCont';
    n_set = 2;
    n_dat = 0;
    p_holdout = 0.5;
    group = []; % (tr) = group_id

    file_orig = ''; % Processing an existing file.
    
    % files_ix{i_set}:
    % If nonempty, store indices per i_set.
    files_ix = {}; 
    
    % files_res{i_set}:
    % If nonempty, store results per i_set.
    files_res = {}; 
    
    % to_inherit_th0
    % : if true, use Cv.Fl.res.th as each Fl's new th0
    to_inherit_th0 = true; 
    
    parallel_mode = 'none'; % 'none' or 'set'
    
    % estimate_params 
    % : if false (default), use Cv.Fl.res as Cv.res_all_data.
    % : if true, fit with all data after cross-validation.
    estimate_params = false;
    
    % fit_opts : fit option, e.g., MaxIter
    fit_opts = {
        'UseParallel', 'always'
%         'FiniteDifferenceStepSize', sqrt(eps) * 10
        };
end
%% Internal
properties    
    ix_all_data = []; % numerical index.
    ix_train = {}; % {set}(k) = tr
    ix_test = {}; % {set}(k) = tr
    
    % Deprecated: file.
%     file = ''; % Storing indicies. If given, load if exists, save if absent.
end
%% Results
properties
    res = struct;
    res_all_data = struct;
    ress = {};
end
%% Main methods
methods
    function Cv = CrossvalFl(varargin)
        if nargin > 0
            Cv.init(varargin{:});
        end
    end
    function init(Cv, Fl, varargin)
        bml.oop.varargin2props(Cv, varargin);
        Cv.set_Fl(Fl);
        
        if ~isempty(Cv.group) && ~isempty(Cv.Fl)
            assert(length(Cv.group) == Cv.n_dat);
        end
        
        Cv.calc_ix;
    end
    function set_Fl(Cv, Fl)
        Cv.Fl = Fl;
        Cv.W = Fl.W;
        if ~isempty(Fl)
            Cv.ix_all_data = Fl.W.Data.get_dat_filt_numeric;
            Cv.n_dat = length(Cv.ix_all_data);
            
            if ~Cv.estimate_params
                Cv.res_all_data = Cv.Fl.res;
            end
        end
    end
    function res = fit(Cv)
        res = Cv.fit_Fl;
    end
    function calc_ix(Cv)
        if ~isempty(Cv.ix_train) && ~isempty(Cv.ix_test)
            % If indices are already given, skip calculating.
            return;
        else
            Cv.reset_ix;
        end
        
        switch Cv.op
            case 'Kfold'
                % Cannot be done incrementally.
                % Just use file_ix{1}.
                file = Cv.files_ix{1};
                
                if exist(file, 'file')
                    L = load(file);
                    if all(isfield(L, {'ix_all_data', 'ix_train', 'ix_test'})) ...
                            && isequal(L.ix_all_data, Cv.ix_all_data)

                        for fs = {'ix_train', 'ix_test'}
                            Cv.(fs{1}) = L.(fs{1});
                        end

                        fprintf('crossval indices loaded from %s\n', file);

                        return;
                    else
                        error([
                            'crossval indices are incompatible! ' ...
                            'Delete %s and rerun.\n'], Cv.file);
                    end
                end
                
                % If absent, make the sets.
                if ~isempty(Cv.group)
                    ix = crossvalind('Kfold', Cv.group, Cv.n_set);
                else
                    ix = crossvalind('Kfold', Cv.n_dat, Cv.n_set);
                end
                for i_set = Cv.n_set:-1:1
                    Cv.ix_test{i_set} = find(ix == i_set);
                    Cv.ix_train{i_set} = find(ix ~= i_set);
                end
                
                % Save if file name is specified.
                if ~isempty(file)
                    mkdir2(fileparts(file));
                    L = copyFields(struct, Cv, {
                        'ix_all_data', 'ix_train', 'ix_test'
                        }); %#ok<NASGU>
                    save(file, '-struct', 'L');
                    fprintf('crossval indices saved to %s\n', file);
                end
                
            case 'KfoldCont'
                % Does not need saving index, since it is deterministic.
                n_tr = size(Cv.Fl.W.Data.ds, 1);
                st = floor(((1:Cv.n_set) - 1) ./ Cv.n_set .* n_tr) + 1;
                en = [st(2:end) - 1, n_tr];
                ix0 = 1:n_tr;                
                
                Cv.ix_test = cell(1, Cv.n_set);
                Cv.ix_train = cell(1, Cv.n_set);
                for i_set = Cv.n_set:-1:1
                    Cv.ix_test{i_set} = st(i_set):en(i_set);
                    Cv.ix_train{i_set} = setdiff(ix0, Cv.ix_test{i_set});
                end
                
            case 'Holdout'
                % Incremental calculation and cacheing.
                % If n_set is larger than previous, calculates a new one.
                % If not, loads previous.
                for i_set = Cv.n_set:-1:1
                    Cv.calc_ix_unit(i_set);
                end
                
            otherwise
                error('Unsupported yet!');
        end
                
        Cv.test_calc_ix;
    end
    function calc_ix_unit(Cv, i_set)
        if numel(Cv.file_ix) >= i_set
            file = Cv.file_ix{i_set};
        else
            file = '';
        end
        
        if exist(file, 'file')
            L = load(file);
            if all(isfield(L, {'ix_all_data', 'ix_train', 'ix_test'})) ...
                    && isequal(L.ix_all_data, Cv.ix_all_data)
            	
                for fs = {'ix_train', 'ix_test'}
                    Cv.(fs{1}){i_set} = L.(fs{1});
                end
                
                fprintf('crossval indices for i_set = %d loaded from %s\n', ...
                    i_set, file);
                
                return;
            else
                error([
                    'crossval indices for i_set = %d are incompatible! ' ...
                    'Delete %s and rerun.\n'], i_set, Cv.file);
            end
        end
        
        switch Cv.op
            case 'Holdout'
                if ~isempty(Cv.group)
                    [ix_train, ix_test] = crossvalind('Holdout', Cv.group, ...
                        Cv.p_holdout);
                else
                    [ix_train, ix_test] = crossvalind('Holdout', Cv.n_dat, ...
                        Cv.p_holdout);
                end

                Cv.ix_test{i_set} = find(ix_test);
                Cv.ix_train{i_set} = find(ix_train);
                
            otherwise
                error('op=%s doesn''t support incremental calculation!', ...
                    Cv.op);
        end
        
        % Save if file name is specified.
        if ~isempty(file)
            L.ix_all_data = Cv.ix_all_data;
            L.ix_train = ix_train;
            L.ix_test = ix_test; %#ok<STRNU>

            mkdir2(fileparts(file));
            save(file, '-struct', 'L');
            fprintf('crossval indices saved to %s\n', file);
        end
    end
    function test_calc_ix(Cv)
        %%
        if isempty(Cv.group)
            return;
        end
        
        n0 = length(Cv.ix_all_data);
        tab0 = tabulate(Cv.group);
        
        for i_set = 1:Cv.n_set
            ix_test = Cv.ix_test{i_set};
            ix_train = Cv.ix_train{i_set};
            
            assert(length(ix_test) + length(ix_train) == n0);
        
            tab1 = tabulate(Cv.group(ix_train));
            tab2 = tabulate(Cv.group(ix_test));
            
            %%
            if Cv.n_set == 2
                assert(all(tab1(:,2) + tab2(:,2) == tab0(:,2)));
                assert(max(abs(tab1(:,2) - tab2(:,2))) == 1);
            end
        end
    end
    function reset_ix(Cv)
        Cv.ix_train = {};
        Cv.ix_test = {};
    end
    function res = fit_Fl(Cv)
        ress = cell(1, Cv.n_set);
        if strcmp(Cv.parallel_mode, 'set')
            parfor i_set = 1:Cv.n_set
                ress{i_set} = Cv.fit_Fl_unit(i_set);
            end
        else
            for i_set = 1:Cv.n_set
                t_st = tic;
                fprintf( ...
                    '---- Cross-validation set %d/%d began at %s\n', ...
                    i_set, Cv.n_set, datestr(now, 30));
                ress{i_set} = Cv.fit_Fl_unit(i_set);
                t_el = toc(t_st);
                fprintf( ...
                    ['---- Cross-validation set %d/%d took %1.1fs, ', ...
                     'finished at %s\n'], ...
                    i_set, Cv.n_set, t_el, datestr(now, 30));
                
                Cv.ress{i_set} = ress{i_set};
            end
        end
        Cv.ress = ress;
        res = Cv.fit_postprocess(ress); % Get res from ress
        Cv.res = res;
    end
    function res = fit_Fl_unit(Cv, i_set)
        % Get filters
        ix_all_data = Cv.ix_all_data;
        ix_train = Cv.ix_train{i_set};
        ix_test = Cv.ix_test{i_set};

        % L0: indices used to validate match with saved results.
        L0 = packStruct(ix_all_data, ix_train, ix_test);
        
        % Indices actually used in the fit, as in files_ix.
        ix0_train = ix_all_data(ix_train);
        ix0_test = ix_all_data(ix_test);
        
        % Load results if file name is given and the file exists
        if numel(Cv.files_res) >= i_set
            file = Cv.files_res{i_set};
        else
            file = '';
        end
        if exist(file, 'file')
            L = load(file);
            for fs = {'ix_all_data', 'ix_train', 'ix_test'}
                assert(isequal(L.(fs{1}), L0.(fs{1})), ...
                    'Discrepancy in %s: %s\n', file, fs{1});
            end
            
            % If no discrepancy is found, reuse the result.
            res = L.res;
            return;
        end
        
        % Train model
        Fl = Cv.Fl.deep_copy;
        
        if Cv.to_inherit_th0
            Fl.W.th0 = Cv.Fl.res.th;
            Fl.W.th = Fl.W.th0;
        end
        
        Fl.W.Data.set_filt_spec(ix0_train);
        res = Fl.fit('opts', Cv.fit_opts);
        
        res.fval_train = res.fval;
        
        % Validate model
        Fl.W.Data.set_filt_spec(ix0_test);
        res.fval_test = Fl.W.get_cost;
        
        res.fval = res.fval_test;
        
        % Save results if file name is given
        if ~isempty(file)
            mkdir2(fileparts(file));
            
            L0.res = res;
            save(file, '-struct', 'L0');
            fprintf('Saved results for i_set=%d to %s\n', i_set, file);
        end
        
        % Recover data filter
        Fl.W.Data.set_filt_spec(ix_all_data);
    end
    function res = fit_postprocess(Cv, ress)
        if Cv.estimate_params
            Cv.res_all_data = Fl.fit;
        else
            % Assume that res_all_data is set in set_Fl.
        end
        
        res = Cv.res_all_data;
        
        res.fval_train = cellfun(@(S) S.fval_train, Cv.ress);
        res.fval_test = cellfun(@(S) S.fval_test, Cv.ress);
        res.fval = nanmean(res.fval_test);
        
        res.CrossvalFl = bml.oop.copyprops(struct, Cv, ...
            'skip_internal', true);
        
        res = Cv.Fl.calc_ic(res);
        Cv.res = res;
    end
end
%% Fit a file and save it
methods
    function fit_file(Cv, file0, varargin)
        Cv.file_orig = file0;
        L = load(file0);
        Fl = L.Fl;
        Fl.res2W;
        Cv.init(Fl, varargin{:});

        Cv.fit;
        
        Cv.save_mat;
    end
    function save_mat(Cv)
        file = Cv.get_file;
        L = packStruct(Cv);
        L = copyFields(L, Cv, {'res', 'ress', 'W', 'Fl'}); %#ok<NASGU>
        mkdir2(fileparts(file));
        save(file, '-struct', 'L');
        fprintf('Saved to %s\n', file);
    end
    function Cv = load_mat(Cv0, file)
        if nargin < 2
            file = Cv0.get_file;
        end
        L = load(file);
        Cv = L.Cv;
    end
    function S_file = get_S_file(Cv, varargin)
        if isempty(Cv.file_orig)
            S_file = struct;
        else
            [~, nam] = fileparts(Cv.file_orig);
            S2s = bml.str.Serializer;
            S_file = S2s.convert(nam);
        end
        
        S1_file = varargin2S({
            'cvk', Cv.op
            });
        
        switch Cv.op
            case 'HoldOut'
                S1_file.pho = round(Cv.p_holdout * 100);
            case {'Kfold', 'KfoldCont'}
                S1_file.ncv = Cv.n_set;
        end
                
        S_file = copyFields(S_file, S1_file);
    end
    function file = get_file(Cv, varargin)
        file = Cv.get_file@bml.oop.PropFileNameTree(varargin{:});
        [pth, nam] = fileparts(file);
        
        if ~isempty(Cv.W)
            file = fullfile(pth, class(Cv.W), nam);
        end
    end
end
end