classdef PerturbPredIndiv < Fit.Common.CommonWorkspace
%% Settings
properties
    class_W = 'Fit.Dtb.MeanRt.Main';
    args_W = varargin2S({
        'parad', 'VD_wSDT'
        });
    files_res = {
        'Data/Fit.Dtb.MeanRt.Main/sbj=S1+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1.mat'
        'Data/Fit.Dtb.MeanRt.Main/sbj=S2+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1.mat'
        'Data/Fit.Dtb.MeanRt.Main/sbj=S3+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1.mat'
        'Data/Fit.Dtb.MeanRt.Main/sbj=S4+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=1+bch=0+thf={tnd_std_1}+acbch=1.mat'
        'Data/Fit.Dtb.MeanRt.Main/sbj=S5+prd=VD_wSDT+rtfd=SDT_ClockOn+tr=[201,0]+bal=0+dly=all+dur=800+bnd=const+tnd=normal+ntnd=1+bayes=none+lps0=1+igch=0+bch=0+thf={tnd_std_1}+acbch=1.mat'
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
end    
%% Internal
properties
    W = [];
    res = [];
    file_res = '';
end
%% Results
properties
    llk0 = [];
    llk = []; % (n_perturb, 1)
end
%% Init
methods
    function W0 = PerturbPredIndiv(varargin)
        W0.parad = 'VD_wSDT';
        if nargin > 0
            W0.init(varargin{:});
        end
    end
    function init(W0, varargin)
        W0.init@Fit.Common.CommonWorkspace(varargin{:});

        S2s = bml.str.Serializer;
        file1 = S2s.ls(W0.files_res, 'allof', varargin2S({
            'sbj', W0.subj
            'prd', W0.parad
            }));
        assert(isscalar(file1));
        W0.file_res = file1{1};
        
        file1 = W0.file_res;
        L = load(file1, 'W', 'res');
        fprintf('Loaded %s\n', file1);
        W = L.W;
        W0.W = W;
        W.subj = W0.subj;
        W.init;
        W.th = L.res.th;
        W.pred;
        W0.res = L.res;
        
        W0.llk0 = W0.get_llk_ch(W);
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
%% Save
methods
    function fs = get_file_fields(~)
        fs = {
            'subj', 'sbj'
            'parad', 'prd'
            };
    end
    function L = get_struct2save(W0)
        L = copyFields(struct, W0, {
            'class_W'
            'args_W'
            'files_res'
            'W'
            'res'
            'file_res'
            'llk0'
            'llk'
            });
        L.W0 = W0;
    end
    function save_mat(W0)
        L = W0.get_struct2save; %#ok<NASGU>
        file = W0.get_file;
        mkdir2(fileparts(file));
        save(file, '-struct', 'L');
    end
    function W0 = load_mat(W0, file)
        if nargin < 2
            file = W0.get_file;
        end
        L = load(file);
        W0 = L.W0;
    end
end
end