function dst = datenum2sec(src)
% datenum2sec  Converts MATLAB's serial date number to seconds.
%
% dst = datenum2sec(src)

dst = src * (24 * 60 * 60);