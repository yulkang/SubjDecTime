function [txt, pval] = pval_txt_from_tf_shuf(tf)
n_true = nnz(tf);
n_all = numel(tf);
pval = n_true / n_all;
if n_true == 1
    txt = sprintf('p <= %1.2g', pval);
else
    txt = sprintf('p = %1.2g', pval);
end