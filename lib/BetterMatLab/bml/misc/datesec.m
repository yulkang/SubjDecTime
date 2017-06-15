function s = datesec(varargin)
% Converts datestr or datenum into the unit of seconds.

s = datenum(varargin{:}) / datenum([0 0 0 0 0 1]);