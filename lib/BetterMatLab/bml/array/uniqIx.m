function ix = uniqIx(v, varargin)
% ix = uniqIx(v, varargin)
%
% OPTIONS
% -------
% 'reverse', false
% 'uniqArg', {}
% 'round', nan
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'reverse', false
    'uniqArg', {}
    'round', nan
    });

if ~isnan(S.round)
    try
        v = round(v, S.round);
    catch
        v = round(v * 10^S.round) / S.round;
    end
end

[~,~,ix] = unique(v, S.uniqArg{:});

if S.reverse
    ix = max(ix) + 1 - ix;
end