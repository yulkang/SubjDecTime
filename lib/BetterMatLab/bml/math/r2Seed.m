function r = r2Seed(s)
% Scales numerical array appropriately for randomization seeds. (within 1e9).
% 
% r = r2Seed(s)
%
% s is a numerical array.

r = floor(s./max(s(:)).*1e9);