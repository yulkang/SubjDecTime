function [res_sep, res_ixn, hpred, hdat, hLine, hTick] = glmsep(x, y, sep, varargin)
% [res_sep, res_ixn, hpred, hdat, hLine, hTick] = glmsep(x, y, sep, varargin)
%
% 'h',        []
% 'plot',      'y' % 'y', 'slope', 'bias', 'none'
% 'normalize_bias', true
% ...
% 'sep',          @(v) discretize(v, 'unique')
% 'seps',         @(v) unique(v)
% 'seplegend',    @(v) {} % @(v) csprintf('%d', v)
% ...
% 'glmopt',    {}
% 'plotopt',   {}
% 'betaopt',   {} % slope or bias plots
% 'betaseopt', {}
% 'legendopt', {}

S = varargin2S(varargin, {
    'h',        []
    'plot',      'y' % 'y', 'slope', 'bias', 'none'
    'normalize_bias', true
    ...
    'sep',          @(v) discretize(v, 'unique')
    'seps',         @(v) unique(v)
    'seplegend',    @(v) {} % @(v) csprintf('%d', v)
    ...
    'glmopt',    {}
    'plotopt',   {}
    'betaopt',   {} % slope or bias plots
    'betaseopt', {}
    'legendopt', {}
    });

glmopt = varargin2C(S.glmopt, {
    'binomial'
    }, false, 1);

plotopt = varargin2S(S.plotopt, {
    'x',        []
    'to_bin_x', 'auto' % 'never'|'auto'|'always' % auto: bin if #unique > n_bin_x
    'n_bin_x',  7
    'data',     {'Marker', 'o', 'LineStyle', 'none', 'MarkerSize', 8}
    'pred',     {'Marker', 'none', 'LineStyle', '-'}
    'col',      @hsv2
    'link',     'logit'
    });

betaopt = varargin2C(S.betaopt, {
    'LineStyle',    '-'
    'Color',        'k'
    'Marker',       'o'
    'MarkerFaceColor', 'k'
    'MarkerEdgeColor', 'w'
    'MarkerSize',   8
    });

betaseopt = varargin2C(S.betaseopt, {
    'LineStyle',    '-'
    'Color',        'k'
    'Marker',       'none'
    });

legendopt = varargin2S(S.legendopt, {
    'Location',     'best'
    });

%% Separate fit
res_sep     = dataset;
seps        = S.seps(sep);
sep         = S.sep(sep);
seplegend   = S.seplegend(seps);
nsep        = max(sep);
if isempty(nsep)
    nsep = 0;
end
hpred       = ghandles(1, nsep);
hdat        = ghandles(1, nsep);
if nsep == 0
    res_ixn = struct;
    return;
end

if ~strcmp(S.plot, 'none')
    if isempty(S.h), S.h = gca; end
    axes(S.h); % inevitable due to bug in NextPlot and hold on.
end
if strcmp(S.plot, 'y')
    if isempty(plotopt.x)
        max_x = max(abs(x));
        plotopt.x = linspace(-max_x, max_x);
    end
    colors = plotopt.col(nsep);
end
for isep = 1:nsep
    %% Fit
    filt = sep == isep;
    
    [b,~,stats] = glmfit(x(filt), y(filt), glmopt{:});
    se = stats.se;
    p = stats.p;
    
    res_sep = ds_set(res_sep, isep, ...
        'sep', seps(isep), 'b', b(:)', 'se', se(:)', 'p', p(:)', 'stats', {stats});    
    
    %% Plot
    if strcmp(S.plot, 'y')
        % Prediction
        yhat = glmval(b, plotopt.x, plotopt.link, stats);

        pred_args = varargin2C(plotopt.pred, {
            'Color',        colors(isep,:)
            'LineWidth',    2
            });
        hpred(isep) = plot(plotopt.x, yhat, pred_args{:});
        hold on;
%         set(S.h, 'NextPlot', 'add');

        % Data
        if strcmp(plotopt.to_bin_x, 'always') || ...
                (strcmp(plotopt.to_bin_x, 'auto') && ...
                 plotopt.n_bin_x < numel(unique(x(filt))))
             
            xsep = zeros(size(filt));
            xsep(filt) = quantilize(x(filt), plotopt.n_bin_x);
            c_filt = filt & (xsep > 0);
            xcon = accumarray(xsep(c_filt), x(c_filt), [], @nanmean);
            ycon = accumarray(xsep(c_filt), y(c_filt), [], @nanmean);
        else
            [xcon, ycon] = consolidate(x(filt), y(filt));
        end
        data_args = varargin2C(plotopt.data, {
            'Color',           colors(isep,:)
            'MarkerFaceColor', colors(isep,:) % 'none' % DEBUG % 
            'MarkerEdgeColor', 'w' % colors(isep,:) % 
            });
        hdat(isep) = plot(xcon, ycon, data_args{:});
        hold on;
    end            
end

%% Put data above pred
if strcmp(S.plot, 'y')
    for isep = 1:nsep
        uistack(hdat(isep), 'top');
    end
end    

%% Summary plots
switch S.plot
    case 'slope'
        b  = cell2mat2(res_sep.b);
        se = cell2mat2(res_sep.se);
        [hLine, hTick] = errorbar_wo_tick(seps(:), b(:,2), -se(:,2), +se(:,2), betaopt, betaseopt);

    case 'bias'
        b = cell2mat2(res_sep.b);
        
        if S.normalize_bias
            b  = b(:,2)  ./ b(:,1); % Convert into units of x
            se = se(:,2) ./ b(:,1);
        end
        
        [hLine, hTick] = errorbar_wo_tick(seps(:), b(:), -se(:), +se(:), betaopt, betaseopt);
end    

%% Legend
if ~strcmp(S.plot, 'none') && ~isempty(seplegend)
    legend(seplegend, legendopt{:});
end

%% Interaction
incl = sep > 0;
x = x(incl,:);
y = y(incl);
sep = sep(incl);

[b,~,stats] = glmfit([x, seps(sep), x .* seps(sep)], y, S.glmopt{:});
res_ixn = varargin2S({
    'b',     b(:)'
    'se',    stats.se(:)'
    'p',     stats.p(:)'
    'stats', stats
    });
