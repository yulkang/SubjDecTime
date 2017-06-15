function [est, ci, samp] = nll2ci(x, nll, varargin)
% [est, ci, samp] = nll2ci(x, nll, ['samp_args', {}, 'ci_args', {}])
S = varargin2S(varargin, {
    'samp_args', {}
    'ci_args', {}
    });
samp = nll2samp(x, nll, S.samp_args{:});
[est, ci] = samp2ci(samp, S.ci_args{:});
end