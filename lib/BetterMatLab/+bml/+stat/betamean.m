function m = betamean(ab)
% Mean of the beta distribution

m = ab(:,1) ./ sum(ab, 2);