classdef RtVsSdt < Fit.Common.CommonWorkspace
properties
    to_save = true;
end
methods
    function W = RtVsSdt(varargin)
        W.parad = 'RT_wSDT';
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function batch(W0, varargin)
        S_batch = varargin2S(varargin, {
            'subj', Data.Consts.subjs
            });
        [Ss, n] = factorizeS(S_batch);
        
        file_log = [W0.get_file({'sbj', S_batch.subj}), '.txt'];
        if exist(file_log, 'file'), 
            delete(file_log); 
        end
        mkdir2(fileparts(file_log));
        diary(file_log);
        
        for ii = 1:n
            S = Ss(ii);
            C = S2C(S);
            
            W = feval(class(W0), C{:});
            W.main;
        end
        
        diary('off');
        
        if W.to_save
            W0.imgather_batch;
        end
    end
    function main(W)
        if W.to_save
            W.save_mat;
        end
        W.plot_and_save_all;
    end
    function save_mat(W)
        rt = W.Data.ds.RT;
        sdt = W.Data.ds.SDT_ClockOn;
        dif = sdt - rt;
        
        over_thres = nanmean(dif < 0);
        fprintf('Subject %s: Proportion SDT < RT: ', W.subj);
        disp(over_thres);
        
        over_thres = nanmean(dif < 0.4);
        fprintf('Subject %s: Proportion SDT < 0.4 + RT: ', W.subj);
        disp(over_thres);
        
        over_thres = nansum((dif > 0) & (dif < 0.4)) ./ nansum(dif > 0);
        fprintf('Subject %s: Proportion SDT < 0.4 + RT among SDT > RT: ', W.subj);
        disp(over_thres);
        
        L = packStruct(sdt, rt, dif); %#ok<NASGU>
        
        file = W.get_file;
        mkdir2(fileparts(file));
        save(file, '-struct', 'L');
        fprintf('Saved to %s.mat\n', file);
    end
    function plot_and_save_all(W)
        %%
        W.plot_ecdf;
%         W.plot_scatter;
    end
    function plot_scatter(W)
        %%
        rt = W.Data.ds.RT;
        sdt = W.Data.ds.SDT_ClockOn;
        
        dif = sdt - rt;
        
        clf;
        plot(rt, dif, '.', 'Color', 0.5 + [0 0 0]);
        xlabel('RT (s)');
        ylabel('SDT - RT (s)');
        crossLine('h', 0, {'-', [0 0 0] + 0.7});
        
        b = glmfit(rt, dif, 'normal');
        
        min_rt = min(rt);
        max_rt = max(rt);
        
        dif_pred = glmval(b, [min_rt; max_rt], 'identity');
        
        hold on;
        plot([min_rt; max_rt], dif_pred, 'k-');
        
        txt = {
            sprintf('SDT - RT = %1.2f + %1.2f RT', ...
                b(1), b(2))
            };
        bml.plot.text_align(txt);
        
        bml.plot.beautify;
        title(W.subj);
        
        file = W.get_file({'plt', 'scatter_dif'});
        if W.to_save
            savefigs(file);
        end
    end
    function plot_ecdf(W)
        %%
        rt = W.Data.ds.RT;
        sdt = W.Data.ds.SDT_ClockOn;
        
        dif = sdt - rt;
        
        clf;
        [y, x] = ecdf(dif);
        stairs(x, y, 'k-');
        xlabel('t_{dif} (s)');
        ylabel('P(SDT - RT < t_{dif})');
        crossLine('v', 0, {'-', [0 0 0] + 0.7});
        
        txt = {
            sprintf('P(SDT < RT) = %1.2f', ...
                nanmean(dif < 0))
            };
        bml.plot.text_align(txt);
        
        set(gca, ...
            'YTick', [0, 0.5, 1], ...
            'YTickLabel', {'0', '', '1'});
        
        bml.plot.beautify;
        title(W.subj);
        
        file = W.get_file({'plt', 'ecdf_dif'});
        if W.to_save
            savefigs(file);        
        end
    end
    function imgather_batch(W0)
        for kind = {'ecdf_dif'} % 'scatter_dif', 
            W0.imgather_plot(kind{1});
        end
    end
    function imgather_plot(W0, plot_kind)
        %%
        clf;
        axs = W0.imgather({}, {'subj', Data.Consts.subjs}, {}, {
            'plt', plot_kind
            }, ...
            'to_gltitle', false, ...
            'savefigs', false);
        if iscell(axs)
            axs = [axs{:}];
        end
        
        n = numel(axs);
        for ii = 1:n
            ax1 = axs(ii);
            subj1 = Data.Consts.subjs{ii};
            
            if ii > 1
                ylabel(ax1, '');
            end
            if ii ~= round(n / 2)
                xlabel(ax1, '');
            end
            
            title(ax1, subj1);
        end
        
        %%
        bml.plot.position_subplots(axs, ...
            'margin_left', 0.04, ...
            'margin_right', 0.01, ...
            'margin_bottom', 0.2);
        
        file = W0.get_file({
            'sbj', 'all'
            'plt', ['gth_', plot_kind]
            });
        savefigs(file, ...
            'size', [100 + n * 200, 200]);
    end
end
end