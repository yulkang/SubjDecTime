function [est, ci] = samp2ci(samp, varargin)
% [est, ci] = samp2ci(samp, varargin)
S = varargin2S(varargin, {
    'alpha', 0.05
    'tail', 'both' % 'both'|'left'|'right'
    });

switch S.tail
    case 'both'
        est = median(samp);
        ci = prctile(samp, [S.alpha/2*100, 100-S.alpha/2*100]);
    otherwise
        error('Not implemented yet!');
end