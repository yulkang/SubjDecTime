function [m_sp, se_sp, n_sp] = rate2sp(rate, dur)
% rate2sp  calculates mean and SEM of spike count given rate and duration.
% 
% [m_sp, se_sp, n_sp] = rate2sp(rate, dur)

lambda = bsxfun(@times, rate, dur);
n_sp   = poissrnd(lambda, size(rate));

m_sp   = mean(n_sp, 1);
se_sp  = sem(n_sp, 1);