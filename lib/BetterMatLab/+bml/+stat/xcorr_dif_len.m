function [res, lags, n_considered] = xcorr_dif_len(a, b, varargin)
% Normalize even when length of the two vectors are different.
%
% [res, lags, n_considered] = xcorr_dif_len(a, b, varargin)
%
% OPTIONS
% -------
% 'scaleopt', 'none' % 'none'|'unbiased'|'coeff'
% 'maxlag', [] % maximum lag after shifting a and b.
% 'shift_a', 0
% 'shift_b', 0
% 'pad_absent', nan % 0 or NaN
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'scaleopt', 'none' % 'none'|'unbiased'|'coeff'
    'maxlag', [] % maximum lag after shifting a and b.
    'shift_a', 0
    'shift_b', 0
    'pad_absent', nan % nan % 0 or NaN
    });

is_row = isrow(a);
if ~is_row
    a = a';
    b = b';
end

len_a = length(a);
len_b = length(b);
n_long  = max(len_a, len_b);
n_short = min(len_a, len_b);

shift = S.shift_b - S.shift_a;

if isempty(S.maxlag) 
    S.maxlag = n_long;
end
maxlag0 = S.maxlag;
maxlag = max(abs([
    maxlag0 - shift;
  -(maxlag0 + shift)
    ]));

[res0, lags0] = xcorr(a, b, maxlag);

lags = lags0 - shift;

incl = abs(lags) <= maxlag0;

lags = lags(incl);
res  = res0(incl);

a_incl_st = max(lags + 1     + shift, 1);
a_incl_en = min(lags + len_b + shift, len_a);
n_considered = max(a_incl_en - a_incl_st + 1, 0);

% disp([res; a_incl_st; a_incl_en; n_considered]); % DEBUG

switch S.scaleopt
    case 'none'
        % Do nothing
        
    case 'unbiased'        
        res = res ./ n_considered;
        
    case 'coeff'
        is_inside = (lags >= 0) & (lags <= n_long - n_short);
        
        scale = mean(res(is_inside));
        res = res ./ scale;
end

%% Replace with NaN if requested
if ~isempty(S.pad_absent)
    res(n_considered == 0) = S.pad_absent;
end