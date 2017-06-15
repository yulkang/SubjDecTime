function nll = nll_rt_ch_tr(pred_pmf, rt, ch)
% nll = nll_rt_ch_tr(pred_pmf, rt, ch)
%
% pred_pmf(tr, rt, ch)
% rt(tr)
% ch(tr)

pred_pmf = log(max(pred_pmf, 0) + eps);
n_tr = length(rt);

ix = sub2ind(size(pred_pmf), (1:n_tr)', rt(:), ch(:));

nll = -sum(pred_pmf(ix));