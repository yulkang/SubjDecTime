function [hBar, biasLogOddsRatio, biasRate] = plotBias(ch, ansCh, varargin)
% [h, biasLogOddsRatio, biasRate] = plotBias(ch, ansCh, varargin)
S = varargin2S(varargin, {
    'titles', {'Left', 'Right'}
    'normalize', true
    });

ch = ch(:);
ansCh = ansCh(:);
n  = size(ch,1);

xCh_orig  = [nnz(ch == 1), nnz(ch == 2)];
xAns_orig = [nnz(ansCh == 1), nnz(ansCh == 2)];

if S.normalize
    xCh  = xCh_orig / n * 100;
    xAns = xAns_orig / n * 100;
else
    xCh  = xCh_orig;
    xAns = xAns_orig;
end    

hAx = subplotRCs(1,2);

for ii = 2:-1:1
    axes(hAx(ii)); %#ok<LAXES>
    hBar{ii} = barh([xCh(ii), xAns(ii)], 'c');
    
    if ii == 1
        set(gca, ...
            'XDir', 'reverse', ...
            'YDir', 'reverse', ...
            'YTickLabel', {'Choice', 'Answer'});
        
        text(0,1,sprintf('%1.1f', xCh(ii)),  'HorizontalAlignment', 'Right');
        text(0,2,sprintf('%1.1f', xAns(ii)), 'HorizontalAlignment', 'Right');
    else
        set(gca, ...
            'YDir', 'reverse', ...
            'YTickLabel', {'', ''});
        
        text(0,1,sprintf('%1.1f', xCh(ii)),  'HorizontalAlignment', 'Left');
        text(0,2,sprintf('%1.1f', xAns(ii)), 'HorizontalAlignment', 'Left');
    end
    set(gca, 'TickDir', 'out');
    title(S.titles{ii});
    
    if S.normalize
        xlabel('% Trials');
    else
        xlabel('# Trials');
    end
end
sameAxes(hAx);
set(hAx, 'XGrid', 'on');

biasLogOddsRatio = log(xCh_orig(2))  - log(xCh_orig(1)) ...
                 - log(xAns_orig(2)) + log(xAns_orig(1));
biasRate = biasLogOddsRatio * 100 / n;
gltitle(hAx, 'all', sprintf('Log OR: %1.2f / %1.0ftr (%1.2f / 100tr)', ...
    biasLogOddsRatio, n, biasRate), ...
    'shift', [0, -0.03]);
