function [vecT vecV] = vec4runningMean(x, y, posFilt, negFilt)
% VEC4RUNNINGMEAN   Generates vectors to use in RUNNINGMEAN
%
% [vecT vecV] = vec4runningMean(x, y, posFilt, negFilt)
% 
% Use a continous variable for pos or negFilt to weight them.
%
% See also: RUNNINGMEAN

posFilt(isnan(posFilt)) = 0;
negFilt(isnan(negFilt)) = 0;

tfPos = logical(posFilt);
tfNeg = logical(negFilt);

vecT = [hVec(x(tfPos)), hVec(x(tfNeg))];
vecV = [hVec(y(tfPos) .* posFilt(tfPos)), hVec(y(tfNeg) .* -negFilt(tfNeg))];

[vecT, ix] = sort(vecT);
vecV = vecV(ix);

end