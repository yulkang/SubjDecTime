function [d, f, db] = fundir(rel)
% Caller's location
%
% [d, f, db] = fundir

if nargin < 1, rel = ''; end

db = dbstack('-completenames');

try
    f = db(2).file;
    d = fileparts(f);
catch
    f = '';
    d = '';
end

d = fullfile(d, rel);
end