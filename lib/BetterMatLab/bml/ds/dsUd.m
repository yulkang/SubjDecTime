function ds = dsUd(ds, field, v)
% Set/get dataset's userdata.
%
% Get mode
% --------
% ud = dsUd(ds)         % get the whole UserData
% v  = dsUd(ds, field)  % get a field
%
% Set mode
% --------
% ds = dsUd(ds, [], v)      % replace the whole UserData
% ds = dsUd(ds, field, v)   % replace a field
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

if nargin == 1 || isempty(field) 
    % get the whole UserData
    ds = ds.Properties.UserData;
elseif nargin == 2 
    % get a field
    ds = ds.Properties.UserData.(field);
elseif isempty(field) 
    % replace the whole UserData
    ds.Properties.UserData = v;
else
    % replace a field
    ds.Properties.UserData.(field) = v;
end