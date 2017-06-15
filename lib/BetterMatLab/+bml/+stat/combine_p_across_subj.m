function p = combine_p_across_subj(ps)
% ps(shuf, test, subj) = p-values from tests. 
% shuf=1 is the original data, shuf>1 are samples under the H0.
%
% p : a scalar probability that the average (across subjects) of 
%     minimum (across tests within each subject) p-values of the original
%     data is larger than that from a null sample.
%
% - Taking the minimum is just a way of summarizing across tests.
% If we are asking if there is *any* significant test across subjects,
% the reasonable representative statistic is the minimum p-value across
% tests within each subject.
%
% - Taking the average assumes that the p-values come from a common beta
% distribution across subjects.
%
% - The last step of computing the p from mean_p is based on 
% Curtis & Sham 2002 & 2003, AJHG.
%
% Yul Kang 2016. hk2699 at columbia dot edu.

min_p = min(ps, [], 2);
mean_p = mean(min_p, 3);
p = mean(mean_p <= mean_p(1));
end