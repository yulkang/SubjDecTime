function timeline(t, labels, varargin)
% TIMELINE - marks time
%
% timeline(t, labels, 'opt1', opt1, ...)
%
% t      : A vector of time points.
% labels : A cell array of strings.
%
% Options:
% 'style': 'spike' or 'fill'
% 'tlim' : range of time shown

n = length(t);

S = varargin2S(varargin, {...
    'tlim',   [0 max(t)] ...
    'style',  'spike' ...
    });

h = gca;

switch S.style
    case 'spike'
        crossLine('h', t, '-');
        
        t_label = t;
        
    case 'fill'
        t_orig = t;
        t = [t(:)', S.tlim(2)];
        
        t_label = (t_orig + t(2:end))/2;
        
        c = lines(n);
        
        for ii = 1:n
            patch([0 1 1 0], [t(ii), t(ii), t(ii+1), t(ii+1)], c(ii,:));
        end
        t = t_orig;
end

s_labels = csprintf('%s %d', labels, t);

if ~any(t_label == S.tlim(2))
    t_label  = [t_label, S.tlim(2)];
    s_labels = [s_labels, {sprintf('%d', S.tlim(2))}];
end

ylim(S.tlim);
set(h, 'TickLength', [0 0], 'YTick', t_label, 'YDir', 'reverse', ...
    'YTickLabel', s_labels);

