function running_fun_binned_data_const_n(fun, v, varargin)
% res = fun(v, [w])
%
% 'step', 25
% 'win', 50

error('Not implemented yet!');

S = varargin2S(varargin, {
    'step', 25
    'win', 50
    'n_in_bin', []
    'allow_less', false
    });

n = size(v, 1);

w = S.n_in_bin;
to_use_w = ~isempty(w);
if ~to_use_w
    w = ones(n, 1);
end
cum_w = cumsum(w);

if S.allow_less
    f_en_ix = @(tr_en) find(cum_w <= tr_en, 1, 'last');
else
    f_en_ix = @(tr_en) find(cum_w >= tr_en, 1, 'first');
end

tr_st = 0;
tr_en = S.win;
st_ix = 1;
en_ix = f_en_ix(tr_en);
i_res = 0;
while ~isempty(en_ix)
    res(i_res) = fun(
end
end