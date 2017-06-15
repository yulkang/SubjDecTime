function res = running_fun_const_bin(y, varargin)
% res = running_fun_const_bin(y, varargin)
%
% OPTIONS
% -------
% 'win', 21
% 'step', 1
% 'x', []
% 'fun', @(y,x) {nanmean(x(:)), nansem(x(:)), nanmean(y(:)), nansem(y(:))}
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

S = varargin2S(varargin, {
    'win', 21
    'step', 1
    'x', []
    'fun', @(y,x) {nanmean(x(:)), nansem(x(:)), nanmean(y(:)), nansem(y(:))}
    'xwin_max', 2
    'at_least_one', true
    });

n = size(y,1);
m = size(y,2);

if isempty(S.x), S.x = 1:m; end
% if isempty(S.step), S.step = max(1, round(S.win / 2)); end

n_in_col = sum(~isnan(y),1);
cn = [0, cumsum(n_in_col)];

ii = 0;
c_st = 1;
c_en = find(cn >= cn(c_st) + S.win * n, 1, 'first');
if isempty(c_en) && S.at_least_one
    c_en = m;
end

res = cell(m,1);

x = repmat(S.x, [n, 1]);
x(isnan(y)) = nan;

while ~isempty(c_en)
    cix = c_st:(c_en - 1);
    
    ii = ii + 1;
    res{ii} = S.fun(y(:,cix), x(:,cix));
    
    c_st = find(cn >= cn(c_st) + S.step * n, 1, 'first');
    c_en = find(cn >= cn(c_st) + S.win  * n, 1, 'first');
    
    if c_en - c_st > S.xwin_max * S.win
        break;
    end
end

res = res(1:ii);