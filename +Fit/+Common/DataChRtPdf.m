classdef DataChRtPdf ...
        < FitData ...
        & TimeAxis.TimeInheritable ...
        & bml.oop.PropFileName
    % Fit.Common.DataChRtPdf
    %
    % 2015 YK wrote the initial version.
%% === Properties
%% --- Loading
properties
    subj = 'S3';
    parad = 'RT_wSDT';
    data_file_type = 'orig'; % 'addCols';
    rt_field_ = ''; 
    
    % tr_incl:
    % 0 = end; -1 : second to last.
    % Defaults to [1, 0] for VD_woSDT, where the number of trials is small,
    % and to [201, 0] for all others.
    tr_incl_ = [201, 0]; 
    ad_cond_incl = 'all';
    incl_tRDK2Go = 'all'; % 0.8;
    incl_tRDKDur = 0.8;
    
    % rt_phys_incl = [st, en]
    % Physical RT percentile to include. If empty, includes all.
    rt_phys_incl = []; 
    
    % rt_phys_incl = [st, en]
    % Go-RT percentile to include. If empty, includes all.
    go_rt_incl = [];
    
    % balance : if true, balance the number of trials with each (corrAns, cond)
    balance = false; % true; 
    
    % to_exclude_no_sdt: if true, exclude trials with no SDT.
    to_exclude_no_sdt = true;
    
    % to_exclude_no_decision : if true, exclude trials with no decision.
    to_exclude_no_decision = true;
    
    bias_cond = 0;
end
properties (Dependent)
    % rt_field : Automatically set according to parad if not set manually
    % 'RT'|'SDT_ClockOn'
    rt_field
    rt_field_label % 'RT'|'SDT'
    
    tr_incl_mlab % tr_incl in matlab convention (starting from 1).
    tr_incl
    
    incl_tRDK2Go_msec
    incl_tRDKDur_msec
end
properties
    general_info = struct; % general
end
%% --- Fields
properties (Dependent)
    cond
    cond_bias
    ch
    rt
    go_rt
    tRDKDur
    tRDK2Go

    cond0
    ch0
    rt0
    tRDKDur0
    tRDK2Go0
    
    n_tr
    n_tr0
end
%% --- Stats
properties (Dependent) % (Transient)
    accu
    
    conds
    d_cond
    rt_ix
    
    obs_mean_rt % (cond, ch)
    obs_sem_rt % (cond, ch)
    obs_std_rt % (cond, ch)
    obs_skew_rt % (cond, ch)
    
    obs_mean_rt_accu % (cond, ch)
    obs_sem_rt_accu % (cond, ch)
    obs_ci_ch % (cond, [lb, ub])
end
properties (Transient)
    RT_data_pdf % (t, cond, ch)
    RT_pred_pdf % (t, cond, ch)
    Td_pred_pdf % (t, cond, ch)
end
properties (Dependent)
    n_cond
    na_cond
    
    a_conds
    ad_cond
    ad_cond0
    
    obs_ch
    obs_n
    obs_n_in_cond_ch % (cond, ch)
    obs_n_in_cond_ch_accu % (cond, ch)

    pred_ch
    pred_n
    pred_mean_rt
    pred_std_rt
    pred_skew_rt
end
%% === Methods
%% --- Loading
methods
    function Dat = DataChRtPdf(varargin)
        if nargin > 0
            Dat.init(varargin{:});
        end
    end
    function init(Dat, varargin)
        bml.oop.varargin2props(Dat, varargin); % , true);
    end
    function file = get_path(Dat)
        % Bypass Dat.path
        file = fullfile('Data/Expr', ...
            str_con(Dat.parad, Dat.data_file_type, Dat.subj));
        
        Dat.path = file;
    end
    function load_data(Dat)
        pth = Dat.get_path;
        if Dat.is_loaded
            fprintf('FitData.load_data: Loaded already. Skipping loading %s\n', ...
                pth);
            return; 
        end
        
        if isempty(pth), return; end
        
        if ~is_in_parallel
            fprintf('Loading %s\n', pth);
        end
        L = load(pth);
        if isfield(L, 'obTr')
            dsTr = L.obTr;
            G = L.G;
        else
            dsTr = L.Expr.obTr;
            G = L.Expr.G;
        end
        dsTr = dsTr(dsTr.succT,:); % Choose successful trials only
%         [sTr, G] = Data.exclOutliers(L.Expr);
        if isempty(dsTr)
            error('No trial is read!\n');
        end
        
        Dat.set_general_info(G);
        Dat.max_t = Dat.general_info.tClockDur;
        
        Dat.set_ds0(dsTr);
        
        Dat.reset_cache;
        Dat.loaded = true;
        Dat.filt_ds;
    end
    function filt = get_dat_filt(Dat)
        filt = Dat.get_dat_filt@FitData;
        
        % trial number
        n_tr0 = size(Dat.ds0, 1);
        tr_ix = (1:n_tr0)';
        tr_incl = Dat.tr_incl_mlab;
        tf_tr_incl = (tr_ix >= tr_incl(1)) & (tr_ix <= tr_incl(2));
        
        % Valid RT
        if ismember(Dat.parad, {'VD_wSDT', 'RT_wSDT'}) ...
                && (Dat.to_exclude_no_decision || Dat.to_exclude_no_sdt)
            incl_valid_rt = ~isnan(Dat.ds0.RT) ...
                          & ~isnan(Dat.ds0.SDT_ClockOn); % For consistency
        else
            incl_valid_rt = true(n_tr0, 1);
        end
        
        % delay and duration criteria
        if strcmpStart('VD', Dat.parad)
            delay   = Dat.ds0.tRDK2Go;
            dur     = Dat.ds0.tRDKDur;
            
            incl_dur = true(n_tr0, 1);
            if ~ischar(Dat.incl_tRDK2Go) && ~strcmp(Dat.incl_tRDK2Go, 'all')
                incl_dur = incl_dur & bsxEq(delay, Dat.incl_tRDK2Go);
            end
            if ~ischar(Dat.incl_tRDKDur) && ~strcmp(Dat.incl_tRDKDur, 'all')
                incl_dur = incl_dur & bsxEq(dur, Dat.incl_tRDKDur);
            end
        elseif strcmpStart('RT', Dat.parad)
            incl_dur   = true(size(Dat.ds0, 1), 1);
        else
            incl_dur   = true(size(Dat.ds0, 1), 1);
        end
        
        % reported SDT
        if isempty(strfind(Dat.parad, 'wSDT')) ...
                || ~Dat.to_exclude_no_sdt
            reported_sdt = true(n_tr0, 1);
        else
            reported_sdt = ~(Dat.ds0.undecided | Dat.ds0.didntSee);
        end

        % made response
        if ismember(Dat.parad, {'BeepOnly_longDelay4'}) ...
                || ~Dat.to_exclude_no_decision
            % no response is needed
            incl_ch = true(n_tr0, 1);
        else
            incl_ch = ~isnan(Dat.ds0.subjAns);
        end
        
        % gather all
        ix = find( ...
              incl_valid_rt ...
            & incl_dur ...
            & incl_ch ...
            & tf_tr_incl ...
            & reported_sdt);
        
        filt = intersect(filt(:), ix(:), 'stable');
        
        % balance final count
        if Dat.balance
            cond = Dat.ds0.cond(filt);
            corrAns = Dat.ds0.corrAns(filt);
            
            [~,~,ic] = unique([cond, corrAns], 'rows');
            cnt = histD(ic, 'to_plot', false);
            min_cnt = min(cnt);
            
            excl = false(length(ic), 1);
            
            for i_cond = 1:max(ic)
                incl = ic == i_cond;
                n_incl = nnz(incl);
                n_excl = max(n_incl - min_cnt, 0);
                
                if n_excl > 0
                    ix_excl = find(incl, n_excl, 'last');
                    excl(ix_excl) = true;
                end
            end
            
            filt = filt(~excl);
        end
        
        % difficulty filter
        if ischar(Dat.ad_cond_incl) && isequal(Dat.ad_cond_incl, 'all')
            incl_ad_cond = true(n_tr0, 1);
        else
            incl_ad_cond = bsxEq(Dat.ad_cond0, Dat.ad_cond_incl);
        end
        
        filt = intersect(filt(:), find(incl_ad_cond(:)), 'stable');
        
        % physical RT filter
        if isempty(Dat.rt_phys_incl)
            incl_rt_phys = true(n_tr0, 1);
        else
            assert(numel(Dat.rt_phys_incl) == 2);
            
            rt_phys0 = Dat.ds0.RT;
            rt_phys = rt_phys0(filt);
            rt_st = prctile(rt_phys, Dat.rt_phys_incl(1));
            rt_en = prctile(rt_phys, Dat.rt_phys_incl(2));
            
            incl_rt_phys = (rt_phys0 >= rt_st) & (rt_phys0 <= rt_en);
        end
        filt = intersect(filt(:), find(incl_rt_phys(:)), 'stable');
        
        % Go-RT filter
        if isempty(Dat.go_rt_incl)
            incl_go_rt = true(n_tr0, 1);
        else
            assert(numel(Dat.go_rt_incl) == 2);
            
            go_rt0 = Dat.ds0.RT - Dat.ds0.tRDK2Go - Dat.ds0.tRDKDur;
            go_rt = go_rt0(filt);
            rt_st = prctile(go_rt, Dat.go_rt_incl(1));
            rt_en = prctile(go_rt, Dat.go_rt_incl(2));
            
            incl_go_rt = (go_rt0 >= rt_st) & (go_rt0 <= rt_en);
        end
        filt = intersect(filt(:), find(incl_go_rt(:)), 'stable');
    end
    function filt = unify_filt_class(Dat, filt)
        filt = Dat.convert_filt_to_numeric(filt);
    end
    function v = get.tr_incl(Dat)
        v = Dat.get_tr_incl;
    end
    function v = get_tr_incl(Dat)
        if ~ismember(Dat.parad, Data.Consts.dtb_wSDT_parads_short)
            v = [1, 0];
            if ~isequal(Dat.tr_incl_, v)
                warning(['tr_incl is ignored in parad~=dtb_wSDT_parads' ...
                         ' due to too small number of trials!']);
            end
        else
            v = Dat.tr_incl_;
        end
    end
    function set.tr_incl(Dat, v)
        Dat.tr_incl_ = v;
    end
    function v = get.tr_incl_mlab(Dat)
        n = size(Dat.ds0, 1);
        v = bml.indsub.ix2py(Dat.tr_incl, n);
    end
    function set_general_info(Dat, G)
        Dat.general_info = G;
    end
    function v = get.rt_field(Dat)
        if isempty(Dat.rt_field_)
            if bml.str.strcmpStart('RT', Dat.parad)
                v = 'RT';
            elseif bml.str.strcmpStart('VD', Dat.parad)
                if strfind(Dat.parad, 'wSDT')
                    v = 'SDT_ClockOn';
                else
                    v = 'RT';
                end
            else
                error('Unknown paradigm: %s\n', Dat.parad);
            end
        else
            v = Dat.rt_field_;
        end
    end
    function v = get.rt_field_label(Dat)
        switch Dat.rt_field
            case 'RT'
                v = 'RT';
            case 'SDT_ClockOn'
                v = 'SDT';
            otherwise
                v = Dat.rt_field;
        end
    end
    function set.rt_field(Dat, v)
        Dat.rt_field_ = v;
    end
end
%% --- Data Fields
methods
    function v = get.accu(Dat)
%         if ~Dat.is_loaded
%             try
%                 Dat.load_data;
%             catch err
%                 warning(err_msg(err));
%                 warning('Load data before use!');
%                 v = [];
%                 return;
%             end
%         end

%         try
            cond_bias = Dat.cond - Dat.bias_cond;
            v = (cond_bias == 0) ...
              | (sign(Dat.ch - 0.5) == sign(cond_bias));
%             v = Dat.ds.accuAns;
%         catch
%             v = [];
%         end
    end
    function v = get.cond(Dat)
%         if ~Dat.is_loaded
%             try
%                 Dat.load_data;
%             catch err
%                 warning(err_msg(err));
%                 warning('Load data before use!');
%                 v = [];
%                 return;
%             end
%         end

%         try
            v = Dat.ds.cond;
%         catch
%             v = [];
%         end
    end
    function v = get.cond_bias(Dat)
%         if ~Dat.is_loaded
%             try
%                 Dat.load_data;
%             catch err
%                 warning(err_msg(err));
%                 warning('Load data before use!');
%                 v = [];
%                 return;
%             end
%         end

%         if Dat.is_loaded
            v = Dat.ds.cond - Dat.bias_cond;
%         else
%             v = [];
%         end
    end
    function v = get.ch(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         try
            v = double(Dat.ds.subjAns == 2);
            v(Dat.ds.didntSee | Dat.ds.undecided) = nan;
%         catch
%             v = [];
%         end
    end
    function v = get.rt(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
        v = Dat.ds.(Dat.rt_field);
    end
    function set.rt(Dat, v)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
        Dat.set_ds(Dat.rt_field, v);
    end
    
    function v = get.go_rt(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
        v = Dat.ds.(Dat.rt_field);
    end
    function set.go_rt(Dat, v)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
        Dat.set_ds(Dat.rt_field, v);
    end
    
    function v = get.tRDKDur(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         try
            v = Dat.ds.tRDKDur;
%         catch
%             v = [];
%         end
    end
    function v = get.tRDK2Go(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         try
            v = Dat.ds.tRDK2Go;
%         catch
%             v = [];
%         end
    end
    
    function v = get.cond0(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         try
            v = Dat.ds0.cond;
%         catch
%             v = [];
%         end
    end
    function v = get.ad_cond0(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         try
            [~,~,v] = unique(abs(Dat.ds0.cond));
%         catch
%             v = [];
%         end
    end
    function v = get.ch0(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         try
            v = double(Dat.ds0.subjAns == 2);
            v(Dat.ds0.didntSee | Dat.ds0.undecided) = nan;
%         catch
%             v = [];
%         end
    end
    function v = get.rt0(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         try
            v = Dat.ds0.(Dat.rt_field);
%         catch
%             v = [];
%         end
    end
    function v = get.tRDKDur0(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         try
            v = Dat.ds0.tRDKDur;
%         catch
%             v = [];
%         end
    end
    function v = get.tRDK2Go0(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         try
            v = Dat.ds0.tRDK2Go;
%         catch
%             v = [];
%         end
    end
    
    function v = get.n_tr(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         if Dat.is_loaded
            v = size(Dat.ds, 1);
%         else
%             v = 0;
%         end
    end
    function v = get.n_tr0(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         if Dat.is_loaded
            v = size(Dat.ds0, 1);
%         else
%             v = 0;
%         end
    end
end
%% --- Stats - derived quantities
methods
    function reset_cache(Dat)
        for props = {
%                 'accu'
%                 ...
%                 'conds'
%                 'd_cond'
%                 'rt_ix'
%                 ...
%                 'RT_data_pdf'
%                 'obs_mean_rt'
%                 'obs_sem_rt'
%                 'obs_std_rt'
%                 'obs_skew_rt'
%                 ...
%                 'obs_mean_rt_accu'
%                 'obs_sem_rt_accu'
%                 'obs_ci_ch'
                ...
                'RT_pred_pdf'
                'Td_pred_pdf'
                }'
            Dat.(props{1}) = [];
        end
    end
    function v = get.conds(Dat)
%         if ~Dat.is_loaded
%             try
%                 Dat.load_data;
%             catch err
%                 warning(err_msg(err));
%                 warning('Load data before use!');
%                 v = [];
%                 return;
%             end
%         end

%         if isempty(Dat.conds) && Dat.is_loaded
            v = unique(Dat.get_ds0('cond')); 
%             Dat.conds = v;
%         else
%             v = Dat.conds;
%         end 
    end
    function v = get.d_cond(Dat)
%         if ~Dat.is_loaded
%             try
%                 Dat.load_data;
%             catch err
%                 warning(err_msg(err));
%                 warning('Load data before use!');
%                 v = [];
%                 return;
%             end
%         end

%         if Dat.is_loaded
%         if isempty(Dat.d_cond) && Dat.is_loaded
            v = bsxFind(Dat.cond, Dat.conds);
%             Dat.d_cond = v;
%         else
%             v = Dat.d_cond;
%         end
    end
    function v = get.n_cond(Dat)
        v = numel(Dat.conds);
    end
    function v = get.na_cond(Dat)
        v = numel(Dat.a_conds);
    end
    function v = get.a_conds(Dat)
        v = unique(abs(Dat.conds));
    end
    function v = get.ad_cond(Dat)
        [~,~,v] = unique(abs(Dat.cond));
    end
    function v = get.rt_ix(Dat)
%         if ~Dat.is_loaded
%             try
%                 Dat.load_data;
%             catch err
%                 warning(err_msg(err));
%                 warning('Load data before use!');
%                 v = [];
%                 return;
%             end
%         end

%         if Dat.is_loaded
%         if isempty(Dat.rt_ix) && Dat.is_loaded
            v = min(round(Dat.rt / Dat.dt) + 1, Dat.nt);
%             Dat.rt_ix = v;
%         else
%             v = Dat.rt_ix;
%         end
    end
    function v = get.RT_data_pdf(Dat)
%         if ~Dat.is_loaded
%             try
%                 Dat.load_data;
%             catch err
%                 warning(err_msg(err));
%                 warning('Load data before use!');
%                 v = [];
%                 return;
%             end
%         end

%         if Dat.is_loaded
%         if isempty(Dat.RT_data_pdf) && Dat.is_loaded
            v = accumarray( ...
                    [Dat.rt_ix, Dat.d_cond, Dat.ch + 1], ...
                    1, ...
                    [Dat.nt, Dat.n_cond, 2], ...
                    @sum);
% %             Dat.RT_data_pdf = v;
%         else
%             v = [];
% %             v = Dat.RT_data_pdf;
%         end
    end

    function v = get.obs_n(Dat)
        v = Dat.calc_n_from_pdf(Dat.RT_data_pdf);
    end
    function v = get.pred_n(Dat)
        v = Dat.calc_n_from_pdf(Dat.RT_pred_pdf);
    end
    function v = calc_n_from_pdf(~, p)
        v = sums(p, [1, 3]);
    end
    
    function v = get.obs_ch(Dat)
        v = Dat.calc_ch_from_pdf(Dat.RT_data_pdf);
    end
    function v = get.pred_ch(Dat)
        v = Dat.calc_ch_from_pdf(Dat.RT_pred_pdf);
    end
    function v = calc_ch_from_pdf(~, p)
        if isempty(p)
            v = [];
        else
            v = sum(p(:,:,2)) ./ sums(p, [1 3], true);
        end
    end
    
    function v = get.obs_ci_ch(Dat)
        v = Dat.get_obs_ci_ch;
    end
    function v = get_obs_ci_ch(Dat, alpha)
        if ~exist('alpha', 'var'), alpha = 0.05; end
        
        n = Dat.obs_n;
        
        if isempty(n)
            v = [];
            return;
        else
            n1 = Dat.obs_ch .* n;
            [~, v] = binofit(n1, n, alpha);
        end
    end
    
    function v = get.obs_mean_rt(Dat)
%         if Dat.is_loaded
%         if isempty(Dat.obs_mean_rt) && Dat.is_loaded
            v = Dat.calc_mean_rt_from_pdf(Dat.RT_data_pdf);
%             Dat.obs_mean_rt = v;
%         else
%             v = [];
% %             v = Dat.obs_mean_rt;
%         end
    end
    function v = get.pred_mean_rt(Dat)
        v = Dat.calc_mean_rt_from_pdf(Dat.RT_pred_pdf);
    end
    function v = calc_mean_rt_from_pdf(Dat, p)
        if isempty(p)
            v = [];
        else
            v = squeeze(mean_distrib(p, Dat.t(:), 1));
        end
    end
    
    function v = get.obs_std_rt(Dat)
%         if Dat.is_loaded
%         if isempty(Dat.obs_std_rt) && Dat.is_loaded
            v = Dat.calc_std_rt_from_pdf(Dat.RT_data_pdf);
%             Dat.obs_std_rt = v;
%         else
%             v = [];
% %             v = Dat.obs_std_rt;
%         end
    end
    function v = get.pred_std_rt(Dat)
        v = Dat.calc_std_rt_from_pdf(Dat.RT_pred_pdf);
    end
    function v = calc_std_rt_from_pdf(Dat, p)
        if isempty(p)
            v = [];
        else
            v = squeeze(std_distrib(p, Dat.t(:), 1));
        end
    end
    
    function v = get.obs_skew_rt(Dat)
%         if Dat.is_loaded
%         if isempty(Dat.obs_skew_rt) && Dat.is_loaded
            v = Dat.calc_skew_rt_from_pdf(Dat.RT_data_pdf);
%             Dat.obs_skew_rt = v;
%         else
%             v = [];
% %             v = Dat.obs_skew_rt;
%         end
    end
    function v = get.pred_skew_rt(Dat)
        v = Dat.calc_skew_rt_from_pdf(Dat.RT_pred_pdf);
    end
    function v = calc_skew_rt_from_pdf(Dat, p)
        if isempty(p)
            v = [];
        else
            v = squeeze(skew_distrib(p, Dat.t(:), 1));
        end
    end
    
    function v = get.obs_mean_rt_accu(Dat)
%         if ~Dat.is_loaded
%             try
%                 Dat.load_data;
%             catch err
%                 warning(err_msg(err));
%                 warning('Load data before use!');
%                 v = [];
%                 return;
%             end
%         end

%         if Dat.is_loaded
%         if isempty(Dat.obs_mean_rt_accu) && Dat.is_loaded
            accu = logical(Dat.accu);
            n_ch = 2;
            
%             Dat.obs_mean_rt_accu = accumarray(...
            v = accumarray( ...
                [Dat.d_cond(accu), Dat.ch(accu) + 1], ...
                Dat.rt(accu), ...
                [Dat.n_cond, n_ch], ...
                @nanmean, nan);
%         else
%             v = [];
%         end
%         v = Dat.obs_mean_rt_accu;
    end
    
    function v = get_obs_mean_rt_accu_vec(Dat)
        accu = logical(Dat.accu);

        v = accumarray( ...
            Dat.d_cond(accu), ...
            Dat.rt(accu), ...
            [Dat.n_cond, 1], ...
            @nanmean, nan);
    end
    
    function v = get.obs_sem_rt(Dat)
%         if ~Dat.is_loaded
%             try
%                 Dat.load_data;
%             catch err
%                 warning(err_msg(err));
%                 warning('Load data before use!');
%                 v = [];
%                 return;
%             end
%         end

%         if Dat.is_loaded
%         if isempty(Dat.obs_sem_rt) && Dat.is_loaded
            n_ch = 2;
            
%             Dat.obs_sem_rt = accumarray(...
            v = accumarray(...
                [Dat.d_cond, Dat.ch + 1], ...
                Dat.rt, ...
                [Dat.n_cond, n_ch], ...
                @nansem, nan);
%         else
%             v = [];
%         end
%         v = Dat.obs_sem_rt;
    end
    function v = get.obs_sem_rt_accu(Dat)
%         disp(Dat.is_loaded); % DEBUG
        
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         if Dat.is_loaded
%         if isempty(Dat.obs_sem_rt_accu) && Dat.is_loaded
            accu = logical(Dat.accu);
            n_ch = 2;
            
%             Dat.obs_sem_rt_accu = accumarray(...
            v = accumarray( ...
                [Dat.d_cond(accu), Dat.ch(accu) + 1], ...
                Dat.rt(accu), ...
                [Dat.n_cond, n_ch], ...
                @nansem, nan);
%         else
%             v = [];
%         end
%         v = Dat.obs_sem_rt_accu;
    end
    
    function v = get_obs_sem_rt_accu_vec(Dat)
        accu = logical(Dat.accu);

        v = accumarray( ...
            Dat.d_cond(accu), ...
            Dat.rt(accu), ...
            [Dat.n_cond, 1], ...
            @nansem, nan);
    end    
    
    function v = get.obs_n_in_cond_ch(Dat)
        n_ch = 2;
        if ~isempty(Dat.d_cond)
            v = accumarray(...
                [Dat.d_cond, Dat.ch + 1], ...
                1, ...
                [Dat.n_cond, n_ch], ...
                @sum, 0);
        else
            v = [];
        end
    end
    function v = get.obs_n_in_cond_ch_accu(Dat)
        if ~Dat.is_loaded
            try
                Dat.load_data;
            catch err
                warning(err_msg(err));
                warning('Load data before use!');
                v = [];
                return;
            end
        end
%         if Dat.is_loaded
%         if isempty(Dat.obs_mean_rt_accu) && Dat.is_loaded
            accu = logical(Dat.accu);
            n_ch = 2;
            
%             Dat.obs_mean_rt_accu = accumarray(...
            v = accumarray( ...
                [Dat.d_cond(accu), Dat.ch(accu) + 1], ...
                1, ...
                [Dat.n_cond, n_ch], ...
                @sum, nan);
%         else
%             v = [];
%         end
%         v = Dat.obs_mean_rt_accu;
    end
end
%% -- Saving
methods
    function f = get_file_fields(W)
        f = {
            'subj',         'sbj'
            'parad',        'prd'
            'rt_field',     'rtfd'
            'tr_incl',      'tr'
            'balance',      'bal'
            'rt_phys_incl', 'rtp'
            'go_rt_incl',   'grp'
            };
        
        if bml.str.strcmpStart('VD', W.parad)
            f = [f
                {
                'incl_tRDK2Go_msec', 'dly'
                'incl_tRDKDur_msec', 'dur'
                }];
        end
    end
    function v = get.incl_tRDK2Go_msec(W)
        if ischar(W.incl_tRDK2Go)
            v = W.incl_tRDK2Go;
        else
            v = round(W.incl_tRDK2Go * 1000);
        end
    end
    function set.incl_tRDK2Go_msec(W, v)
        if ischar(v)
            W.incl_tRDK2Go = v;
        else
            W.incl_tRDK2Go = v / 1000;
        end
    end
    function v = get.incl_tRDKDur_msec(W)
        if ischar(W.incl_tRDKDur)
            v = W.incl_tRDKDur;
        else
            v = round(W.incl_tRDKDur * 1000);
        end
    end
    function set.incl_tRDKDur_msec(W, v)
        if ischar(v)
            W.incl_tRDKDur = v;
        else
            W.incl_tRDKDur = v / 1000;
        end
    end
%     function set.balance(Dat, v)
%         disp(v);
%         Dat.balance = v;
%     end
end
%% -- Save
methods
%     function Dat = saveobj(Dat)
%         if ~is_in_parallel
%             disp('resetting cache'); % DEBUG
%             Dat.reset_cache;
%         end
%     end
end
methods
%     function Dat = loadobj(Dat)
%         disp('Loading'); % DEBUG
%         Dat.loaded = false;
%         Dat.load_data;
%     end
end
%% -- Exporting ds
methods
    function [files, Ss, S_batch] = batch_export_ds(Dat0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            'parad', Data.Consts.dtb_parads_short
            'data_file_type', {'orig', 'addEn'}
            'excl_col', {{}}
            'props', {{'ds0'}}
            });
        [Ss, n] = bml.args.factorizeS(S_batch);
        files = cell(n, 1);
        for ii = 1:n
            C = S2C(Ss(ii));
            Dat0 = feval(class(Dat0), C{:});
            files{ii} = Dat0.export_ds(C{:});
        end
    end
    function [file, L] = export_ds(Dat, varargin)
        S = varargin2S(varargin, {
            'excl_col', {}
            'props', {'ds0'}
            });
        
        Dat.load_data;

        L = struct;
        for prop = S.props(:)'
            ds = Dat.(prop{1});
            ds = Dat.exclude_cols(ds, S.excl_col(:)');
            L.(prop{1}) = ds;
        end
        
        file0 = Dat.get_file({}, {'rt_field', 'tr_incl', 'balance'});
        [pth, nam] = fileparts(file0);
        file = fullfile(pth, 'ds', [nam '.mat']);
        
        fprintf('Exporting ds0 to %s\n', file);
%         fprintf('Exporting ds and ds0 to %s\n', file);
        mkdir2(fileparts(file));
        save(file, '-struct', 'L');
    end
end
methods
    function ds = exclude_cols(~, ds, excl_col)
        if nargin < 3
            excl_col = {'Eye_', 'Mouse_', 't_Eye_', 't_Mouse_', ...
                't_Scr_beginDraw', 't_Scr_finishDraw', 't_Scr_frOn', ...
                't_RDKCol_to', 't_RDKCol_xy', 't_RDKCol_col2', ...
                'f_file', 'trialFile', 'runFile', 'parad_short', 'cEn'};
        end
        
        cols = ds.Properties.VarNames;

        for col = cols(:)'
            to_remove = false;

            v = ds.(col{1});
            if iscell(v)
                if all(cellfun(@isempty, v))
                    to_remove = true;
                end
            else
                if all(isnan(v))
                    to_remove = true;
                elseif all(v == 0)
                    to_remove = true;
                end
            end
            if to_remove
                ds.(col{1}) = [];
            end
        end
        
        for col = excl_col
            to_excl = strcmpStart(col{1}, cols);
            cols_to_excl = cols(to_excl);

            for col1 = cols_to_excl(:)'
                if bml.ds.iscolumn_ds(ds, col1{1})
                    ds.(col1{1}) = [];
                end
            end
        end
    end
end
%% -- Plot / Print stats
methods
    function tabulate(Dat)
        % Useful for checking balancing
        tabulate(Dat.cond);
        tabulate(Dat.ds.corrAns);
        disp(crosstab(Dat.ds.cond, Dat.ds.corrAns));
    end
end
end