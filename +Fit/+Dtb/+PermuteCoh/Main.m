classdef Main < Fit.Dtb.Main
    % Fit.Dtb.PermuteCoh.Main
    
%% == Individual permutation
properties
    n_perm = 401;
    
    % ix_perm_cond{1, perm}(c, 1) : condition index of perm-th permutation.
    % conds(ix_perm_cond{perm}(c)) == conds0(c)
    % choice and RT remain unchanged.
    ix_perm_cond = {}; 
    
    % ix_perm_tr{1, perm}(tr, 1) : trial index of perm-th permutation.
    % cond(ix_perm_tr{perm}(tr)) == cond0(tr)
    % choice and RT remain unchanged.
    ix_perm_tr = {};
    
    % res_perm{1, perm} : results from perm-th permutation.
    res_perm = {}; 
    
    to_overwrite_fit_perm = false;
    
    abs_cond = true;
    parallel_mode = 'perm';
    
    W_fit = Fit.Dtb.Main;
end
properties (Dependent)
    % Number of conditions used in permutation. Depends on abs_cond.
    n_cond_perm 
    
    W_fit_class
    W_fit_cl % strrep(W_fit_class, '.', '_') to use in file names
end
%% == Batch Facades
methods
    function batch_meanRt_sdt_ch(W0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs_wo_SDT_modul
            'W_fit_class', 'Fit.Dtb.MeanRt.Main'
            'n_tnd', 1
            'bias_cond_from_ch', false
            'to_determine_accu_from_bias_ch', true
            'ignore_choice', false
            'tnd_bayes', 'none'
            'bound_shape', 'const'
            });
        C_batch = S2C(S_batch);
        
        W0.batch(C_batch{:});
    end
    function batch_meanRt(W0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs_w_SDT_modul
            'W_fit_class', 'Fit.Dtb.MeanRt.Main'
            'n_tnd', 1
            'bias_cond_from_ch', false
            'to_determine_accu_from_bias_ch', true
            'ignore_choice', true
            'tnd_bayes', 'none'
            'bound_shape', 'const'
            });
        C_batch = S2C(S_batch);
        
        W0.batch(C_batch{:});
    end
    function batch_collapsing_bound(W0, varargin)
        S_batch = varargin2S(varargin, {
            'W_fit_class', 'Fit.Dtb.Main'
            'parad', {'VD_wSDT'}
            'rt_field', {'SDT_ClockOn'}
            'n_tnd', 1
            'tnd_distrib', 'gamma'
            'tnd_bayes', 'none'
            });
        C_batch = S2C(S_batch);        
        W0.batch(C_batch{:});
        
        S_batch = varargin2S(varargin, {
            'W_fit_class', 'Fit.Dtb.Main'
            'parad', {'RT_wSDT'}
            'rt_field', {'RT'}
            'n_tnd', 2
            'tnd_distrib', 'gamma'
            'tnd_bayes', 'none'
            });
        C_batch = S2C(S_batch);        
        W0.batch(C_batch{:});
    end
    function batch(W0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            'parad', {'VD_wSDT'}
            'data_file_type', {'orig'}
            'rt_field', {'SDT_ClockOn'}
            'n_tnd', 2
            });
        [Ss, n_batch] = bml.args.factorizeS(S_batch);
        
        for i_batch = 1:n_batch
            S = Ss(i_batch);
            C = S2C(S);
            
            W = feval(class(W0));
            W.init(C{:});
            W.main;
        end
    end
end
%% == Main
methods
    function W = Main(varargin)
        W.parad = 'VD_wSDT';
        W.tnd_distrib = 'normal';
        if nargin > 0
            W.init(varargin{:});
        end
        W.add_children_props({'W_fit'}); % Share Data with W_fit
    end
    function main(W0, varargin)
        rng('shuffle');
        ix_perm_tr = W0.get_ix_perm_tr;
        
        res_perm = cell(1, W0.n_perm);
        C = S2C(W0.get_S0_file);
        
        if strcmp(W0.parallel_mode, 'perm')
            parfor i_perm = 1:W0.n_perm
                W = feval(class(W0), C{:}); %#ok<PFBNS>

                res_perm{i_perm} = ...
                    W.get_res_perm(ix_perm_tr{i_perm}, i_perm);

                W.save_fit_perm(i_perm, res_perm{i_perm}, ix_perm_tr{i_perm});
            end
        else
            for i_perm = W0.n_perm:-1:1
%                 W = feval(class(W0), C{:});

                res_perm{i_perm} = ...
                    W0.get_res_perm(ix_perm_tr{i_perm}, i_perm);

                W0.save_fit_perm(i_perm, res_perm{i_perm}, ix_perm_tr{i_perm});
            end
        end
        W0.res_perm = res_perm;
    end
    function init(W, varargin)
        W.init@Fit.Dtb.Main(varargin{:});
        W.W_fit.init(varargin{:});
    end
end
%% ---- Get permutations
methods
    function ix_perm_tr = get_ix_perm_tr(W)
        n_perm = W.n_perm;
        ix_perm_tr = cell(1, n_perm);
        ix_perm_cond = cell(1, n_perm);
        
        % Do not parallelize, to preserve randomness.
        fprintf('Getting ix_perm (o: loaded, v: created and saved): ');
        for i_perm = 1:n_perm
            [ix_perm_tr{i_perm}, ix_perm_cond{i_perm}] = ...
                W.get_ix_perm_unit(i_perm);
            
            if mod(i_perm, 50) == 0
                fprintf('%d\n', i_perm);
            end
        end
        W.ix_perm_tr = ix_perm_tr;
        W.ix_perm_cond = ix_perm_cond;
        
        fprintf('\nDone.\n');
    end
    function [ix_perm_tr, ix_perm_cond] = get_ix_perm_unit(W, i_perm)
        ix_tr0 = W.Data.get_dat_filt_numeric;
        
        % If file exists, load it.
        file = W.get_file_ix_perm(i_perm);
        if exist([file '.mat'], 'file')
            fprintf('o');
            
            L = load(file, 'i_perm', 'ix_perm_tr', 'ix_perm_cond');
            assert(i_perm == L.i_perm);
            ix_perm_tr = L.ix_perm_tr;
            ix_perm_cond = L.ix_perm_cond;
            
            return;
        end
        
        % Otherwise, make one and save.
        fprintf('v');
        if i_perm == 1
            % If i_perm == 1, use the original.
            ix_perm_cond = (1:W.n_cond_perm)';
            ix_perm_tr = ix_tr0;
        else
            if W.balance
                % Permute condition and then within each condition.
                ix_perm_cond = vVec(randperm(W.n_cond_perm));
                ix_perm_tr = zeros(size(ix_tr0));

                cond0 = W.Data.cond;
                corrAns0 = W.Data.ds.corrAns;

                n_cond = size(ix_perm_cond, 1);

                if W.abs_cond
                    [~,~,d_cond0] = unique(abs(cond0));

                    for corrAns = hVec(unique(corrAns0))
                        incl_corrAns = corrAns0 == corrAns;

                        for cond = 1:n_cond
                            src = find((d_cond0 == cond) & incl_corrAns);
                            dst = (d_cond0 == ix_perm_cond(cond)) ...
                                & incl_corrAns;

                            n_incl = length(src);
                            src = src(randperm(n_incl));
                            ix_perm_tr(dst) = ix_tr0(src);
                        end
                    end
                else
                    [~,~,d_cond0] = unique([cond0, corrAns0], 'rows');

                    for cond = 1:n_cond
                        src = find(d_cond0 == cond);
                        dst = d_cond0 == ix_perm_cond(cond);

                        n_incl = length(src);
                        src = src(randperm(n_incl));
                        ix_perm_tr(dst) = ix_tr0(src);
                    end
                end
            else
                % Permute ignoring conditions
                ix_perm_cond = nan(W.n_cond_perm, 1);
                ix_perm_tr = vVec(ix_tr0(randperm(numel(ix_tr0))));
            end

%             % DEBUG
%             plot(ix_tr0, ix_perm_tr(:,1), 'o');
%             nnz(ix_perm_tr(:,1) == 0)
        end
        
        % Save
        mkdir2(fileparts(file));
        save(file, 'i_perm', 'ix_perm_tr', 'ix_perm_cond');
    end
    function n_cond_perm = get.n_cond_perm(W)
        if W.abs_cond
            n_cond_perm = W.Data.na_cond;
        else
            n_cond_perm = ...
                length(unique([W.Data.cond, W.Data.ds.corrAns], 'rows'));
        end
    end
    function file = get_file_ix_perm(W, i_perm)
        nam = W.Data.get_file_name({'iprm', i_perm, 'absc', W.abs_cond});
        file = fullfile('Data', class(W), 'ix_perm', nam);
    end
end
%% ---- Fit permuted trials
methods
    function [res, ix_perm_tr] = get_res_perm(W, ix_perm_tr, i_perm)
        % Load if present
        file = W.get_file_fit_perm(i_perm);
        if exist([file '.mat'], 'file') && ~W.to_overwrite_fit_perm
            L = load(file, 'res', 'ix_perm_tr');
            assert(isequal(ix_perm_tr, L.ix_perm_tr));
            res = L.res;
            return;
        end
        
        % Fit if absent
        res = W.fit_perm(ix_perm_tr);
    end
    function res = fit_perm(W, ix_perm_tr)
        ix_tr0 = (1:length(W.Data.get_dat_filt_numeric))';
        ix_perm_tr = bml.matrix.rankdim(ix_perm_tr(:), 1);
        
        W.W_fit.init;
        W.W_fit.Data.rt = W.Data.rt(ix_perm_tr);
        
        [~, res] = W.fit;
        
        W.Data.rt = W.Data.rt(ix_tr0);
    end
    function [Fl, res] = fit(W, varargin)
        [Fl, res] = W.W_fit.fit(varargin{:});
    end
    function save_fit_perm(W, i_perm, res, ix_perm_tr)
        file = W.get_file_fit_perm(i_perm);
        fprintf('Saving to %s\n', file);
        mkdir2(fileparts(file));
        save(file, 'i_perm', 'ix_perm_tr', 'res');
    end
    function file = get_file_fit_perm(W, i_perm)
        nam = W.get_file_name({'iprm', i_perm});
        file = fullfile('Data', class(W), 'fit_perm', nam);
    end
    function fs = get_file_fields(W)
        fs = [
            W.get_file_fields@Fit.Dtb.Main
            {'abs_cond',  'absc'}
            {'W_fit_class',  'ftcl'}
            ]; 
    end
end
%% ---- Interface to W_fit
methods
    function v = get.W_fit_class(W)
        v = class(W.W_fit);
    end
    function v = get.W_fit_cl(W)
        v = strrep(W.W_fit_class, '.', '_');
    end
    function set.W_fit_class(W, v)
        if ~strcmp(class(W.W_fit), v)
            W.W_fit = feval(v);
            W.add_children_props({'W_fit'});
        end
    end
end
%% == Load results
methods
    function [res_perm, ix_perm_tr, ix_perm_cond] = load_res_perm(W)
        fprintf('\n');
        fprintf('Loading permuted fits from %d files.\n', W.n_perm);
        fprintf('Last index file: %s\n', W.get_file_ix_perm(W.n_perm));
        fprintf('Last fit file: %s\n', W.get_file_fit_perm(W.n_perm));
        fprintf('\n');
        
        for i_perm = W.n_perm:-1:1
            file_ix = W.get_file_ix_perm(i_perm);
            L = load(file_ix);
            ix_perm_cond{i_perm} = L.ix_perm_cond;            
            
            file_res = W.get_file_fit_perm(i_perm);
            L = load(file_res);
            
            ix_perm_tr{i_perm} = L.ix_perm_tr;
            res_perm{i_perm} = L.res;
        end
    end
end
end