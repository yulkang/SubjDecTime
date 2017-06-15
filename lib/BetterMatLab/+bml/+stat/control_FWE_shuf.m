function [h, p] = control_FWE_shuf(dat, varargin)
% Permutation-based control of FWE that can reject multiple H0s.
%
% dat : (n_shuffle+1, n_test) matrix of the statistic.
% dat(1,:) : statistics from the original data.
% dat(2:end, :) : a sample of the statistics under H0 on each row.
%
% OPTIONS:
% 'alpha', 0.05
% 'use_rank', false
%
% Each column is a test. Tests can be either correlated or not.
% Smaller statistic is defined to be more significant.
% 
% h  : (1, n_test) logical vector of significnace.
% pv : (1, n_test) corrected p-value. Biased but consistent with h.
%
% EXAMPLE:
% [h, p] = bml.stat.control_FWE_rank_of_rank([rand(1,1e2)*0.04; rand(1e4,1e2)]);
% plot(h); hold on; plot(p); hold off;
%
% Partly based on Curtis & Sham 2002 & 2003, AJHG.
%
% Yul Kang 2016. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'alpha', 0.05
    ... use_rank
    ... : If true, use rank of the statistics within each test.
    ...   May have less power because null distributions will nontheless
    %     have small ranks just by chance.
    'use_rank', false
    });
to_get_p = nargout >= 2;

n_test = size(dat, 2);
p = nan(1, n_test);

if S.use_rank
    stat_all = bml.matrix.rankdim(dat, 1);
else
    stat_all = dat;
end
rank_orig = stat_all(1,:);
thres_all = unique(rank_orig);

for i_thres = 1:numel(thres_all)
    thres = thres_all(i_thres);
    
    % What portion of experiments pass the threshold if we were to
    % declare those that contain tests ranks no inferior to thres?
    p_thres = mean(sum(stat_all <= thres, 2) > 0);
    
    if ~to_get_p && p_thres >= S.alpha
        break;
    end
    p(rank_orig == thres) = p_thres;
end
h = p < S.alpha;