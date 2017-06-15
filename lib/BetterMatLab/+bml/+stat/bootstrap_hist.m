function hst = bootstrap_hist(hst0, varargin)
% Stratified bootstrap of a histogram within each condition.
%
% hst = bootstrap_hist(hst0, varargin)
%
% hst0(bin, condition)
% hst{boot}(bin, condition)

S = varargin2S(varargin, {
    'n_boot', 1e3
    'seed', []
    });

if ~isempty(S.seed)
    rng(S.seed);
end

cum_hst0 = cumsum(hst0);
n0 = cum_hst0(end,:);

n_cond = size(hst0, 2);
n_bin = size(hst0, 1);

samp0 = cell(1, n_cond);
w0 = cell(1, n_cond);
n_nonzero = zeros(1, n_cond);

for i_cond = 1:n_cond
    samp0{i_cond} = find(hst0(:,i_cond));
    w0{i_cond} = hst0(samp0{i_cond}, i_cond);
    n_nonzero(i_cond) = numel(samp0{i_cond});
end

hst = cell(S.n_boot, 1);
for i_boot = 1:S.n_boot
    for i_cond = n_cond:-1:1
        bin1 = randsample(n_nonzero(i_cond), n0(i_cond), true, w0{i_cond});
        bin1 = samp0{i_cond}(bin1);
        hst1(:,i_cond) = accumarray(bin1, 1, [n_bin, 1], @sum);
    end
    hst{i_boot} = hst1;
end