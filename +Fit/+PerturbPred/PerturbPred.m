classdef PerturbPred < Fit.Common.CommonWorkspace
%% Settings
properties
    class_Ws = 'Fit.Dtb.MeanRt.Main';
    args_Ws = varargin2S({
        'parad', 'VD_wSDT'
        });
    files_res = {
        'Data/Fit.Dtb.MeanRt.Main/sbj=S1+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1'
        'Data/Fit.Dtb.MeanRt.Main/sbj=S2+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1'
        'Data/Fit.Dtb.MeanRt.Main/sbj=S3+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1'
        'Data/Fit.Dtb.MeanRt.Main/sbj=S4+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1'
        'Data/Fit.Dtb.MeanRt.Main/sbj=S5+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=0+bch=0+thf={tnd_std_1}+acbch=1'
        ...
%         'Data/Fit.Dtb.MeanRt.Main/sbj=S1+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+acbch=1.mat'
%         'Data/Fit.Dtb.MeanRt.Main/sbj=S2+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+acbch=1.mat'
%         'Data/Fit.Dtb.MeanRt.Main/sbj=S3+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+acbch=1.mat'
%         'Data/Fit.Dtb.MeanRt.Main/sbj=S4+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+acbch=1.mat'        
%         'Data/Fit.Dtb.MeanRt.Main/sbj=S5+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=0+bch=0+acbch=1.mat'
        ...
%         'Data/Fit.Dtb.MeanRt.Main/sbj=S1+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=0+bch=0+thf={tnd_std_1,tnd_std_2}+acbch=1.mat'
%         'Data/Fit.Dtb.MeanRt.Main/sbj=S2+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=0+bch=0+thf={tnd_std_1,tnd_std_2}+acbch=1.mat'
%         'Data/Fit.Dtb.MeanRt.Main/sbj=S3+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=0+bch=0+thf={tnd_std_1,tnd_std_2}+acbch=1.mat'
%         'Data/Fit.Dtb.MeanRt.Main/sbj=S4+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=0+bch=0+thf={tnd_std_1,tnd_std_2}+acbch=1.mat'
%         'Data/Fit.Dtb.MeanRt.Main/sbj=S5+prd=RT_wSDT+rtfd=RT+tr=[201,0]+bal=0+bnd=const+tnd=normal+ntnd=2+bayes=none+lps0=1+igch=0+imk=0+bch=0+thf={tnd_std_1,tnd_std_2}+acbch=1.mat'       
        };
    subjs = Data.Consts.subjs; % _w_SDT_modul;    
    
    ths_for_logit = {'k', 'b', 'bias_cond'};
    ds_params = dataset;
end    
%% Internal
properties
    Ws = {};
    ress = {};
end
%% Results
properties
    llk = []; % (perm, subj)
    llk0 = []; % (1, subj)
    p_perm = []; % (1, subj)
    p_perm_sum = nan;
end
%% Init
methods
    function init(W0, varargin)
        W0.init@Fit.Common.CommonWorkspace(varargin{:});
        
        if isempty(W0.files_res)
            subjs = W0.subjs;
            n = numel(subjs);
            for ii = 1:n
                C = varargin2C({
                    'subj', subjs{ii};
                    }, W0.args_Ws);
                W = feval(W0.class_Ws, C{:});
                W0.files_res{ii} = [W.get_file, '.mat'];
            end
        end
        
        n = numel(W0.subjs);
%         n = numel(W0.files_res);
        W0.ds_params = dataset;
        for ii = n:-1:1
            file1 = W0.files_res{ii};
            L = load(file1, 'W', 'res');
            fprintf('Loaded %s\n', file1);
            W = L.W;
            W0.Ws{ii} = W;
            W.subj = W0.subjs{ii};
            W.init;
%             W0.subjs{ii} = W.subj;
            W0.ress{ii} = L.res;
            
            th = L.res.th;
            W0.ds_params = ...
                ds_set(W0.ds_params, ii, ...
                    copyFields(struct, th, W0.ths_for_logit));
        end
    end
end
%% Utility
methods
    function llk = get_llk_ch(~, W)
        ch_obs = vVec(W.Data.obs_ch);
        n_obs = vVec(W.Data.obs_n);
        y_obs = [ch_obs .* n_obs, n_obs];

        W.pred;
        ch_pred = W.ch_pred;
        llk = bml.stat.glmlik_binomial( ...
                [], y_obs, ch_pred(:));
    end
end
end